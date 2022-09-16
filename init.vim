lua require('core.init')

set clipboard^=unnamed,unnamedplus
" set autochdir

if has('unix')
	set thesaurus+=/usr/share/dict/words
endif

if exists("g:neovide")
    " Neovide config
	let g:neovide_refresh_rate=24	" come on it's just a text editor
	let g:neovide_transparency=1.0
	let g:neovide_scroll_animation_length = 0.3
	let g:neovide_remember_window_size = v:true
	let g:neovide_input_use_logo=v:true	" the super/command/win key
	let g:neovide_input_macos_alt_is_meta=v:false
	let g:neovide_touch_deadzone=0.0
	let g:neovide_cursor_animation_length=0.05
	let g:neovide_cursor_trail_length=0.8
	let g:neovide_cursor_antialiasing=v:false	" i dont need it
	let g:neovide_cursor_vfx_mode = "wireframe"
	let g:neovide_remember_window_size = v:true
endif

autocmd FileType markdown setlocal spell
augroup GO_LSP
	autocmd!
	autocmd BufWritePre *.go :silent! lua vim.lsp.buf.format({async = false})
	autocmd BufWritePre *.go :silent! lua GoImports(3000)
augroup END
autocmd BufEnter,BufNew term://* startinsert

let g:copilot_no_maps = v:true
imap <silent><script><expr> <C-J> copilot#Accept("")
imap <C-]> <Cmd>call copilot#Next()<CR>
imap <C-[> <Cmd>call copilot#Previous()<CR>

