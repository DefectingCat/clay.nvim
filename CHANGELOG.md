# 变更日志

记录对使用者有影响的配置、配色、插件适配和兼容性变化。版本规则见 [RELEASING.md](RELEASING.md)；每个已发布版本对应同名的 Git 附注标签。

## [Unreleased]

## [v0.4.0] - 2026-10-30

### 新增

- 新增设计规范 `design/clay-design-system.md`：色板角色、语法与界面映射、Diff/诊断层级、终端 16 色和移植到其他软件的规则；测试确保其色值与主题一致。
- 新增亮色变体。主题跟随 `background`：`:set background=light` 切换到亮色，Neovim 自动重新加载主题，lualine 主题随之更新。亮色变体按对比度镜像暗色：每档文字与底色的对比度相同，表面向深处叠加；Clay 保持品牌色 `#D97757`。
- `palette` 支持 `dark`、`light` 子表，只覆盖对应变体；顶层颜色仍作用于两个变体。`get_palette()` 可传入 `"dark"` 或 `"light"` 读取指定变体。
- 新增色板键 `shadow`，用于浮窗阴影和背景遮罩。
- 预览支持 `CLAY_BACKGROUND=light`；`design/clay-grayscale.html` 可切换暗色与亮色。

### 不兼容变化

- 主题不再把 `background` 强制设为 `dark`。`background=light` 时（包括 Neovim 根据终端底色自动检测的情况）会加载亮色变体；需要始终使用暗色请在加载主题前设置 `vim.o.background = "dark"`。

### 变更

- 字符串改用偏 Clay 色相的暖灰 `#B0978E`（新增色板键 `string`），不再与关键字、函数调用同为 `#8E8E8E`。
- 标点与运算符（`subtle`）由 `#7A7A7A` 调暗为 `#686868`，与注释区分；`bright` 由 `#DDDDDD` 提亮为 `#E6E6E6`。
- Git 与 Diff 文本改为三档：新增 `bright`、修改 `secondary`、删除 `muted`；`DiagnosticInfo` 改用 `muted`，与 Warn 区分。
- 不透明背景由带冷色的 `#111315` 改为中性 `#121212`，与侧栏、浮窗同色调。
- `CursorLine` 提亮为 `#1E1E1E`，高于浮窗底色，在浮窗内也可见；选区提亮为 `#363636`。
- `DiffChange`、`Search`、LSP 引用改用独立的 `diff_change`、`search`、`reference` 背景，不再与 `CursorLine` 或 `Visual` 相同；`DiffAdd` 与 `DiffDelete` 分别调整为 `#2D2D2D`、`#181818`。
- 终端色板的红色与亮红改为 Clay（原为黄色），报错与 diff 删除行不再与默认文字同色。

### 发布验证

- Neovim 0.12.6 与 0.10.4：各 20 项核心检查通过；发布工具 5 项检查通过；0.12.6 上九种语言检查及缺失 parser 回退检查通过。
- 真实插件检查：0.12.6 与 0.10.4 上本机仅 7 个插件有 checkout，各 7 项通过、12 项因缺少 checkout 跳过；其余插件由推送后的 CI 覆盖，发布前未在本机验证。
- 视觉变化（亮色变体及各档配色调整）由测试检查对比度与区分度，未做 `make preview` 人工预览。

## [v0.3.0] - 2026-10-20

### 新增

- 为 `setup()`、`get_options()`、`get_palette()` 和 `overrides` 新增 LuaLS 类型注解，编辑配置时可补全选项、accent 取值与色板名称。
- `:help clay-integrations` 改为列出每个适配插件及其仓库地址；列表由各集成模块的元数据生成，测试确保其与实际高亮组一致。

### 变更

- 首次加载主题时不再执行 `:highlight clear`，保留启动期间插件已定义的高亮组；从其他主题切换或重新加载时仍会清除旧高亮。

### 修复

- 透明模式下，`Normal`、`MsgArea` 与侧栏背景设置 `blend = 0`，避免 noice 迷你消息等带 `winblend` 的浮窗透出下方文字；关闭透明后仍按 `winblend` 混合。
- 不再设置 `NormalNC`。Neovim 对未聚焦的浮窗优先使用 `NormalNC`，此前 LSP hover、诊断浮窗等未获焦点的浮窗会丢失浮窗底色、显示编辑区背景；普通非当前窗口的外观不变。

### 开发与发布

- 新增 `make docs`，从集成元数据重新生成帮助文档中的插件表。
- 测试新增 `solid` / `rounded` 浮窗与补全菜单边框的底色检查，并消除 LuaLS 在测试代码中的警告。

### 发布验证

- Neovim 0.12.6 与 0.10.4：各 16 项核心检查通过；发布工具 5 项检查通过；0.12.6 上九种语言检查及缺失 parser 回退检查通过。
- 真实插件检查：0.12.6 与 0.10.4 上本机仅 7 个插件有 checkout，各 7 项通过、12 项因缺少 checkout 跳过；其余插件由推送后的 CI 覆盖，发布前未在本机验证。
- LuaLS 3.19.2 检查仓库无诊断问题。
- 视觉变化（`winblend` 浮窗、未聚焦浮窗底色、`solid` / `rounded` 边框）在 tmux 中按终端输出的颜色核对，未做 `make preview` 人工预览。

## [v0.2.1] - 2026-10-20

### 开发与发布

- 新增推送与 PR 检查，覆盖两个 Neovim 版本、真实插件、九种语言及发布说明工具；CI 依赖固定版本。
- 推送版本标签后自动执行检查，并从变更日志生成 GitHub Release；已发布版本不会被重跑覆盖。
- 修复空目录首次准备 parser 时，高亮查询未被当前 Neovim 进程发现的问题。

### 发布验证

- Neovim 0.12.6：13 项核心检查、发布工具检查与九种语言检查通过。
- 真实插件检查：本机仅 7 个插件有 checkout，7 项通过、12 项因缺少 checkout 跳过；其余插件与 Neovim 0.10.4 由推送后的 CI 覆盖，发布前未在本机验证。
- 本次不含主题行为变化，未做人工视觉预览。

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
