local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local preview = dofile(root .. "/scripts/preview-runtime.lua")
preview.configure(root)
local theme = require("clay")
vim.cmd.colorscheme("clay")

-- Exercise real parsers and queries. Each fixture has one definition and call.
---@type { [1]: string, [2]: string[], [3]: integer, [4]: integer }[]
local cases = {
  { "lua", { "local function greet(value)", "  return value", "end", "greet('clay')" }, 0, 3 },
  { "c", { "int greet(int value) { return value; }", "int main(void) { return greet(1); }" }, 0, 1 },
  { "cpp", { "struct Greeter { int greet(int value) { return value; } };", "int main() { Greeter g; return g.greet(1); }" }, 0, 1 },
  { "go", { "package main", "func greet(value int) int { return value }", "func main() { greet(1) }" }, 1, 2 },
  { "java", { "class Greeter {", "  int greet(int value) { return value; }", "  int run() { return greet(1); }", "}" }, 1, 2 },
  { "python", { "def greet(value):", "    return value", "greet('clay')" }, 0, 2 },
  { "rust", { "fn greet(value: i32) -> i32 { value }", "fn main() { greet(1); }" }, 0, 1 },
  { "javascript", { "function greet(value) { return value; }", "greet('clay');" }, 0, 1 },
  { "typescript", { "function greet(value: string): string { return value; }", "greet('clay');" }, 0, 1 },
}

local function check_token(buf, lines, row, definition, expected)
  local col = assert(lines[row + 1]:find("greet", 1, true)) - 1
  local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
  local found = false
  local foreground, priority = nil, -1
  for _, item in ipairs(captures) do
    local group = "@" .. item.capture .. "." .. item.lang
    local fg = vim.api.nvim_get_hl(0, { name = group, link = false }).fg
    local metadata = item.metadata or {}
    local rank = tonumber(metadata.priority or (metadata[item.id] or {}).priority) or 100
    if fg and rank >= priority then
      foreground, priority = fg, rank
    end
    local is_function = item.capture:match("^function") ~= nil
    local is_call = item.capture:find("call", 1, true) ~= nil
    if is_function and (definition ~= is_call) then
      found = true
      assert(fg == expected, item.capture .. " has wrong foreground")
    end
  end
  assert(found, "Missing " .. (definition and "definition" or "call") .. " capture: " .. vim.inspect(captures))
  assert(foreground == expected, "Another capture overrode the function color: " .. vim.inspect(captures))
end

local function run()
  local colors = theme.get_palette()
  for _, case in ipairs(cases) do
    local ft, lines, defrow, callrow = case[1], case[2], case[3], case[4]
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = ft
    local ok, err = preview.start(buf)
    assert(ok, ft .. ": " .. tostring(err) .. "\nRun make preview-parsers first")
    assert(vim.b[buf].clay_preview_highlighter == "Tree-sitter")
    assert(vim.b[buf].clay_preview_error == nil)
    for _, accent in ipairs({ "restrained", "minimal", "expressive" }) do
      theme.setup({ accent = accent })
      vim.cmd.colorscheme("clay")
      local definition = accent == "minimal" and colors.bright or colors.clay
      local call = accent == "expressive" and colors.clay or colors.muted
      check_token(buf, lines, defrow, true, tonumber(definition:sub(2), 16))
      check_token(buf, lines, callrow, false, tonumber(call:sub(2), 16))
    end
    vim.treesitter.stop(buf)
    vim.api.nvim_buf_delete(buf, { force = true })
    print("PASS " .. ft .. ": definitions/calls in all 3 accent modes")
  end
  -- A missing parser must be visible to the user, never reported as Tree-sitter.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "clay_missing_parser"
  local ok, err = preview.start(buf)
  assert(not ok and err)
  assert(vim.b[buf].clay_preview_highlighter == "regex")
  assert(vim.b[buf].clay_preview_error:find("clay_missing_parser", 1, true))
  vim.api.nvim_buf_delete(buf, { force = true })
  print("PASS missing parser: explicit regex fallback with the original error")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
