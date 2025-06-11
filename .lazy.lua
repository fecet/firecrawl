-- vim.g.VirtualEnvironment = "dl"
-- os.execute("eval $(pixi shell-hook --manifest-path=$HOME/codes/environment/pixi.toml)")
vim.env.http_proxy = "http://127.0.0.1:7890"
vim.env.https_proxy = "http://127.0.0.1:7890"

local sync_task = {
	name = "sync project",
	params = function()
		local hosts = { "cbaidu", "uhk", "wl", "cbaidu", "det", "frp" }
		return {
			target = {
				desc = "target host to sync",
				type = "enum",
				choices = hosts,
				default = hosts[1],
			},
		}
	end,
	builder = function(params)
		local cmds = { "rsync" }
		if params.target == "det" then
			vim.list_extend(cmds, { "-e", "ssh -F det/.det_ssh_config -o RequestTTY=False" })
		end
		-- local target_dest = vim.fs.joinpath("~/codes", vim.fs.basename(vim.env.PWD))
		local target_dest = "~/codes"
		local rootdir = string.gsub(LazyVim.root(), "Nutstore Files", "nutstore")
		vim.list_extend(cmds, {
			"-avP",
			-- vim.fs.find("./rsync_exclude"),
			"--delete",
		})
		vim.list_extend(
			cmds,
			vim.tbl_map(function(x)
				return "--exclude-from=" .. x
			end, vim.fs.find({ ".rsync_exclude" }, { type = "file", path = rootdir }))
		)
		vim.list_extend(cmds, { rootdir, params.target .. ":" .. target_dest })

		-- print(vim.inspect(cmds))
		return {
			cmd = cmds,
			cwd = rootdir,
		}
	end,
}
return {
	{
		"sustech-data/neopyter",
		opts = {
			-- remote_address = "0.0.0.0:9001",
			-- auto_attach = false,
		},
	},
	{
		"stevearc/overseer.nvim",
		opts = function(_, opts)
			local overseer = require("overseer")
			overseer.register_template(sync_task)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- opts.servers.protols.root_dir = function()
				-- return string.gsub(LazyVim.root(), "Nutstore Files", "nutstore")
				-- return vim.env.HOME .. "/codes/coder-job/proto/src"
			-- end
			-- opts.servers.clangd.init_option = { fallbackFlags = { "-std=c++20" } }
			-- opts.servers.clangd.settings = {
			-- 	clangd = { fallbackFlags = { "-std=c++20" } },
			-- }
			-- vim.list_extend(opts.servers.clangd.cmd, { "-std=c++20" })
		end,
	},
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	opts = function(_, opts)
	-- 		opts.diagnostics.virtual_text = false
	-- 	end,
	-- },
	{
		"sphamba/smear-cursor.nvim",
		enabled = false,
	},
	{
		"felpafel/inlay-hint.nvim",
		enabled = false,
	},
}
