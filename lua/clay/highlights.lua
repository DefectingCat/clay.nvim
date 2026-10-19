local M = {}

---@param c clay.Palette
---@param opts clay.Config
---@return clay.Highlights
function M.get(c, opts)
  local bg = opts.transparent and "NONE" or c.bg
  -- An unset background cannot blend: a float with 'winblend' (noice's mini
  -- view uses 30) would show the text beneath. blend=0 keeps it legible.
  local blend = opts.transparent and 0 or nil
  local definition = opts.accent == "minimal" and c.bright or c.clay
  local call = opts.accent == "expressive" and c.clay or c.muted
  local groups = {
    Normal = { fg = c.fg, bg = bg, blend = blend },
    NormalNC = { fg = c.fg, bg = bg, blend = blend },
    NormalFloat = { fg = c.fg, bg = c.float },
    FloatBorder = { fg = c.float_border, bg = c.float },
    FloatTitle = { fg = c.clay, bg = c.float },
    FloatFooter = { fg = c.comment, bg = c.float },
    FloatShadow = { bg = c.sidebar, blend = 80 },
    FloatShadowThrough = { bg = c.sidebar, blend = 100 },
    Cursor = { fg = c.bg, bg = c.clay },
    CursorLine = { bg = c.cursorline },
    CursorLineNr = { fg = c.clay, bold = true },
    LineNr = { fg = c.gutter },
    SignColumn = { fg = c.secondary, bg = bg },
    FoldColumn = { fg = c.gutter, bg = bg },
    Folded = { fg = c.secondary, bg = c.cursorline },
    NonText = { fg = c.gutter },
    Whitespace = { fg = c.border },
    EndOfBuffer = { fg = opts.transparent and c.border or c.bg },
    Conceal = { fg = c.comment },
    WinSeparator = { fg = c.border },
    ColorColumn = { bg = c.cursorline },
    MatchParen = { fg = c.bright, bg = c.selection, bold = true },
    Visual = { fg = c.bright, bg = c.selection },
    Search = { fg = c.bright, bg = c.selection, underline = true },
    CurSearch = { fg = c.bg, bg = c.clay, bold = true },
    Substitute = { fg = c.bg, bg = c.clay },
    Pmenu = { fg = c.secondary, bg = c.float },
    PmenuSel = { fg = c.bright, bg = c.selection },
    PmenuKind = { fg = c.comment, bg = c.float },
    PmenuKindSel = { fg = c.secondary, bg = c.selection },
    PmenuExtra = { fg = c.comment, bg = c.float },
    PmenuExtraSel = { fg = c.secondary, bg = c.selection },
    PmenuSbar = { bg = c.cursorline },
    PmenuThumb = { bg = c.gutter },
    PmenuMatch = { fg = c.clay, bold = true },
    PmenuMatchSel = { fg = c.bright, sp = c.clay, underline = true, bold = true },
    ComplMatchIns = { fg = c.bright },
    PreInsert = { fg = c.comment },
    ComplHint = { fg = c.comment },
    ComplHintMore = { fg = c.comment },
    SnippetTabstop = { bg = c.cursorline },
    SnippetTabstopActive = { bg = c.selection },
    StatusLine = { fg = c.secondary, bg = c.statusline },
    StatusLineNC = { fg = c.comment, bg = c.sidebar },
    TabLine = { fg = c.comment, bg = c.sidebar },
    TabLineFill = { bg = c.sidebar },
    TabLineSel = { fg = c.bright, bg = c.bg, sp = c.clay, underline = true },
    WinBar = { fg = c.secondary, bg = bg },
    WinBarNC = { fg = c.comment, bg = bg },
    Title = { fg = c.bright, bold = true },
    Directory = { fg = c.secondary },
    ModeMsg = { fg = c.clay, bold = true },
    MoreMsg = { fg = c.clay },
    Question = { fg = c.clay },
    MsgArea = { fg = c.fg, bg = bg, blend = blend },
    MsgSeparator = { fg = c.border, bg = c.sidebar },
    ErrorMsg = { fg = c.bright, bold = true },
    WarningMsg = { fg = c.secondary, bold = true },
    OkMsg = { fg = c.fg },
    QuickFixLine = { fg = c.bright, bg = c.selection },
    DiffAdd = { bg = c.diff_add },
    DiffChange = { bg = c.cursorline },
    DiffDelete = { fg = c.secondary, bg = c.diff_delete },
    DiffText = { fg = c.bright, bg = c.selection, bold = true },
    Added = { fg = c.bright },
    Removed = { fg = c.secondary },
    Changed = { fg = c.fg },
    SpellBad = { sp = c.bright, undercurl = true },
    SpellCap = { sp = c.secondary, undercurl = true },
    SpellLocal = { sp = c.comment, underline = true },
    SpellRare = { sp = c.comment, underdotted = true },

    Comment = { fg = c.comment, italic = opts.italic_comments },
    Constant = { fg = c.secondary },
    String = { fg = c.muted },
    Identifier = { fg = c.fg },
    -- Regex syntax often uses Function for calls as well as declarations.
    Function = { fg = call },
    Statement = { fg = c.muted, bold = opts.bold_keywords },
    PreProc = { fg = c.muted },
    Type = { fg = c.secondary },
    Special = { fg = c.secondary },
    Delimiter = { fg = c.subtle },
    Operator = { fg = c.subtle },
    Underlined = { fg = c.fg, underline = true },
    Ignore = { fg = c.comment },
    Error = { fg = c.bright, sp = c.bright, undercurl = true },
    Todo = { fg = c.bright, bold = true },
    Bold = { bold = true },
    Italic = { italic = true },

    ["@function"] = { fg = definition },
    ["@function.call"] = { fg = call },
    ["@function.builtin"] = { fg = opts.accent == "expressive" and c.clay or c.subtle },
    ["@constructor"] = { fg = call },
    ["@variable.builtin"] = { fg = c.muted },
    ["@variable.parameter"] = { fg = c.muted },
    ["@variable.member"] = { fg = c.secondary },
    ["@constant.builtin"] = { fg = c.muted },
    ["@type.definition"] = { fg = c.fg },
    ["@module.builtin"] = { fg = c.subtle },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.link.url"] = { fg = c.secondary, underline = true },
    ["@markup.list.checked"] = { fg = c.comment },
    ["@markup.list.unchecked"] = { fg = c.secondary },

    -- Semantic tokens have higher priority than Tree-sitter. An unqualified
    -- function token cannot distinguish a definition from a call; leave its
    -- foreground unset, then use declaration/definition modifiers if supplied.
    ["@lsp.type.function"] = opts.accent == "expressive" and { fg = c.clay } or {},
    ["@lsp.type.method"] = opts.accent == "expressive" and { fg = c.clay } or {},
    ["@lsp.type.variable"] = {},
    ["@lsp.mod.declaration"] = {},
    ["@lsp.mod.definition"] = {},
    ["@lsp.mod.defaultLibrary"] = {},
    ["@lsp.mod.readonly"] = {},
    ["@lsp.mod.deprecated"] = { strikethrough = true },
    ["@lsp.typemod.function.declaration"] = { fg = definition },
    ["@lsp.typemod.function.definition"] = { fg = definition },
    ["@lsp.typemod.method.declaration"] = { fg = definition },
    ["@lsp.typemod.method.definition"] = { fg = definition },
    LspReferenceText = { bg = c.cursorline },
    LspReferenceRead = { bg = c.cursorline },
    LspReferenceWrite = { bg = c.cursorline, underline = true },
    LspReferenceTarget = { bg = c.selection },
    LspInlayHint = { fg = c.comment },
    LspCodeLens = { fg = c.comment },
    LspCodeLensSeparator = { fg = c.gutter },
    LspSignatureActiveParameter = { fg = c.bright, bold = true, underline = true },

    ClayAccent = { fg = c.clay },
    ClayMode = { fg = c.bg, bg = c.clay, bold = true },
    ClayMuted = { fg = c.comment },
  }

  local links = {
    lCursor = "Cursor", CursorIM = "Cursor", TermCursor = "Cursor", TermCursorNC = "Cursor",
    CursorColumn = "CursorLine", CursorLineFold = "FoldColumn", CursorLineSign = "SignColumn",
    LineNrAbove = "LineNr", LineNrBelow = "LineNr", SpecialKey = "NonText", VertSplit = "WinSeparator",
    VisualNOS = "Visual", IncSearch = "CurSearch", WildMenu = "PmenuSel", PmenuBorder = "FloatBorder",
    PmenuShadow = "FloatShadow", PmenuShadowThrough = "FloatShadowThrough",
    StatusLineTerm = "StatusLine", StatusLineTermNC = "StatusLineNC", DiffTextAdd = "DiffText",
    StderrMsg = "ErrorMsg", StdoutMsg = "MsgArea", Character = "String", Number = "Constant",
    Boolean = "Constant", Float = "Constant", Conditional = "Statement", Repeat = "Statement",
    Label = "Statement", Keyword = "Statement", Exception = "Statement", Include = "PreProc",
    Define = "PreProc", Macro = "PreProc", PreCondit = "PreProc", StorageClass = "Statement",
    Structure = "Type", Typedef = "Type", Tag = "Type", SpecialChar = "Special",
    SpecialComment = "Comment", Debug = "Special",
    diffAdded = "Added", diffRemoved = "Removed", diffChanged = "Changed",
    diffFile = "Title", diffNewFile = "Title", diffOldFile = "Comment", diffLine = "Comment",
    diffIndexLine = "Comment", diffSubname = "Title",

    ["@variable"] = "Identifier", ["@variable.parameter.builtin"] = "@variable.builtin",
    ["@constant"] = "Constant", ["@constant.macro"] = "Constant",
    ["@module"] = "Identifier", ["@label"] = "Label",
    ["@string"] = "String", ["@string.documentation"] = "Comment", ["@string.regexp"] = "String",
    ["@string.escape"] = "Special", ["@string.special"] = "Special",
    ["@string.special.symbol"] = "String", ["@string.special.url"] = "Underlined",
    ["@character"] = "Character", ["@character.special"] = "Special",
    ["@boolean"] = "Boolean", ["@number"] = "Number", ["@number.float"] = "Float",
    ["@type"] = "Type", ["@type.builtin"] = "Type",
    ["@attribute"] = "PreProc", ["@attribute.builtin"] = "PreProc", ["@property"] = "@variable.member",
    ["@function.method"] = "@function", ["@function.method.call"] = "@function.call",
    ["@function.macro"] = "Macro", ["@operator"] = "Operator",
    ["@punctuation.delimiter"] = "Delimiter", ["@punctuation.bracket"] = "Delimiter",
    ["@punctuation.special"] = "Special", ["@comment"] = "Comment",
    ["@comment.documentation"] = "Comment", ["@comment.error"] = "Todo",
    ["@comment.warning"] = "Todo", ["@comment.todo"] = "Todo", ["@comment.note"] = "Comment",
    ["@markup.heading"] = "Title", ["@markup.quote"] = "Comment", ["@markup.math"] = "String",
    ["@markup.link"] = "Underlined", ["@markup.link.label"] = "Underlined",
    ["@markup.raw"] = "String", ["@markup.raw.block"] = "String", ["@markup.list"] = "Delimiter",
    ["@diff.plus"] = "Added", ["@diff.minus"] = "Removed", ["@diff.delta"] = "Changed",
    ["@tag"] = "Tag", ["@tag.builtin"] = "Tag", ["@tag.attribute"] = "Identifier",
    ["@tag.delimiter"] = "Delimiter", ["@conceal"] = "Conceal",
    ["@lsp.type.class"] = "@type", ["@lsp.type.comment"] = "@comment",
    ["@lsp.type.decorator"] = "@attribute", ["@lsp.type.enum"] = "@type",
    ["@lsp.type.enumMember"] = "@constant", ["@lsp.type.event"] = "@type",
    ["@lsp.type.interface"] = "@type", ["@lsp.type.keyword"] = "@keyword",
    ["@lsp.type.macro"] = "@function.macro", ["@lsp.type.modifier"] = "@keyword",
    ["@lsp.type.namespace"] = "@module", ["@lsp.type.number"] = "@number",
    ["@lsp.type.operator"] = "@operator", ["@lsp.type.parameter"] = "@variable.parameter",
    ["@lsp.type.property"] = "@property", ["@lsp.type.regexp"] = "@string.regexp",
    ["@lsp.type.string"] = "@string", ["@lsp.type.struct"] = "@type",
    ["@lsp.type.type"] = "@type", ["@lsp.type.typeParameter"] = "@type",
  }
  for _, keyword in ipairs({
    "", ".coroutine", ".function", ".operator", ".import", ".type", ".modifier", ".repeat",
    ".return", ".debug", ".exception", ".conditional", ".conditional.ternary", ".directive", ".directive.define",
  }) do
    links["@keyword" .. keyword] = "Statement"
  end
  for level = 1, 6 do
    links["@markup.heading." .. level] = "Title"
  end
  for severity, color in pairs({ Error = c.bright, Warn = c.secondary, Info = c.secondary, Hint = c.comment, Ok = c.fg }) do
    local base = "Diagnostic" .. severity
    groups[base] = { fg = color }
    groups["DiagnosticUnderline" .. severity] = { sp = color, undercurl = true }
    groups["DiagnosticVirtualText" .. severity] = { fg = c.comment }
    links["DiagnosticVirtualLines" .. severity] = "DiagnosticVirtualText" .. severity
    links["DiagnosticSign" .. severity] = base
    links["DiagnosticFloating" .. severity] = base
  end
  groups.DiagnosticDeprecated = { strikethrough = true }
  groups.DiagnosticUnnecessary = { fg = c.comment }
  for group, target in pairs(links) do
    groups[group] = { link = target }
  end
  return groups
end

return M
