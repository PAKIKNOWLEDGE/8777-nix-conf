# 验证说明

1. 确保已安装 `folke/which-key.nvim`（LazyVim 默认已包含）
2. 将本插件加入 `lazy.nvim` 列表并调用 `require("lazyvim_chinese").setup()`
3. 打开 Neovim，按 `<Space>u` 打开 UI 菜单，看到新增 `C` 项
4. 按 `<Space>uC`：
    - 第一次：启用汉化，WhichKey 分组显示中文
    - 再次按：禁用汉化，恢复英文

如需扩展中文映射，编辑 [translate.lua](../lua/lazyvim_chinese/translate.lua)。
