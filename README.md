# claude.nvim

以中性灰为主体、Clay 陶土色点缀的深色 Neovim 主题。

默认背景透明，沿用终端底色；关闭透明时使用 `#111315`（RGB 17, 19, 21）背景。正文采用 `#CCCCCC`，强调色为 `#D97757`。默认只为函数定义和当前操作位置添加 Clay；关键字、字符串、变量和函数调用通过灰阶区分。诊断、Diff、Git 状态同样保持灰阶。

灵感来自 [Claude Design System 设计风格与动效体系总结](https://rua.plus/post/claude-design-system-style-and-motion) 中的配色与表面层级。这是独立社区主题。

灰阶层级参考 [lackluster.nvim](https://github.com/slugbyte/lackluster.nvim/tree/70dd682e564784893b984deb51dd5ddd263c8cc7)：让变量与类型名更突出，弱化关键字、调用和标点，默认不加粗关键字。保留 Claude 的 Clay 作为唯一强调色，注释则提高亮度以方便阅读。

| 用途 | 默认颜色 |
| --- | --- |
| 正文、变量、类型定义 | `#CCCCCC` |
| 成员、常量、类型 | `#AAAAAA` |
| 参数、关键字、字符串、函数调用 | `#8E8E8E` |
| 注释、标点、运算符 | `#7A7A7A` |
| 函数定义、焦点、模式标记 | `#D97757` Clay |
| 浮窗 / 状态栏 / 选区 | `#1A1A1A` / `#242424` / `#2A2A2A` |

以上语法层级以 Tree-sitter 为准；点缀范围也可通过下面的 `accent` 选项切换。

## 直接预览

需要 Neovim 0.10.4+ 和支持 true color 的终端。无需安装插件、无需修改个人配置：

```bash
cd /run/media/xfy/Plextor512/Developer/claude-nvim
make preview
```

SSH 会话也可以直接运行。输入 `:q!` 退出。

```bash
CLAUDE_ACCENT=minimal make preview
CLAUDE_ACCENT=expressive make preview
```

预览使用独立配置与示例文件，启用行号、当前行、状态栏和一条示例诊断。优先使用 Neovim 的 Lua Tree-sitter parser；未安装 parser 时回退到传统语法高亮。

`design/claude-grayscale.html` 保留最初的交互设计稿；`make preview` 展示实际主题。

## 安装

当前仓库尚未设置远程地址，可以先使用本地目录。

### lazy.nvim

```lua
{
  dir = "/run/media/xfy/Plextor512/Developer/claude-nvim",
  name = "claude.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("claude").setup({
      accent = "restrained",
    })
    vim.cmd.colorscheme("claude")
  end,
}
```

也可以在 `init.lua` 中直接加入 runtimepath：

```lua
vim.opt.runtimepath:prepend("/run/media/xfy/Plextor512/Developer/claude-nvim")
vim.cmd.colorscheme("claude")
```

主题会设置 `background=dark` 和 `termguicolors`。侧栏、状态栏、光标形状、诊断符号、插件安装与布局由自己的 Neovim 配置决定。

## 配置

`setup()` 可省略；每次调用都从以下默认值开始。修改配置后重新执行 `:colorscheme claude` 生效。

```lua
require("claude").setup({
  accent = "restrained", -- "minimal" | "restrained" | "expressive"
  transparent = true,
  italic_comments = true,
  bold_keywords = false,
  terminal_colors = true,
  palette = {},
  overrides = {},
})

vim.cmd.colorscheme("claude")
```

| 点缀范围 | 函数定义 | 函数调用 | 当前操作位置 |
| --- | --- | --- | --- |
| `minimal` | 亮灰 | 灰 | Clay |
| `restrained`（默认） | Clay | 灰 | Clay |
| `expressive` | Clay | Clay | Clay |

定义与调用的区分依赖 Tree-sitter 的 capture 或 LSP 的 declaration/definition modifier。传统语法高亮无法可靠区分两者，因此默认 `Function` 保持灰色。LSP 的通用 function/method 高亮不会覆盖 Tree-sitter 的前景色。

透明模式默认开启，移除编辑区和侧栏底色，选区、状态栏与浮窗保留实色以保持层次。设置 `transparent = false` 可恢复主题实色背景。透明模式让终端背景透出，实际透明度由终端或前端设置决定。光标高亮是否显示取决于终端、前端和 `guicursor` 设置。

`terminal_colors=true` 会为 Neovim 内置终端设置 16 色 ANSI 调色板，yellow/bright yellow 使用 Clay，其余使用灰阶。设为 `false` 可保留已有终端调色板；它不会撤销先前已经设置的终端颜色。

### 自定义色板和高亮

```lua
require("claude").setup({
  palette = {
    bg = "#1c1c1c",
    clay = "#d97757",
  },
  overrides = function(colors, opts)
    return {
      Comment = { fg = colors.secondary, italic = opts.italic_comments },
      ["@markup.heading"] = { fg = colors.clay, bold = true },
      TelescopeBorder = { link = "FloatBorder" },
    }
  end,
})
```

`overrides` 也可直接传入高亮表；每项会完整替换对应高亮，`{}` 表示清空。色板支持的键见 [palette.lua](lua/claude/palette.lua)。`require("claude").get_palette()` 返回当前色板的副本。

## 插件适配

内置高亮映射覆盖：

- Telescope、Snacks picker / dashboard / indent
- nvim-cmp、blink.cmp
- Neo-tree、nvim-tree
- Gitsigns、which-key、indent-blankline
- mini.statusline、mini.tabline、mini.indentscope
- lualine 专用主题

这些映射不会主动加载插件。插件新增的高亮组、第三方图标的独立颜色以及用户覆盖仍可能带入其他颜色；可通过 `:Inspect`、`:highlight` 和 `overrides` 调整。

### lualine

```lua
require("lualine").setup({
  options = {
    theme = "claude",
    icons_enabled = false,
    component_separators = "",
    section_separators = "",
  },
})
```

所有模式使用相同的 Clay 色块，依靠模式名称区分。自定义色板时先配置 `claude`，再初始化 lualine。

### 灰阶诊断

诊断保留不同明度和下划线。建议配合带含义的符号；以下是可选的用户配置，主题本身不会修改它：

```lua
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
  severity_sort = true,
})
```

## 验证

```bash
make test
```

测试需要 Lua Tree-sitter parser，检查加载与重载、三档点缀、灰阶约束、链接有效性、透明背景、配置覆盖、终端色板、lualine 数据和真实 Lua 定义/调用 capture。测试在独立 Neovim 进程运行，不加载个人配置。

已在 Neovim 0.10.4 和 0.12.5 上通过全部 13 项检查，包含灰阶明暗层级与 Clay 焦点。部分插件高亮名称已对照上游源码核对；尚未逐一运行完整的第三方插件组合。
