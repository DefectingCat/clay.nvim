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

local function luminance(value)
  local total = 0
  for index, weight in ipairs({ 0.2126, 0.7152, 0.0722 }) do
    local channel = math.floor(value / 256 ^ (3 - index)) % 256 / 255
    channel = channel <= 0.03928 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
    total = total + weight * channel
  end
  return total
end

local function contrast(a, b)
  local x, y = luminance(a), luminance(b)
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05)
end

-- Changing 'background' makes Neovim reload the active colorscheme.
local function each_variant(fn)
  for _, variant in ipairs({ "dark", "light" }) do
    vim.o.background = variant
    fn(variant, theme.get_palette(variant))
  end
  vim.o.background = "dark"
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
    equal(vim.g.colors_name, nil)
    vim.api.nvim_set_hl(0, "ClayTestStartup", { fg = "#123456" })
    vim.cmd.colorscheme("clay")
    equal(hl("ClayTestStartup").fg, color("#123456"), "first load cleared a group defined during startup")
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
    each_variant(function(variant, c)
      local function fg(name)
        return hl(name).fg
      end
      local function above(a, b)
        assert(contrast(fg(a), color(c.bg)) > contrast(fg(b), color(c.bg)), variant .. ": " .. a .. " should stand out more than " .. b)
      end
      above("@variable", "@variable.member")
      above("@variable.member", "@variable.parameter")
      above("@variable", "@keyword")
      above("@variable", "@function.call")
      above("@keyword", "@punctuation.bracket")
      above("@variable", "@string")
      equal(fg("@type"), fg("@variable.member"))
      equal(fg("@type.definition"), fg("@variable"))
      equal(fg("@lsp.type.parameter"), fg("@variable.parameter"))
      equal(fg("@lsp.type.property"), fg("@variable.member"))
      assert(not hl("@keyword").bold)
      equal(fg("@function"), color(c.clay))
      equal(fg("CursorLineNr"), color(c.clay))
      equal(hl("ClayMode").bg, color(c.clay))
      equal(hl("StatusLine").bg, color(c.statusline))
    end)
  end)

  test("related syntax, diff, diagnostic, and surface states stay distinguishable", function()
    each_variant(function(variant, c)
      local function differ(a, b, key)
        key = key or "fg"
        local x, y = hl(a)[key], hl(b)[key]
        assert(x and y and x ~= y, variant .. ": " .. a .. " and " .. b .. " share " .. key .. " " .. vim.inspect(x))
      end
      differ("@string", "@keyword")
      differ("@string", "@type")
      differ("@comment", "@punctuation.bracket")
      differ("@comment", "@operator")
      differ("Added", "Changed")
      differ("Changed", "Removed")
      differ("Added", "Removed")
      differ("DiagnosticWarn", "DiagnosticInfo")
      differ("DiagnosticInfo", "DiagnosticHint")
      for _, pair in ipairs({
        { "DiffAdd", "DiffChange" }, { "DiffChange", "DiffDelete" }, { "DiffAdd", "DiffDelete" },
        { "DiffChange", "CursorLine" }, { "DiffAdd", "CursorLine" }, { "DiffDelete", "CursorLine" },
        { "Search", "Visual" }, { "LspReferenceText", "CursorLine" }, { "CursorLine", "NormalFloat" },
      }) do
        differ(pair[1], pair[2], "bg")
      end
      -- Backdrops and popup shadows must darken whatever lies beneath.
      assert(luminance(hl("FloatShadow").bg) < luminance(color(c.bg)), variant .. ": FloatShadow does not darken")
    end)
  end)

  test("'background' selects the variant and changing it reloads the theme", function()
    load({ transparent = false })
    local dark, light = theme.get_palette("dark"), theme.get_palette("light")
    equal(hl("Normal").bg, color(dark.bg))
    vim.o.background = "light"
    equal(vim.g.colors_name, "clay")
    equal(theme.get_palette(), light)
    equal(hl("Normal").bg, color(light.bg))
    equal(hl("Normal").fg, color(light.fg))
    assert(luminance(color(light.bg)) > luminance(color(light.fg)), "light variant must use dark text on a light canvas")
    vim.o.background = "dark"
    equal(hl("Normal").bg, color(dark.bg))
    load()
  end)

  test("top-level palette colors apply to both variants and variant tables take precedence", function()
    load({ palette = { clay = "#c87860", dark = { fg = "#d0d0d0" }, light = { clay = "#a05030" } } })
    local defaults = require("clay.palette")
    equal(theme.get_palette("dark").clay, "#c87860")
    equal(theme.get_palette("dark").fg, "#d0d0d0")
    equal(theme.get_palette("light").clay, "#a05030")
    equal(theme.get_palette("light").fg, defaults.light.fg)
    equal(hl("@function").fg, color("#c87860"))
    vim.o.background = "light"
    equal(hl("@function").fg, color("#a05030"))
    vim.o.background = "dark"
    load()
  end)

  test("colors stay grayscale apart from Clay and the string tint, and every link resolves", function()
    each_variant(function(variant, c)
      local groups = vim.tbl_extend("force", require("clay.highlights").get(c, theme.get_options()), require("clay.integrations").get(c, theme.get_options()))
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
          if value and value ~= color(c.clay) and value ~= color(c.string) then
            local r, g, b = math.floor(value / 65536), math.floor(value / 256) % 256, value % 256
            assert(r == g and g == b, variant .. ": " .. name .. " contains a chromatic " .. key)
          end
        end
      end
      for _, name in ipairs({ "CmpItemAbbr", "BlinkCmpLabel", "SnacksPickerFile", "NeoTreeFileName", "OilFile", "NavicText", "NavicIconsFunction", "TroubleText" }) do
        equal(hl(name).bg, nil, name .. " must not paint over a selected row")
      end
    end)
  end)

  test("background defaults to transparent and can switch to opaque and back", function()
    load()
    equal(theme.get_palette().bg, "#121212")
    for _, name in ipairs({ "Normal", "SignColumn", "FoldColumn", "WinBar", "MsgArea", "NeoTreeNormal", "NeoTreeNormalNC", "NvimTreeNormal", "NvimTreeNormalNC", "TroubleNormal", "NoiceSplit", "BufferLineFill", "BufferLineBuffer" }) do
      equal(hl(name).bg, nil, name .. " should be transparent by default")
    end
    equal(hl("NormalFloat").bg, color(colors.float))
    equal(hl("Pmenu").bg, color(colors.float))
    -- Window backgrounds left unset must not let blended floats show the text beneath.
    for _, name in ipairs({ "Normal", "MsgArea", "ClaySidebar", "NoiceMini", "TroubleNormal" }) do
      equal(hl(name).blend, 0, name .. " must not blend while transparent")
    end
    equal(hl("NormalFloat").blend, nil)
    -- Neovim draws unfocused floats with NormalNC ahead of NormalFloat.
    equal(hl("NormalNC"), {}, "NormalNC would override NormalFloat in unfocused floats")
    load({ transparent = false })
    equal(hl("NormalNC"), {}, "NormalNC would override NormalFloat in unfocused floats")
    for _, name in ipairs({ "Normal", "MsgArea", "ClaySidebar", "NoiceMini" }) do
      equal(hl(name).blend, nil, name .. " should honor 'winblend' when opaque")
    end
    equal(hl("Normal").bg, color(colors.bg))
    equal(hl("NeoTreeNormal").bg, color(colors.sidebar))
    equal(hl("NvimTreeNormal").bg, color(colors.sidebar))
    load()
    equal(hl("Normal").bg, nil)
    equal(hl("NeoTreeNormal").bg, nil)
    equal(hl("NvimTreeNormal").bg, nil)
  end)

  test("border groups share their surface so solid winborder and pumborder read as padding", function()
    local saved = {}
    for _, key in ipairs({ "winborder", "pumborder" }) do
      if vim.fn.exists("+" .. key) == 1 then
        saved[key] = vim.o[key]
      end
    end
    for _, opts in ipairs({ {}, { transparent = false }, { palette = { float = "#202020" } } }) do
      for _, border in ipairs({ "solid", "rounded" }) do
        for key in pairs(saved) do
          vim.o[key] = border
        end
        load(opts)
        local float = color(theme.get_palette().float)
        for _, name in ipairs({ "NormalFloat", "FloatBorder", "FloatTitle", "FloatFooter", "Pmenu", "PmenuBorder", "BlinkCmpMenuBorder", "TelescopeBorder", "NoicePopupBorder" }) do
          equal(hl(name).bg, float, name .. " background with " .. border .. " borders")
        end
        equal(hl("FloatBorder").fg, color(colors.float_border))
      end
    end
    for key, value in pairs(saved) do
      vim.o[key] = value
    end
    load()
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
    equal(hl("Comment").fg, color(colors.string))
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
      { palette = { light = "#ffffff" } }, { palette = { light = { absent = "#ffffff" } } },
      { palette = { dark = { clay = "orange" } } },
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

  test("type annotations name every palette color", function()
    local source = table.concat(vim.fn.readfile(root .. "/lua/clay/init.lua"), "\n")
    local alias = assert(source:match("%-%-%-@alias clay%.PaletteName ([^\n]+)"), "clay.PaletteName alias missing")
    local names = {}
    for name in alias:gmatch('"([%w_]+)"') do
      names[#names + 1] = name
    end
    table.sort(names)
    local palettes = require("clay.palette")
    for _, variant in ipairs({ "dark", "light" }) do
      local keys = vim.tbl_keys(palettes[variant])
      table.sort(keys)
      equal(names, keys, "clay.PaletteName differs from the " .. variant .. " palette")
    end
  end)

  test("integration metadata owns every plugin group and the help table is current", function()
    local integrations = require("clay.integrations")
    local plugins = integrations.list_plugins()
    local matched = {}
    for name in pairs(integrations.get(colors, theme.get_options())) do
      -- Clay helpers and legacy Tree-sitter captures are shared, not plugin-owned.
      if not name:match("^Clay") and not name:match("^@") then
        local owner
        for _, plugin in ipairs(plugins) do
          for _, pattern in ipairs(plugin.groups) do
            if name:match(pattern) then
              owner = plugin
              matched[pattern] = true
            end
          end
        end
        assert(owner, name .. " is not owned by any plugin in M.plugins")
      end
    end
    local repositories = {}
    for _, plugin in ipairs(plugins) do
      assert(plugin.url:match("^https://github%.com/[^/]+/[^/]+$"), "unexpected URL: " .. plugin.url)
      repositories[plugin.url:sub(#"https://github.com/" + 1)] = true
      for _, pattern in ipairs(plugin.groups) do
        assert(matched[pattern], plugin.name .. " pattern matches no group: " .. pattern)
      end
    end
    local pinned = vim.json.decode(table.concat(vim.fn.readfile(root .. "/.github/ci-dependencies.json"), "\n")).plugins
    for name, dependency in pairs(pinned) do
      assert(repositories[dependency.repository], name .. " is pinned for CI but missing from integration metadata")
    end
    local docs = dofile(root .. "/scripts/integration-docs.lua")
    local help = vim.fn.readfile(docs.path)
    equal(docs.update(help), help, "doc/clay.txt integration table is stale; run make docs")
  end)

  test("design system spec and preview colors match the theme", function()
    local spec = vim.fn.readfile(root .. "/design/clay-design-system.md")
    local documented, terminal = { dark = {}, light = {} }, { dark = {}, light = {} }
    for _, line in ipairs(spec) do
      -- Tolerate column padding added by Markdown table formatters.
      local key, dark, light = line:match("^|%s*`([%w_]+)`%s*|%s*`(#%x+)`%s*|%s*`(#%x+)`%s*|")
      if key then
        documented.dark[key], documented.light[key] = dark, light
      end
      local index, dark_key, dark_value, light_key, light_value =
        line:match("^|%s*(%d+)%s*|[^|]+|%s*`([%w_]+)`%s*|%s*`(#%x+)`%s*|%s*`([%w_]+)`%s*|%s*`(#%x+)`%s*|")
      if index then
        terminal.dark[tonumber(index)] = { dark_key, dark_value }
        terminal.light[tonumber(index)] = { light_key, light_value }
      end
    end
    -- The light rule only overrides variables, so it inherits Clay from the dark rule.
    local preview = { dark = {}, light = {} }
    for _, line in ipairs(vim.fn.readfile(root .. "/design/clay-grayscale.html")) do
      local variant = line:match("^%s*#clay%-grayscale%-preview {") and "dark"
        or line:match('^%s*#clay%-grayscale%-preview%[data%-variant="light"%] {') and "light"
      if variant then
        for name, value in line:gmatch("%-%-cn%-([%w%-]+): (#%x+);") do
          preview[variant][name] = value
        end
      end
    end
    preview.light = vim.tbl_extend("keep", preview.light, preview.dark)
    local preview_keys = {
      bg = "bg", side = "sidebar", float = "float", panel = "statusline", line = "cursorline",
      select = "selection", border = "border", ["float-border"] = "float_border",
      ["diff-add"] = "diff_add", ["diff-delete"] = "diff_delete", fg = "fg", bright = "bright",
      secondary = "secondary", string = "string", muted = "muted", comment = "comment",
      subtle = "subtle", gutter = "gutter", clay = "clay",
    }
    local palettes = require("clay.palette")
    load()
    each_variant(function(variant, c)
      equal(documented[variant], palettes[variant], "design/clay-design-system.md " .. variant .. " palette is stale")
      for name, key in pairs(preview_keys) do
        equal(preview[variant][name], palettes[variant][key], "design/clay-grayscale.html " .. variant .. " --cn-" .. name)
      end
      for index = 0, 15 do
        local row = assert(terminal[variant][index], "terminal table row " .. index .. " missing")
        equal(row[2], c[row[1]], variant .. " terminal row " .. index .. " value differs from its key")
        equal(vim.g["terminal_color_" .. index], row[2], variant .. " terminal row " .. index)
      end
    end)
  end)

  test("terminal colors are optional and all 16 entries are populated when enabled", function()
    vim.g.terminal_color_3 = "#123456"
    load({ terminal_colors = false })
    equal(vim.g.terminal_color_3, "#123456")
    load()
    each_variant(function(variant, c)
      for index = 0, 15 do
        assert(vim.g["terminal_color_" .. index]:match("^#%x%x%x%x%x%x$"))
      end
      equal(vim.g.terminal_color_1, c.clay)
      for _, index in ipairs({ 1, 2, 9, 10 }) do
        assert(vim.g["terminal_color_" .. index] ~= c.fg, variant .. ": terminal color " .. index .. " matches default text")
      end
      -- ANSI names are absolute: black stays darker than white on either canvas.
      assert(luminance(color(vim.g.terminal_color_0)) < luminance(color(vim.g.terminal_color_7)), variant .. ": black is lighter than white")
    end)
  end)

  test("lualine mode colors remain Clay and nested tables are independent", function()
    each_variant(function(_, c)
      package.loaded["lualine.themes.clay"] = nil
      local status = require("lualine.themes.clay")
      for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal" }) do
        equal(status[mode].a.bg, c.clay)
        equal(status[mode].b.bg, c.statusline)
        equal(status[mode].c.bg, c.statusline)
      end
      status.normal.a.bg = "#ffffff"
      equal(status.insert.a.bg, c.clay)
    end)
  end)

  test("colorscheme reload and switching back from another theme", function()
    local events = 0
    local autocmd = vim.api.nvim_create_autocmd("ColorScheme", { pattern = "clay", callback = function() events = events + 1 end })
    vim.cmd.colorscheme("default")
    vim.api.nvim_set_hl(0, "ClayTestStale", { fg = "#123456" })
    vim.cmd.colorscheme("clay")
    equal(hl("ClayTestStale"), {}, "switching themes kept a stale group")
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
    -- Neovim 0.12 returns nil instead of raising when the parser is missing.
    local parser = assert(vim.treesitter.get_parser(buf, "lua"), "Lua Tree-sitter parser missing")
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
