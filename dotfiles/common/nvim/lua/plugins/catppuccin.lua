return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte / frappe / macchiato / mocha
      transparent_background = false,
      term_colors = true,
      styles = { comments = { "italic" } },
      integrations = {
        alpha = true,
        cmp = true,
        gitsigns = true,
        telescope = true,
        which_key = true,
      },
    },
  },
}
