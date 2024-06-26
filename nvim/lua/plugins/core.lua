return {
    {
        "LazyVim",
        opts = {
            colorscheme = "tokyonight-night",
            news = {
                lazyvim = true,
                neovim = true,
            },
        },
    },
    {
        "mini.animate",
        opts = {
            cursor = { enable = false },
            resize = { enable = false },
        },
    },
    {
        "bufferline.nvim",
        opts = {
            options = {
                separator_style = "slant",
                always_show_bufferline = true,
                hover = {
                    enabled = true,
                    delay = 100,
                    reveal = { "close" },
                },
            },
        },
    },
}
