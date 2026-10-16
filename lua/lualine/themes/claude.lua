local c = require("claude").get_palette()
local active = {
  a = { fg = c.bg, bg = c.clay, gui = "bold" },
  b = { fg = c.fg, bg = c.selection },
  c = { fg = c.secondary, bg = c.float },
}

return {
  normal = vim.deepcopy(active),
  insert = vim.deepcopy(active),
  visual = vim.deepcopy(active),
  replace = vim.deepcopy(active),
  command = vim.deepcopy(active),
  terminal = vim.deepcopy(active),
  inactive = {
    a = { fg = c.comment, bg = c.sidebar },
    b = { fg = c.comment, bg = c.sidebar },
    c = { fg = c.comment, bg = c.sidebar },
  },
}
