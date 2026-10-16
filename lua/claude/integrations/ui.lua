local M = {}

function M.get(c)
  local groups = {
    LazyButton = { fg = c.secondary, bg = c.selection },
    MasonMutedBlock = { fg = c.comment, bg = c.selection },
    MasonMutedBlockBold = { fg = c.comment, bg = c.selection, bold = true },
    TroubleCount = { fg = c.secondary, bold = true },
  }
  local links = {
    LazyNormal = "NormalFloat", LazyH1 = "ClaudeMode", LazyH2 = "Title",
    LazyButtonActive = "ClaudeMode", LazySpecial = "ClaudeAccent", LazyComment = "Comment",
    LazyCommit = "Identifier", LazyCommitIssue = "Number", LazyCommitType = "Title",
    LazyCommitScope = "Italic", LazyDimmed = "Comment", LazyProp = "Comment", LazyValue = "String",
    LazyNoCond = "DiagnosticWarn", LazyLocal = "Constant", LazyProgressDone = "ClaudeAccent",
    LazyProgressTodo = "Comment", LazyTaskOutput = "Identifier", LazyError = "DiagnosticError",
    LazyWarning = "DiagnosticWarn", LazyInfo = "DiagnosticInfo", LazyDir = "Directory",
    LazyUrl = "Underlined", LazyBold = "Bold", LazyItalic = "Italic",
    MasonNormal = "NormalFloat", MasonBackdrop = "FloatShadow", MasonHeader = "ClaudeMode",
    MasonHeaderSecondary = "LazyButton", MasonHighlight = "ClaudeAccent",
    MasonHighlightBlock = "ClaudeMode", MasonHighlightBlockBold = "ClaudeMode",
    MasonHighlightSecondary = "Special", MasonHighlightBlockSecondary = "LazyButton",
    MasonHighlightBlockBoldSecondary = "ClaudeSelection", MasonLink = "Underlined",
    MasonMuted = "Comment", MasonError = "DiagnosticError", MasonWarning = "DiagnosticWarn",
    MasonHeading = "Title",
    NoiceCmdline = "MsgArea", NoiceCmdlineIcon = "ClaudeAccent", NoiceCmdlineIconSearch = "ClaudeAccent",
    NoiceCmdlinePrompt = "ClaudeAccent", NoiceCmdlinePopup = "NormalFloat",
    NoiceCmdlinePopupBorder = "FloatBorder", NoiceCmdlinePopupBorderSearch = "FloatBorder",
    NoiceCmdlinePopupTitle = "FloatTitle", NoiceConfirm = "NormalFloat", NoiceConfirmBorder = "FloatBorder",
    NoiceCursor = "Cursor", NoiceMini = "MsgArea", NoicePopup = "NormalFloat", NoicePopupBorder = "FloatBorder",
    NoicePopupmenu = "Pmenu", NoicePopupmenuBorder = "FloatBorder", NoicePopupmenuMatch = "ClaudeMatch",
    NoicePopupmenuSelected = "PmenuSel", NoiceScrollbar = "PmenuSbar", NoiceScrollbarThumb = "PmenuThumb",
    NoiceSplit = "Normal", NoiceSplitBorder = "WinSeparator", NoiceVirtualText = "Comment",
    NoiceFormatProgressDone = "ClaudeSelection", NoiceFormatProgressTodo = "CursorLine",
    NoiceFormatEvent = "Comment", NoiceFormatKind = "Comment", NoiceFormatDate = "Special",
    NoiceFormatConfirm = "ClaudeSelection", NoiceFormatConfirmDefault = "ClaudeMode", NoiceFormatTitle = "Title",
    NoiceLspProgressSpinner = "ClaudeAccent", NoiceLspProgressTitle = "Comment", NoiceLspProgressClient = "Title",
    NoiceCompletionItemMenu = "Comment", NoiceCompletionItemWord = "Identifier",
    NoiceCompletionItemKindDefault = "Special",
    NotifyBackground = "NormalFloat", NotifyLogTime = "Comment", NotifyLogTitle = "Title",
    TroubleNormal = "ClaudeSidebar", TroubleNormalNC = "ClaudeSidebar", TroubleText = "Identifier",
    TroublePreview = "Visual", TroubleFilename = "Identifier", TroubleBasename = "Identifier",
    TroubleDirectory = "Directory", TroubleIconDirectory = "Directory", TroubleSource = "Comment",
    TroubleCode = "Special", TroublePos = "Comment", TroubleLocation = "Comment",
    TroubleIndent = "Whitespace", TroubleIndentFoldClosed = "ClaudeAccent", TroubleIndentFoldOpen = "Comment",
  }
  for _, reason in ipairs({ "Runtime", "Plugin", "Event", "Keys", "Start", "Source", "Ft", "Cmd", "Import", "Require" }) do
    links["LazyReason" .. reason] = "Special"
  end
  for _, part in ipairs({ "Top", "Middle", "Last", "Ws" }) do
    links["TroubleIndent" .. part] = "Whitespace"
  end
  for _, kind in ipairs({
    "Array", "Boolean", "Class", "Color", "Constant", "Constructor", "Enum", "EnumMember", "Event", "Field",
    "File", "Folder", "Function", "Interface", "Key", "Keyword", "Method", "Module", "Namespace", "Null",
    "Number", "Object", "Operator", "Package", "Property", "Reference", "Snippet", "String", "Struct", "Text",
    "TypeParameter", "Unit", "Value", "Variable",
  }) do
    links["TroubleIcon" .. kind] = "Special"
    links["NoiceCompletionItemKind" .. kind] = "Special"
  end
  for level, fg in pairs({ ERROR = c.bright, WARN = c.secondary, INFO = c.secondary, DEBUG = c.comment, TRACE = c.comment }) do
    -- nvim-notify uses uppercase levels in its highlight names.
    groups["Notify" .. level .. "Icon"] = { fg = fg }
    groups["Notify" .. level .. "Title"] = { fg = fg, bold = true }
    links["Notify" .. level .. "Border"] = "FloatBorder"
    links["Notify" .. level .. "Body"] = "NormalFloat"
  end
  for level, target in pairs({ Error = "DiagnosticError", Warn = "DiagnosticWarn", Info = "DiagnosticInfo", Debug = "Comment", Trace = "Comment", Off = "Comment" }) do
    links["NoiceFormatLevel" .. level] = target
  end
  for level, target in pairs({ Error = "DiagnosticError", Warning = "DiagnosticWarn", Information = "DiagnosticInfo", Hint = "DiagnosticHint" }) do
    links["Trouble" .. level] = target
    links["TroubleText" .. level] = target
    links["TroubleSign" .. level] = target
  end
  for name, target in pairs(links) do
    groups[name] = { link = target }
  end
  return groups
end

return M
