-- Regenerate the plugin table in doc/clay.txt from integration metadata.
-- Run `make docs`; tests/run.lua fails while the table is stale.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local M = {}

M.path = root .. "/doc/clay.txt"

local header = "Plugin                   Repository ~"

function M.render()
  vim.opt.runtimepath:prepend(root)
  local lines = { header }
  for _, plugin in ipairs(require("clay.integrations").list_plugins()) do
    local repository = assert(plugin.url:match("^https://(github%.com/[^/]+/[^/]+)$"), "unexpected URL: " .. plugin.url)
    lines[#lines + 1] = string.format("%-25s%s", plugin.name, repository)
  end
  return lines
end

---Replace the table (header line up to the next blank line) in help text.
---@param lines string[]
---@return string[]
function M.update(lines)
  local first = vim.fn.index(lines, header) + 1
  assert(first > 0, "doc/clay.txt has no line: " .. header)
  local last = first
  while lines[last + 1] and lines[last + 1] ~= "" do
    last = last + 1
  end
  local result = vim.list_slice(lines, 1, first - 1)
  vim.list_extend(result, M.render())
  return vim.list_extend(result, vim.list_slice(lines, last + 1))
end

if arg and arg[0] and arg[0]:match("integration%-docs%.lua$") then
  vim.fn.writefile(M.update(vim.fn.readfile(M.path)), M.path)
end

return M
