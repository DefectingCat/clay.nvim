local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local bundled_parsers = vim.fn.fnamemodify(vim.fn.resolve(vim.v.progpath), ":p:h:h") .. "/lib/nvim"
vim.opt.runtimepath = { root, vim.env.VIMRUNTIME, bundled_parsers }
vim.opt.packpath = {}
local theme = require("clay")
local colors = theme.get_palette()
local count = 0

local function equal(actual, expected, label)
  assert(vim.deep_equal(actual, expected), (label or "values differ") .. "\nexpected: " .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual))
end

local function color(value)
  return tonumber(value:sub(2), 16)
end

local function hl(name, link)
  return vim.api.nvim_get_hl(0, { name = name, link = link or false })
end

local function load(opts)
  theme.setup(opts)
  vim.cmd.colorscheme("clay")
end

local function test(name, fn)
  fn()
  count = count + 1
  print("PASS " .. name)
end

local function run()
  test("loads without setup and leaves editor behavior unchanged", function()
    local saved = {}
    for _, key in ipairs({ "statusline", "guicursor", "cursorline", "number", "laststatus", "winborder" }) do
      if vim.fn.exists("+" .. key) == 1 then
        saved[key] = vim.o[key]
      end
    end
    local diagnostic = vim.diagnostic.config()
    vim.cmd.colorscheme("clay")
    equal(vim.g.colors_name, "clay")
    equal(vim.o.background, "dark")
    equal(theme.get_options().transparent, true)
    equal(hl("Normal").bg, nil)
    equal(hl("Normal").fg, color(colors.fg))
    for key, value in pairs(saved) do
      equal(vim.o[key], value, key .. " changed")
    end
    equal(vim.diagnostic.config(), diagnostic, "diagnostic configuration changed")
  end)

  test("restrained accents survive semantic token layering", function()
    equal(hl("@function").fg, color(colors.clay))
    equal(hl("@function.method").fg, color(colors.clay))
    equal(hl("@function.call").fg, color(colors.muted))
    equal(hl("@function.method.call").fg, color(colors.muted))
    equal(hl("@lsp.type.function").fg, nil)
    equal(hl("@lsp.type.method").fg, nil)
    equal(hl("@lsp.typemod.function.definition").fg, color(colors.clay))
    equal(hl("@lsp.typemod.method.declaration").fg, color(colors.clay))
  end)

  test("accent modes switch without leaving stale highlights", function()
    load({ accent = "expressive" })
    equal(hl("@function.call").fg, color(colors.clay))
    equal(hl("@lsp.type.function").fg, color(colors.clay))
    load({ accent = "minimal" })
    equal(hl("@function").fg, color(colors.bright))
    equal(hl("@lsp.type.function").fg, nil)
    equal(hl("CursorLineNr").fg, color(colors.clay))
    load()
    equal(hl("@function").fg, color(colors.clay))
    equal(hl("@function.call").fg, color(colors.muted))
  end)

  test("grayscale hierarchy keeps identifiers above structural syntax and retains Clay focus", function()
    local function fg(name)
      return hl(name).fg
    end
    assert(fg("@variable") > fg("@variable.member"))
    assert(fg("@variable.member") > fg("@variable.parameter"))
    assert(fg("@variable") > fg("@keyword"))
    assert(fg("@variable") > fg("@function.call"))
    assert(fg("@keyword") > fg("@punctuation.bracket"))
    assert(fg("@variable") > fg("@string"))
    equal(fg("@type"), fg("@variable.member"))
    equal(fg("@type.definition"), fg("@variable"))
    equal(fg("@lsp.type.parameter"), fg("@variable.parameter"))
    equal(fg("@lsp.type.property"), fg("@variable.member"))
    assert(not hl("@keyword").bold)
    equal(fg("@function"), color(colors.clay))
    equal(fg("CursorLineNr"), color(colors.clay))
    equal(hl("ClayMode").bg, color(colors.clay))
    equal(hl("StatusLine").bg, color(colors.statusline))
  end)

  test("colors stay grayscale apart from the canvas and Clay and every link resolves", function()
    local groups = vim.tbl_extend("force", require("clay.highlights").get(colors, theme.get_options()), require("clay.integrations").get(colors, theme.get_options()))
    for name, spec in pairs(groups) do
      if spec.link then
        assert(groups[spec.link], name .. " has an undefined link: " .. spec.link)
        local seen, current = {}, name
        while groups[current].link do
          assert(not seen[current], "highlight link cycle: " .. name)
          seen[current] = true
          current = groups[current].link
        end
      end
      for _, key in ipairs({ "fg", "bg", "sp" }) do
        local value = hl(name)[key]
        if value and value ~= color(colors.clay) and value ~= color(colors.bg) then
          local r, g, b = math.floor(value / 65536), math.floor(value / 256) % 256, value % 256
          assert(r == g and g == b, name .. " contains a chromatic " .. key)
        end
      end
    end
    for _, name in ipairs({ "CmpItemAbbr", "BlinkCmpLabel", "SnacksPickerFile", "NeoTreeFileName", "OilFile", "NavicText", "NavicIconsFunction", "TroubleText" }) do
      equal(hl(name).bg, nil, name .. " must not paint over a selected row")
    end
  end)

  test("background defaults to transparent and can switch to opaque and back", function()
    load()
    equal(theme.get_palette().bg, "#111315")
    for _, name in ipairs({ "Normal", "NormalNC", "SignColumn", "FoldColumn", "WinBar", "MsgArea", "NeoTreeNormal", "NeoTreeNormalNC", "NvimTreeNormal", "NvimTreeNormalNC", "TroubleNormal", "NoiceSplit", "BufferLineFill", "BufferLineBuffer" }) do
      equal(hl(name).bg, nil, name .. " should be transparent by default")
    end
    equal(hl("NormalFloat").bg, color(colors.float))
    equal(hl("Pmenu").bg, color(colors.float))
    load({ transparent = false })
    equal(hl("Normal").bg, color(colors.bg))
    equal(hl("NeoTreeNormal").bg, color(colors.sidebar))
    equal(hl("NvimTreeNormal").bg, color(colors.sidebar))
    load()
    equal(hl("Normal").bg, nil)
    equal(hl("NeoTreeNormal").bg, nil)
    equal(hl("NvimTreeNormal").bg, nil)
  end)

  test("text styles and custom palette propagate to integrations", function()
    load({ italic_comments = false, bold_keywords = true, palette = { clay = "#c87860" } })
    assert(not hl("Comment").italic)
    equal(hl("Keyword").bold, true)
    equal(hl("@function").fg, color("#c87860"))
    equal(hl("TelescopeMatching").fg, color("#c87860"))
    package.loaded["lualine.themes.clay"] = nil
    equal(require("lualine.themes.clay").normal.a.bg, "#c87860")
    load()
    equal(hl("Comment").italic, true)
    assert(not hl("Keyword").bold)
  end)

  test("overrides replace attributes, accept links, and do not mutate configuration", function()
    load({ overrides = function(c, opts)
      c.clay = "#ffffff"
      opts.accent = "minimal"
      return { Comment = { link = "String" }, ClayTest = { fg = "#abcdef", bold = true } }
    end })
    equal(hl("Comment", true).link, "String")
    equal(hl("Comment").fg, color(colors.muted))
    equal(hl("ClayTest").fg, color("#abcdef"))
    equal(theme.get_palette().clay, colors.clay)
    equal(theme.get_options().accent, "restrained")
    load({ overrides = { Comment = {} } })
    equal(hl("Comment"), {})
    load()
    equal(hl("Comment").fg, color(colors.comment))
    equal(hl("ClayTest"), {})
  end)

  test("invalid setup is rejected without changing active configuration", function()
    local invalid = {
      "dark", { accent = "rainbow" }, { transparent = "yes" }, { typo = true },
      { palette = false }, { palette = { absent = "#ffffff" } }, { palette = { clay = "orange" } },
      { overrides = 1 },
    }
    for _, opts in ipairs(invalid) do
      local ok, err = pcall(theme.setup, opts)
      assert(not ok and tostring(err):find("clay.nvim:", 1, true))
      equal(theme.get_options().accent, "restrained")
      equal(hl("Normal").bg, nil)
    end
    theme.setup({ overrides = function() return nil end })
    assert(not pcall(theme.load))
    equal(hl("Normal").bg, nil)
    load()
  end)

  test("terminal colors are optional and all 16 entries are populated when enabled", function()
    vim.g.terminal_color_3 = "#123456"
    load({ terminal_colors = false })
    equal(vim.g.terminal_color_3, "#123456")
    load()
    for index = 0, 15 do
      assert(vim.g["terminal_color_" .. index]:match("^#%x%x%x%x%x%x$"))
    end
    equal(vim.g.terminal_color_3, colors.clay)
  end)

  test("lualine mode colors remain Clay and nested tables are independent", function()
    package.loaded["lualine.themes.clay"] = nil
    local status = require("lualine.themes.clay")
    for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal" }) do
      equal(status[mode].a.bg, colors.clay)
      equal(status[mode].b.bg, colors.statusline)
      equal(status[mode].c.bg, colors.statusline)
    end
    status.normal.a.bg = "#ffffff"
    equal(status.insert.a.bg, colors.clay)
  end)

  test("colorscheme reload and switching back from another theme", function()
    local events = 0
    local autocmd = vim.api.nvim_create_autocmd("ColorScheme", { pattern = "clay", callback = function() events = events + 1 end })
    vim.cmd.colorscheme("default")
    vim.cmd.colorscheme("clay")
    vim.cmd.colorscheme("clay")
    equal(events, 2)
    equal(hl("Normal").bg, nil)
    equal(hl("@lsp.type.function").fg, nil)
    vim.api.nvim_del_autocmd(autocmd)
  end)

  test("real Lua parser distinguishes a definition from its call", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "local function greet(name)", "  return name", "end", "greet('Clay')",
    })
    vim.bo[buf].filetype = "lua"
    local parser = vim.treesitter.get_parser(buf, "lua")
    parser:parse()
    vim.treesitter.start(buf, "lua")
    local function has_capture(row, column, expected)
      for _, capture in ipairs(vim.treesitter.get_captures_at_pos(buf, row, column)) do
        if capture.capture == expected then
          return true
        end
      end
      return false
    end
    assert(has_capture(0, 16, "function"), "definition capture missing")
    assert(has_capture(3, 1, "function.call"), "call capture missing")
    vim.treesitter.stop(buf)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print(string.format("\n%d tests passed on %s", count, tostring(vim.version())))
