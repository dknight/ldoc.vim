" http://vimdoc.sourceforge.net/htmldoc/usr_41.html
" xdkn1ght (http://www.whoop.ee)

"""""""""""""""""""""""""""""
" Utility functions.
"""""""""""""""""""""""""""""
function! s:warnMsg(msg)
	echohl WarningMsg
	echo a:msg
	echohl None
endfunction

" Conflict detection for loading of this plug-in
if exists("loaded_ldoc_ddc")
	call s:warnMsg("Ldoc already loaded!")
	finish
endif
let loaded_ldoc_ddc = 1

"""""""""""""""""""""""""""""
" Global variables.
"""""""""""""""""""""""""""""
if !exists("g:ldoc_startBeginCommentTag")
	let g:ldoc_startBeginCommentTag = "----------------------------------------"
endif
if !exists("g:ldoc_startEndCommentTag")
	let g:ldoc_startEndCommentTag   = "----------------------------------------"
endif
if !exists("g:ldoc_startNoteCommentTag")
	let g:ldoc_startNoteCommentTag = "--- "
endif
if !exists("g:ldoc_startFlagCommentTag")
	let g:ldoc_startFlagCommentTag = "-- "
endif


"""""""""""""""""""""""""""""
" Global flag variables.
"""""""""""""""""""""""""""""
if !exists("g:ldoc_flagAuthor")
	let g:ldoc_flagAuthor = "@author "
endif
if !exists("g:ldoc_flagType")
	let g:ldoc_flagType = "@type "
endif
if !exists("g:ldoc_flagParam")
	let g:ldoc_flagParam = "@param "
endif
if !exists("g:ldoc_flagReturn")
	let g:ldoc_flagReturn = "@return "
endif

"""""""""""""""""""""""""""""
" Write functions.
" See `append` function for details, parameter 2 can be passed directly 
" into the arguments' list.
"""""""""""""""""""""""""""""
function! s:writeToNextLine(str)
	call append(line("."), a:str)
endfunction
function! s:writeToPrevLine(str)
	call append(line(".")-1, a:str)
endfunction

"""""""""""""""""""""""""""""
" Module ldoc comments.
"""""""""""""""""""""""""""""
function! <SID>ldoc_moduleComment()
	if !exists("g:ldoc_authorName")
		let g:ldoc_authorName = input("Enter the author's name (default `whoami`): ")
	endif
	if(strlen(g:ldoc_authorName) == 0)
		let l:whoami = system("whoami")
		let g:ldoc_authorName = substitute(l:whoami, '\n', "", "")
		echo g:ldoc_authorName
	endif
	let l:moduleDesc = input("Description of the module: ")
	mark l
	let l:writeText = [g:ldoc_startBeginCommentTag]
	let l:markJump = 0
	let l:str = g:ldoc_startNoteCommentTag
	if(strlen(l:moduleDesc) == 0)
		let l:markJump = 1
	else
		let l:str = l:str . l:moduleDesc
	endif
	call add(l:writeText, l:str)
	call add(l:writeText, g:ldoc_startFlagCommentTag . g:ldoc_flagAuthor . g:ldoc_authorName)
	call add(l:writeText, g:ldoc_startEndCommentTag)
	call s:writeToPrevLine(l:writeText)
	if(l:markJump == 1)
		exec "normal " . (line(".") - len(l:writeText) + 1) . "G$"
	else
		exec "normal 'l"
	endif
endfunction

"""""""""""""""""""""""""""""
" Type ldoc comments.
"""""""""""""""""""""""""""""
function! <SID>ldoc_typeComment()
	let l:curLineStr = getline(line("."))
	let l:typeNameList = matchlist(l:curLineStr, 'local[ \t]\+\([a-zA-Z0-9_]\+\)[ \t]\+')
	if(len(l:typeNameList) < 2)
		call s:warnMsg("Failed to get type")
		return
	endif
	let l:typeName = l:typeNameList[1]
	let l:typeDesc = input("Description of the input type: ")
	mark l
	let l:writeText = []
	let l:markJump = 0
	let l:str = g:ldoc_startNoteCommentTag
	if(strlen(l:typeDesc) == 0)
		let l:markJump = 1
	else
		let l:str = l:str . l:typeDesc
	endif
	call add(l:writeText, l:str)
	call add(l:writeText, g:ldoc_startFlagCommentTag . g:ldoc_flagType . l:typeName)
	call s:writeToPrevLine(l:writeText)
	if(l:markJump == 1)
		exec "normal " . (line(".") - len(l:writeText)) . "G$"
	else
		exec "normal 'l"
	endif
endfunction

"""""""""""""""""""""""""""""
" Function ldoc comments.
"""""""""""""""""""""""""""""
function! <SID>ldoc_functionComment()
	let l:curLineStr = getline(line("."))
	let l:paramList = matchlist(l:curLineStr, 'function[ \t]\+\([a-zA-Z0-9_.:]\+\)[ \t]*(\([a-zA-Z0-9_, \t\.]*\))')
	if(len(l:paramList) >= 2)
	else
		let l:paramList = matchlist(l:curLineStr, '\([a-zA-Z0-9_]\+\)[ \t]*=[ \t]*function[ \t]*(\([a-zA-Z0-9_, \t\.]*\))')
		if(len(l:paramList) < 2)
			call s:warnMsg("Failed to get the function")
			return
		endif
	endif
	let l:funcName = l:paramList[1]
	if(len(l:paramList) > 3)
		let l:paramList = split(l:paramList[2], '[ \t]*,[ \t]*')
		let l:paramList2 = []
		for l:ele in l:paramList
			call add(l:paramList2, substitute(l:ele, '[ \t]+', "", ""))
		endfor
	endif
	mark l
	let l:funcDesc = input("Function [" . l:funcName . "] description: ")
	let l:writeText = []
	let l:str = g:ldoc_startNoteCommentTag
	let l:markJump = 0
	if(strlen(l:funcDesc) == 0)
		let l:markJump = 1
	else
		let l:str = l:str . l:funcDesc
	endif
	call add(l:writeText, l:str)
	for l:ele in l:paramList2
		let l:str = g:ldoc_startFlagCommentTag . g:ldoc_flagParam . l:ele
		let l:paramDesc = input("Argument [" . l:ele . "] description: ")
		if(strlen(l:paramDesc) > 0)
			let l:str = l:str . "\t" . l:paramDesc
		endif
		call add(l:writeText, l:str)
	endfor
	let l:funcReturn = input("Return value description: ")
	let l:return =  g:ldoc_startFlagCommentTag . g:ldoc_flagReturn . l:funcReturn
	call add(l:writeText, l:return)
	call s:writeToPrevLine(l:writeText)
	if(l:markJump == 1)
		exec "normal " . (line(".") - len(l:writeText)) . "G$"
	else
		exec "normal 'l"
	endif
endfunction


"""""""""""""""""""""""""""""
" Shortcuts' key mappings 
"""""""""""""""""""""""""""""
command! -nargs=0 LdocM :call <SID>ldoc_moduleComment()
command! -nargs=0 LdocT :call <SID>ldoc_typeComment()
command! -nargs=0 LdocF :call <SID>ldoc_functionComment()

