let s:pluginPath = expand('<sfile>:p:h') . '/..'

function! Complete(partialCommand)
    return systemlist(s:pluginPath . '/capture.zsh ' . a:partialCommand)
endfunction

function MakeCommandCompletion(ArgLead, CmdLine, CursorPos)
  let l:words = split(a:CmdLine)
  let l:command = join(l:words)
  return Complete(l:command)
endfunction

if exists('g:loaded_ntty')
  finish
endif
let g:loaded_ntty = 1
