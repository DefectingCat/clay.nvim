# 版本规则与发布流程

## 版本来源

采用 [语义化版本](https://semver.org/lang/zh-CN/)，Git 标签格式为 `vMAJOR.MINOR.PATCH`。使用[附注标签](https://git-scm.com/docs/git-tag)记录发布者、时间和说明，标签所指向的提交就是该版本的完整内容。

Git 标签是发布版本的权威来源。`CHANGELOG.md` 记录每次发布的变化；README、Lua 模块和独立 `VERSION` 文件不另行维护当前版本号。主题加载不依赖 Git 命令或 `.git` 目录，源码归档也能正常使用。

在 checkout 中可用 `git describe --tags --match 'v[0-9]*' --dirty --always` 查看当前修订。标签之后的提交和带有 `-dirty` 的工作区不等同于标签对应的发行版；没有可达标签时显示提交哈希。

已发布的标签不得移动、覆盖或删除。发布后发现问题，创建新的修订版本。

## 兼容性范围

以下内容作为本项目的公共接口与兼容性约定：

- `:colorscheme clay` 入口，以及 `require("clay")` 的 `setup()`、`load()`、`get_options()`、`get_palette()`。
- README 和 `doc/clay.txt` 中记录的配置项、取值、默认行为、色板键及 `overrides` 回调与替换语义。
- 文档公开的 `ClayMode`、`ClayAccent`、`ClayMuted` 高亮组，以及 `lualine.themes.clay` 集成入口。
- 最低支持的 Neovim 版本。

其他内部模块与实现细节不作为稳定接口。第三方插件自身的最低版本要求与主题最低版本分别记录；预览 parser 准备工具的要求也独立于主题。

## 递增规则

`0.x` 阶段采用以下项目约定；SemVer 本身不保证此阶段的接口稳定性：

| 变更 | 版本递增 |
| --- | --- |
| 兼容的错误修复，如修正错误高亮、修复已有插件适配 | 修订号：`0.1.0 → 0.1.1` |
| 新增兼容配置项、新的插件适配或功能 | 次版本号：`0.1.x → 0.2.0` |
| 删除或重命名配置项、改变接口语义、提高最低 Neovim 版本 | 次版本号，并在变更日志中标明不兼容变化和迁移方式 |
| 明显改变默认配色、点缀策略或透明行为 | 至少次版本号，单独说明视觉变化；若破坏兼容性，按不兼容变化处理 |
| 仅修改文档或开发工具 | 可随下一次发布合入；需要单独发布时递增修订号 |

公共接口准备好承担稳定兼容性承诺时发布 `1.0.0`。之后兼容修复递增修订号，兼容功能递增次版本号，不兼容修改递增主版本号；明显的默认视觉变化至少递增次版本号。次版本号或主版本号递增时，将其右侧数字归零。

现有 `feat:`、`fix:`、`docs:` 等提交前缀用于整理记录；版本号由完整变更内容决定。尤其要人工检查默认视觉变化与兼容性调整。

## 发布步骤

1. 检查待发布提交和已有标签，确定下一个版本号。将 `CHANGELOG.md` 的 `Unreleased` 内容整理到带版本号和实际发布日期的章节，保留空的 `Unreleased` 章节。首版汇总已有功能；后续版本记录相对上个版本的变化。配置变化同步更新 README 和帮助文档。
2. 在最低支持版与当前目标 Neovim 版本上运行核心测试；多语言测试使用兼容的 parser 和查询，真实插件检查使用已有 checkout。缺少依赖时按 README 准备，不能把 `SKIP` 记成通过。

   ```bash
   make test
   make test-release
   make test NVIM=/path/to/minimum-supported-nvim
   make test-languages
   CLAY_PLUGIN_ROOTS="$HOME/.local/share/nvim/lazy:/path/to/plugin-checkouts" make test-plugins
   CLAY_PLUGIN_ROOTS="$HOME/.local/share/nvim/lazy:/path/to/plugin-checkouts" make test-plugins NVIM=/path/to/minimum-supported-nvim
   ```

   替换示例路径；记录实际 Neovim 版本、通过数量、跳过项与未验证范围。明显配色变化还需用 `make preview` 人工查看。测试命令及 parser 准备要求见 [README.md](README.md#验证)。

3. 运行 `git diff --check`，审阅改动并提交全部预期的发布内容。创建标签前，`git status --short` 必须为空；确认变更日志的版本、日期与验证结果正确。
4. 在该提交上创建附注标签。以下以首版为例，后续发布替换 `release_tag`，不得复用已有标签：

   ```bash
   release_tag=v0.1.0
   git tag -a "$release_tag" -m "Release $release_tag"
   git cat-file -t "$release_tag"
   git rev-parse "$release_tag^{commit}" HEAD
   git describe --tags --exact-match --match 'v[0-9]*' HEAD
   git status --short
   ```

   对象类型应为 `tag`，两个提交哈希应相同，精确匹配结果应为预期标签，工作区仍应干净。

## 远程发布与安装

推送分支或提交 PR 时，`CI` 工作流执行发布工具检查、Neovim 0.10.4 / 0.12.5 核心与插件检查，以及 0.12.5 的九语言检查。`Release` 工作流在推送 `v*` 标签时复用同一套检查，全部通过后自动创建 GitHub Release，正文提取自 `CHANGELOG.md` 对应版本章节。

发布标签必须为 `vMAJOR.MINOR.PATCH` 格式的附注标签，指向默认分支已有的提交；变更日志需包含唯一、带日期且非空的版本章节。先推送提交，再推送标签：

```bash
git push origin master
git push origin "$release_tag"
```

在 Actions 中确认 `Release` 成功，并检查发布页。工作流失败后可重跑；已经发布的 Release 会保留原样，已有草稿则报错交由维护者处理。日常 CI 的手动运行入口仅执行检查，不发布版本。安装工作流之前的标签不会自动补发。

Actions 使用完整提交 SHA，Dependabot 每周检查 Action 更新。测试插件与 nvim-treesitter 的提交固定在 `.github/ci-dependencies.json`；Neovim 版本、Tree-sitter CLI 和 actionlint 的版本固定在工作流中。升级依赖时同步更新相应 SHA / 校验和并运行检查。CI 依赖下载失败会终止作业；0.10.4 上 nvim-lightbulb 的版本跳过单独报告，不计入通过项。

发布任务使用 GitHub 自动提供的 `GITHUB_TOKEN`，仅该任务拥有 `contents: write`，无需额外 PAT。发布说明可在本地预览：

```bash
python3 scripts/release_notes.py "$release_tag"
```

使用远程 Git 仓库安装时，lazy.nvim 支持 `tag = "v0.2.0"` 固定发行版，或 `version = "~0.2.0"` 选择 `0.2.x` 系列，具体见 [lazy.nvim 版本选项](https://lazy.folke.io/spec#spec-versioning)。`v0.1.0` 使用旧的 `claude.nvim` 名称与接口，`v0.2.0` 起改为 `clay.nvim`；迁移方式见变更日志。本地 `dir` 安装使用目录当前内容，应自行切换该 checkout；添加版本选项不会替本地目录切换发布标签。
