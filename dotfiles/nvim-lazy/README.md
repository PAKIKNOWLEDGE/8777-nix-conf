# lazyvim.chinese

离线 LazyVim 菜单汉化插件，为常见 `<leader>` 分组提供中文名称，并在 `<leader>u` 菜单下增加 `C` 项用于一键执行/取消汉化。

## 功能

- 为常见 LazyVim 菜单分组提供中文名称（例如：`<leader>f` → 查找、`<leader>w` → 窗口等）
- 在 `<leader>u` 菜单下增加 `C` 切换项：开启/关闭汉化
- 完全离线，无需网络

## 安装

使用 `lazy.nvim`：

```lua
{
  "xuxiaowei-com-cn/lazyvim.chinese",
  config = function()
    require("lazyvim_chinese").setup()
  end,
}
```

或在任意位置调用：

```lua
require("lazyvim_chinese").setup()
```

开发时配置：`~/.config/nvim/lua/plugins/lazyvim.chinese.lua`

```lua
return {
  {
    dir = "/Users/xuxiaowei/IdeaProjects/lazyvim.chinese",
    lazy = false,
    config = function()
      require("lazyvim_chinese").setup()
    end,
  },
}
```

## 使用

- 按 `<Space>uC`（`<leader>uC`）开启/关闭汉化
- 开启后 WhichKey 的分组名称显示为中文，关闭后恢复英文

## 自定义

可在 `lua/lazyvim_chinese/translate.lua` 中按需增添/修改分组映射。
