# Clay 设计规范

clay.nvim 的配色规则。移植到终端、其他编辑器、浏览器或任何界面时，以本文为准；`lua/clay/palette.lua` 是色值的唯一来源，本文的色板表由测试校验与其一致。

## 设计原则

1. **灰阶为底，Clay 点睛。** 层级靠亮度表达，而不是色相。除 Clay 和字符串的暖灰外，所有颜色都是 R = G = B 的中性灰。
2. **越重要越亮。** 用户写的东西（变量、定义）最亮；语言结构（关键字、标点）退后；辅助信息（注释、行号、提示）最暗。
3. **Clay 只标记焦点。** 函数定义、光标、当前匹配、当前模式、选中项的提示符。同屏 Clay 越少越好；它不用于诊断、Git 或 Diff。
4. **状态靠亮度阶梯区分，不靠颜色。** 错误、警告、新增、删除都是灰，用不同亮度档位和符号区分。
5. **表面安静且中性。** 底色无色偏；浮层比底色亮一档，状态面再亮一档；默认透明，让终端或宿主决定底色。
6. **相关状态必须可区分。** 会同时出现的两个状态（如搜索与选区、当前行与 Diff 行）不得共用同一颜色。

## 色板

### 文字

亮度从高到低排列。对比度以 `bg` 为底按 WCAG 计算。

| 键 | 色值 | L\* | 对比度 | 角色 |
| --- | --- | --- | --- | --- |
| `bright` | `#e6e6e6` | 91.3 | 15.0 | 强调文字：标题、选中项、错误、新增 |
| `fg` | `#cccccc` | 82.0 | 11.7 | 正文、变量、标识符 |
| `secondary` | `#aaaaaa` | 69.6 | 8.1 | 类型、常量、成员、警告、修改、次要界面文字 |
| `string` | `#b0978e` | 64.4 | 6.8 | 字符串；唯一带色相的文字灰，色相取自 Clay |
| `muted` | `#8e8e8e` | 59.0 | 5.7 | 关键字、函数调用、参数、信息、删除 |
| `comment` | `#7a7a7a` | 51.2 | 4.4 | 注释、提示、内联提示、未聚焦界面 |
| `subtle` | `#686868` | 44.0 | 3.4 | 标点、运算符 |
| `gutter` | `#555555` | 36.1 | 2.5 | 行号、不可见字符、滚动条滑块 |

### 点缀

| 键 | 色值 | L\* | 对比度 | 角色 |
| --- | --- | --- | --- | --- |
| `clay` | `#d97757` | 60.5 | 6.0 | 焦点；作为背景时文字用 `bg` |

### 表面

由暗到亮排列。相邻档位亮度差约 ΔL\* 3 以上。

| 键 | 色值 | L\* | 角色 |
| --- | --- | --- | --- |
| `sidebar` | `#101010` | 4.7 | 侧栏、文件树、未聚焦状态栏、标签栏 |
| `bg` | `#121212` | 5.5 | 编辑区底色（关闭透明时） |
| `diff_delete` | `#181818` | 8.2 | Diff 删除行 |
| `float` | `#1a1a1a` | 9.3 | 浮窗、补全菜单、对话框 |
| `cursorline` | `#1e1e1e` | 11.3 | 当前行、折叠行、参考列 |
| `statusline` | `#242424` | 14.2 | 状态栏 |
| `diff_change` | `#252525` | 14.7 | Diff 修改行 |
| `reference` | `#2a2a2a` | 17.1 | 光标下符号的其他引用 |
| `diff_add` | `#2d2d2d` | 18.5 | Diff 新增行 |
| `selection` | `#363636` | 22.6 | 选区、菜单选中项、括号匹配、行内 Diff |
| `search` | `#424242` | 28.0 | 搜索匹配 |

### 线条

| 键 | 色值 | 角色 |
| --- | --- | --- |
| `border` | `#2a2a2a` | 分割线、缩进线 |
| `float_border` | `#444444` | 浮窗边框 |

## 语义映射

### 语法

| 元素 | 颜色 | 样式 |
| --- | --- | --- |
| 变量、模块、类型定义名 | `fg` | |
| 函数定义 | 随点缀模式（见下） | |
| 函数调用、构造调用 | 随点缀模式（见下） | |
| 类型、常量、布尔、数字、成员/属性 | `secondary` | |
| 字符串、字符、代码块 | `string` | |
| 关键字、参数、内置变量、属性/注解 | `muted` | 默认不加粗 |
| 注释、文档字符串 | `comment` | 默认斜体 |
| 标点、运算符 | `subtle` | |
| 内置函数 | `subtle`；`expressive` 模式为 `clay` | |
| 标题、TODO/FIXME | `bright` | 粗体 |
| 链接 | `fg` 或 `secondary` | 下划线 |

### 点缀模式

| 模式 | 函数定义 | 函数调用 | 界面焦点 |
| --- | --- | --- | --- |
| `minimal` | `bright` | `muted` | `clay` |
| `restrained`（默认） | `clay` | `muted` | `clay` |
| `expressive` | `clay` | `clay` | `clay` |

### 界面

