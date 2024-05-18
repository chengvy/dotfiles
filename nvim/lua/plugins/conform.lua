return {
    "conform.nvim",
    opts = {
        -- format_on_save = function() end,
        -- format_after_save = function() end,
        formatters_by_ft = {
            -- zsh = { "shfmt" },
        },
        formatters = {
            shfmt = {
                prepend_args = { "-i", "4", "-bn", "-ci" },
            },
        },
    },
}
