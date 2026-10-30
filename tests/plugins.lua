-- Optional tests against real plugin checkouts; never load a personal init.lua.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath = { root, vim.env.VIMRUNTIME }
vim.opt.packpath = {}
vim.opt.loadplugins = false
local roots = vim.split(vim.env.CLAY_PLUGIN_ROOTS or "", ":", { trimempty = true })
assert(#roots > 0, "Set CLAY_PLUGIN_ROOTS to colon-separated directories containing plugin checkouts")

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

local theme = require("clay")
vim.cmd.colorscheme("clay")
local function snapshot()
  local colors, opts = theme.get_palette(), theme.get_options()
  local names = vim.tbl_extend("force", require("clay.highlights").get(colors, opts), require("clay.integrations").get(colors, opts))
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
  -- Also inspect groups created by the plugins, not only names defined by us:
  -- a stale/incorrect group name can otherwise leave an upstream rainbow intact.
  local palette = theme.get_palette()
  local clay, string_tint = tonumber(palette.clay:sub(2), 16), tonumber(palette.string:sub(2), 16)
  local prefixes = {
    "Lazy", "Mason", "Noice", "Notify", "Trouble", "BufferLine", "Oil", "Flash", "Navic", "Dashboard",
    "Todo", "RainbowDelimiter", "Headline", "Dash", "DoubleDash", "CodeBlock", "Quote", "Yanky",
    "Scrollbar", "LightBulb", "GitGutter", "IndentLine", "MiniJump", "MiniStarter", "MiniSurround",
    "MiniTrailspace", "MiniCursorword", "MiniDiff", "Neogit",
  }
  for name in pairs(vim.api.nvim_get_hl(0, {})) do
    for _, prefix in ipairs(prefixes) do
      if name:sub(1, #prefix) == prefix then
        local spec = vim.api.nvim_get_hl(0, { name = name, link = false })
        for _, key in ipairs({ "fg", "bg", "sp" }) do
          local value = spec[key]
          if value and value ~= clay and value ~= string_tint then
            local r, g, b = math.floor(value / 65536), math.floor(value / 256) % 256, value % 256
            assert(r == g and g == b, label .. " introduced a chromatic " .. name .. "." .. key)
          end
        end
        break
      end
    end
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
  { "todo-comments.nvim", function() require("todo-comments").setup({}) end },
  { "rainbow-delimiters.nvim", function() vim.cmd.runtime("plugin/rainbow-delimiters.lua") end },
  { "headlines.nvim", function() require("headlines").setup({}) end },
  { "yanky.nvim", function()
    require("yanky.config").setup({})
    require("yanky.highlight").setup()
  end },
  { "nvim-scrollbar", function() require("scrollbar").setup({ set_highlights = false }) end },
  { "nvim-lightbulb", function() require("nvim-lightbulb").setup({}) end, min_version = "0.11.0" },
  { "vim-gitgutter", function() vim.cmd.runtime("plugin/gitgutter.vim") end },
  { "indentmini.nvim", function() require("indentmini").setup({}) end },
  { "mini.nvim", function()
    for _, module in ipairs({ "jump", "jump2d", "surround", "trailspace", "cursorword" }) do
      require("mini." .. module).setup({})
    end
    require("mini.starter").setup({ autoopen = false })
    require("mini.diff").setup({ source = require("mini.diff").gen_source.none() })
  end },
  { "neogit", function()
    assert(add("plenary.nvim"), "neogit requires a plenary.nvim checkout")
    require("neogit").setup({})
  end },
}

local function run()
  local count, skipped = 0, 0
  for _, check in ipairs(checks) do
    local name, setup = unpack(check)
    if check.min_version and vim.fn.has("nvim-" .. check.min_version) == 0 then
      skipped = skipped + 1
      print("SKIP " .. name .. ": upstream requires Neovim " .. check.min_version .. "+")
    elseif add(name) then
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
  for _, case in ipairs({
    { opts = { transparent = false } }, { opts = { palette = { clay = "#c87860" } } },
    { opts = {}, background = "light" }, { opts = {} },
  }) do
    vim.o.background = case.background or "dark"
    theme.setup(case.opts)
    theme.load() -- Snapshot before ColorScheme hooks from the real plugins run.
    local expected = snapshot()
    vim.cmd.colorscheme("clay")
    unchanged(expected, "ColorScheme reload")
  end
  print(string.format("%d real plugin checks passed, %d skipped; opaque, custom accent, light, and default reloads passed", count, skipped))
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
