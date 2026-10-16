local M = {}

function M.get(c)
  local groups = {
    Headline = { fg = c.bright, bg = c.cursorline, bold = true },
    CodeBlock = { bg = c.cursorline },
    MiniJump2dSpot = { fg = c.bg, bg = c.clay, bold = true, nocombine = true },
    MiniJump2dSpotAhead = { fg = c.secondary, bg = c.selection, nocombine = true },
    MiniTrailspace = { fg = c.bright, bg = c.selection },
    MiniCursorword = { bg = c.cursorline, underline = true },
    MiniCursorwordCurrent = { underline = true },
    ScrollbarHandle = { bg = c.selection, blend = 30 },
    LightBulbFloatWin = { fg = c.clay, bg = c.float },
    IndentLine = { fg = c.border },
    IndentLineCurrent = { fg = c.gutter },
  }
  local links = {
    Dash = "Comment", DoubleDash = "Comment", Quote = "Comment",
    YankyPut = "Visual", YankyYanked = "Visual",
    LightBulbSign = "ClaudeAccent", LightBulbVirtualText = "ClaudeAccent",
    LightBulbNumber = "ClaudeAccent", LightBulbLine = "CursorLine",
    MiniJump = "CurSearch", MiniJump2dSpotUnique = "MiniJump2dSpot", MiniJump2dDim = "Comment",
    MiniSurround = "CurSearch", MiniStarterCurrent = "ClaudeSelection", MiniStarterFooter = "Comment",
    MiniStarterHeader = "Title", MiniStarterInactive = "Comment", MiniStarterItem = "Identifier",
    MiniStarterItemBullet = "Delimiter", MiniStarterItemPrefix = "ClaudeAccent",
    MiniStarterSection = "Title", MiniStarterQuery = "ClaudeAccent",
    MiniDiffSignAdd = "Added", MiniDiffSignChange = "Changed", MiniDiffSignDelete = "Removed",
    MiniDiffOverAdd = "DiffAdd", MiniDiffOverChange = "DiffText", MiniDiffOverChangeBuf = "DiffText",
    MiniDiffOverContext = "DiffChange", MiniDiffOverDelete = "DiffDelete",
    GitGutterAdd = "Added", GitGutterChange = "Changed", GitGutterDelete = "Removed",
    GitGutterChangeDelete = "Changed", GitGutterAddLineNr = "Added", GitGutterChangeLineNr = "Changed",
    GitGutterDeleteLineNr = "Removed", GitGutterChangeDeleteLineNr = "Changed",
    GitGutterAddLine = "DiffAdd", GitGutterChangeLine = "DiffChange", GitGutterDeleteLine = "DiffDelete",
    GitGutterChangeDeleteLine = "DiffChange", GitGutterAddIntraLine = "DiffText", GitGutterDeleteIntraLine = "DiffText",
  }
  -- Keep TODO categories and diagnostics neutral; reserve Clay for interaction.
  for keyword, fg in pairs({ FIX = c.bright, TODO = c.secondary, HACK = c.secondary, WARN = c.secondary, PERF = c.muted, NOTE = c.comment, TEST = c.muted }) do
    groups["TodoBg" .. keyword] = { fg = fg, bg = c.selection, bold = true }
    groups["TodoFg" .. keyword] = { fg = fg }
    groups["TodoSign" .. keyword] = { fg = fg }
  end
  for name, fg in pairs({ Red = c.subtle, Yellow = c.secondary, Blue = c.muted, Orange = c.bright, Green = c.fg, Violet = c.comment, Cyan = c.secondary }) do
    groups["RainbowDelimiter" .. name] = { fg = fg }
  end
  for mark, fg in pairs({ Cursor = c.clay, Search = c.clay, Error = c.bright, Warn = c.secondary, Info = c.secondary, Hint = c.comment, Misc = c.muted, GitAdd = c.bright, GitChange = c.fg, GitDelete = c.secondary }) do
    groups["Scrollbar" .. mark] = { fg = fg }
    groups["Scrollbar" .. mark .. "Handle"] = { fg = fg, bg = c.selection, blend = 30 }
  end
  for level = 1, 6 do
    links["@text.title." .. level .. ".marker.markdown"] = "Title"
  end
  for name, target in pairs(links) do
    groups[name] = { link = target }
  end
  return groups
end

return M
