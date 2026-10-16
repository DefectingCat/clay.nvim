local M = {}

local defaults = {
  accent = "restrained", -- minimal | restrained | expressive
  transparent = false,
  italic_comments = true,
  bold_keywords = true,
  terminal_colors = true,
  palette = {},
  overrides = {},
}

local options = vim.deepcopy(defaults)

local function fail(message)
  error("claude.nvim: " .. message, 3)
end

---Configure the theme. Apply it separately with :colorscheme claude.
---@param opts? table
function M.setup(opts)
  if opts ~= nil and type(opts) ~= "table" then
    fail("setup expects a table")
  end
  local next_options = vim.deepcopy(defaults)
  for key, value in pairs(opts or {}) do
    if defaults[key] == nil then
      fail("unknown option: " .. tostring(key))
    end
    next_options[key] = vim.deepcopy(value)
  end
  if not vim.tbl_contains({ "minimal", "restrained", "expressive" }, next_options.accent) then
    fail("accent must be minimal, restrained, or expressive")
  end
  for _, key in ipairs({ "transparent", "italic_comments", "bold_keywords", "terminal_colors" }) do
    if type(next_options[key]) ~= "boolean" then
      fail(key .. " must be a boolean")
    end
  end
  if type(next_options.palette) ~= "table" then
    fail("palette must be a table")
  end
  local palette = require("claude.palette")
  for key, value in pairs(next_options.palette) do
    if palette[key] == nil then
      fail("unknown palette color: " .. tostring(key))
    end
    if type(value) ~= "string" or not value:match("^#%x%x%x%x%x%x$") then
      fail("palette." .. key .. " must be a #RRGGBB color")
    end
  end
  if type(next_options.overrides) ~= "table" and type(next_options.overrides) ~= "function" then
    fail("overrides must be a table or function")
  end
  options = next_options
end

---Return a copy so integrations cannot mutate theme configuration.
function M.get_options()
  return vim.deepcopy(options)
end

function M.get_palette()
  return vim.tbl_extend("force", vim.deepcopy(require("claude.palette")), options.palette)
end

function M.load()
  local colors = M.get_palette()
  local opts = M.get_options()
  local groups = require("claude.highlights").get(colors, opts)
  local overrides = opts.overrides
  if type(overrides) == "function" then
    overrides = overrides(vim.deepcopy(colors), vim.deepcopy(opts))
  end
  if type(overrides) ~= "table" then
    fail("overrides must return a table of highlight definitions")
  end
  for group, spec in pairs(overrides) do
    if type(group) ~= "string" or type(spec) ~= "table" then
      fail("overrides must map highlight names to tables")
    end
    -- Replace instead of deep-merging: a link must replace existing attributes.
    groups[group] = spec
  end

  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.cmd("highlight clear")
  if vim.g.syntax_on then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "claude"
  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end

  if opts.terminal_colors then
    local terminal = {
      colors.sidebar, colors.fg, colors.bright, colors.clay,
      colors.secondary, colors.fg, colors.secondary, colors.fg,
      colors.comment, colors.fg, colors.bright, colors.clay,
      colors.secondary, colors.fg, colors.secondary, colors.bright,
    }
    for index, color in ipairs(terminal) do
      vim.g["terminal_color_" .. (index - 1)] = color
    end
  end
end

return M
