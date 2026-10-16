-- Isolated demo configuration: nvim -u scripts/preview.lua examples/demo.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local preview = dofile(root .. "/scripts/preview-runtime.lua")
preview.configure(root)
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
vim.opt.statusline = "%#ClaudeMode# %{mode()} %#StatusLine# %f %m %= %{get(b:, 'claude_preview_highlighter', 'plain')}  %y  %l:%c "
vim.diagnostic.config({
  virtual_text = { prefix = "·" },
  signs = { text = { [1] = "E", [2] = "W", [3] = "I", [4] = "H" } },
  underline = true,
})
vim.api.nvim_create_autocmd("FileType", {
  callback = function(event)
    local ok, err = preview.start(event.buf)
    if not ok then
      vim.notify("Preview uses regex syntax: " .. tostring(err)
        .. "\nRun make preview-parsers for multilingual Clay definitions.", vim.log.levels.WARN)
    end
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    local row = math.min(14, line_count)
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
    vim.api.nvim_win_set_cursor(0, { row, math.min(11, #line) })
    vim.diagnostic.set(vim.api.nvim_create_namespace("claude-preview"), 0, {
      { lnum = math.min(27, line_count - 1), col = 0, severity = vim.diagnostic.severity.HINT, message = "Demo hint: grayscale diagnostic" },
    })
  end,
})
vim.cmd("filetype on")
vim.cmd("syntax enable")
