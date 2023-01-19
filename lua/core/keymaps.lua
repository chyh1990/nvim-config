local function set_bg_light()
	vim.cmd('set background=light')
	local colors_name = vim.g.colors_name
	vim.cmd('colorscheme shine')
	vim.cmd('colorscheme ' .. colors_name)
end

local function set_bg_dark()
	vim.cmd('set background=dark')
	local colors_name = vim.g.colors_name
	vim.cmd('colorscheme ron')
	vim.cmd('colorscheme ' .. colors_name)
end

local function get_uri_data(result)
  local uri, range

  if type(result[1]) == 'table' then
    uri = result[1].uri or result[1].targetUri
    range = result[1].range or result[1].targetSelectionRange
  else
    uri = result.uri or result.targetUri
    range = result.range or result.targetSelectionRange
  end

  if not uri then
    vim.notify('[Lspsaga] Does not find target uri', vim.log.levels.WARN)
    return
  end

  local bufnr = vim.uri_to_bufnr(uri)
  local link = vim.uri_to_fname(uri)

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  local start_line = range.start.line
  local start_char_pos = range.start.character
  local end_char_pos = range['end'].character

  return bufnr, link, start_line, start_char_pos, end_char_pos
end

function GotoDefinition()
  local libs = require('lspsaga.libs')
  vim.lsp.handlers['textDocument/definition'] = function(_, result, _, _)
    if not result or vim.tbl_isempty(result) then
	  print("No LSP location available")
	  vim.api.nvim_command('normal! gd')
      return
    end
    local _, link, start_line, start_char_pos, _ = get_uri_data(result)
    vim.api.nvim_command('edit ' .. link)
    vim.api.nvim_win_set_cursor(0, { start_line + 1, start_char_pos })
    local width = #vim.api.nvim_get_current_line()
    libs.jump_beacon({ start_line, start_char_pos }, width)
  end
  vim.lsp.buf.definition()
end

-- vim.g.mapleader = ';'

