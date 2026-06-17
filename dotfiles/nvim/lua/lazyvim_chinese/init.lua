local M = {}

local wk_ok, wk = pcall(require, "which-key")
local translate = require("lazyvim_chinese.translate")
local dashboard = require("lazyvim_chinese.dashboard")

local enabled = false

local function apply(trans_map, mode)
	if not wk_ok then
		return
	end
	local regs = {}
	for lhs, name in pairs(trans_map) do
		regs[lhs] = { name = name }
	end
	wk.register(regs, { mode = mode or "n" })
end

function M.enable()
	if enabled then
		return
	end
	enabled = true
	apply(translate.cn)
	apply(translate.cn_v, "v")
	dashboard.apply(true)
end

function M.disable()
	if not enabled then
		return
	end
	enabled = false
	apply(translate.en)
	apply(translate.en_v, "v")
	dashboard.apply(false)
end

function M.toggle()
	if enabled then
		M.disable()
	else
		M.enable()
	end
end

function M.setup()
	vim.keymap.set(
		"n",
		"<leader>uC",
		function()
			require("lazyvim_chinese").toggle()
		end,
		{ desc = "菜单汉化切换" }
	)

	M.enable()

	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = function()
			if enabled then
				apply(translate.cn)
				apply(translate.cn_v, "v")
				dashboard.apply(true)
			else
				apply(translate.en)
				apply(translate.en_v, "v")
				dashboard.apply(false)
			end
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "AlphaReady",
		callback = function()
			dashboard.apply(enabled)
		end,
	})
end

return M
