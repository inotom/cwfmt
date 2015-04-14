"
" File: autoload/cwfmt.vim
" file created in 2015/04/14 14:40:57.
" LastUpdated:2015/04/14 17:52:34.
" Author: iNo <wdf7322@yahoo.co.jp>
" Version: 1.0
" License: MIT License {{{
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"

if !exists('g:loaded_cwfmt')
  runtime! plugin/cwfmt.vim
endif

let s:save_cpo = &cpo
set cpo&vim

" state constant
let s:NORMAL_STATE = 0
let s:INFO_STATE   = 1
let s:CODE_STATE   = 2

let s:state = s:NORMAL_STATE

let s:EMPTY_INFO_BUF = 0
let s:HAS_INFO_BUF   = 1

let s:hasInfoBuf = s:EMPTY_INFO_BUF

" convert title with chatwork tag
function! s:getTitle(str)
  return "[title]" . substitute(a:str, '^#\s\+', '', '') . "[/title]"
endfunction

" parse line on normal state
function! s:parseNormalStateLine(str)
  let newLine = ""

  if a:str =~ '^==='
    let newLine = "[info]"
    let s:state = s:INFO_STATE
    let s:hasInfoBuf = s:HAS_INFO_BUF
  elseif a:str =~'^#\s'
    let newLine = s:getTitle(a:str)
  elseif a:str =~ '^---'
    let newLine = "[hr]"
  elseif a:str =~ '^```'
    let newLine = "[info][code]"
    let s:state = s:CODE_STATE
  else
    let newLine = a:str
  endif

  return newLine
endfunction

" parse line on all states
function! s:parseLine(str)
  let newLine = ""

  if s:state == s:NORMAL_STATE
    return s:parseNormalStateLine(a:str)
  elseif s:state == s:INFO_STATE
    if a:str =~ '^==='
      let newLine = "[/info]"
      let s:state = s:NORMAL_STATE
    elseif a:str =~ '^#\s'
      let newLine = s:getTitle(a:str)
    else
      let newLine = a:str
      let s:hasInfoBuf = s:EMPTY_INFO_BUF
    endif
  elseif s:state == s:CODE_STATE
    if a:str =~ '^```'
      let newLine = "[/code][/info]"
      let s:state = s:NORMAL_STATE
    else
      let newLine = a:str
    endif
  endif

  return newLine
endfunction

function! cwfmt#put()
  " get current buffers whole lines
  let line = getline(0, '$')

  " open scratch buffer
  exec ":Scratch"

  " clear scratch buffer
  exec ":0,%delete"

  let lineBuf = ""
  let index = 1

  for l in line
    let lineBuf = lineBuf . s:parseLine(l)

    if !s:hasInfoBuf
      call setline(index, lineBuf)
      let index = index + 1
      let lineBuf = ""
      let s:hasInfoBuf = s:EMPTY_INFO_BUF
    endif
  endfor
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:fdl=0 fdm=marker:ts=2 sw=2 sts=0:
