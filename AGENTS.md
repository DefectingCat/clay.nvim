# Repository Guidelines

## Project Structure & Module Organization

This repository develops **clay.nvim**, a Lua colorscheme for Neovim 0.10.4+.

- `colors/clay.lua` is the colorscheme entry point.
- `lua/clay/` contains configuration, palette, core highlights, and plugin integrations; grouped integrations live in `integrations/`.
- `lua/lualine/themes/clay.lua` provides the lualine theme.
- `tests/` contains core, language, and real-plugin checks; `scripts/` contains isolated preview tooling.
- `examples/demo.*` supplies language samples; `design/clay-grayscale.html` is the interactive design reference.
- `design/clay-design-system.md` is the design specification (palette roles, semantic mappings, ANSI table, porting rules). Palette changes must update it; `make test` checks its palette and terminal tables against the theme.
- `README.md` and `doc/clay.txt` document usage. Keep generated `.preview/site/`, `doc/tags`, and local reference checkouts under `others/` untracked.

## Build, Test, and Development Commands

There is no separate build step. Run commands from the repository root:

- `make test`: run core checks in headless Neovim; requires a Lua Tree-sitter parser.
- `make preview FILE=examples/demo.py`: open an isolated visual preview. Use `CLAY_ACCENT=minimal` or `CLAY_ACCENT=expressive` to compare accent modes.
- `make preview-parsers`: download and compile repository-local parsers. Requires Neovim 0.12+, nvim-treesitter, tree-sitter CLI 0.26.1+, a C compiler, curl, and tar; see README for configuration.
- `make test-languages`: verify real definition/call captures across nine languages after preparing parsers.
- `CLAY_PLUGIN_ROOTS="$HOME/.local/share/nvim/lazy" make test-plugins`: check existing plugin checkouts without installing them.
- `make docs`: regenerate the plugin table in `doc/clay.txt` from each integration module's `M.plugins`. Every new integration needs an entry (repository URL plus group-name patterns); `make test` fails on unowned groups or a stale table.

Override the executable with `NVIM=/path/to/nvim`.

## Coding Style & Naming Conventions

Use two-space Lua indentation, double-quoted strings, snake_case identifiers, and the existing `local M = {}` module pattern. Use `Clay` for custom highlight prefixes and `CLAY_` for environment variables. No repository-wide formatter or linter is configured; match adjacent code and run `git diff --check`.

Reuse palette keys instead of duplicating colors. Preserve grayscale diagnostics, Diff, and Git indicators, with Clay accents controlled by the selected mode. Integrations should define highlights without loading plugins or changing user settings.

## Testing Guidelines

Tests use Lua assertions inside isolated Neovim processes, without an external framework or coverage threshold. Add descriptive `test("behavior", function() ... end)` cases to `tests/run.lua`; extend language/plugin tables where appropriate. Cover reloads, transparency, accent modes, and overrides. Report `SKIP` separately from passes. Preview visual changes manually; validate compatibility changes on the minimum supported version.

## Commit & Pull Request Guidelines

Follow history’s prefixes: `feat:`, `test:`, `docs:`, `design:`, and `chore(release):`; mark breaking changes with `!`, as in `refactor!:`. Keep subjects imperative and specific.

PRs should describe behavior changes, link relevant issues, record tested Neovim versions and skipped checks, and include screenshots for visual changes. Update README/help for configuration changes and `CHANGELOG.md` for user-visible changes. Follow `RELEASING.md` for versioning.
