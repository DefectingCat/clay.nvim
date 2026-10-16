-- Quiet surfaces. A little clay.
local M = {}

local defaults = {
  background = "dark",
  accent = "#d97757",
  contrast = "soft",
  italics = true,
}

---Build a configuration without changing its defaults.
---@param opts? table
---@return table
function M.setup(opts)
  opts = opts or {}
  local config = vim.tbl_extend("force", defaults, opts)

  -- Function definitions receive Clay; calls stay gray.
  if config.italics then
    vim.notify("Comments are italic")
  end

  return config
end

local config = M.setup({ contrast = "soft" })

-- TODO: inspect selection, search, and completion highlights.
-- Try /config, viw, or :highlight @function
print(config.accent)

return M
