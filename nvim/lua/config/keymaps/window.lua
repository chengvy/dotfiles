---@module "config.keymaps.window"

local map = vim.keymap.set

map({ "n", "v", "i" }, "<C-q>", function()
    if #vim.api.nvim_list_tabpages() > 1 then
        vim.cmd("tabclose")
    else
        vim.cmd("quitall")
    end
end, { desc = "Close tabpage" })

map({ "n", "v", "i" }, "<M-q>", function()
    local curr = vim.api.nvim_get_current_buf()
    local bufs = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
    local wins = vim.tbl_filter(function(w)
        return vim.bo[vim.api.nvim_win_get_buf(w)].buflisted
    end, vim.api.nvim_tabpage_list_wins(0))
    if not vim.bo[curr].buflisted or #wins > 1 then
        vim.cmd("quit")
    elseif #vim.api.nvim_list_tabpages() > 1 then
        vim.cmd("tabclose")
    elseif #bufs > 1 then
        require("lazyvim.util.ui").bufremove()
    else
        vim.cmd("quitall")
    end
end, { desc = "Close window or buffer" })

map({ "n", "v", "i" }, "<M-h>", "<Cmd>tabprev<CR>", { desc = "Prev tabpage" })
map({ "n", "v", "i" }, "<M-l>", "<Cmd>tabnext<CR>", { desc = "Next tabpage" })