| 元素 | 前景 | 背景 | 备注 |
| --- | --- | --- | --- |
| 编辑区 | `fg` | `bg` 或透明 | |
| 光标 | `bg` | `clay` | |
| 当前行 | | `cursorline` | 当前行号用 `clay` 加粗 |
| 行号 | `gutter` | | |
| 选区 | `bright` | `selection` | |
| 搜索匹配 | `bright` | `search` | 下划线 |
| 当前搜索匹配、替换 | `bg` | `clay` | 粗体 |
| 引用高亮 | | `reference` | |
| 浮窗 | `fg` | `float` | 边框 `float_border`，背景同 `float` |
| 浮窗标题 | `clay` | `float` | |
| 补全菜单 | `secondary` | `float` | 选中项 `bright` 在 `selection` 上；匹配字符 `clay` 加粗 |
| 状态栏 | `secondary` | `statusline` | 模式块 `bg` 在 `clay` 上，粗体 |
| 未聚焦状态栏、标签栏 | `comment` | `sidebar` | |
| 当前标签 | `bright` | `bg` | `clay` 下划线 |
| 分割线 | `border` | | |
| 目录名 | `secondary` | | |
| 错误消息 | `bright` | | 粗体 |
| 警告消息 | `secondary` | | 粗体 |
| 模式提示、确认提问 | `clay` | | |

### Diff 与 Git

| 状态 | 文字/符号 | 整行背景 |
| --- | --- | --- |
| 新增 | `bright` | `diff_add` |
| 修改 | `secondary` | `diff_change` |
| 删除 | `muted` | `diff_delete`（填充符号用 `secondary`） |
| 行内变化 | `bright` 粗体 | `selection` |

### 诊断

| 级别 | 颜色 | 下划线 |
| --- | --- | --- |
| Error | `bright` | 波浪线 `bright` |
| Warn | `secondary` | 波浪线 `secondary` |
| Info | `muted` | 波浪线 `muted` |
| Hint | `comment` | 波浪线 `comment` |
| Ok | `fg` | |

行尾虚拟文本统一用 `comment`；级别靠符号和下划线区分。

## 终端 ANSI 16 色

| 序号 | 名称 | 键 | 色值 |
| --- | --- | --- | --- |
| 0 | black | `sidebar` | `#101010` |
| 1 | red | `clay` | `#d97757` |
| 2 | green | `bright` | `#e6e6e6` |
| 3 | yellow | `secondary` | `#aaaaaa` |
| 4 | blue | `secondary` | `#aaaaaa` |
| 5 | magenta | `muted` | `#8e8e8e` |
| 6 | cyan | `secondary` | `#aaaaaa` |
| 7 | white | `fg` | `#cccccc` |
| 8 | bright black | `comment` | `#7a7a7a` |
| 9 | bright red | `clay` | `#d97757` |
| 10 | bright green | `bright` | `#e6e6e6` |
| 11 | bright yellow | `fg` | `#cccccc` |
| 12 | bright blue | `fg` | `#cccccc` |
| 13 | bright magenta | `secondary` | `#aaaaaa` |
| 14 | bright cyan | `fg` | `#cccccc` |
| 15 | bright white | `bright` | `#e6e6e6` |

终端自身：前景 `fg`，背景 `bg`，光标 `clay`（光标下文字 `bg`），选区 `selection`。红色必须与 white 不同，错误输出和 diff 删除行才不会混进正文。

## 移植到其他软件

1. **先按角色找颜色，不按名字找。** 目标软件的"keyword"“string”“selection”等槽位，对照上面的语义映射表取色值；没有对应角色的槽位，取同类角色最接近的档位。
2. **只有 Clay 和 `string` 带色相。** 目标软件要求的红、绿、黄、蓝等彩色槽位，按 ANSI 表或诊断表映射回灰阶；不要另加彩色。
3. **Clay 控制在焦点上。** 光标、当前匹配、当前模式、选中项提示符、函数定义；其他地方用灰。
4. **表面只能向上叠。** 浮层比底色亮，选中比悬停亮，搜索比选区亮；不要让当前行比浮窗底色更暗，否则浮窗里看不到当前行。
5. **透明底色时检查当前行。** 宿主底色接近 `#1e1e1e` 时，改用更亮的当前行色。
6. **样式：** 注释斜体；关键字不加粗；粗体留给标题、错误、TODO、模式块和当前匹配。

### 移植检查

- [ ] 所有前景、背景、下划线颜色都是中性灰、Clay 或 `string` 暖灰
- [ ] 字符串与关键字、注释与标点颜色不同
- [ ] 新增、修改、删除三种 Diff/Git 状态颜色两两不同
- [ ] Warn、Info、Hint 颜色两两不同
- [ ] 搜索与选区背景不同；当前行与 Diff 行背景不同；当前行比浮窗底色亮
- [ ] 正文对比度 ≥ 7，注释 ≥ 4，Clay 作为文字 ≥ 4.5
- [ ] 终端 red/green 与 white 不同

## 参考

- 交互式效果：`design/clay-grayscale.html`
- 色值来源：`lua/clay/palette.lua`
- 高亮实现：`lua/clay/highlights.lua`、`lua/clay/integrations/`
- 灵感：[Claude Design System](https://rua.plus/post/claude-design-system-style-and-motion)；灰阶层级参考 [lackluster.nvim](https://github.com/slugbyte/lackluster.nvim)
