---@module "config.keymaps.editor"

local map = vim.keymap.set

map({ "i" }, "jk", "<Esc>", { desc = "Enter normal mode" })
map({ "t" }, "jk", "<C-\\><C-n>", { desc = "Enter normal mode" })
