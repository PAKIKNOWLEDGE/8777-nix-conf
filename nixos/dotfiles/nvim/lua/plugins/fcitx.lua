return {
  "h-hg/fcitx.nvim",
  -- 只有在 Linux 且存在 fcitx5 时才启用
  enabled = vim.fn.has("linux") == 1,
  event = "InsertEnter", -- 提升性能：进入插入模式时再加载
  config = function()
    -- 该插件通常开箱即用，无需额外复杂配置
  end,
}
