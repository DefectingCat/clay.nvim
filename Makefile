NVIM ?= nvim

.PHONY: preview
preview:
	$(NVIM) -u scripts/preview.lua -i NONE -n examples/demo.lua
