local logo = [[
  ███████╗██╗  ██╗██╗██╗     ██╗         ██╗███████╗███████╗██╗   ██╗███████╗
  ██╔════╝██║ ██╔╝██║██║     ██║         ██║██╔════╝██╔════╝██║   ██║██╔════╝
  ███████╗█████╔╝ ██║██║     ██║         ██║███████╗███████╗██║   ██║█████╗
  ╚════██║██╔═██╗ ██║██║     ██║         ██║╚════██║╚════██║██║   ██║██╔══╝
  ███████║██║  ██╗██║███████╗███████╗    ██║███████║███████║╚██████╔╝███████╗
  ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝    ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝
]]

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
      preset = {
        header = logo,
        keys = {
          { icon = " ", key = "f", desc = "查找文件 (Skill Issue)", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "新建文件 (Skill Issue)", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "查找文本 (Skill Issue)", action = ":lua Snacks.dashboard.pick('grep')" },
          { icon = " ", key = "r", desc = "最近文件 (Skill Issue)", action = ":lua Snacks.dashboard.pick('recent')" },
          { icon = " ", key = "p", desc = "项目管理 (Skill Issue)", action = ":lua Snacks.dashboard.pick('projects')" },
          { icon = " ", key = "c", desc = "配置文件 (Skill Issue)", action = ":edit $MYVIMRC" },
          { icon = " ", key = "s", desc = "恢复会话 (Skill Issue)", action = ":lua require('persistence').load()" },
          { icon = "󰒲 ", key = "l", desc = "插件管理 (Skill Issue)", action = ":Lazy" },
          { icon = " ", key = "q", desc = "退出程序 (Skill Issue)", action = ":qa" },
        },
      },
    },
  },
}
