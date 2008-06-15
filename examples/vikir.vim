" vikir.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Name:             vikir
" Description:      vi wiki in ruby
" Author:           remi Taylor  <remi@remitaylor.com>
" Maintainer:       -- '' --
"
" Licence:          This program is free software; you can redistribute it
"                   and/or modify it under the terms of the GNU General Public
"                   License.  See http://www.gnu.org/copyleft/gpl.txt
"
" Credits:          
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" hello angry vim hacker
"
" you wanna see lots and lots and lots and lots and lots
" of jazz here with things like <unique> <silent> <SID> 
" all over the place
"
" well, sorry to disappoint you ... 
"
" this and vikir.rb are all you'll find here!

if &cp || (exists("g:loaded_vikir") && g:loaded_vikir)
	finish
endif

rubyf ~/.vim/plugin/vikir.rb

let g:loaded_vikir = 1
