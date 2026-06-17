return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        variant = "moon", -- 也可以指定 "main", "moon", 或 "dawn"
        dark_variant = "moon", -- 或者 "moon" (更深一点)
        dim_inactive_cursor = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          legacy_compute = true,
        },

        styles = {
          bold = true,
          italic = true,
          transparency = false, -- 开启这个才能透明
        },
      })
    end,
  },

  -- 告诉 LazyVim 切换到这个主题
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
}
