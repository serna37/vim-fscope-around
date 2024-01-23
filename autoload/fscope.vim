if execute('sil! hi FScopeCurrentRowPrimary') =~ 'E411'
    aug fmode_colors
        au!
        au ColorScheme * hi FScopeCurrentRowPrimary ctermfg=204 cterm=BOLD
        au ColorScheme * hi FScopeCurrentRowSecondary ctermfg=81 cterm=BOLD
        au ColorScheme * hi FScopeAround cterm=BOLD ctermbg=236
    aug END
    hi FScopeCurrentRowPrimary ctermfg=204 cterm=BOLD
    hi FScopeCurrentRowSecondary ctermfg=81 cterm=BOLD
    hi FScopeAround cterm=BOLD ctermbg=236
endif


let s:fmode = #{flg: 0}

fu! s:fmode.scope(current_row, col, row_no, row_txt) abort

    let r_txt = a:row_txt
    let row_no = a:row_no
    let col_no = a:current_row > a:row_no ? len(a:row_txt) : a:current_row == a:row_no ? a:col : 0

    let cs_f = []
    let cs_f2 = []

    let offset = 0
    while offset != -1
        let start_ch = matchstrpos(r_txt, '\<.', offset)
        let offset = matchstrpos(r_txt, '.\>', offset)[2]
        let track = start_ch[1] >= col_no ? r_txt[col_no:start_ch[1]-1] : r_txt[start_ch[2]+1:col_no]

        " from leadgin char to last char
        let unique_ch = -1
        for idx in range(start_ch[1] - 1, offset - 1)
            " unique from cursor pos
            let char = r_txt[idx]
            if char =~ '[0-9A-Za-z]' && stridx(track, char) == -1
                let unique_ch = idx
                break
            endif
        endfor

        if unique_ch != -1
            " from leadgin char to last char
            cal add(cs_f, [row_no, unique_ch + 1])
        else
            " secondary color on leading char
            cal add(cs_f2, [row_no, start_ch[2]])
        endif

    endwhile

    cal s:fmode.sethi(cs_f, cs_f2, a:current_row == a:row_no)
endf


fu! s:fmode.sethi(c_f, c_f2, is_current) abort
    let priority = get(g:, 'fscope_highlight_priority', 16)

    if a:is_current
        if !empty(a:c_f)
            cal matchaddpos('FScopeCurrentRowPrimary', a:c_f, priority)
        endif
        if !empty(a:c_f2)
            cal matchaddpos('FScopeCurrentRowSecondary', a:c_f2, priority)
        endif
        retu
    endif

    if !empty(a:c_f)
        cal matchaddpos('FScopeAround', a:c_f, priority)
    endif
    if !empty(a:c_f2)
        cal matchaddpos('FScopeAround', a:c_f2, priority)
    endif
endf

fu! s:clearhi() abort
    let _ = getmatches()->filter({_, v -> v.group =~ 'FScope.*'})->map({_, v -> matchdelete(v.id)})
endf

let s:tid = -1
fu! s:fmode.exe() abort
    let current_row = line('.')
    let col = col('.')
    let rows = get(g:, 'fscope_around_row', 5)
    for idx in range(-rows, rows)
        let target_row_no = current_row + idx
        cal self.scope(current_row, col, target_row_no, getline(target_row_no))
    endfor
    if get(g:, 'fscope_lazy_mode', 1)
        cal timer_stop(s:tid)
        let s:tid = timer_start(get(g:, 'fscope_lazy_time', 3000), {-> s:clearhi()})
    endif
endf

fu! s:fmode.set() abort
    cal s:clearhi()
    cal self.exe()
endf

let s:prev_bt = -1
fu! s:fmode.winleave() abort
    let s:prev_bt = &bt
endf

fu! s:fmode.winenter() abort
    let is_clear_windo = s:prev_bt != 'popup'
    let is_clear_windo = is_clear_windo && s:prev_bt != 'terminal'
    let is_clear_windo = is_clear_windo && &bt != 'popup'
    let is_clear_windo = is_clear_windo && &bt != 'terminal'
    if is_clear_windo
        let current_win = win_getid()
        windo cal getmatches()->filter({_, v -> v.group =~ 'FScope.*'})->map('execute("cal matchdelete(v:val.id)")')
        cal win_gotoid(current_win)
    endif
    cal self.exe()
endf

fu! s:fmode.activate() abort
    let self.flg = 1
    aug f_scope
        au!
        au CursorMoved * cal s:fmode.set()
        au WinLeave * cal s:fmode.winleave()
        au WinEnter * cal s:fmode.winenter()
    aug End
    cal self.set()
endf

fu! s:fmode.deactivate() abort
    let self.flg = 0
    aug f_scope
        au!
    aug End
    let current_win = win_getid()
    windo cal getmatches()->filter({_, v -> v.group =~ 'FScope.*'})->map('execute("cal matchdelete(v:val.id)")')
    cal win_gotoid(current_win)
endf

fu! s:fmode.toggle() abort
    let Func = self.flg ? self.deactivate : self.activate
    cal Func()
endf

fu! s:fmode.takeover() abort
    let Func = self.flg ? self.activate : self.deactivate
    cal Func()
endf

fu! fscope#activate() abort
    cal s:fmode.activate()
endf
fu! fscope#deactivate() abort
    cal s:fmode.deactivate()
endf
fu! fscope#toggle() abort
    cal s:fmode.toggle()
endf
fu! fscope#(bang, ...) abort
    if a:bang
        if a:0 == 0
            cal s:fmode.deactivate()
            retu
        elseif a:0 == 1
            if a:1 ==# '!'
                cal s:fmode.toggle()
                retu
            endif
        endif
        retu
    endif
    cal s:fmode.activate()
endf

