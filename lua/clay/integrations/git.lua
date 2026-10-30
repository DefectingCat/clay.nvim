local M = {}

M.plugins = {
  { url = "https://github.com/NeogitOrg/neogit", groups = { "^Neogit" } },
  { url = "https://github.com/esmuellert/codediff.nvim", groups = { "^CodeDiff" } },
}

-- Neogit derives missing groups by re-saturating ErrorMsg and String, which
-- turns Clay's grays into red and orange; define every colored group here.
function M.get(c)
  local groups = {
    NeogitDiffContextHighlight = { bg = c.float },
    NeogitDiffAdd = { fg = c.bright, bg = c.diff_add },
    NeogitDiffAddCursor = { fg = c.bright, bg = c.cursorline },
    NeogitDiffDelete = { fg = c.muted, bg = c.diff_delete },
    NeogitDiffDeleteCursor = { fg = c.muted, bg = c.cursorline },
    NeogitHunkHeader = { fg = c.secondary, bg = c.statusline, bold = true },
    NeogitHunkHeaderHighlight = { fg = c.bright, bg = c.selection, bold = true },
    NeogitDiffHeader = { fg = c.secondary, bg = c.statusline, bold = true },
    NeogitDiffHeaderHighlight = { fg = c.bright, bg = c.selection, bold = true },
    NeogitCommitViewHeader = { fg = c.bright, bg = c.selection, bold = true },
    NeogitFloatHeader = { fg = c.fg, bg = c.float, bold = true },
    NeogitFloatHeaderHighlight = { fg = c.clay, bg = c.float, bold = true },
    NeogitBranch = { fg = c.secondary, bold = true },
    NeogitBranchHead = { fg = c.bright, bold = true, underline = true },
    NeogitRemote = { fg = c.muted, bold = true },
    NeogitTagName = { fg = c.secondary },
    NeogitTagDistance = { fg = c.comment },
  }
  local links = {
    NeogitDiffContext = "Normal", NeogitDiffContextCursor = "CursorLine",
    NeogitDiffAddHighlight = "NeogitDiffAdd", NeogitDiffDeleteHighlight = "NeogitDiffDelete",
    NeogitDiffAddInline = "DiffText", NeogitDiffDeleteInline = "DiffText",
    NeogitDiffAdditions = "Added", NeogitDiffDeletions = "Removed",
    NeogitHunkHeaderCursor = "NeogitHunkHeaderHighlight",
    NeogitHunkMergeHeader = "NeogitHunkHeader", NeogitHunkMergeHeaderHighlight = "NeogitHunkHeaderHighlight",
    NeogitHunkMergeHeaderCursor = "NeogitHunkHeaderHighlight",
    NeogitChangeModified = "Changed", NeogitChangeAdded = "Added", NeogitChangeDeleted = "Removed",
    NeogitChangeRenamed = "Changed", NeogitChangeUpdated = "Changed", NeogitChangeCopied = "Added",
    NeogitChangeUnmerged = "DiagnosticError", NeogitChangeNewFile = "Added",
    NeogitSectionHeader = "Title", NeogitUnmergedInto = "Title", NeogitUnpushedTo = "Title",
    NeogitUnpulledFrom = "Title", NeogitFilePath = "Directory", NeogitActiveItem = "ClaySelection",
    NeogitPopupSwitchKey = "ClayAccent", NeogitPopupOptionKey = "ClayAccent",
    NeogitPopupConfigKey = "ClayAccent", NeogitPopupActionKey = "ClayAccent",
    -- codediff force-sets its line and character groups; configure those via
    -- its highlights option. These remaining groups are only defaults.
    CodeDiffMoveFrom = "Changed", CodeDiffMoveTo = "Changed", CodeDiffFiller = "NonText",
    CodeDiffStatusAdded = "Added", CodeDiffStatusUntracked = "Added", CodeDiffStatusModified = "Changed",
    CodeDiffStatusRenamed = "Changed", CodeDiffStatusDeleted = "Removed", CodeDiffStatusConflict = "DiagnosticError",
  }
  -- Graph and signature colors follow the rainbow-delimiter gray steps.
  for name, fg in pairs({
    White = c.fg, Red = c.bright, Orange = c.bright, Yellow = c.secondary, Green = c.fg,
    Cyan = c.secondary, Blue = c.muted, Purple = c.comment, Gray = c.subtle,
  }) do
    groups["NeogitGraph" .. name] = { fg = fg }
    groups["NeogitGraphBold" .. name] = { fg = fg, bold = true }
  end
  groups.NeogitGraphAuthor = { fg = c.secondary }
  for name, target in pairs(links) do
    groups[name] = { link = target }
  end
  return groups
end

return M
