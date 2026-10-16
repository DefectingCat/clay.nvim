NVIM ?= nvim

.PHONY: test test-plugins preview
test:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/run.lua

test-plugins:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/plugins.lua

preview:
	$(NVIM) -u scripts/preview.lua -i NONE -n examples/demo.lua
