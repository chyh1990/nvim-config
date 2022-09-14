local M = {}

function M.config()
	-- Setup nvim-cmp.
	local cmp = require 'cmp'
	cmp.setup({
		snippet = {
			-- REQUIRED - you must specify a snippet engine
			expand = function(args)
				-- luasnip
				require('luasnip').lsp_expand(args.body)
				-- vsnip
				-- vim.fn["vsnip#anonymous"](args.body)
				-- snippy
				-- require('snippy').expand_snippet(args.body)
				-- ultisnip
				-- vim.fn["UltiSnips#Anon"](args.body)
			end,
		},
		mapping = {
			['<Up>'] = cmp.mapping.select_prev_item(select_opts),
			['<Down>'] = cmp.mapping.select_next_item(select_opts),

			['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
			['<C-n>'] = cmp.mapping.select_next_item(select_opts),

			['<C-u>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),

			['<C-e>'] = cmp.mapping.abort(),
			['<CR>'] = cmp.mapping.confirm({select = true}),

			['<C-d>'] = cmp.mapping(function(fallback)
				if luasnip.jumpable(1) then
					luasnip.jump(1)
				else
					fallback()
				end
			end, {'i', 's'}),

			['<C-b>'] = cmp.mapping(function(fallback)
				if luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, {'i', 's'}),

			['<Tab>'] = cmp.mapping(function(fallback)
				local col = vim.fn.col('.') - 1

				if cmp.visible() then
					cmp.select_next_item(select_opts)
				elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
					fallback()
				else
					cmp.complete()
				end
			end, {'i', 's'}),

			['<S-Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item(select_opts)
				else
					fallback()
				end
			end, {'i', 's'}),	
		},
		sources = cmp.config.sources({
			{ name = 'nvim_lsp' },
			-- { name = 'luasnip' }, -- For luasnip users.
			-- { name = 'ultisnips' }, -- For ultisnips users.
			-- { name = 'snippy' }, -- For snippy users.
		}, { { name = 'buffer' } })
	})

	-- You can also set special config for specific filetypes:
	--    cmp.setup.filetype('gitcommit', {
	--        sources = cmp.config.sources({
	--            { name = 'cmp_git' },
	--        }, {
	--            { name = 'buffer' },
	--        })
	--    })

	-- nvim-cmp for commands
	cmp.setup.cmdline('/', {
		sources = {
			{ name = 'buffer' }
		}
	})
	cmp.setup.cmdline(':', {
		sources = cmp.config.sources({
			{ name = 'path' }
		}, {
			{ name = 'cmdline' }
		})
	})

	local has_words_before = function()
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end

	local luasnip = require("luasnip")
	local cmp = require("cmp")

	cmp.setup({

		mapping = {

			["<C-n>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end, { "i", "s" }),

			["<C-p>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),

			-- ... Your other mappings ...
		},

		-- ... Your other configuration ...
	})

	-- nvim-lspconfig config
	-- List of all pre-configured LSP servers:
	-- github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	-- require 'lspconfig'.gopls.setup {}
	local servers = { 'clangd', 'rust_analyzer', 'pylsp', 'sumneko_lua', 'gopls' }
	for _, lsp in pairs(servers) do
		require('lspconfig')[lsp].setup {
			on_attach = on_attach
		}
	end

	local devicons = require('nvim-web-devicons')
	cmp.register_source('devicons', {
		complete = function(_, _, callback)
			local items = {}
			for _, icon in pairs(devicons.get_icons()) do
				table.insert(items, {
					label = icon.icon .. '  ' .. icon.name,
					insertText = icon.icon,
					filterText = icon.name,
				})
			end
			callback({ items = items })
		end,
	})

	local saga = require 'lspsaga'

	-- change the lsp symbol kind
	--local kind = require('lspsaga.lspkind')
	--kind[type_number][2] = icon -- see lua/lspsaga/lspkind.lua

	-- use default config
	saga.init_lsp_saga({
		border_style = "single",
		saga_winblend = 0,
		move_in_saga = { prev = '<C-p>',next = '<C-n>'},
		diagnostic_header = { " ", " ", " ", "ﴞ " },
		-- show_diagnostic_source = true,
		-- diagnostic_source_bracket = {},
		max_preview_lines = 10,
		code_action_icon = "",
		code_action_num_shortcut = true,
		code_action_lightbulb = {
			enable = true,
			sign = true,
			enable_in_insert = true,
			sign_priority = 20,
			virtual_text = true,
		},
		finder_icons = {
			def = '  ',
			ref = '諭 ',
			link = '  ',
		},
		finder_request_timeout = 1500,
		finder_action_keys = {
			open = "o",
			vsplit = "s",
			split = "i",
			tabe = "t",
			quit = "q",
			scroll_down = "<C-f>",
			scroll_up = "<C-b>", -- quit can be a table
		},
		code_action_keys = {
			quit = "q",
			exec = "<CR>",
		},
		rename_action_quit = "q",
		rename_in_select = true,
		-- definition_preview_icon = "  ",
		-- show symbols in winbar must nightly
		symbol_in_winbar = {
			in_custom = false,
			enable = false,
			separator = ' ',
			show_file = true,
			click_support = false,
		},
		show_outline = {
			win_position = 'right',
			win_with = '',
			win_width = 30,
			auto_enter = true,
			auto_preview = true,
			virt_text = '┃',
			jump_key = 'o',
			auto_refresh = true,
		},
		server_filetype_map = {},
	})

	require('rust-tools').setup()

end

return M
