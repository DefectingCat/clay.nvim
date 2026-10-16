local M = {}

-- Share the same isolated parser/query paths between the preview and its tests.
function M.configure(root)
  local paths = { root }
  local extra = vim.env.CLAUDE_PREVIEW_RUNTIME
  if extra then
    vim.list_extend(paths, vim.split(extra, ":", { trimempty = true }))
  elseif vim.fn.has("nvim-0.12") == 1 then
    -- The current nvim-treesitter installer targets Neovim 0.12+.
    table.insert(paths, root .. "/.preview/site")
  end
  table.insert(paths, vim.env.VIMRUNTIME)
  table.insert(paths, vim.fn.fnamemodify(vim.fn.resolve(vim.v.progpath), ":p:h:h") .. "/lib/nvim")
  vim.opt.runtimepath = paths
  vim.opt.packpath = {}
  vim.opt.loadplugins = false
end

function M.start(buf)
  local ft = vim.bo[buf].filetype
  if ft == "" then
    vim.b[buf].claude_preview_highlighter = "plain"
    return true
  end
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local ok, err = pcall(function()
    local parser = vim.treesitter.get_parser(buf, lang)
    assert(parser, "parser unavailable: " .. lang)
    assert(vim.treesitter.query.get(lang, "highlights"), "highlights query unavailable: " .. lang)
    parser:parse()
    vim.treesitter.start(buf, lang)
  end)
  vim.b[buf].claude_preview_highlighter = ok and "Tree-sitter" or "regex"
  vim.b[buf].claude_preview_error = ok and nil or tostring(err)
  if not ok then
    pcall(vim.treesitter.stop, buf)
    vim.bo[buf].syntax = ft
  end
  return ok, err
end

return M
