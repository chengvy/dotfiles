return {
    "sindrets/diffview.nvim",
    cmd = {
        "DiffviewOpen",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewRefresh",
        "DiffviewFileHistory",
    },
    keys = {
        { "<leader>gdv", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
        { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
        { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview file history" },
    },
}
