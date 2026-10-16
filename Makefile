NVIM ?= nvim
FILE ?= examples/demo.lua

.PHONY: test test-plugins test-languages preview preview-parsers
test:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/run.lua

test-plugins:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/plugins.lua

test-languages:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/languages.lua

preview:
	$(NVIM) -u scripts/preview.lua -i NONE -n -- "$(FILE)"

preview-parsers:
	$(NVIM) --headless -u NONE -i NONE -n -l scripts/prepare-preview.lua
