--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Indentation: 2-space tabs everywhere
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Shim for Neovim 0.12.1: make_position_params now requires explicit position_encoding.
-- Plugins like Telescope haven't been updated yet, so provide the encoding automatically.
local _orig_make_position_params = vim.lsp.util.make_position_params
vim.lsp.util.make_position_params = function(winnr, encoding)
	if not encoding then
		local buf = vim.api.nvim_win_get_buf(winnr or 0)
		local clients = vim.lsp.get_clients({ bufnr = buf })
		encoding = clients[1] and clients[1].offset_encoding or "utf-16"
	end
	return _orig_make_position_params(winnr, encoding)
end

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	-- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

	-- NOTE: Plugins can also be added by using a table,
	-- with the first argument being the link and the following
	-- keys can be used to configure plugin behavior/loading/etc.
	--
	-- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
	--

	-- Alternatively, use `config = function() ... end` for full control over the configuration.
	-- If you prefer to call `setup` explicitly, use:
	--    {
	--        'lewis6991/gitsigns.nvim',
	--        config = function()
	--            require('gitsigns').setup({
	--                -- Your gitsigns configuration here
	--            })
	--        end,
	--    }
	--
	-- Here is a more advanced example where we pass configuration
	-- options to `gitsigns.nvim`.
	--
	-- See `:help gitsigns` to understand what the configuration keys do
  {
    "karb94/neoscroll.nvim",
    opts = {},
    config = function()
      require('neoscroll').setup({
      mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
        '<C-u>', '<C-d>',
        '<C-b>', '<C-f>',
        '<C-y>', '<C-e>',
        'zt', 'zz', 'zb',
      },
      hide_cursor = true,          -- Hide cursor while scrolling
      stop_eof = true,             -- Stop at <EOF> when scrolling downwards
      respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      duration_multiplier = 1.0,   -- Global duration multiplier
      easing = 'linear',           -- Default easing function
      pre_hook = nil,              -- Function to run before the scrolling animation starts
      post_hook = nil,             -- Function to run after the scrolling animation ends
      performance_mode = false,    -- Disable "Performance Mode" on all buffers.
      ignored_events = {           -- Events ignored while scrolling
          'WinScrolled', 'CursorMoved'
      },
    })
  end
  },

  -- {
  --   "yetone/avante.nvim",
  --   build = function()
  --     -- conditionally use the correct build system for the current OS
  --     if vim.fn.has("win32") == 1 then
  --       return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  --     else
  --       return "make"
  --     end
  --   end,
  --   event = "VeryLazy",
  --   version = false, -- Never set this value to "*"! Never!
  --   ---@module 'avante'
  --   ---@type avante.Config
  --   opts = {
  --     -- add any opts here
  --     -- for example
  --     provider = "gemini",
  --     providers = {
  --       openai = {
  --         endpoint = "https://api.openai.com/v1",
  --         model = "gpt-4o",
  --         timeout = 30000, -- Timeout in milliseconds
  --         extra_request_body = {
  --           temperature = 0.75,
  --           max_tokens = 8192,
  --         },
  --       },
  --       claude = {
  --         endpoint = "https://api.anthropic.com",
  --         model = "claude-sonnet-4-20250514",
  --         timeout = 30000, -- Timeout in milliseconds
  --           extra_request_body = {
  --             temperature = 0.75,
  --             max_tokens = 20480,
  --           },
  --       },
  --       moonshot = {
  --         endpoint = "https://api.moonshot.ai/v1",
  --         model = "kimi-k2-0711-preview",
  --         timeout = 30000, -- Timeout in milliseconds
  --         extra_request_body = {
  --           temperature = 0.75,
  --           max_tokens = 32768,
  --         },
  --       },
  --       gemini = {
  --         endpoint = "https://generativelanguage.googleapis.com/v1beta/models/",
  --         model = "gemini-2.0-flash:generateContent",
  --         timeout = 30000, -- Timeout in milliseconds
  --         extra_request_body = {
  --           temperature = 0.75,
  --           max_tokens = 32768,
  --         },
  --       },
  --     },
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     "echasnovski/mini.pick", -- for file_selector provider mini.pick
  --     "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
  --     "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     "stevearc/dressing.nvim", -- for input provider dressing
  --     "folke/snacks.nvim", -- for input provider snacks
  --     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       'MeanderingProgrammer/render-markdown.nvim',
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  -- },
  -- amongst your other plugins
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup{}
    end
  },
	{ -- AI inline completion (Windsurf/Codeium backend, free tier). Run `:NeoCodeium auth` once.
		"monkoose/neocodeium",
		event = "InsertEnter",
		cmd = "NeoCodeium", -- so `:NeoCodeium auth` works before entering insert mode
		config = function()
			local neocodeium = require("neocodeium")
			local has_cmp, cmp = pcall(require, "cmp")

			neocodeium.setup({
				-- Don't render ghost text while the nvim-cmp menu is open.
				filter = function()
					return not (has_cmp and cmp.visible())
				end,
			})

			-- Clear a pending suggestion when the cmp menu appears.
			if has_cmp then
				cmp.event:on("menu_opened", function()
					neocodeium.clear()
				end)
			end

			-- <Tab> accepts the suggestion, otherwise inserts a literal tab.
			vim.keymap.set("i", "<Tab>", function()
				if neocodeium.visible() then
					neocodeium.accept()
				else
					vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
				end
			end, { desc = "Accept AI suggestion or insert tab" })

			vim.keymap.set("i", "<A-w>", neocodeium.accept_word, { desc = "Accept AI suggestion word" })
			vim.keymap.set("i", "<A-a>", neocodeium.accept_line, { desc = "Accept AI suggestion line" })
			vim.keymap.set("i", "<A-]>", function()
				neocodeium.cycle_or_complete()
			end, { desc = "Next AI suggestion" })
			vim.keymap.set("i", "<A-[>", function()
				neocodeium.cycle_or_complete(-1)
			end, { desc = "Previous AI suggestion" })
			vim.keymap.set("i", "<A-c>", neocodeium.clear, { desc = "Clear AI suggestion" })
		end,
	},
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
      on_attach = function(bufnr)
        vim.keymap.set(
					"n",
					"<leader>hp",
					require("gitsigns").preview_hunk,
					{ buffer = bufnr, desc = "Preview git hunk" }
				)
				vim.keymap.set(
					"n",
					"<leader>hb",
					require("gitsigns").blame_line,
					{ buffer = bufnr, desc = "Blame current line" }
				)
				vim.keymap.set(
					"n",
					"<leader>hB",
					require("gitsigns").blame,
					{ buffer = bufnr, desc = "Blame current buffer" }
				)
      end,
		},
	},
	{ "HiPhish/debugpy.nvim" },
	{
		"windwp/nvim-ts-autotag",
		ft = { "html", "xml", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{ "nvim-tree/nvim-tree.lua" },
	{
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup()
    end
  },
	{
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end
  },
	{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	{ "mfussenegger/nvim-dap" },
	{ "mfussenegger/nvim-dap-python" },
	{ -- Go debugger: registers the delve adapter + Go debug/test configurations
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" },
	},
  {
    'xemptuous/sqlua.nvim',
    lazy = true,
    cmd = 'SQLua',
    config = function() require('sqlua').setup() end
  },
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		-- Global shortcuts to open/toggle the UI (lazy-load the plugin on press).
		keys = {
			{ "<leader>Du", "<cmd>DBUIToggle<CR>", desc = "Database: Toggle UI" },
			{ "<leader>Df", "<cmd>DBUIFindBuffer<CR>", desc = "Database: Find buffer" },
			{ "<leader>Da", "<cmd>DBUIAddConnection<CR>", desc = "Database: Add connection" },
			{ "<leader>Dq", "<cmd>DBUILastQueryInfo<CR>", desc = "Database: Last query info" },
		},
		init = function()
			-- DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_execute_on_save = 0 -- don't run the whole file automatically on :w

			-- SQL buffer setup. Registered in init() so it always applies,
			-- even before :DBUI has been run in the session.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "sql", "mysql", "plsql" },
				callback = function(ev)
					-- nvim-cmp completion source for this buffer.
					-- NOTE: vim-dadbod-completion only returns items when the
					-- buffer is connected to a database (a DBUI query buffer, or
					-- `b:db` / $DATABASE_URL set). In a plain scratch .sql file
					-- with no connection it returns nothing, not even keywords.
					local ok, cmp = pcall(require, "cmp")
					if ok then
						cmp.setup.buffer({
							sources = {
								{ name = "vim-dadbod-completion" },
								{ name = "luasnip" },
								{ name = "path" },
							},
						})
					end

					-- Execute / save the query under the cursor (or selection in
					-- visual mode). These <Plug> maps come from vim-dadbod-ui.
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
					end
					map({ "n", "x" }, "<leader>De", "<Plug>(DBUI_ExecuteQuery)", "Database: Execute query")
					map("n", "<leader>Ds", "<Plug>(DBUI_SaveQuery)", "Database: Save query")
					map("n", "<leader>Dp", "<Plug>(DBUI_EditBindParameters)", "Database: Edit bind parameters")
				end,
			})
		end,
	},
	{
		"nvim-neotest/nvim-nio",
		config = function()
			-- Optional: add any specific configuration for nvim-nio here
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		requires = { "mfussenegger/nvim-dap" },
	},
	{ "m4xshen/autoclose.nvim" },
	{ "windwp/nvim-autopairs" },
	{ -- Multiple cursors that behave like real cursors (insert/visual modes, undo, macros)
		"jake-stewart/multicursor.nvim",
		branch = "1.0",
		event = "VeryLazy",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			local set = vim.keymap.set
			local nx = { "n", "x" }

			-- Core, VSCode-flavoured bindings.
			-- NOTE: <C-d> is taken by neoscroll, so "add cursor at next match" is <C-n>.
			set(nx, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "Multicursor: add at next match" })
			set(nx, "<C-Up>", function() mc.lineAddCursor(-1) end, { desc = "Multicursor: add cursor above" })
			set(nx, "<C-Down>", function() mc.lineAddCursor(1) end, { desc = "Multicursor: add cursor below" })
			set(nx, "<C-q>", mc.toggleCursor, { desc = "Multicursor: disable/enable cursors" })

			-- Add and remove cursors with ctrl + left click.
			set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Multicursor: toggle cursor at mouse" })
			set("n", "<C-LeftDrag>", mc.handleMouseDrag, { desc = "Multicursor: drag cursors" })
			set("n", "<C-LeftRelease>", mc.handleMouseRelease, { desc = "Multicursor: release cursors" })

			-- Everything else lives under <leader>m to stay out of the way.
			set(nx, "<leader>mn", function() mc.matchAddCursor(1) end, { desc = "Add cursor at [n]ext match" })
			set(nx, "<leader>mN", function() mc.matchAddCursor(-1) end, { desc = "Add cursor at previous match" })
			set(nx, "<leader>ms", function() mc.matchSkipCursor(1) end, { desc = "[S]kip next match" })
			set(nx, "<leader>mS", function() mc.matchSkipCursor(-1) end, { desc = "Skip previous match" })
			set(nx, "<leader>ma", mc.matchAllAddCursors, { desc = "Add cursor to [a]ll matches in buffer" })
			set(nx, "<leader>mj", function() mc.lineAddCursor(1) end, { desc = "Add cursor below" })
			set(nx, "<leader>mk", function() mc.lineAddCursor(-1) end, { desc = "Add cursor above" })
			set(nx, "<leader>mJ", function() mc.lineSkipCursor(1) end, { desc = "Skip line below" })
			set(nx, "<leader>mK", function() mc.lineSkipCursor(-1) end, { desc = "Skip line above" })
			set(nx, "<leader>mo", mc.addCursorOperator, { desc = "Add cursor per line of m[o]tion (e.g. mmip)" })
			set(nx, "<leader>m=", mc.alignCursors, { desc = "Align cursor columns" })
			set(nx, "<leader>mq", mc.duplicateCursors, { desc = "Duplicate cursors, disable originals" })
			set("n", "<leader>mr", mc.restoreCursors, { desc = "[R]estore last cleared cursors" })
			set("n", "<leader>m/", mc.searchAllAddCursors, { desc = "Add cursor to every search result" })
			set("x", "<leader>mv", mc.splitCursors, { desc = "Split selection by regex" })
			set("x", "<leader>mm", mc.matchCursors, { desc = "[M]atch cursors in selection by regex" })
			set("x", "<leader>mt", function() mc.transposeCursors(1) end, { desc = "[T]ranspose selections forward" })
			set("x", "<leader>mT", function() mc.transposeCursors(-1) end, { desc = "Transpose selections backward" })

			-- Layer mappings only apply while multiple cursors exist, so they can
			-- safely shadow existing keys (like <Esc> for :nohlsearch).
			mc.addKeymapLayer(function(layerSet)
				layerSet(nx, "<Left>", mc.prevCursor, { desc = "Multicursor: previous cursor" })
				layerSet(nx, "<Right>", mc.nextCursor, { desc = "Multicursor: next cursor" })
				layerSet(nx, "<leader>mx", mc.deleteCursor, { desc = "Delete main cursor" })
				layerSet("n", "<Esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end, { desc = "Multicursor: enable/collapse cursors" })
			end)

			local hl = vim.api.nvim_set_hl
			hl(0, "MultiCursorCursor", { reverse = true })
			hl(0, "MultiCursorVisual", { link = "Visual" })
			hl(0, "MultiCursorSign", { link = "SignColumn" })
			hl(0, "MultiCursorMatchPreview", { link = "Search" })
			hl(0, "MultiCursorDisabledCursor", { reverse = true })
			hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
			hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
		end,
	},
	{
		"stevearc/oil.nvim",
		opts = {},
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
	--
	-- This is often very useful to both group configuration, as well as handle
	-- lazy loading plugins that don't need to be loaded immediately at startup.
	--
	-- For example, in the following configuration, we use:
	--  event = 'VimEnter'
	--
	-- which loads which-key before all the UI elements are loaded. Events can be
	-- normal autocommands events (`:help autocmd-events`).
	--
	-- Then, because we use the `opts` key (recommended), the configuration runs
	-- after the plugin has been loaded as `require(MODULE).setup(opts)`.

	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			-- delay between pressing a key and opening which-key (milliseconds)
			-- this setting is independent of vim.opt.timeoutlen
			delay = 0,
			icons = {
				-- set icon mappings to true if you have a Nerd Font
				mappings = vim.g.have_nerd_font,
				-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
				-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>D", group = "[D]atabase", mode = { "n", "x" } },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "<leader>m", group = "[M]ulticursor", mode = { "n", "x" } },
			},
		},
	},

	-- NOTE: Plugins can specify dependencies.
	--
	-- The dependencies are proper plugin specifications as well - anything
	-- you do for a plugin at the top level, you can do for a dependency.
	--
	-- Use the `dependencies` key to specify the dependencies of a particular plugin
	{ -- Fuzzy Finder (files, lsp, etc)
		"ibhagwan/fzf-lua",
		event = "VimEnter",
		dependencies = {
			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- fzf-lua replaces telescope here; it does not depend on the
			-- removed `nvim-treesitter.parsers` API, so it works on nvim 0.12
			-- with nvim-treesitter `main`.
			require("fzf-lua").setup({
				"default",
				-- Use the dropdown-style winopts for the buffer-lines picker (mapped to <leader>/).
				-- Other defaults are fine for kickstart.
			})
			-- Route vim.ui.select through fzf-lua (replaces telescope-ui-select).
			require("fzf-lua").register_ui_select()

			-- DEBUGGER: resolve an interpreter per machine. A hardcoded absolute
			-- venv path breaks on every other checkout (and on this one once the
			-- project moves), so prefer the active venv, then a project-local one.
			local function debugpy_python()
				local candidates = {}
				if vim.env.VIRTUAL_ENV then
					table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/python")
				end
				table.insert(candidates, vim.fn.getcwd() .. "/.venv/bin/python")
				table.insert(candidates, vim.fn.expand("~/Work/audeering/.venv/bin/python"))
				for _, c in ipairs(candidates) do
					if vim.fn.executable(c) == 1 then
						return c
					end
				end
				return "python3"
			end
			require("dap-python").setup(debugpy_python())
			table.insert(require("dap").configurations.python, {
				type = "python",
				request = "launch",
				name = "launch File",
				program = "${file}",
				console = "externalTerminal",
				-- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
			})
			require("dap-go").setup()
			local dapui = require("dapui")
      dapui.setup()

      local dap = require("dap")

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
          -- adjust the command path if `codelldb` is not in your PATH
        },
      }

      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--quiet", "--interpreter=dap" }, -- Add these arguments
        name = "gdb",
      }

      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "gdb",
          request = "launch",
          program = function()
            -- Prompts for the path to the executable to debug
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- Godot ships a DAP server inside the editor on port 6006; it listens only
      -- while the Godot editor is open on the project. (Not to be confused with
      -- Network > Debug > Remote Port / 6007, which is the game->editor channel.)
      dap.adapters.godot = {
        type = "server",
        host = "127.0.0.1",
        port = 6006,
      }

      dap.configurations.gdscript = {
        {
          name = "Launch project",
          type = "godot",
          request = "launch",
          project = "${workspaceFolder}",
        },
        {
          name = "Launch current scene",
          type = "godot",
          request = "launch",
          project = "${workspaceFolder}",
          scene = "current",
        },
      }

			vim.api.nvim_set_keymap(
				"n",
				"<F5>",
				'<cmd>lua require("dap").continue()<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<F10>",
				'<cmd>lua require("dap").step_over()<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<F11>",
				'<cmd>lua require("dap").step_into()<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<F12>",
				'<cmd>lua require("dap").step_out()<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>b",
				'<cmd>lua require("dap").toggle_breakpoint()<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>B",
				'<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>lp",
				'<cmd>lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dr",
				'<cmd>lua require("dap").repl.open()<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>dl",
				'<cmd>lua require("dap").run_last()<CR>',
				{ noremap = true, silent = true }
			)
			vim.keymap.set("n", "<leader>dt", '<cmd>lua require("dapui").toggle()<CR>', { silent = true })
			vim.keymap.set("n", "<leader>dgt", function() require("dap-go").debug_test() end, { desc = "Debug nearest Go test" })
			vim.keymap.set("n", "<leader>dgl", function() require("dap-go").debug_last_test() end, { desc = "Debug last Go test" })

			require("oil").setup()
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

			-- See `:help fzf-lua` and `:Fzflua` for the full list of pickers.
			local fzf = require("fzf-lua")
			vim.keymap.set("n", "<leader>sh", fzf.helptags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", fzf.files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", fzf.builtin, { desc = "[S]earch fzf-lua pickers" })
			vim.keymap.set("n", "<leader>sw", fzf.grep_cword, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", fzf.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", fzf.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "[ ] Find existing buffers" })

			-- Fuzzy search lines of the current buffer.
			vim.keymap.set("n", "<leader>/", function()
				fzf.blines({ winopts = { preview = { hidden = true } } })
			end, { desc = "[/] Fuzzily search in current buffer" })

			-- Live grep restricted to the files of currently open buffers.
			vim.keymap.set("n", "<leader>s/", function()
				local paths = {}
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
						local name = vim.api.nvim_buf_get_name(buf)
						if name ~= "" and vim.fn.filereadable(name) == 1 then
							table.insert(paths, vim.fn.fnamemodify(name, ":."))
						end
					end
				end
				fzf.live_grep({ search_paths = paths, prompt = "Open Files> " })
			end, { desc = "[S]earch [/] in Open Files" })

			-- Shortcut for searching your Neovim configuration files
			vim.keymap.set("n", "<leader>sn", function()
				fzf.files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},
	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Brief aside: **What is LSP?**
			--
			-- LSP is an initialism you've probably heard, but might not understand what it is.
			--
			-- LSP stands for Language Server Protocol. It's a protocol that helps editors
			-- and language tooling communicate in a standardized fashion.
			--
			-- In general, you have a "server" which is some tool built to understand a particular
			-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
			-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
			-- processes that communicate with some "client" - in this case, Neovim!
			--
			-- LSP provides Neovim with features like:
			--  - Go to definition
			--  - Find references
			--  - Autocompletion
			--  - Symbol Search
			--  - and more!
			--
			-- Thus, Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.
			--
			-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
			-- and elegantly composed help section, `:help lsp-vs-treesitter`

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", require("fzf-lua").lsp_typedefs, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", require("fzf-lua").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map(
						"<leader>ws",
						require("fzf-lua").lsp_live_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					-- Hover documentation for the symbol under the cursor.
					map("K", vim.lsp.buf.hover, "Hover Documentation")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				clangd = {},
				gopls = {
					settings = {
						gopls = {
							gofumpt = true,
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							analyses = {
								unusedparams = true,
								shadow = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},
				pyright = {},
				rust_analyzer = {},
				-- GLSL. Note Godot's RenderingDevice shaders start with a
				-- `#[compute]` directive that Godot strips before compiling; it is
				-- not valid GLSL, so expect one diagnostic on that line.
				glsl_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				ts_ls = {},
				eslint = {
					-- For React Native / JS projects: run ESLint fixes on save.
					on_attach = function(_, bufnr)
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							command = "EslintFixAll",
						})
					end,
				},
				tailwindcss = {
					-- Tailwind LSP for NativeWind (React Native) and web Tailwind.
					filetypes = {
						"html",
						"css",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
					},
					settings = {
						tailwindCSS = {
							-- NativeWind exposes `className` and the `tw` tagged template;
							-- teach the LSP to complete inside both.
							experimental = {
								classRegex = {
									{ "tw`([^`]*)", "([^\\s]+)" },
									{ "tw=\"([^\"]*)", "([^\\s]+)" },
									{ "tw={\"([^\"}]*)", "([^\\s]+)" },
								},
							},
							includeLanguages = {
								typescript = "javascript",
								typescriptreact = "javascript",
							},
						},
					},
				},
				--
        pylsp = {
          plugins = {
            pycodestyle = {
              ignore = {'W391'},
              maxLineLength = 100
            }
          }
        },
				lua_ls = {
					-- cmd = { ... },
					-- filetypes = { ... },
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--
			-- To check the current status of installed tools and/or manually install
			-- other tools, you can run
			--    :Mason
			--
			-- You can press `g?` for help in this menu.
			--
			-- `mason` had to be setup earlier: to configure its options see the
			-- `dependencies` table for `nvim-lspconfig` above.
			--
			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"gofumpt", -- Stricter gofmt for Go
				"goimports", -- Auto-manage Go imports
				"golangci-lint", -- Go linter
				"delve", -- Go debugger
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
			require("mason-lspconfig").setup({
				ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
  {
    'sindrets/diffview.nvim',
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    dependencies = {
      -- Optional: If you want to use diffview with git, you need to install the git plugin
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Optional: For file icons in diffview
    },
    config = function()
      -- Configure diffview.nvim
      -- Lua
      local actions = require("diffview.actions")

      require("diffview").setup({
        diff_binaries = false,    -- Show diffs for binaries
        enhanced_diff_hl = false, -- See |diffview-config-enhanced_diff_hl|
        git_cmd = { "git" },      -- The git executable followed by default args.
        hg_cmd = { "hg" },        -- The hg executable followed by default args.
        use_icons = true,         -- Requires nvim-web-devicons
        show_help_hints = true,   -- Show hints for how to open the help panel
        watch_index = true,       -- Update views and index buffers when the git index changes.
        icons = {                 -- Only applies when use_icons is true.
          folder_closed = "",
          folder_open = "",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "✓",
        },
        view = {
          -- Configure the layout and behavior of different types of views.
          -- Available layouts:
          --  'diff1_plain'
          --    |'diff2_horizontal'
          --    |'diff2_vertical'
          --    |'diff3_horizontal'
          --    |'diff3_vertical'
          --    |'diff3_mixed'
          --    |'diff4_mixed'
          -- For more info, see |diffview-config-view.x.layout|.
          default = {
            -- Config for changed files, and staged files in diff views.
            layout = "diff2_horizontal",
            disable_diagnostics = false,  -- Temporarily disable diagnostics for diff buffers while in the view.
            winbar_info = false,          -- See |diffview-config-view.x.winbar_info|
          },
          merge_tool = {
            -- Config for conflicted files in diff views during a merge or rebase.
            layout = "diff3_horizontal",
            disable_diagnostics = true,   -- Temporarily disable diagnostics for diff buffers while in the view.
            winbar_info = true,           -- See |diffview-config-view.x.winbar_info|
          },
          file_history = {
            -- Config for changed files in file history views.
            layout = "diff2_horizontal",
            disable_diagnostics = false,  -- Temporarily disable diagnostics for diff buffers while in the view.
            winbar_info = false,          -- See |diffview-config-view.x.winbar_info|
          },
        },
        file_panel = {
          listing_style = "tree",             -- One of 'list' or 'tree'
          tree_options = {                    -- Only applies when listing_style is 'tree'
            flatten_dirs = true,              -- Flatten dirs that only contain one single dir
            folder_statuses = "only_folded",  -- One of 'never', 'only_folded' or 'always'.
          },
          win_config = {                      -- See |diffview-config-win_config|
            position = "left",
            width = 35,
            win_opts = {},
          },
        },
        file_history_panel = {
          log_options = {   -- See |diffview-config-log_options|
            git = {
              single_file = {
                diff_merges = "combined",
              },
              multi_file = {
                diff_merges = "first-parent",
              },
            },
            hg = {
              single_file = {},
              multi_file = {},
            },
          },
          win_config = {    -- See |diffview-config-win_config|
            position = "bottom",
            height = 16,
            win_opts = {},
          },
        },
        commit_log_panel = {
          win_config = {},  -- See |diffview-config-win_config|
        },
        default_args = {    -- Default args prepended to the arg-list for the listed commands
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        hooks = {},         -- See |diffview-config-hooks|
        keymaps = {
          disable_defaults = false, -- Disable the default keymaps
          view = {
            -- The `view` bindings are active in the diff buffers, only when the current
            -- tabpage is a Diffview.
            { "n", "<tab>",       actions.select_next_entry,              { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>",     actions.select_prev_entry,              { desc = "Open the diff for the previous file" } },
            { "n", "[F",          actions.select_first_entry,             { desc = "Open the diff for the first file" } },
            { "n", "]F",          actions.select_last_entry,              { desc = "Open the diff for the last file" } },
            { "n", "gf",          actions.goto_file_edit,                 { desc = "Open the file in the previous tabpage" } },
            { "n", "<C-w><C-f>",  actions.goto_file_split,                { desc = "Open the file in a new split" } },
            { "n", "<C-w>gf",     actions.goto_file_tab,                  { desc = "Open the file in a new tabpage" } },
            { "n", "<leader>e",   actions.focus_files,                    { desc = "Bring focus to the file panel" } },
            { "n", "<leader>b",   actions.toggle_files,                   { desc = "Toggle the file panel." } },
            { "n", "g<C-x>",      actions.cycle_layout,                   { desc = "Cycle through available layouts." } },
            { "n", "[x",          actions.prev_conflict,                  { desc = "In the merge-tool: jump to the previous conflict" } },
            { "n", "]x",          actions.next_conflict,                  { desc = "In the merge-tool: jump to the next conflict" } },
            { "n", "<leader>co",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
            { "n", "<leader>ct",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
            { "n", "<leader>cb",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
            { "n", "<leader>ca",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
            { "n", "dx",          actions.conflict_choose("none"),        { desc = "Delete the conflict region" } },
            { "n", "<leader>cO",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
            { "n", "<leader>cT",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
            { "n", "<leader>cB",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
            { "n", "<leader>cA",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
            { "n", "dX",          actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
          },
          diff1 = {
            -- Mappings in single window diff layouts
            { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
          },
          diff2 = {
            -- Mappings in 2-way diff layouts
            { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
          },
          diff3 = {
            -- Mappings in 3-way diff layouts
            { { "n", "x" }, "2do",  actions.diffget("ours"),            { desc = "Obtain the diff hunk from the OURS version of the file" } },
            { { "n", "x" }, "3do",  actions.diffget("theirs"),          { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
            { "n",          "g?",   actions.help({ "view", "diff3" }),  { desc = "Open the help panel" } },
          },
          diff4 = {
            -- Mappings in 4-way diff layouts
            { { "n", "x" }, "1do",  actions.diffget("base"),            { desc = "Obtain the diff hunk from the BASE version of the file" } },
            { { "n", "x" }, "2do",  actions.diffget("ours"),            { desc = "Obtain the diff hunk from the OURS version of the file" } },
            { { "n", "x" }, "3do",  actions.diffget("theirs"),          { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
            { "n",          "g?",   actions.help({ "view", "diff4" }),  { desc = "Open the help panel" } },
          },
          file_panel = {
            { "n", "j",              actions.next_entry,                     { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>",         actions.next_entry,                     { desc = "Bring the cursor to the next file entry" } },
            { "n", "k",              actions.prev_entry,                     { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<up>",           actions.prev_entry,                     { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<cr>",           actions.select_entry,                   { desc = "Open the diff for the selected entry" } },
            { "n", "o",              actions.select_entry,                   { desc = "Open the diff for the selected entry" } },
            { "n", "l",              actions.select_entry,                   { desc = "Open the diff for the selected entry" } },
            { "n", "<2-LeftMouse>",  actions.select_entry,                   { desc = "Open the diff for the selected entry" } },
            { "n", "-",              actions.toggle_stage_entry,             { desc = "Stage / unstage the selected entry" } },
            { "n", "s",              actions.toggle_stage_entry,             { desc = "Stage / unstage the selected entry" } },
            { "n", "S",              actions.stage_all,                      { desc = "Stage all entries" } },
            { "n", "U",              actions.unstage_all,                    { desc = "Unstage all entries" } },
            { "n", "X",              actions.restore_entry,                  { desc = "Restore entry to the state on the left side" } },
            { "n", "L",              actions.open_commit_log,                { desc = "Open the commit log panel" } },
            { "n", "zo",             actions.open_fold,                      { desc = "Expand fold" } },
            { "n", "h",              actions.close_fold,                     { desc = "Collapse fold" } },
            { "n", "zc",             actions.close_fold,                     { desc = "Collapse fold" } },
            { "n", "za",             actions.toggle_fold,                    { desc = "Toggle fold" } },
            { "n", "zR",             actions.open_all_folds,                 { desc = "Expand all folds" } },
            { "n", "zM",             actions.close_all_folds,                { desc = "Collapse all folds" } },
            { "n", "<c-b>",          actions.scroll_view(-0.25),             { desc = "Scroll the view up" } },
            { "n", "<c-f>",          actions.scroll_view(0.25),              { desc = "Scroll the view down" } },
            { "n", "<tab>",          actions.select_next_entry,              { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>",        actions.select_prev_entry,              { desc = "Open the diff for the previous file" } },
            { "n", "[F",             actions.select_first_entry,             { desc = "Open the diff for the first file" } },
            { "n", "]F",             actions.select_last_entry,              { desc = "Open the diff for the last file" } },
            { "n", "gf",             actions.goto_file_edit,                 { desc = "Open the file in the previous tabpage" } },
            { "n", "<C-w><C-f>",     actions.goto_file_split,                { desc = "Open the file in a new split" } },
            { "n", "<C-w>gf",        actions.goto_file_tab,                  { desc = "Open the file in a new tabpage" } },
            { "n", "i",              actions.listing_style,                  { desc = "Toggle between 'list' and 'tree' views" } },
            { "n", "f",              actions.toggle_flatten_dirs,            { desc = "Flatten empty subdirectories in tree listing style" } },
            { "n", "R",              actions.refresh_files,                  { desc = "Update stats and entries in the file list" } },
            { "n", "<leader>e",      actions.focus_files,                    { desc = "Bring focus to the file panel" } },
            { "n", "<leader>b",      actions.toggle_files,                   { desc = "Toggle the file panel" } },
            { "n", "g<C-x>",         actions.cycle_layout,                   { desc = "Cycle available layouts" } },
            { "n", "[x",             actions.prev_conflict,                  { desc = "Go to the previous conflict" } },
            { "n", "]x",             actions.next_conflict,                  { desc = "Go to the next conflict" } },
            { "n", "g?",             actions.help("file_panel"),             { desc = "Open the help panel" } },
            { "n", "<leader>cO",     actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
            { "n", "<leader>cT",     actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
            { "n", "<leader>cB",     actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
            { "n", "<leader>cA",     actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
            { "n", "dX",             actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
          },
          file_history_panel = {
            { "n", "g!",            actions.options,                     { desc = "Open the option panel" } },
            { "n", "<C-A-d>",       actions.open_in_diffview,            { desc = "Open the entry under the cursor in a diffview" } },
            { "n", "y",             actions.copy_hash,                   { desc = "Copy the commit hash of the entry under the cursor" } },
            { "n", "L",             actions.open_commit_log,             { desc = "Show commit details" } },
            { "n", "X",             actions.restore_entry,               { desc = "Restore file to the state from the selected entry" } },
            { "n", "zo",            actions.open_fold,                   { desc = "Expand fold" } },
            { "n", "zc",            actions.close_fold,                  { desc = "Collapse fold" } },
            { "n", "h",             actions.close_fold,                  { desc = "Collapse fold" } },
            { "n", "za",            actions.toggle_fold,                 { desc = "Toggle fold" } },
            { "n", "zR",            actions.open_all_folds,              { desc = "Expand all folds" } },
            { "n", "zM",            actions.close_all_folds,             { desc = "Collapse all folds" } },
            { "n", "j",             actions.next_entry,                  { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>",        actions.next_entry,                  { desc = "Bring the cursor to the next file entry" } },
            { "n", "k",             actions.prev_entry,                  { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<up>",          actions.prev_entry,                  { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<cr>",          actions.select_entry,                { desc = "Open the diff for the selected entry" } },
            { "n", "o",             actions.select_entry,                { desc = "Open the diff for the selected entry" } },
            { "n", "l",             actions.select_entry,                { desc = "Open the diff for the selected entry" } },
            { "n", "<2-LeftMouse>", actions.select_entry,                { desc = "Open the diff for the selected entry" } },
            { "n", "<c-b>",         actions.scroll_view(-0.25),          { desc = "Scroll the view up" } },
            { "n", "<c-f>",         actions.scroll_view(0.25),           { desc = "Scroll the view down" } },
            { "n", "<tab>",         actions.select_next_entry,           { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>",       actions.select_prev_entry,           { desc = "Open the diff for the previous file" } },
            { "n", "[F",            actions.select_first_entry,          { desc = "Open the diff for the first file" } },
            { "n", "]F",            actions.select_last_entry,           { desc = "Open the diff for the last file" } },
            { "n", "gf",            actions.goto_file_edit,              { desc = "Open the file in the previous tabpage" } },
            { "n", "<C-w><C-f>",    actions.goto_file_split,             { desc = "Open the file in a new split" } },
            { "n", "<C-w>gf",       actions.goto_file_tab,               { desc = "Open the file in a new tabpage" } },
            { "n", "<leader>e",     actions.focus_files,                 { desc = "Bring focus to the file panel" } },
            { "n", "<leader>b",     actions.toggle_files,                { desc = "Toggle the file panel" } },
            { "n", "g<C-x>",        actions.cycle_layout,                { desc = "Cycle available layouts" } },
            { "n", "g?",            actions.help("file_history_panel"),  { desc = "Open the help panel" } },
          },
          option_panel = {
            { "n", "<tab>", actions.select_entry,          { desc = "Change the current option" } },
            { "n", "q",     actions.close,                 { desc = "Close the panel" } },
            { "n", "g?",    actions.help("option_panel"),  { desc = "Open the help panel" } },
          },
          help_panel = {
            { "n", "q",     actions.close,  { desc = "Close help menu" } },
            { "n", "<esc>", actions.close,  { desc = "Close help menu" } },
          },
        },
      })
    end,
  },
	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			fat_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "goimports", "gofumpt" },
				python = { "isort", "black" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
					--   'rafamadriz/friendly-snippets',
					--   config = function()
					--     require('luasnip.loaders.from_vscode').lazy_load()
					--   end,
					-- },
				},
			},
			"saadparwaiz1/cmp_luasnip",

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp-signature-help",
		},
		config = function()
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),
					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					-- If you prefer more traditional completion keymaps,
					-- you can uncomment the following lines
					--['<CR>'] = cmp.mapping.confirm { select = true },
					--['<Tab>'] = cmp.mapping.select_next_item(),
					--['<S-Tab>'] = cmp.mapping.select_prev_item(),

					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					["<C-Space>"] = cmp.mapping.complete({}),

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "nvim_lsp_signature_help" },
				},
			})
		end,
	},

	{ -- You can easily change to a different colorscheme.
		-- Change the name of the colorscheme plugin below, and then
		-- change the command in the config to whatever the name of that colorscheme is.
		--
		-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
		"folke/tokyonight.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("tokyonight").setup({
				styles = {
					comments = { italic = false }, -- Disable italics in comments
				},
			})

			-- Load the colorscheme here.
			-- Like many other themes, this one has different styles, and you could load
			-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			-- Loading mini modules
			require("mini.comment").setup()
			require("mini.cursorword").setup()
			require("mini.git").setup()
			require("mini.icons").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			require("ufo").setup()
			-- nvim-ufo config

			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
	},
	{ -- Flutter / Dart development
		"nvim-flutter/flutter-tools.nvim",
		ft = { "dart" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("flutter-tools").setup({
				lsp = {
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
				},
				widget_guides = { enabled = true },
				closing_tags = { enabled = true, highlight = "Comment", prefix = "// " },
				dev_log = { enabled = true, open_cmd = "tabedit" },
			})

			local map = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
			end
			map("<leader>Fr", "<cmd>FlutterRun<CR>", "Flutter: Run")
			map("<leader>Fq", "<cmd>FlutterQuit<CR>", "Flutter: Quit")
			map("<leader>Fh", "<cmd>FlutterReload<CR>", "Flutter: Hot Reload")
			map("<leader>FR", "<cmd>FlutterRestart<CR>", "Flutter: Hot Restart")
			map("<leader>Fd", "<cmd>FlutterDevices<CR>", "Flutter: Devices")
			map("<leader>Fe", "<cmd>FlutterEmulators<CR>", "Flutter: Emulators")
			map("<leader>Fo", "<cmd>FlutterOutlineToggle<CR>", "Flutter: Outline")
			map("<leader>Fl", "<cmd>FlutterLogToggle<CR>", "Flutter: Log")
			map("<leader>Fc", "<cmd>FlutterLogClear<CR>", "Flutter: Clear log")
			map("<leader>FD", "<cmd>FlutterDevTools<CR>", "Flutter: DevTools")
			map("<leader>Fp", "<cmd>FlutterPubGet<CR>", "Flutter: pub get")
			map("<leader>FP", "<cmd>FlutterPubUpgrade<CR>", "Flutter: pub upgrade")
		end,
	},
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local langs = {
				"bash",
				"c",
				"css",
				"diff",
				"dart",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"html",
				"javascript",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"python",
				"gdscript",
				"gdshader",
				"godot_resource",
				"glsl",
			}
			require("nvim-treesitter").install(langs)
			-- Parser names and filetypes mostly match, except Godot's .tres/.tscn
			-- files: parser `godot_resource`, filetype `gdresource`.
			local highlight_fts = vim.list_extend(vim.deepcopy(langs), { "gdresource" })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = highlight_fts,
				callback = function()
					vim.treesitter.start()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	-- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
	-- init.lua. If you want these files, they are in the repository, so you can just download them and
	-- place them in the correct locations.

	-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
	--
	--  Here are some example plugins that I've included in the Kickstart repository.
	--  Uncomment any of the lines below to enable them (you will need to restart nvim).
	--
	-- require 'kickstart.plugins.debug',
	-- require 'kickstart.plugins.indent_line',
	-- require 'kickstart.plugins.lint',
	-- require 'kickstart.plugins.autopairs',
	-- require 'kickstart.plugins.neo-tree',
	-- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

	-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
	--    This is the easiest way to modularize your config.
	--
	--  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
	-- { import = 'custom.plugins' },
	--
	-- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
	-- Or use telescope!
	-- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
	-- you can continue same window with `<space>sr` which resumes last telescope search
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- ============================================================================
-- React Native workflow keymaps (<leader>N*)
-- ============================================================================
do
	local Terminal = require("toggleterm.terminal").Terminal
	local terms = {}

	-- Persistent named terminal: re-toggles the same shell rather than spawning
	-- a new one each time. Used for Metro and logcat so logs survive.
	local function toggle_named(name, cmd, direction)
		if not terms[name] then
			terms[name] = Terminal:new({
				cmd = cmd,
				direction = direction or "horizontal",
				hidden = true,
				close_on_exit = false,
			})
		end
		terms[name]:toggle()
	end

	local function notify(msg, level)
		vim.notify("[RN] " .. msg, level or vim.log.levels.INFO)
	end

	-- Send POST /reload to the Metro dev server (port 8081).
	local function reload_app()
		vim.system({ "curl", "-s", "-X", "POST", "http://localhost:8081/reload" }, { text = true }, function(out)
			vim.schedule(function()
				if out.code == 0 then
					notify("reload sent")
				else
					notify("reload failed — is Metro running on :8081?", vim.log.levels.WARN)
				end
			end)
		end)
	end

	local map = function(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
	end

	map("<leader>Nm", function() toggle_named("metro", "npx react-native start") end, "RN: Metro (toggle)")
	map("<leader>Na", function() toggle_named("android", "npx react-native run-android") end, "RN: Run Android")
	map("<leader>Ni", function() toggle_named("ios", "npx react-native run-ios") end, "RN: Run iOS")
	map("<leader>Nl", function() toggle_named("logcat", "adb logcat *:S ReactNative:V ReactNativeJS:V") end, "RN: Android logcat")
	map("<leader>Nr", reload_app, "RN: Reload app")
	map("<leader>Nd", function()
		vim.system({ "adb", "shell", "input", "keyevent", "82" }, { text = true }, function(out)
			vim.schedule(function()
				notify(out.code == 0 and "dev menu opened" or "adb failed — device connected?",
					out.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
			end)
		end)
	end, "RN: Open Android dev menu")
	map("<leader>Np", function() toggle_named("install", "npm install") end, "RN: npm install")
	map("<leader>Nx", function()
		toggle_named("clean", "watchman watch-del-all && rm -rf node_modules && rm -rf $TMPDIR/metro-* && npm install")
	end, "RN: Clean caches & reinstall")
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- ============================================================================
-- Godot / GDScript workflow (<leader>G*)
-- ============================================================================
do
	-- nvim detects .gdshader but not .gdshaderinc, so shader include files end up
	-- with no filetype at all: no highlighting, no LSP. Map them onto gdshader.
	vim.filetype.add({ extension = { gdshaderinc = "gdshader" } })

	-- Resolve the Godot binary per machine instead of pinning one path+version:
	-- $GODOT wins, then anything on PATH, then the highest-versioned official
	-- tarball under ~/Programs/Godot.
	local function godot_bin()
		if vim.env.GODOT and vim.fn.executable(vim.env.GODOT) == 1 then
			return vim.env.GODOT
		end
		for _, name in ipairs({ "godot", "godot4", "Godot" }) do
			if vim.fn.executable(name) == 1 then
				return name
			end
		end
		local found = vim.fn.glob(vim.fn.expand("~/Programs/Godot/Godot_v*"), false, true)
		found = vim.tbl_filter(function(f)
			return vim.fn.executable(f) == 1
		end, found)
		table.sort(found)
		return found[#found]
	end
	-- Godot editor setting: Network > Language Server > Remote Port.
	local LSP_PORT = tonumber(vim.env.GDScript_Port or "6005")

	local function project_root()
		return vim.fs.root(vim.api.nvim_buf_get_name(0) ~= "" and 0 or vim.fn.getcwd(), { "project.godot" })
	end

	-- ---------------------------------------------------------------- LSP
	-- Godot itself *is* the GDScript language server -- it listens on
	-- 127.0.0.1:6005 only while the editor is open on the project. There is no
	-- separate binary, so this is configured here rather than in the Mason-driven
	-- `servers` table above (Mason has no `gdscript` package and would error).
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
	if ok_cmp then
		capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
	end

	vim.lsp.config("gdscript", {
		cmd = vim.lsp.rpc.connect("127.0.0.1", LSP_PORT),
		filetypes = { "gdscript" },
		-- No `.git` fallback: without a live Godot editor the connect fails, so
		-- only attach inside an actual Godot project.
		root_markers = { "project.godot" },
		capabilities = capabilities,
	})
	vim.lsp.enable("gdscript")

	-- ------------------------------------------------------- external editor
	-- Godot's "Use External Editor" talks to a running nvim over a socket. Listen
	-- on <project>/server.pipe so ~/.local/bin/godot-nvim-open can send jumps
	-- here instead of spawning a second instance.
	local function start_pipe()
		local root = project_root()
		if not root then
			return
		end
		local pipe = root .. "/server.pipe"
		if pcall(vim.fn.serverstart, pipe) then
			return
		end
		-- "address already in use": either another nvim genuinely owns this pipe,
		-- or it is a stale socket left by one that died without cleaning up.
		-- Probe rather than guess. Note `sockconnect` *throws* on a dead socket
		-- instead of returning 0, so it needs the pcall too.
		local connected, chan = pcall(vim.fn.sockconnect, "pipe", pipe, { rpc = true })
		if connected and chan ~= 0 then
			pcall(vim.fn.chanclose, chan)
			return -- live instance; leave it alone
		end
		os.remove(pipe)
		pcall(vim.fn.serverstart, pipe)
	end

	-- Remove our own socket on exit so the next launch does not have to reclaim it.
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			local root = project_root()
			if root and vim.tbl_contains(vim.fn.serverlist(), root .. "/server.pipe") then
				os.remove(root .. "/server.pipe")
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = start_pipe })
	-- Also cover opening a Godot file after startup from a non-Godot cwd.
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "gdscript", "gdresource", "gdshader" },
		once = true,
		callback = start_pipe,
	})

	-- ------------------------------------------------------------- keymaps
	local function godot(args, msg)
		local root = project_root()
		if not root then
			vim.notify("[Godot] no project.godot found", vim.log.levels.WARN)
			return
		end
		local bin = godot_bin()
		if not bin then
			vim.notify("[Godot] no Godot binary found -- set $GODOT", vim.log.levels.ERROR)
			return
		end
		local cmd = { bin, "--path", root }
		vim.list_extend(cmd, args)
		vim.system(cmd, { detach = true })
		vim.notify("[Godot] " .. msg)
	end

	local map = function(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
	end

	map("<leader>Ge", function() godot({ "--editor" }, "editor opening") end, "Godot: open editor")
	map("<leader>Gr", function() godot({}, "project running") end, "Godot: run project")
	map("<leader>Gs", function()
		local file = vim.api.nvim_buf_get_name(0)
		if not file:match("%.tscn$") then
			vim.notify("[Godot] current buffer is not a .tscn scene", vim.log.levels.WARN)
			return
		end
		godot({ file }, "running " .. vim.fs.basename(file))
	end, "Godot: run current scene")
	map("<leader>Gl", function()
		-- Godot's LSP only exists while its editor is open, so a restart after
		-- launching the editor is the normal recovery path.
		local clients = vim.lsp.get_clients({ name = "gdscript" })
		for _, c in ipairs(clients) do
			c:stop()
		end
		vim.defer_fn(function()
			vim.cmd("edit")
			vim.notify("[Godot] gdscript LSP restarted")
		end, 500)
	end, "Godot: restart GDScript LSP")
end
