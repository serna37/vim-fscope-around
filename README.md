# vim-fscope-around

# installation
```vim
Plug 'serna37/vim-fscope-around'
```

# usage
```vim
" keymaps sample
nnoremap <silent><Leader><Leader>fa <Plug>(fscope-around-activate)
nnoremap <silent><Leader><Leader>fd <Plug>(fscope-around-deactivate)
nnoremap <silent><Leader><Leader>fs <Plug>(fscope-around-toggle)

" commands
" active
FScope
" deactive
FScope!
" toggle
FScope!!
```

# custom
overrite in your `.vimrc`
```vim
" highlight priority (default 16)
let g:fscope_highlight_priority = 16
" target range (default 5)
let g:fscope_around_row = 5
" active on start vim (default 1)
let g:fscope_init_active = 1
```

