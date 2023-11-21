noremap <silent><Plug>(fscope-around-activate) :<C-u>cal fscope#activate()<CR>
noremap <silent><Plug>(fscope-around-deactivate) :<C-u>cal fscope#deactivate()<CR>
noremap <silent><Plug>(fscope-around-toggle) :<C-u>cal fscope#toggle()<CR>
com! FScope cal fscope#activate()
com! FScope! cal fscope#deactivate()
com! FScope!! cal fscope#toggle()

