---@module "config.options.editor"

local g = vim.g
local o = vim.o

g.mapleader = " "

-- disable autoformat-on-save by default
g.autoformat = false

o.shiftwidth = 4
o.tabstop = 8
o.listchars = "tab:├─,trail:-,nbsp:+"
