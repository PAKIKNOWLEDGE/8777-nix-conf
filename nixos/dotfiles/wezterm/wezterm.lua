-- =============================================================
-- WezTerm 终端模拟器配置文件
-- WezTerm 官网：https://wezfurlong.org/wezterm/
-- 参考文档：https://wezfurlong.org/wezterm/config/files.html
-- =============================================================

-- 加载 WezTerm 的 Lua API。require("wezterm") 是使用所有配置函数的入口
local wezterm = require("wezterm")

-- Matugen 动态配色（由 matugen image xxx.jpg --config i3/config-i3.toml 生成）
local matugen = pcall(require, "matugen") and require("matugen") or nil

-- =============================================================
-- 辅助函数：从完整路径中提取文件名
-- 例如："/usr/bin/zsh" -> "zsh"，"C:\\Windows\\explorer.exe" -> "explorer.exe"
-- 这个函数用在后面标签栏显示当前进程名
-- =============================================================
function basename(s)
	-- string.gsub 用正则把 "任意内容/任意内容" 替换成 "第二个任意内容"
	-- (.*[/\\])(.*) 的意思是：匹配"前面一堆字符加斜杠或反斜杠 + 后面一堆字符"
	-- %2 表示取匹配到的第2组（即文件名部分）
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

-- =============================================================
-- 自定义标签栏（Tab）标题格式
-- 当你有多个标签页时，每个标签显示 "编号: 进程名"，例如 "1: zsh"
-- =============================================================
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- 当前标签页中活跃的窗格（Pane）
	-- 一个标签页可以拆分成多个窗格，active_pane 是当前光标所在的窗格
	local pane = tab.active_pane

	-- 如果只有一个标签页，就不显示编号
	local index = ""
	if #tabs > 1 then
		-- Lua 字符串格式化，%d 是数字占位符
		-- tab.tab_index 从0开始，+1 变成从1开始，更符合人类习惯
		index = string.format("%d: ", tab.tab_index + 1)
	end

	-- 获取当前窗格前台进程的名字（只取文件名部分，不要路径）
	local process = basename(pane.foreground_process_name)

	-- 返回一个格式化后的文本块，WezTerm 会把它渲染成标签标题
	return { {
		Text = " " .. index .. process .. " ",
	} }
end)

