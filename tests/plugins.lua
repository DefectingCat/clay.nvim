-- Optional tests against real plugin checkouts; never load a personal init.lua.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath = { root, vim.env.VIMRUNTIME }
vim.opt.packpath = {}
vim.opt.loadplugins = false
local roots = vim.split(vim.env.CLAUDE_PLUGIN_ROOTS or "", ":", { trimempty = true })
assert(#roots > 0, "Set CLAUDE_PLUGIN_ROOTS to colon-separated directories containing plugin checkouts")

local function add(name)
  for _, parent in ipairs(roots) do
    local path = parent .. "/" .. name
    if vim.fn.isdirectory(path) == 1 then
      vim.opt.runtimepath:append(path)
      return true
    end
  end
  return false
end

local theme = require("claude")
vim.cmd.colorscheme("claude")
local function snapshot()
  local colors, opts = theme.get_palette(), theme.get_options()
  local names = vim.tbl_extend("force", require("claude.highlights").get(colors, opts), require("claude.integrations").get(colors, opts))
  local result = {}
  for name in pairs(names) do
    result[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
  end
  return result
end

local function unchanged(expected, label)
  vim.wait(50, function() return false end)
  for name, spec in pairs(expected) do
    local actual = vim.api.nvim_get_hl(0, { name = name, link = false })
    assert(vim.deep_equal(spec, actual), label .. " replaced " .. name .. ": " .. vim.inspect(actual))
  end
end

local checks = {
  { "lazy.nvim", function() require("lazy.view.colors").setup() end },
  { "mason.nvim", function() require("mason.ui.colors") end },
  { "noice.nvim", function() require("noice.config.highlights").setup() end },
  { "nvim-notify", function() require("notify.config.highlights").setup() end },
  { "trouble.nvim", function() require("trouble.config.highlights").setup() end },
  { "bufferline.nvim", function() require("bufferline").setup({ options = { show_buffer_icons = false } }) end },
  { "oil.nvim", function() require("oil").setup({ default_file_explorer = false, columns = {} }) end },
  { "flash.nvim", function() require("flash.highlight").setup() end },
  { "nvim-navic", function() require("nvim-navic").setup({ highlight = true }) end },
  { "dashboard-nvim", function() require("dashboard").setup({ theme = "doom" }) end },
}

local function run()
  local count, skipped = 0, 0
  for _, check in ipairs(checks) do
    local name, setup = unpack(check)
    if add(name) then
      local expected = snapshot()
      setup()
      unchanged(expected, name .. " late initialization")
      count = count + 1
      print("PASS real plugin highlights: " .. name)
    else
      skipped = skipped + 1
      print("SKIP missing checkout: " .. name)
    end
  end
  assert(count > 0, "No supported plugin checkouts found")
  for _, opts in ipairs({ { transparent = false }, { palette = { clay = "#c87860" } }, {} }) do
    theme.setup(opts)
    theme.load() -- Snapshot before ColorScheme hooks from the real plugins run.
    local expected = snapshot()
    vim.cmd.colorscheme("claude")
    unchanged(expected, "ColorScheme reload")
  end
  print(string.format("%d real plugin checks passed, %d skipped; opaque, custom accent, and default reloads passed", count, skipped))
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
