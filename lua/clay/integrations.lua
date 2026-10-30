local M = {}

local modules = { "ui", "navigation", "editing", "git" }

-- Upstream plugins styled here; patterns match the highlight groups each one owns.
M.plugins = {
  { url = "https://github.com/hrsh7th/nvim-cmp", groups = { "^Cmp" } },
  { url = "https://github.com/saghen/blink.cmp", groups = { "^BlinkCmp" } },
  { url = "https://github.com/nvim-telescope/telescope.nvim", groups = { "^Telescope" } },
  { url = "https://github.com/folke/snacks.nvim", groups = { "^Snacks" } },
  { url = "https://github.com/nvim-neo-tree/neo-tree.nvim", groups = { "^NeoTree" } },
  { url = "https://github.com/nvim-tree/nvim-tree.lua", groups = { "^NvimTree" } },
  { url = "https://github.com/folke/which-key.nvim", groups = { "^WhichKey" } },
  { url = "https://github.com/nvim-mini/mini.nvim", groups = { "^MiniIndentscope", "^MiniStatusline", "^MiniTabline" } },
  { url = "https://github.com/lukas-reineke/indent-blankline.nvim", groups = { "^Ibl" } },
  { url = "https://github.com/lewis6991/gitsigns.nvim", groups = { "^GitSigns" } },
}

---Every styled plugin across integration modules, merged by URL and sorted by name.
---@return { name: string, url: string, groups: string[] }[]
function M.list_plugins()
  local by_url, result = {}, {}
  local sources = { M.plugins }
  for _, module in ipairs(modules) do
    sources[#sources + 1] = require("clay.integrations." .. module).plugins
  end
  for _, plugins in ipairs(sources) do
    for _, plugin in ipairs(plugins) do
      local entry = by_url[plugin.url]
      if not entry then
        entry = { name = plugin.url:match("[^/]+$"), url = plugin.url, groups = {} }
        by_url[plugin.url] = entry
        result[#result + 1] = entry
      end
      vim.list_extend(entry.groups, plugin.groups)
    end
  end
  table.sort(result, function(a, b)
    return a.name:lower() < b.name:lower()
  end)
  return result
end

-- Defining a plugin's highlight groups does not load or configure that plugin.
---@param c clay.Palette
---@param opts clay.Config
---@return clay.Highlights
function M.get(c, opts)
  local groups = {
    -- blend=0 for the same reason as Normal: unset backgrounds cannot blend.
    ClaySidebar = { fg = c.fg, bg = opts.transparent and "NONE" or c.sidebar, blend = opts.transparent and 0 or nil },
    ClaySelection = { fg = c.bright, bg = c.selection },
    ClayMatch = { fg = c.clay, bold = true },
    CmpItemAbbr = { fg = c.secondary },
    CmpItemAbbrDeprecated = { fg = c.comment, strikethrough = true },
    CmpItemMenu = { fg = c.comment },
    BlinkCmpLabel = { fg = c.secondary },
    BlinkCmpLabelDeprecated = { fg = c.comment, strikethrough = true },
    BlinkCmpLabelDescription = { fg = c.comment },
    BlinkCmpLabelDetail = { fg = c.comment },
    BlinkCmpGhostText = { fg = c.comment },
    TelescopeSelection = { fg = c.bright, bg = c.selection },
    TelescopeSelectionCaret = { fg = c.clay, bg = c.selection },
    TelescopeMultiSelection = { fg = c.bright, bold = true },
    SnacksPickerSelected = { fg = c.clay },
    SnacksPickerPickWin = { fg = c.clay, bold = true },
    WhichKey = { fg = c.clay },
    WhichKeyGroup = { fg = c.bright },
    MiniIndentscopeSymbol = { fg = c.gutter },
    IblIndent = { fg = c.border },
    IblScope = { fg = c.gutter },
  }
  local links = {
    TelescopeNormal = "NormalFloat", TelescopeBorder = "FloatBorder", TelescopeTitle = "FloatTitle",
    TelescopePromptNormal = "NormalFloat", TelescopePromptBorder = "FloatBorder",
    TelescopePromptTitle = "FloatTitle", TelescopePromptPrefix = "ClayAccent",
    TelescopePromptCounter = "ClayMuted", TelescopeResultsNormal = "NormalFloat",
    TelescopeResultsBorder = "FloatBorder", TelescopeResultsTitle = "FloatTitle",
    TelescopePreviewNormal = "NormalFloat", TelescopePreviewBorder = "FloatBorder",
    TelescopePreviewTitle = "FloatTitle", TelescopeMatching = "ClayMatch",
    TelescopeResultsComment = "Comment",
    SnacksNormal = "NormalFloat", SnacksNormalNC = "NormalFloat", SnacksBackdrop = "FloatShadow",
    SnacksPickerNormal = "NormalFloat", SnacksPickerBorder = "FloatBorder",
    SnacksPickerTitle = "FloatTitle", SnacksPickerMatch = "ClayMatch",
    SnacksPickerPrompt = "ClayAccent", SnacksPickerListCursorLine = "ClaySelection",
    SnacksPickerDir = "ClayMuted", SnacksPickerFile = "Identifier",
    SnacksPickerDirectory = "Directory", SnacksPickerRow = "ClayMuted", SnacksPickerCol = "ClayMuted",
    SnacksPickerInput = "NormalFloat", SnacksPickerInputBorder = "FloatBorder",
    SnacksPickerInputTitle = "FloatTitle", SnacksPickerList = "NormalFloat",
    SnacksPickerListBorder = "FloatBorder", SnacksPickerListTitle = "FloatTitle",
    SnacksPickerPreview = "NormalFloat", SnacksPickerPreviewBorder = "FloatBorder",
    SnacksPickerPreviewTitle = "FloatTitle", SnacksIndent = "Whitespace", SnacksIndentScope = "IblScope",
    SnacksDashboardHeader = "Title", SnacksDashboardFooter = "Comment", SnacksDashboardKey = "ClayAccent",
    SnacksDashboardDesc = "Normal", SnacksDashboardIcon = "Directory",
    CmpItemAbbrMatch = "ClayMatch", CmpItemAbbrMatchFuzzy = "ClayMatch", CmpGhostText = "Comment",
    BlinkCmpMenu = "Pmenu", BlinkCmpMenuBorder = "FloatBorder", BlinkCmpMenuSelection = "PmenuSel",
    BlinkCmpLabelMatch = "ClayMatch", BlinkCmpKind = "Special",
    BlinkCmpSource = "ClayMuted", BlinkCmpDoc = "NormalFloat", BlinkCmpDocBorder = "FloatBorder",
    BlinkCmpDocSeparator = "WinSeparator", BlinkCmpDocCursorLine = "CursorLine",
    BlinkCmpSignatureHelp = "NormalFloat", BlinkCmpSignatureHelpBorder = "FloatBorder",
    BlinkCmpSignatureHelpActiveParameter = "LspSignatureActiveParameter",
    BlinkCmpScrollBarThumb = "PmenuThumb", BlinkCmpScrollBarGutter = "PmenuSbar",
    NeoTreeNormal = "ClaySidebar", NeoTreeNormalNC = "ClaySidebar",
    NeoTreeEndOfBuffer = "EndOfBuffer", NeoTreeWinSeparator = "WinSeparator",
    NeoTreeDirectoryName = "Directory", NeoTreeDirectoryIcon = "Directory",
    NeoTreeRootName = "Title", NeoTreeFileName = "Identifier", NeoTreeFileIcon = "Directory",
    NeoTreeFileNameOpened = "Title", NeoTreeIndentMarker = "Whitespace",
    NeoTreeExpander = "ClayMuted", NeoTreeCursorLine = "CursorLine",
    NeoTreeFloatBorder = "FloatBorder", NeoTreeFloatTitle = "FloatTitle",
    NeoTreeGitAdded = "Added", NeoTreeGitModified = "Changed", NeoTreeGitDeleted = "Removed",
    NeoTreeGitConflict = "DiagnosticError", NeoTreeGitUntracked = "Added", NeoTreeGitIgnored = "Comment",
    NeoTreeSymbolicLinkTarget = "Comment", NeoTreeModified = "ClayAccent",
    NvimTreeNormal = "ClaySidebar", NvimTreeNormalNC = "ClaySidebar", NvimTreeNormalFloat = "NormalFloat",
    NvimTreeWinSeparator = "WinSeparator", NvimTreeEndOfBuffer = "EndOfBuffer",
    NvimTreeFolderName = "Directory", NvimTreeFolderIcon = "Directory", NvimTreeRootFolder = "Title",
    NvimTreeOpenedFolderName = "Title", NvimTreeEmptyFolderName = "Comment",
    NvimTreeIndentMarker = "Whitespace", NvimTreeCursorLine = "CursorLine",
    NvimTreeGitDirty = "Changed", NvimTreeGitNew = "Added", NvimTreeGitDeleted = "Removed",
    NvimTreeGitStaged = "Added", NvimTreeGitMerge = "DiagnosticError", NvimTreeGitIgnored = "Comment",
    NvimTreeSymlink = "Underlined", NvimTreeSpecialFile = "Title", NvimTreeImageFile = "Identifier",
    WhichKeyDesc = "Identifier", WhichKeySeparator = "Comment", WhichKeyValue = "String",
    WhichKeyBorder = "FloatBorder", WhichKeyNormal = "NormalFloat", WhichKeyFloat = "NormalFloat",
    MiniStatuslineModeNormal = "ClayMode", MiniStatuslineModeInsert = "ClayMode",
    MiniStatuslineModeVisual = "ClayMode", MiniStatuslineModeReplace = "ClayMode",
    MiniStatuslineModeCommand = "ClayMode", MiniStatuslineModeOther = "ClayMode",
    MiniStatuslineDevinfo = "StatusLine", MiniStatuslineFilename = "StatusLine",
    MiniStatuslineFileinfo = "StatusLine", MiniStatuslineInactive = "StatusLineNC",
    MiniTablineCurrent = "TabLineSel", MiniTablineVisible = "TabLine", MiniTablineHidden = "TabLine",
    MiniTablineModifiedCurrent = "TabLineSel", MiniTablineModifiedVisible = "TabLine",
    MiniTablineModifiedHidden = "TabLine", MiniTablineFill = "TabLineFill", MiniTablineTabpagesection = "ClayMode",
    GitSignsCurrentLineBlame = "Comment", GitSignsAddPreview = "DiffAdd", GitSignsDeletePreview = "DiffDelete",
    GitSignsAddInline = "DiffText", GitSignsChangeInline = "DiffText", GitSignsDeleteInline = "DiffText",
    GitSignsAddLnInline = "DiffText", GitSignsChangeLnInline = "DiffText", GitSignsDeleteLnInline = "DiffText",
    GitSignsDeleteVirtLn = "DiffDelete", GitSignsDeleteVirtLnInLine = "DiffText",
    GitSignsVirtLnum = "LineNr", GitSignsDiffStaged = "Comment",
  }
  for _, kind in ipairs({
    "Text", "Method", "Function", "Constructor", "Field", "Variable", "Class", "Interface", "Module",
    "Property", "Unit", "Value", "Enum", "Keyword", "Snippet", "Color", "File", "Reference", "Folder",
    "EnumMember", "Constant", "Struct", "Event", "Operator", "TypeParameter",
  }) do
    links["CmpItemKind" .. kind] = "Special"
    links["BlinkCmpKind" .. kind] = "Special"
  end
  links.CmpItemKind = "Special"
  for kind, target in pairs({ Add = "Added", Change = "Changed", Delete = "Removed", Changedelete = "Changed", Topdelete = "Removed", Untracked = "Added" }) do
    for _, staged in ipairs({ "", "Staged" }) do
      local name = "GitSigns" .. staged .. kind
      for _, suffix in ipairs({ "", "Nr", "Cul" }) do
        links[name .. suffix] = target
      end
      if kind == "Add" or kind == "Untracked" then
        links[name .. "Ln"] = "DiffAdd"
      elseif kind == "Delete" or kind == "Topdelete" then
        links[name .. "Ln"] = "DiffDelete"
      else
        links[name .. "Ln"] = "DiffChange"
      end
    end
  end
  for group, target in pairs(links) do
    groups[group] = { link = target }
  end
  for _, module in ipairs(modules) do
    groups = vim.tbl_extend("force", groups, require("clay.integrations." .. module).get(c, opts))
  end
  return groups
end

return M
