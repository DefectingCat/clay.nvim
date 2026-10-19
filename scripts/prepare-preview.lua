-- Install only into this checkout; never change the user's Neovim setup.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local function run()
  assert(vim.fn.has("nvim-0.12") == 1, "preview-parsers requires Neovim 0.12+ (the theme itself supports 0.10.4+)")
  for _, tool in ipairs({ "tree-sitter", "cc", "curl", "tar" }) do
    assert(vim.fn.executable(tool) == 1, "preview-parsers requires " .. tool)
  end
  local treesitter = vim.env.CLAY_TREESITTER_DIR or (vim.fn.stdpath("data") .. "/lazy/nvim-treesitter")
  assert(vim.fn.filereadable(treesitter .. "/lua/nvim-treesitter/install.lua") == 1,
    "Set CLAY_TREESITTER_DIR to a current nvim-treesitter checkout")
  vim.opt.runtimepath = { treesitter, vim.env.VIMRUNTIME }
  vim.opt.packpath = {}
  vim.opt.loadplugins = false
  local installer = require("nvim-treesitter")
  local install_dir = root .. "/.preview/site"
  -- Neovim caches existing runtime directories; create this before setup adds it.
  vim.fn.mkdir(install_dir, "p")
  installer.setup({ install_dir = install_dir })
  local languages = { "lua", "c", "cpp", "go", "java", "python", "rust", "javascript", "typescript" }
  local success = installer.install(languages, { max_jobs = 3, summary = true }):wait(300000)
  assert(success, "Some preview parsers failed to install; see the errors above and rerun make preview-parsers")
  for _, lang in ipairs(languages) do
    assert(vim.fn.filereadable(root .. "/.preview/site/parser/" .. lang .. ".so") == 1, "Missing parser: " .. lang)
    assert(vim.treesitter.query.get(lang, "highlights"), "Missing highlights query: " .. lang)
  end
  print("Preview parsers ready in " .. root .. "/.preview/site")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
