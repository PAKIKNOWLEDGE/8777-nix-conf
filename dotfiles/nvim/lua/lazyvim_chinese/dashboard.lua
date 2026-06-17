local M = {}

local en_to_cn = {
	["Find File"] = "查找文件",
	["New File"] = "新建文件",
	["Projects"] = "项目",
	["Find Text"] = "查找文本",
	["Recent Files"] = "最近文件",
	["Config"] = "配置",
	["Restore Session"] = "恢复会话",
	["Lazy Extras"] = "Lazy 扩展",
	["Lazy"] = "Lazy",
	["Quit"] = "退出",
}

local cn_to_en = {}
for k, v in pairs(en_to_cn) do
	cn_to_en[v] = k
end

local function apply_alpha(map)
	local ok, dashboard = pcall(require, "alpha.themes.dashboard")
	if not ok then
		return false
	end
	local buttons = dashboard.section and dashboard.section.buttons and dashboard.section.buttons.val or {}
	for _, btn in ipairs(buttons) do
		local val = btn.val
		if map[val] then
			btn.val = map[val]
		end
	end
	local ok2, alpha = pcall(require, "alpha")
	if ok2 and alpha.redraw then
		alpha.redraw()
	else
		local ok3, dash = pcall(require, "alpha")
		if ok3 and dash.setup and dashboard.opts then
			dash.setup(dashboard.opts)
		end
	end
	return true
end

local function apply_snacks(map)
	local ok, snacks = pcall(require, "snacks")
	if not ok or not snacks.config or not snacks.config.dashboard or not snacks.config.dashboard.preset then
		return false
	end
	local keys = snacks.config.dashboard.preset.keys or {}
	for _, item in ipairs(keys) do
		local d = item.desc
		if d and map[d] then
			item.desc = map[d]
		end
	end
	local ok2, sd = pcall(require, "snacks.dashboard")
	if ok2 then
		pcall(function()
			sd()
		end)
	end
	return true
end

function M.apply(cn)
	local map = cn and en_to_cn or cn_to_en
	local done = apply_snacks(map)
	if not done then
		apply_alpha(map)
	end
end

return M
