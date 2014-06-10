function! s:UpperIndentLimit(lineno)
  " handle the special case if the cursor is on a blank line
  let current_line = prevnonblank(a:lineno)
  let current_indent = indent(current_line)
  let prev_line = prevnonblank(current_line - 1)

  while prev_line > 0 && indent(prev_line) >= current_indent
    let prev_line = prevnonblank(prev_line - 1)
  endwhile
  return prev_line
endfunction

function! s:LowerIndentLimit(lineno)
  let current_line = nextnonblank(a:lineno)
  let current_indent = indent(current_line)
  let next_line = nextnonblank(current_line + 1)

  while next_line < line('$') && indent(next_line) >= current_indent
    let next_line = nextnonblank(next_line + 1)
  endwhile
  return next_line
endfunction

function! s:IndentTextObject(visual)
  let upper_limit = s:UpperIndentLimit('.')
  let lower_limit = s:LowerIndentLimit('.')

  call s:SelectLines(a:visual, upper_limit, lower_limit)
endfunction

function! s:SelectLines(visual, upper_limit, lower_limit)

  exe 'normal! '.a:upper_limit.'G0'
  if a:lower_limit > a:upper_limit
    exe 'normal! '.a:visual.(a:lower_limit - a:upper_limit).'j$'
  else
    exe 'normal! '.a:visual.'$'
  endif
endfunction

"class ->

  "asdf
  "asdf

  "asdf
  "asdf

  "asdf
  "asdf     
"asdf

function! s:FunctionTextObject(type)
  let current_line = line('.')
  call s:FindAndReturnSearchForPattern('[-=]>', a:type)
endfunction


function! s:ClassTextObject(type)
  let current_line = line('.')
  call s:FindAndReturnSearchForPattern('class ', a:type)
endfunction

function! s:FindAndReturnSearchForPattern(pattern, type)
  let pattern_line = search(a:pattern,'Wbnc')
  if pattern_line
    let next_line_to_function = nextnonblank(pattern_line + 1)
    let pattern_end = s:LowerIndentLimit(next_line_to_function)
    if a:type ==# 'a'
      call s:SelectLines(visualmode(), pattern_line, pattern_end - 1)
    else
      call s:SelectLines(visualmode(), pattern_line + 1, pattern_end - 1)
    endif
  endif
endfunction

onoremap if :<c-u>call <SID>FunctionTextObject('i')<cr>
onoremap af :<c-u>call <SID>FunctionTextObject('a')<cr>
xnoremap if :<c-u>call <SID>FunctionTextObject('i')<cr>
xnoremap af :<c-u>call <SID>FunctionTextObject('a')<cr>

onoremap ic :<c-u>call <SID>ClassTextObject('i')<cr>
onoremap ac :<c-u>call <SID>ClassTextObject('a')<cr>
xnoremap ic :<c-u>call <SID>ClassTextObject('i')<cr>
xnoremap ac :<c-u>call <SID>ClassTextObject('a')<cr>
