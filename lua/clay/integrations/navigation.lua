local M = {}

M.plugins = {
  { url = "https://github.com/akinsho/bufferline.nvim", groups = { "^BufferLine" } },
  { url = "https://github.com/folke/flash.nvim", groups = { "^Flash" } },
  { url = "https://github.com/stevearc/oil.nvim", groups = { "^Oil" } },
  { url = "https://github.com/SmiteshP/nvim-navic", groups = { "^Navic" } },
  { url = "https://github.com/nvimdev/dashboard-nvim", groups = { "^Dashboard" } },
}

function M.get(c, opts)
  local bg = opts.transparent and "NONE" or c.sidebar
  local groups = {
    -- Keep a foreground even when transparent so plugin defaults do not treat
    -- this as an empty highlight and replace it during late initialization.
    BufferLineFill = { fg = c.comment, bg = bg },
    BufferLineGroupLabel = { fg = c.secondary, bg = c.selection, bold = true },
    BufferLineTabSelected = { fg = c.bright, bg = c.selection, sp = c.clay, underline = true },
  }
  local links = {
    BufferLineBackground = "BufferLineBuffer", BufferLineTab = "BufferLineBuffer",
    BufferLineTabClose = "BufferLineCloseButton", BufferLineTruncMarker = "BufferLineBuffer",
    BufferLineGroupSeparator = "BufferLineSeparator", BufferLineOffsetSeparator = "BufferLineSeparator",
    BufferLineTabSeparator = "BufferLineSeparator", BufferLineTabSeparatorSelected = "BufferLineSeparatorSelected",
    FlashBackdrop = "Comment", FlashMatch = "Search", FlashCurrent = "CurSearch",
    FlashLabel = "ClayMode", FlashPrompt = "MsgArea", FlashPromptIcon = "ClayAccent", FlashCursor = "Cursor",
    OilFile = "Identifier", OilDir = "Directory", OilDirIcon = "Directory", OilSocket = "Special",
    OilLink = "Underlined", OilOrphanLink = "DiagnosticError", OilLinkTarget = "Comment",
    OilOrphanLinkTarget = "DiagnosticError", OilEmpty = "Comment", OilHidden = "Comment",
    OilCreate = "Added", OilCopy = "Added", OilRestore = "Added", OilDelete = "Removed",
    OilPurge = "Removed", OilTrash = "Removed", OilTrashSourcePath = "Comment",
    OilMove = "Changed", OilChange = "Changed",
    NavicText = "Identifier", NavicSeparator = "Comment",
    DashboardHeader = "Title", DashboardFooter = "Comment", DashboardDesc = "Identifier",
    DashboardIcon = "Directory", DashboardKey = "ClayAccent", DashboardShortCut = "ClayAccent",
    DashboardShortCutIcon = "ClayAccent", DashboardShortcut = "ClayAccent", DashboardCenter = "Identifier",
    DashboardProjectTitle = "Title", DashboardProjectTitleIcon = "Directory", DashboardProjectIcon = "Directory",
    DashboardMruTitle = "Title", DashboardMruTitleIcon = "Directory", DashboardMruIcon = "Directory",
    DashboardFiles = "Identifier", DashboardRecentProjectIcon = "Directory",
  }
  for _, state in ipairs({ "", "Visible", "Selected" }) do
    local selected = state == "Selected"
    local surface = selected and c.selection or bg
    local fg = selected and c.bright or (state == "Visible" and c.secondary or c.comment)
    for _, part in ipairs({ "Buffer", "CloseButton", "Numbers", "Duplicate", "Diagnostic", "DevIconDefault" }) do
      groups["BufferLine" .. part .. state] = { fg = fg, bg = surface }
    end
    groups["BufferLineBuffer" .. state].bold = selected
    groups["BufferLineSeparator" .. state] = { fg = c.border, bg = surface }
    groups["BufferLineIndicator" .. state] = { fg = selected and c.clay or c.border, bg = surface }
    groups["BufferLineModified" .. state] = { fg = c.secondary, bg = surface }
    groups["BufferLinePick" .. state] = { fg = c.bg, bg = c.clay, bold = true }
    for severity, shade in pairs({ Error = c.bright, Warning = c.secondary, Info = c.secondary, Hint = c.comment }) do
      groups["BufferLine" .. severity .. state] = { fg = shade, bg = surface }
      groups["BufferLine" .. severity .. "Diagnostic" .. state] = { fg = shade, bg = surface }
    end
  end
  for _, kind in ipairs({ "File", "Dir", "Socket", "Link", "OrphanLink", "LinkTarget", "OrphanLinkTarget" }) do
    links["Oil" .. kind .. "Hidden"] = "Comment"
  end
  for _, kind in ipairs({
    "File", "Module", "Namespace", "Package", "Class", "Method", "Property", "Field", "Constructor", "Enum",
    "Interface", "Function", "Variable", "Constant", "String", "Number", "Boolean", "Array", "Object", "Key",
    "Null", "EnumMember", "Struct", "Event", "Operator", "TypeParameter", "Macro",
  }) do
    -- No background: navic can be embedded in either a winbar or a statusline.
    links["NavicIcons" .. kind] = "Special"
  end
  for name, target in pairs(links) do
    groups[name] = { link = target }
  end
  return groups
end

return M
