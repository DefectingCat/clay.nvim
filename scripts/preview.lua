-- Isolated demo configuration: nvim -u scripts/preview.lua examples/demo.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local bundled_parsers = vim.fn.fnamemodify(vim.fn.resolve(vim.v.progpath), ":p:h:h") .. "/lib/nvim"
vim.opt.runtimepath = { root, vim.env.VIMRUNTIME, bundled_parsers }
vim.opt.packpath = {}
vim.opt.loadplugins = false
require("claude").setup({ accent = vim.env.CLAUDE_ACCENT or "restrained" })
vim.cmd.colorscheme("claude")
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor"
vim.opt.statusline = "%#ClaudeMode# %{mode()} %#StatusLine# %f %m %= %y  %l:%c "
vim.diagnostic.config({
  virtual_text = { prefix = "·" },
  signs = { text = { [1] = "E", [2] = "W", [3] = "I", [4] = "H" } },
  underline = true,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function(event)
    local ok = pcall(vim.treesitter.start, event.buf, "lua")
    if not ok then
      vim.notify("Lua parser unavailable; preview uses regex syntax", vim.log.levels.WARN)
    end
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.api.nvim_win_set_cursor(0, { 14, 11 })
    vim.diagnostic.set(vim.api.nvim_create_namespace("claude-preview"), 0, {
      { lnum = 27, col = 0, severity = vim.diagnostic.severity.HINT, message = "Demo hint: grayscale diagnostic" },
    })
  end,
})
vim.cmd("filetype on")
vim.cmd("syntax enable")