-- keymaps
-- vim.keymap.set('i', '<C-g>', '<esc>')
-- vim.keymap.set('i', '<C-;>', '::') -- for C++ and Rust
-- vim.keymap.set('n', '<leader>vl', set_bg_light)
-- vim.keymap.set('n', '<leader>vd', set_bg_dark)
vim.keymap.set('n', '<leader>', ':')
-- f: file tree
vim.keymap.set('n', '<F3>', ':NvimTreeToggle<cr>')
vim.keymap.set('n', '<leader>ft', ':NvimTreeToggle<cr>')
vim.keymap.set('n', '<leader>ff', ':NvimTreeFocus<cr>')
-- y: telescope
vim.keymap.set('n', '<F9>', function() require 'telescope.builtin'.grep_string {} end)
vim.keymap.set('n', '<F10>', function() require 'telescope.builtin'.find_files {} end)
vim.keymap.set('n', '<F11>', function() require 'telescope.builtin'.git_files {} end)
-- vim.keymap.set('n', '<F11>', function() require 'telescope.builtin'.buffers {} end)
vim.keymap.set({ 'n', 'i' }, '<C-p>', function() require 'telescope.builtin'.registers {} end)
-- w: window
vim.keymap.set('n', '<leader>w1', '<c-w>o')
vim.keymap.set('n', '<leader>wx', ':x<cr>')
vim.keymap.set('n', '<leader>w2', ':sp<cr>')
vim.keymap.set('n', '<leader>w3', ':vs<cr>')
-- window resize
vim.keymap.set('n', '<m-9>', '<c-w><')
vim.keymap.set('n', '<m-0>', '<c-w>>')
vim.keymap.set('n', '<m-->', '<c-w>-')
vim.keymap.set('n', '<m-=>', '<c-w>+')
-- b: buffer
vim.keymap.set('n', '<leader>bn', ':bn<cr>')
vim.keymap.set('n', '<C-n>', ':bn<cr>')
vim.keymap.set('n', '<leader>bp', ':bp<cr>')
vim.keymap.set('n', '<C-p>', ':bp<cr>')
vim.keymap.set('n', '<leader>bd', ':BufDel<cr>')
-- p: plugins
vim.keymap.set('n', '<leader>pi', ':PackerInstall<cr>')
vim.keymap.set('n', '<leader>pc', ':PackerClean<cr>')
-- s: search
vim.keymap.set('n', '<leader>ss', '/')
vim.keymap.set('n', '<leader>sw', '/\\<lt>\\><left><left>')
-- l/g/w: language
-- l: general
-- g: goto
-- w: workspace
-- c: inlay hints
vim.keymap.set('n', '<leader>le', ':Lspsaga show_line_diagnostics<cr>')
vim.keymap.set('n', '<leader>lE', ':Lspsaga show_cursor_diagnostics<cr>')
vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist)
vim.keymap.set('n', '<leader>lk', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>ld', ':Lspsaga preview_definition<cr>')
vim.keymap.set('n', '<leader>lr', ':Lspsaga rename<cr>')
vim.keymap.set('n', '<leader>lh', vim.lsp.buf.signature_help)
vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>lb', ':SymbolsOutline<cr>')
vim.keymap.set('n', '<leader>la', ':Lspsaga code_action<cr>')
vim.keymap.set('n', '<leader>lu', ':Lspsaga lsp_finder<cr>')
vim.keymap.set('n', '<F12>', ':Lspsaga code_action<cr>')
vim.keymap.set('n', '<leader>it', function() require('rust-tools.inlay_hints').toggle_inlay_hints() end)
vim.keymap.set('n', '<leader>is', function() require('rust-tools.inlay_hints').set_inlay_hints() end)
vim.keymap.set('n', '<leader>id', function() require('rust-tools.inlay_hints').diable_inlay_hints() end)
vim.keymap.set('n', '<f4>', ':SymbolsOutline<cr>')

-- local opts = { noremap=true, silent=true }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gd', GotoDefinition)
vim.keymap.set('n', 'gr', vim.lsp.buf.references)
vim.keymap.set('n', '<C-K>', vim.lsp.buf.hover)
-- vim.keymap.set('n', '<C-K>', ':Lspsaga hover_doc<cr>', opts)
vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition)
vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation)
vim.keymap.set('n', '<leader>gp', ':Lspsaga diagnostic_jump_prev<cr>')
vim.keymap.set('n', '<leader>gn', ':Lspsaga diagnostic_jump_next<cr>')

vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder)
vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)

-- t: terminal
-- use <f5> to toggle terminal, this can be set in lua/configs/terminal.lua
-- the default position is also set in lua/configs/terminal.lua
vim.keymap.set('t', '<C-g>', '<C-\\><C-n>')
-- switch to another panel with C-w
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')
vim.keymap.set('n', '<leader>tt', ':ToggleTerm direction=tab<cr>')
vim.keymap.set('n', '<leader>tn', function() require('toggleterm.terminal').Terminal:new():toggle() end)
vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<cr>')
vim.keymap.set('n', '<leader>th', ':ToggleTerm direction=horizontal<cr>')
vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical<cr>')

-- h: git
vim.keymap.set('n', '<leader>hu', ':Gitsigns undo_stage_hunk<cr>')
vim.keymap.set('n', '<leader>hn', ':Gitsigns next_hunk<cr>')
vim.keymap.set('n', '<leader>hc', ':Gitsigns preview_hunk<cr>')
vim.keymap.set('n', '<leader>hr', ':Gitsigns reset_hunk<cr>')
vim.keymap.set('n', '<leader>hR', ':Gitsigns reset_buffer')
vim.keymap.set('n', '<leader>hb', ':Gitsigns blame_line<cr>')
vim.keymap.set('n', '<leader>hd', ':Gitsigns diffthis<cr>')
vim.keymap.set('n', '<leader>hs', ':<C-U>Gitsigns select_hunk<CR>')
