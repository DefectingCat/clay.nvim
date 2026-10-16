# 变更日志

记录对使用者有影响的配置、配色、插件适配和兼容性变化。版本规则见 [RELEASING.md](RELEASING.md)；每个已发布版本对应同名的 Git 附注标签。

## [Unreleased]

## [v0.2.0] - 2026-10-16

### 不兼容变化

- 项目更名为 `clay.nvim`，从本版本起使用新接口；`v0.1.0` 保留旧名称 `claude.nvim`。
- 配置入口从 `require("claude")` 改为 `require("clay")`，配色命令从 `:colorscheme claude` 改为 `:colorscheme clay`；lualine 的 `theme = "claude"` 改为 `theme = "clay"`。
- 自定义高亮组前缀从 `Claude` 改为 `Clay`（例如 `ClaudeMode` → `ClayMode`），帮助入口从 `:help claude.txt` 改为 `:help clay.txt`，其他帮助标签也统一使用 `clay-` 前缀。
- 预览和测试环境变量从 `CLAUDE_` 改为 `CLAY_`：`CLAY_ACCENT`、`CLAY_TREESITTER_DIR`、`CLAY_PREVIEW_RUNTIME`、`CLAY_PLUGIN_ROOTS`。
- 旧入口不再提供；升级时同步修改主题配置、lualine 配置、自定义状态栏、高亮覆盖和脚本引用。配色和配置项保持原有行为。

### 文档

- 精简 README，提供 GitHub 安装配置、预览与验证命令；lazy.nvim 示例默认跟随稳定版本。
- 新增 `AGENTS.md` 贡献指南，说明目录结构、代码风格与测试约定。

### 发布验证

- Neovim 0.10.4、0.12.5：各通过 13 项核心检查。
- Neovim 0.12.5：九种语言的定义与调用在三档点缀下均通过检查，缺少 parser 时的回退检查通过。
- 真实插件检查：0.12.5 通过 19 项，无跳过；0.10.4 通过 18 项，跳过要求 Neovim 0.11+ 的 nvim-lightbulb。
- 插件检查覆盖初始化、主题重载、实色背景和自定义强调色，不代表完整插件功能的端到端验证；多语言检查仅在 0.12.5 上运行。

## [v0.1.0] - 2026-10-16

首次版本化发布，汇总此前的主题实现。

### 功能

- 中性灰深色主题，以 `#D97757` Clay 点缀函数定义与操作焦点；提供 `minimal`、`restrained`、`expressive` 三档点缀。
- 默认透明背景；关闭透明时使用 `#111315`，浮窗、状态栏与选区保留实色层次。
- 支持注释斜体、关键字加粗、16 色终端色板开关、自定义色板和高亮覆盖；提供 `setup()`、`load()`、`get_options()`、`get_palette()` 接口。
- 覆盖 Tree-sitter 与 LSP 语义高亮，以及补全、搜索、文件树、Git、诊断、导航和编辑辅助插件；提供 lualine 主题。
- 提供隔离预览、多语言样例与仓库专用 parser 准备工具；缺少 parser 或查询时明确显示 regex 回退。
- 建立版本规则、发布检查流程与变更日志，以 Git 附注标签标识发布版本。

### 兼容性

- 主题最低支持 Neovim 0.10.4，需要支持 true color 的终端。
- 多语言 parser 准备工具需要 Neovim 0.12+；该要求不影响主题本身的最低版本。
- 属于 `0.x` 开发阶段，尚未承诺 `1.0` 之后的公共接口稳定性。默认点缀为 `restrained`，默认开启透明背景。

### 发布验证

- Neovim 0.10.4、0.12.5：各通过 13 项核心检查。
- Neovim 0.12.5：九种语言的函数定义和调用在三档点缀下均通过检查，缺少 parser 的回退检查通过。
- Neovim 0.12.5：19 个真实插件仓库的高亮检查通过；Neovim 0.10.4：18 个通过，要求 Neovim 0.11+ 的 nvim-lightbulb 明确跳过。
- 插件检查使用本机已有 checkout，覆盖初始化与主题重载，不代表所有第三方插件功能均完成端到端验证。九种语言检查仅在 Neovim 0.12.5 上运行。