-- =============================================================
-- 配置表从这里开始。所有配置项都是 key = value 的形式
-- =============================================================
return {

	-- -------------------- 字体设置 --------------------
	font = wezterm.font_with_fallback({
		"JetBrainsMonoNL Nerd Font Mono",
		"Noto Sans CJK SC"
	}),

	-- -------------------- 键盘快捷键 --------------------
	-- Leader 键（引导键）：先按 Ctrl + a，松开，再按下一个键触发某个动作
	-- 用来避免快捷键冲突，相当于给快捷键加了一个"前缀"
	leader = { key = "a", mods = "CTRL" },

	keys = {
		-- -------- 窗格（Pane）分屏 --------
		-- 水平分屏（左右分屏）：Alt + v
		-- SplitVertical 实际上是把当前窗格垂直拆分成左右两个
		{
			key = "v",
			mods = "ALT",
			action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
		},
		-- 垂直分屏（上下分屏）：Alt + h
		-- SplitHorizontal 实际上是把当前窗格水平拆分成上下两个
		{
			key = "h",
			mods = "ALT",
			action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
		},

		-- 标签页切换器（图形化选择标签）：Leader + w
		{ key = "w", mods = "LEADER", action = "ShowTabNavigator" },

		-- -------- 标签页（Tab）切换 --------
		-- 注意：macOS 上 Super 对应 Command 键，Windows/Linux 上对应 Win 键
		-- Super + *（上翻页键旁边的*号）切换到上一个标签页
		{ key = "*", mods = "SUPER", action = wezterm.action({ ActivateTabRelative = -1 }) },
		-- Super + / 切换到下一个标签页
		{ key = "/", mods = "SUPER", action = wezterm.action({ ActivateTabRelative = 1 }) },
		-- Super + Shift + / 把当前标签页向左移动（调换标签顺序）
		{ key = "/", mods = "SUPER|SHIFT", action = wezterm.action({ MoveTabRelative = -1 }) },
		-- Super + Shift + * 把当前标签页向右移动
		{ key = "*", mods = "SUPER|SHIFT", action = wezterm.action({ MoveTabRelative = 1 }) },

		-- -------- 滚动翻页（在回滚缓冲区中）--------
		-- Super + u 向上翻一页（Page Up）
		{ key = "u", mods = "SUPER", action = wezterm.action({ ScrollByPage = -1 }) },
		-- Super + d 向下翻一页（Page Down）
		{ key = "d", mods = "SUPER", action = wezterm.action({ ScrollByPage = 1 }) },

		-- -------- 在窗格（Pane）之间切换焦点 --------
		-- Super + l / h / k / j （Vim 方向键风格）切换当前活跃窗格
		{ key = "l", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
		{ key = "h", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "k", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "u", mods = "SUPER", action = wezterm.action({ ScrollByPage = -1 }) },
		{ key = "d", mods = "SUPER", action = wezterm.action({ ScrollByPage = 1 }) },
		{ key = "l", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
		{ key = "h", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "k", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		-- Super + j 切换到下方窗格
		{ key = "j", mods = "SUPER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
		-- 注意上方有重复的 u / d / l / h / k 快捷键（覆盖了上面的翻页），后定义的会覆盖先定义的

		-- -------- 字体大小控制 --------
		-- Super + 0 重置字体大小到默认值
		{ key = "0", mods = "SUPER", action = "ResetFontSize" },
		-- Super + - 缩小字体
		{ key = "-", mods = "SUPER", action = "DecreaseFontSize" },
		-- Super + = 放大字体（+ 号通常需要按 Shift）
		{ key = "+", mods = "SUPER", action = "IncreaseFontSize" },

		-- -------- 窗格操作 --------
		-- Super + z 最大化/还原当前窗格（类似 Vim 的 Zoom）
		{ key = "z", mods = "SUPER", action = "TogglePaneZoomState" },
		-- Super + t 新建标签页（在当前域中）
		{ key = "t", mods = "SUPER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		-- Super + Shift + w 关闭当前标签页（有确认弹窗）
		{ key = "W", mods = "SUPER", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
		-- Super + w 关闭当前窗格（有确认弹窗）
		{ key = "w", mods = "SUPER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },

		-- -------- 其他功能 --------
		-- Leader + 空格 快速选择屏幕上的文字（类似 tmux 的复制模式）
		{ key = " ", mods = "LEADER", action = "QuickSelect" },
		-- Super + f 切换全屏
		{ key = "f", mods = "SUPER", action = "ToggleFullScreen" },

		-- -------- 调整窗格大小 --------
		-- Super + Alt + h/j/k/l（Vim 方向键风格）调整窗格边界
		-- 最后一个数字 5 是每次调整的步长（单位：单元格）
		{ key = "h", mods = "SUPER|ALT", action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
		{ key = "j", mods = "SUPER|ALT", action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
		{ key = "k", mods = "SUPER|ALT", action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
		{ key = "l", mods = "SUPER|ALT", action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
	},

	-- -------------------- 渲染引擎 --------------------
	-- OpenGL 渲染（性能好，GPU加速）。可选 "WebGpu" 或 "Software"
	front_end = "OpenGL",

	-- 字体大小（单位：点）
	font_size = 14,

	-- -------------------- 色彩主题 --------------------
	-- 优先使用 Matugen 动态配色，没有则用 Catppuccin Mocha 兜底
	color_scheme = matugen and nil or "Catppuccin Mocha",
	colors = matugen,

	-- -------------------- 窗口内边距 --------------------
	-- 窗口边缘留出空白，文字不贴边，看起来更舒服
	window_padding = {
		left = 10,
		right = 10,
		top = 10,
		bottom = 10,
	},

	-- -------------------- 透明度 --------------------
	-- 窗口背景透明度 0.88（1.0 完全不透明，0.0 完全透明）
	window_background_opacity = 0.6,

	-- -------------------- 标签栏设置 --------------------
	enable_tab_bar = true, -- 启用标签栏
	hide_tab_bar_if_only_one_tab = true, -- 如果只有一个标签页，自动隐藏标签栏（节省空间）
	tab_bar_at_bottom = true, -- 标签栏放在窗口底部（类似 VSCode 的风格）
	use_fancy_tab_bar = false, -- 不使用花哨的标签栏样式（用简化版）
	tab_max_width = 20, -- 每个标签标题最大宽度（字符数）

	-- -------------------- 回滚缓冲区 --------------------
	-- 保留 5000 行历史输出（方便往上翻看之前的日志/输出）
	scrollback_lines = 5000,

	-- -------------------- 图形/性能特性 --------------------
	enable_kitty_graphics = true, -- 启用 Kitty 图形协议（支持在终端显示图片）
	enable_scroll_bar = false, -- 不显示滚动条（用键盘快捷键翻页）
	warn_about_missing_glyphs = false, -- 不警告缺失的字形图标（减少烦人提示）
	adjust_window_size_when_changing_font_size = true, -- 调整字体大小时自动调整窗口大小

	-- -------------------- 更新检查 --------------------
	check_for_updates = false, -- 不自动检查更新（手动更新即可）

	-- -------------------- 颜色 / 选中文字设置 --------------------
	bold_brightens_ansi_colors = true, -- 粗体文字使用更亮的颜色（增强可读性）

	-- 双击选词时的分隔符（即这些字符不会被选中）
	selection_word_boundary = " \t\n{}[]()\"'`,;:=",

	-- -------------------- 声音 / 输入法 --------------------
	audible_bell = "Disabled", -- 关闭终端响铃（Bell）
	use_ime = true, -- 启用输入法（输入中文等非英文字符时需要）

	-- -------------------- 配置热重载 --------------------
	-- 修改这个文件后自动重新加载配置（不用重启 WezTerm）
	automatically_reload_config = true,

	-- -------------------- Linux/Wayland 支持 --------------------
	enable_wayland = true, -- 在 Wayland 显示服务器下启用（Linux 用户）

	-- -------------------- 鼠标行为 --------------------
	-- 点击一个窗格时，不触发鼠标事件的"吞咽"模式
	-- 防止因切换焦点而误触窗格内的应用（比如终端里的 TUI 程序）
	swallow_mouse_click_on_pane_focus = true,

	-- -------------------- 默认启动程序 --------------------
	default_prog = { "fish" }, -- 默认 Shell（NixOS 上不要写死 /bin/fish，让 PATH 解析）

	-- -------------------- 默认工作目录 --------------------
	default_cwd = "/home/jose", -- 新标签页/窗格默认进入的目录（建议改成你自己的家目录）

	-- -------------------- 终端类型 --------------------
	term = "xterm-256color", -- 告诉 SSH 等程序终端支持 256 色和大部分现代终端特性

	-- -------------------- 光标样式 --------------------
	default_cursor_style = "BlinkingBlock", -- 闪烁的方块光标
	-- 其他选项: "SteadyBlock"（不闪烁的方块）、"BlinkingUnderline"、"SteadyUnderline"、"BlinkingBar"、"SteadyBar"

	-- -------------------- 文字背景透明度 --------------------
	text_background_opacity = 1.0, -- 文字背景完全不透明（1.0），文字本身不受窗口透明度影响

	-- -------------------- 退出行为 --------------------
	exit_behavior = "Close", -- 当 Shell 退出时自动关闭窗格/标签页
	-- 其他选项: "Hold"（保持窗口不关，方便看退出信息）

	-- -------------------- 超链接识别规则 --------------------
	-- 让终端里的 URL、邮箱地址等变成可点击的超链接（按住 Ctrl/Cmd 点击）
	hyperlink_rules = {

		-- 识别常规 URL（如 https://google.com）
		{
			regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
			format = "$0", -- $0 表示原样打开匹配到的文本
		},

		-- 识别邮箱地址（如 user@example.com），点击后用默认邮件客户端打开
		{
			regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
			format = "mailto:$0",
		},

		-- 识别 file:// 开头的本地文件路径
		{
			regex = [[\bfile://\S*\b]],
			format = "$0",
		},

		-- 识别 IP 地址形式的 URL（如 http://127.0.0.1:8000 本地开发服务器）
		{
			regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
			format = "$0",
		},

		-- 识别 GitHub 风格的 "用户名/仓库名" 格式（如 "wez/wezterm"）
		-- 点击后自动拼接成 GitHub 链接打开
		{
			regex = [["([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)"]],
			format = "https://www.github.com/$1/$3",
		},
	},
}
