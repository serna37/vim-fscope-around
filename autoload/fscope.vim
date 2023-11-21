if execute('sil! hi FScopeCurrentRowPrimary') =~ 'E411'
    aug fmode_colors
        au!
        au ColorScheme * hi FScopeCurrentRowPrimary ctermfg=204 cterm=underline
        au ColorScheme * hi FScopeCurrentRowSecondary ctermfg=81 cterm=underline
        au ColorScheme * hi FScopeAround cterm=underline
    aug END
    hi FScopeCurrentRowPrimary ctermfg=204 cterm=underline
    hi FScopeCurrentRowSecondary ctermfg=81 cterm=underline
    hi FScopeAround cterm=underline
endif


let s:fmode = #{flg: 1}

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

        " leading char is unique from cursor pos
        if start_ch[0] =~ '[0-9A-Za-z]' && stridx(track, start_ch[0]) == -1
            cal add(cs_f, [row_no, start_ch[2]])
            continue
        endif

        " from next char to last char
        for idx in range(start_ch[1], offset - 1)
            let char = r_txt[idx]
            if char =~ '[0-9A-Za-z]'
                cal add(stridx(track, char) == -1 ? cs_f : cs_f2, [row_no, idx + 1])
                break
            endif
        endfor

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

fu! s:fmode.set() abort
    let _ = getmatches()->filter({_, v -> v.group =~ 'FScope.*'})->map({_, v -> matchdelete(v.id)})
    let current_row = line('.')
    let col = col('.')
    let rows = get(g:, 'fscope_around_row', 5)
    for idx in range(-rows, rows)
        let target_row_no = current_row + idx
        cal self.scope(current_row, col, target_row_no, getline(target_row_no))
    endfor
endf

fu! s:fmode.activate() abort
    aug f_scope
        au!
        au CursorMoved * cal s:fmode.set()
    aug End
    cal self.set()
endf

fu! s:fmode.deactivate() abort
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
    let self.flg = !self.flg
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

if get(g:, 'fscope_init_active', 1)
    cal s:fmode.activate()
endif
