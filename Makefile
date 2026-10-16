NVIM ?= nvim

.PHONY: test preview
test:
	$(NVIM) --headless -u NONE -i NONE -n -l tests/run.lua

preview:
	$(NVIM) -u scripts/preview.lua -i NONE -n examples/demo.lua
