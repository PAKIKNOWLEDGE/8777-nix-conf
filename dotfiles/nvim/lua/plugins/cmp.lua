return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    -- VS Code 风格：自动弹出但不自动选中，回车不会误触
    opts.completion = opts.completion or {}
    opts.completion.completeopt = "menu,menuone,noselect"
    opts.preselect = require("cmp.types.cmp").PreselectMode.None
    return opts
  end,
}
