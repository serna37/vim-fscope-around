# vim-fscope-around
inspired by [quick-scope](https://github.com/unblevable/quick-scope).

Highlight `f-char` not only current row, around row
![around-demo.gif](./around-demo.gif)
with [vim-anchor5](https://github.com/serna37/vim-anchor5), [clever-f](https://github.com/rhysd/clever-f.vim)

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
:FScope
" deactive
:FScope!
" toggle
:FScope!!
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
# license
[MIT](./LICENSE)
