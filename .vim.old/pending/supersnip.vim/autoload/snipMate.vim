fun! Filename(...)
	let filename = expand('%:t:r')
	if filename == '' | return a:0 == 2 ? a:2 : '' | endif
	return !a:0 || a:1 == '' ? filename : substitute(a:1, '$1', filename, 'g')
endf
fun	snipMate#removeSnippet()
	aug! snipMateAutocmds
	unl! g:snipPos s:curPos s:snipLen s:endCol s:endLine s:prevLen
	unl! s:curPos s:snipLen s:endCol s:endLine s:prevLen
	     \ s:lastBuf s:oldWord
	unl! s:startCol s:origWordLen s:update
	unl! s:oldVars s:oldEndCol
endf
fun snipMate#removeSnippetBak()
	unl! g:snipPos s:curPos s:snipLen s:endCol s:endLine s:prevLen
	unl! s:curPos s:snipLen s:endCol s:endLine s:prevLen
	     \ s:lastBuf s:oldWord
	if exists('s:origWordLen')
		unl s:origWordLen
	endif
	if exists('s:update')
		unl! s:startCol s:origWordLen s:update
		if exists('s:oldVars') | unl s:oldVars s:oldEndCol | endif
	endif
	aug! snipMateAutocmds
endf
fun snipMate#p()
	if exists('g:snipPos')
		for tmp1 in g:snipPos
			echoe "\n".tmp1[0] .', '.tmp1[1].', '.tmp1[2]
		endfor
	else
		echoe 'not exists g:snipPos at: line'.line('.')
	endif
endf
fun snipMate#expandSnip(snip, col,indent)
	let lnum = line('.') | let col = a:col

	let snippet = s:ProcessSnippet(a:snip)
	" Avoid error if eval evaluates to nothing
	if snippet == '' | return '' | endif

	" Expand snippet onto current position with the tab stops removed
	let snipLines = split(substitute(snippet, '$\d\+\|${\d\+.\{-}}', '', 'g'), "\n", 1)
	let g:lastLine = snipLines[-1]
	let g:totalLine = len(snipLines)

	let line = getline(lnum)
	let afterCursor = strpart(line, col - 1)
	" Keep text after the cursor
	if afterCursor != "\t" && afterCursor != ' '
		let line = strpart(line, 0, col - 1)
		let snipLines[-1] .= afterCursor
	else
		let afterCursor = ''
		" For some reason the cursor needs to move one right after this
		if line != '' && col == 1 && &ve != 'all' && &ve != 'onemore'
			let col += 1
		endif
	endif

	call setline(lnum, line.snipLines[0])
	" Autoindent snippet according to previous indentation
	"let indent = matchend(line, '^.\{-}\ze\(\S\|$\)') + 1
	"call append(lnum, map(snipLines[1:], "'".strpart(line, 0, indent - 1)."'.v:val"))
	"call feedkeys(strpart(line,0,indent-1))
	"修改：第一行以后自动下向第一行对齐
	let indent = matchend(line, '^.\{}\ze\(\S\|$\)') + 1
	let line1 = substitute(copy(line),'[^\t]',' ','g')
	let g:indent = a:indent==-1? indent : a:indent
	let indent = a:indent==-1? indent : a:indent
	let g:indentWord=strpart(line1, 0, g:indent - 1)
	call append(lnum, map(snipLines[1:], "'".strpart(line1, 0, indent - 1)."'.v:val"))

	" Open any folds sni  ppet expands into
	if &fen | sil! exe lnum.','.(lnum + len(snipLines) - 1).'foldopen' | endif


	let [g:snipPos, s:snipLen] = s:BuildTabStops(snippet, lnum, col - indent, indent)
"	for tmp in g:snipPos
"		call feedkeys("\n".tmp[0]."--".tmp[1])
"	endfor	

	if s:snipLen
		aug snipMateAutocmds
			au CursorMovedI * call s:UpdateChangedSnip(0)
			au InsertEnter * call s:UpdateChangedSnip(1)
		aug END
		let s:lastBuf = bufnr(0) " Only expand snippet while in current buffer
		let s:curPos = 0
		let s:endCol = g:snipPos[s:curPos][1]
		let s:endLine = g:snipPos[s:curPos][0]

		call cursor(g:snipPos[s:curPos][0], g:snipPos[s:curPos][1])
		let s:prevLen = [line('$'), col('$')]
		if g:snipPos[s:curPos][2] != -1 | return s:SelectWord() | endif
	else
		unl g:snipPos s:snipLen
		" Place cursor at end of snippet if no tab stop is given
		let newlines = len(snipLines) - 1
		call cursor(lnum + newlines, indent + len(snipLines[-1])  - len(afterCursor)
					\ + (newlines ? 0: col - 1))
	endif
	return ''
endf

" Prepare snippet to be processed by s:BuildTabStops
fun s:ProcessSnippet(snip)
	let snippet = a:snip
	" Evaluate eval (`...`) expressions.
	" Using a loop here instead of a regex fixes a bug with nested "\=".
	if stridx(snippet, '`') != -1
		while match(snippet, '`.\{-}`') != -1
			let snippet = substitute(snippet, '`.\{-}`',
						\ substitute(eval(matchstr(snippet, '`\zs.\{-}\ze`')),
						\ "\n\\%$", '', ''), '')
		endw
		let snippet = substitute(snippet, "\r", "\n", 'g')
	endif

	" Place all text after a colon in a tab stop after the tab stop
	" (e.g. "${#:foo}" becomes "${:foo}foo").
	" This helps tell the position of the tab stops later.
	let snippet = substitute(snippet, '${\d\+:\(.\{-}\)}', '&\1', 'g')
	" Update the a:snip so that all the $# become the text after
	" the colon in their associated ${#}.
	" (e.g. "${1:foo}" turns all "$1"'s into "foo")
	let i = 1
	while stridx(snippet, '${'.i) != -1
		let s = matchstr(snippet, '${'.i.':\zs.\{-}\ze}')
		if s != ''
			let snippet = substitute(snippet, '$'.i, s.'&', 'g')
		endif
		let i += 1
	endw

	if &et " Expand tabs to spaces if 'expandtab' is set.
		return substitute(snippet, '\t', repeat(' ', &sts ? &sts : &sw), 'g')
	endif
	return snippet
endf

" Counts occurences of haystack in needle
fun s:Count(haystack, needle)
	let counter = 0
	let index = stridx(a:haystack, a:needle)
	while index != -1
		let index = stridx(a:haystack, a:needle, index+1)
		let counter += 1
	endw
	return counter
endf

" Builds a list of a list of each tab stop in the snippet containing:
" 1.) The tab stop's line number.
" 2.) The tab stop's column number
"     (by getting the length of the string between the last "\n" and the
"     tab stop).
" 3.) The length of the text after the colon for the current tab stop
"     (e.g. "${1:foo}" would return 3). If there is no text, -1 is returned.
" 4.) If the "${#:}" construct is given, another list containing all
"     the matches of "$#", to be replaced with the placeholder. This list is
"     composed the same way as the parent; the first item is the line number,
"     and the second is the column.
fun s:BuildTabStops(snip, lnum, col, indent)
	let snipPos = []
	let i = 1
	let withoutVars = substitute(a:snip, '$\d\+', '', 'g')
	while stridx(a:snip, '${'.i) != -1
		let beforeTabStop = matchstr(withoutVars, '^.*\ze${'.i.'\D')
		let withoutOthers = substitute(withoutVars, '${\('.i.'\D\)\@!\d\+.\{-}}', '', 'g')

		let j = i - 1
		call add(snipPos, [0, 0, -1])
		let snipPos[j][0] = a:lnum + s:Count(beforeTabStop, "\n")
		let snipPos[j][1] = a:indent + len(matchstr(withoutOthers, '.*\(\n\|^\)\zs.*\ze${'.i.'\D'))
		if snipPos[j][0] == a:lnum | let snipPos[j][1] += a:col | endif

		" Get all $# matches in another list, if ${#:name} is given
		if stridx(withoutVars, '${'.i.':') != -1
			let snipPos[j][2] = len(matchstr(withoutVars, '${'.i.':\zs.\{-}\ze}'))
			let dots = repeat('.', snipPos[j][2])
			call add(snipPos[j], [])
			let withoutOthers = substitute(a:snip, '${\d\+.\{-}}\|$'.i.'\@!\d\+', '', 'g')
			while match(withoutOthers, '$'.i.'\(\D\|$\)') != -1
				let beforeMark = matchstr(withoutOthers, '^.\{-}\ze'.dots.'$'.i.'\(\D\|$\)')
				call add(snipPos[j][3], [0, 0])
				let snipPos[j][3][-1][0] = a:lnum + s:Count(beforeMark, "\n")
				let snipPos[j][3][-1][1] = a:indent + (snipPos[j][3][-1][0] > a:lnum
				                           \ ? len(matchstr(beforeMark, '.*\n\zs.*'))
				                           \ : a:col + len(beforeMark))
				let withoutOthers = substitute(withoutOthers, '$'.i.'\ze\(\D\|$\)', '', '')
				
				"call feedkeys(withoutOthers)
			endw
		endif
		let i += 1
	endw
	return [snipPos, i - 1]
endf

fun snipMate#getNewWord()
	let tmpCl = col('.')
	if g:snipPos[s:curPos][2]>=0 && exists('s:oldWord')
		let newW = s:oldWord 
	else
		let newW = g:snipPos[s:curPos][2]==-2||g:snipPos[s:curPos][2]==-1 ? strpart(getline("."),g:snipPos[s:curPos][1]-1,s:endCol-g:snipPos[s:curPos][1]):''
	endif

	"let newW = strpart(getline("."),g:snipPos[s:curPos][1]-1,s:endCol-g:snipPos[s:curPos][1])
	let triggers = []
	let newTrigger = matchstr(newW,'\.\w\{1,}$')
	let newWidth = len(newW)-len(newTrigger)
	let newStart = tmpCl-len(newTrigger)
	call add(triggers,[newTrigger,newStart,newWidth])

	let newTrigger = matchstr(newW,'\S\{1,}$')
	let newWidth = len(newW)-len(newTrigger)
	let newStart = tmpCl-len(newTrigger)
	call add(triggers,[newTrigger,newStart,newWidth])

	let newTrigger = matchstr(newW,'\W\{1,}$')
	let newWidth = len(newW)-len(newTrigger)
	let newStart = tmpCl-len(newTrigger)
	call add(triggers,[newTrigger,newStart,newWidth])

	let newTrigger = matchstr(newW,'\h\{1,}$')
	let newWidth = len(newW)-len(newTrigger)
	let newStart = tmpCl-len(newTrigger)
	call add(triggers,[newTrigger,newStart,newWidth])

	let newTrigger = matchstr(newW,'\w\{1,}$')
	let newWidth = len(newW)-len(newTrigger)
	let newStart = tmpCl-len(newTrigger)
	call add(triggers,[newTrigger,newStart,newWidth])

	let newTrigger = matchstr(newW,'\H\{1,}$')
	let newWidth = len(newW)-len(newTrigger)
	let newStart = tmpCl-len(newTrigger)
	call add(triggers,[newTrigger,newStart,newWidth])

	
	"return [newTrigger,newStart,newWidth]
	return triggers
endf




fun snipMate#getNewWordBak()
	let tmpCl = col('.')
	if g:snipPos[s:curPos][2]>=0 && exists('s:oldWord')
		let newW = s:oldWord 
	else
		let newW = g:snipPos[s:curPos][2]==-2||g:snipPos[s:curPos][2]==-1 ? strpart(getline("."),g:snipPos[s:curPos][1]-1,s:endCol-g:snipPos[s:curPos][1]):''
	endif

	"let newW = strpart(getline("."),g:snipPos[s:curPos][1]-1,s:endCol-g:snipPos[s:curPos][1])
	let newTrigger = matchstr(newW,'\S\{1,}$')
	let newWidth = len(newW)-len(newTrigger)
	let newStart = tmpCl-len(newTrigger)

	return [newTrigger,newStart,newWidth]
endf



fun snipMate#getCurPos()
	return s:curPos
endf
fun snipMate#setCurPos(pos)
	let s:curPos = a:pos
endf
fun snipMate#setSnipLen(len)
	let s:snipLen=a:len
endf
fun snipMate#getSnipLen()
	get s:snipLen
endf

fun snipMate#jumpTabStop(backwards)
"	call snipMate#p()
	"echo 'in snipMate#jumpTabStop'
	let leftPlaceholder = exists('s:origWordLen')
	                      \ && s:origWordLen != g:snipPos[s:curPos][2]

	if leftPlaceholder && exists('s:oldEndCol')
		let startPlaceholder = s:oldEndCol + 1
	endif
	

	if exists('s:update')
		call s:UpdatePlaceholderTabStops()
	else
		call s:UpdateTabStops()
	endif

	" Don't reselect placeholder if it has been modified
	if leftPlaceholder && g:snipPos[s:curPos][2] != -1
		if exists('startPlaceholder')
			let g:snipPos[s:curPos][1] = startPlaceholder
		else

			if exists('g:inFlag1')
				unl g:inFlag1
			endif
				let g:snipPos[s:curPos][1] = col('.')
				let g:snipPos[s:curPos][2] = 0
		endif
	endif

	let nextLP = s:snipLen-1
	let nextY = g:snipPos[s:snipLen-1][0]
	let nextX = g:snipPos[s:snipLen-1][1]
	let prevLP = 0
	let prevY = g:snipPos[0][0]
	let prevX = g:snipPos[0][1]
	let nextLPe = s:snipLen-1
	let nextYe = g:snipPos[s:snipLen-1][0]
	let nextXe = g:snipPos[s:snipLen-1][1]
	let prevLPe = 0
	let prevYe = g:snipPos[0][0]
	let prevXe = g:snipPos[0][1]
	let num = 0
	for pos in g:snipPos
		"echoe pos[0] .'---'.s:curPos .'---'.g:snipPos[s:curPos][0] .'---'. prevLP .'---'. prevY .'---'. prevX
		"echo pos[0] .'---'.s:curPos .'---'.g:snipPos[s:curPos][0] .'---'. nextLP .'---'. nextY .'---'.nextX
		if pos[0] == g:snipPos[s:curPos][0]
				if pos[0] < prevY
					let prevLP = num
					let prevY = pos[0]
					let prevX = pos[1]

						let prevLPe = num
						let prevYe = pos[0]
						let prevXe = pos[1]
				elseif pos[0] == prevY
					if pos[1]<prevX
						let prevLP = num
						let prevY = pos[0]
						let prevX = pos[1]
					elseif pos[1]>prevXe
						let prevLPe = num
						let prevYe = pos[0]
						let prevXe = pos[1]
					endif
				endif


				if pos[0] > nextY
					let nextLP = num
					let nextY = pos[0]
					let nextX = pos[1]
					
						let nextLPe = num
						let nextYe = pos[0]
						let nextXe = pos[1]
				elseif pos[0] == nextY
					if pos[1]<nextX
						let nextLP = num
						let nextY = pos[0]
						let nextX = pos[1]
					elseif pos[1]>nextXe
						let nextLPe = num
						let nextYe = pos[0]
						let nextXe = pos[1]
					endif
				endif

		elseif pos[0] < g:snipPos[s:curPos][0]
				if pos[0] > prevY
					let prevLP = num
					let prevY = pos[0]
					let prevX = pos[1]

						let prevLPe = num
						let prevYe = pos[0]
						let prevXe = pos[1]
				elseif pos[0]==prevY
					if pos[1]<prevX
						let prevLP = num
						let prevY = pos[0]
						let prevX = pos[1]
					elseif pos[1]>prevXe
						let prevLPe = num
						let prevYe = pos[0]
						let prevXe = pos[1]
					endif
				else
					if prevY >= g:snipPos[s:curPos][0]
						let prevLP = num
						let prevY = pos[0]
						let prevX = pos[1]

						let prevLPe = num
						let prevYe = pos[0]
						let prevXe = pos[1]
					endif
				endif
		elseif pos[0] > g:snipPos[s:curPos][0]
				if pos[0] < nextY
					let nextLP = num
					let nextY = pos[0]
					let nextX = pos[1]

						let nextLPe = num
						let nextYe = pos[0]
						let nextXe = pos[1]
				elseif pos[0]==nextY
					if pos[1]<nextX
						let nextLP = num
						let nextY = pos[0]
						let nextX = pos[1]
					elseif pos[1]>nextXe
						let nextLPe = num
						let nextYe = pos[0]
						let nextXe = pos[1]
					endif
				else
					if nextY <= g:snipPos[s:curPos][0]
						let nextLP = num
						let nextY = pos[0]
						let nextX = pos[1]

						let nextLPe = num
						let nextYe = pos[0]
						let nextXe = pos[1]
					endif
				endif
		endif
		let num +=1
	endfor
"echoe prevLP .'---'.nextLP
	if a:backwards == -1
		let s:curPos += 1
	elseif a:backwards == -2
		let s:curPos -= 1
	elseif a:backwards == "j"
		let s:curPos = nextLP
	elseif a:backwards == "k"
		let s:curPos = prevLP
	elseif a:backwards == "l" 
		let s:curPos = nextLPe
	elseif a:backwards == "h"
		let s:curPos = prevLPe
	elseif a:backwards >=0
		let s:curPos = a:backwards
	end
"	echoe s:curPos
"	let s:curPos += a:backwards==1 ? -1 : 1
	" Loop over the snippet when going backwards from the beginning
	if s:curPos < 0 | let s:curPos = s:snipLen - 1 | endif

	if s:curPos == s:snipLen
		let sMode = s:endCol == g:snipPos[s:curPos-1][1]+g:snipPos[s:curPos-1][2]
		call snipMate#removeSnippet()
		return sMode ? "\<tab>" : TriggerSnippet()
	endif

	call cursor(g:snipPos[s:curPos][0], g:snipPos[s:curPos][1])
	let s:endLine = g:snipPos[s:curPos][0]
	let s:endCol = g:snipPos[s:curPos][1]
	let s:prevLen = [line('$'), col('$')]

	let s:tempvar =  g:snipPos[s:curPos][2] == -1 ? '' : s:SelectWord()
	return s:tempvar
	"return g:snipPos[s:curPos][2] == -1 ? '' : s:SelectWord()
endf
fun snipMate#setCurSnipPos(curPos)
	let s:curPos = a:curPos
"	call cursor(g:snipPos[a:curPos][0], g:snipPos[a:curPos][1])
	let s:endLine = g:snipPos[a:curPos][0]
	let s:endCol = g:snipPos[a:curPos][1]
	let s:prevLen = [line('$'), col('$')]
endf

fun s:UpdatePlaceholderTabStops()
	let changeLen = s:origWordLen - g:snipPos[s:curPos][2]
	unl s:startCol s:origWordLen s:update
	if !exists('s:oldVars') | return | endif
	" Update tab stops in snippet if text has been added via "$#"
	" (e.g., in "${1:foo}bar$1${2}").
	if changeLen != 0
		let curLine = line('.')

		for pos in g:snipPos
			if pos == g:snipPos[s:curPos] | continue | endif
			let changed = pos[0] == curLine && pos[1] > s:oldEndCol
			let changedVars = 0
			let endPlaceholder = pos[2] - 1 + pos[1]
			" Subtract changeLen from each tab stop that was after any of
			" the current tab stop's placeholders.
			for [lnum, col] in s:oldVars
				if lnum > pos[0] | break | endif
				if pos[0] == lnum
					if pos[1] > col || (pos[2] == -1 && pos[1] == col)
						let changed += 1
					elseif col < endPlaceholder
						let changedVars += 1
					endif
				endif
			endfor
			let pos[1] -= changeLen * changed
			let pos[2] -= changeLen * changedVars " Parse variables within placeholders
                                                  " e.g., "${1:foo} ${2:$1bar}"

			if pos[2] == -1 | continue | endif
			" Do the same to any placeholders in the other tab stops.
			for nPos in pos[3]
				let changed = nPos[0] == curLine && nPos[1] > s:oldEndCol
				for [lnum, col] in s:oldVars
					if lnum > nPos[0] | break | endif
					if nPos[0] == lnum && nPos[1] > col
						let changed += 1
					endif
				endfor
				let nPos[1] -= changeLen * changed
			endfor
		endfor
	endif
	unl s:endCol s:oldVars s:oldEndCol
endf

fun s:UpdateTabStops()
	let changeLine = s:endLine - g:snipPos[s:curPos][0]
	let changeCol = s:endCol - g:snipPos[s:curPos][1]
	if exists('s:origWordLen')
		let changeCol -= s:origWordLen
		unl s:origWordLen
	endif
	let lnum = g:snipPos[s:curPos][0]
	let col = g:snipPos[s:curPos][1]
	" Update the line number of all proceeding tab stops if <cr> has
	" been inserted.
	if changeLine != 0
		let changeLine -= 1
		for pos in g:snipPos
			if pos[0] >= lnum
				if exists('g:inFlag')
"					echo 'exists g:inFlag'
				else
					if pos[0] == lnum | let pos[1] += changeCol | endif
				endif
				let pos[0] += changeLine
			endif
			if pos[2] == -1 | continue | endif
			for nPos in pos[3]
				if nPos[0] >= lnum
					if nPos[0] == lnum | let nPos[1] += changeCol | endif
					let nPos[0] += changeLine
				endif
			endfor
		endfor
	elseif changeCol != 0
		" Update the column of all proceeding tab stops if text has
		" been inserted/deleted in the current line.
	"	if exists('g:inFlag') && g:inFlag==1		
	"		unl g:inFlag
	"		echoe 'g:inFlag'
"		echoe 'unl g:inFlag'
	"	else
		for pos in g:snipPos
			if pos[1] >= col && pos[0] == lnum
				let pos[1] += changeCol
			endif
			if pos[2] == -1 | continue | endif
			for nPos in pos[3]
				if nPos[0] > lnum | break | endif
				if nPos[0] == lnum && nPos[1] >= col
					let nPos[1] += changeCol
				endif
			endfor
		endfor

"	echoe 'no inFlag'
"	call snipMate#p()



	"	endif
	endif
endf
fun s:SelectWord()
	let s:origWordLen = g:snipPos[s:curPos][2]
	let s:oldWord = strpart(getline('.'), g:snipPos[s:curPos][1] - 1,
				\ s:origWordLen)
	let s:prevLen[1] -= s:origWordLen
	if !empty(g:snipPos[s:curPos][3])
		let s:update = 1
		let s:endCol = -1
		let s:startCol = g:snipPos[s:curPos][1] - 1
	endif
	if !s:origWordLen 
	   	return '' 
	endif
	let l = col('.') != 1 ? 'l' : ''
	if &sel == 'exclusive'
		return "\<esc>".l.'v'.s:origWordLen."l\<c-g>"
	endif
	return s:origWordLen == 1 ? "\<esc>".l.'gh'
							\ : "\<esc>".l.'v'.(s:origWordLen - 1)."l\<c-g>"
endf

" This updates the snippet as you type when text needs to be inserted
" into multiple places (e.g. in "${1:default text}foo$1bar$1",
" "default text" would be highlighted, and if the user types something,
" UpdateChangedSnip() would be called so that the text after "foo" & "bar"
" are updated accordingly)
"
" It also automatically quits the snippet if the cursor is moved out of it
" while in insert mode.
fun s:UpdateChangedSnip(entering)
	if exists('g:cancelAu')
		if g:cancelAu==0	
			let g:cancelAu += 1
		elseif g:cancelAu==1
			unl g:cancelAu
		endif
		return ''
	endif

"	echoe 'ins:UpdateChangedSnip'
	if exists('g:snipPos') && bufnr(0) != s:lastBuf
		call snipMate#removeSnippet()
	elseif exists('s:update') " If modifying a placeholder
"		echo 'exists s:update'
		"call snipMate#p()
		if !exists('s:oldVars') && s:curPos + 1 < s:snipLen
			" Save the old snippet & word length before it's updated
			" s:startCol must be saved too, in case text is added
			" before the snippet (e.g. in "foo$1${2}bar${1:foo}").
			let s:oldEndCol = s:startCol
			let s:oldVars = deepcopy(g:snipPos[s:curPos][3])
		endif
		let col = col('.') - 1


"		echoe s:endCol
		if s:endCol != -1
			let changeLen = col('$') - s:prevLen[1]
			let s:endCol += changeLen
		else " When being updated the first time, after leaving select mode
			if a:entering | return | endif
			let s:endCol = col - 1
		endif

		" If the cursor moves outside the snippet, quit it
		if (line('.') != g:snipPos[s:curPos][0] && line('.') != g:snipPos[s:curPos][0]+1)|| col < s:startCol ||
					\ col - 1 > s:endCol

			let posL = g:snipPos[s:curPos][0] 
			let posC = g:snipPos[s:curPos][1]
			let lnum = line('.')
			if  lnum== posL+1




				let snipPosTmp = []
				call add(snipPosTmp,[0,0,-1])
				let num = 0
				for pos in g:snipPos
					call add(snipPosTmp,[0,0,-1])
					if pos[0] > posL
						let pos[0] += 1	
					elseif pos[0]==posL && pos[1]>=posC
						"echoe col.'--'.s:endCol
						let pos[0] += 1
						let oriCol = len(getline(lnum-1))
						let curCol = col('.')
						let changedLen = oriCol-curCol
						let pos[1] -= changedLen+1
					endif
					if exists('pos[3]')
						for pos3 in pos[3]
							if pos3[0] > posL
								let pos3[0] += 1
							elseif pos3[0]==posL&&pos3[1]>=posC
								let pos3[0] += 1
								let oriCol = len(getline(lnum-1))
								let curCol = col('.')
								let changedLen = oriCol-curCol
								let pos3[1] -= changedLen+1
							endif
						endfor
					endif
					if num < s:curPos
						let snipPosTmp[num]=g:snipPos[num]
					else
						let snipPosTmp[num+1]=g:snipPos[num]
					endif
					let num +=1
				endfor
					let snipPosTmp[s:curPos] = [lnum-1,len(getline(lnum-1))+1,-1]
					let g:snipPos = snipPosTmp
					call snipMate#setSnipLen(len(g:snipPos))
					let s:curPos +=1


			else
				unl! s:startCol s:origWordLen s:oldVars s:update
				return snipMate#removeSnippet()
			endif
		endif
		call s:UpdateVars()
		let s:prevLen[1] = col('$')
	elseif exists('g:snipPos')
		if g:snipPos[s:curPos][2]!=-1&&g:snipPos[s:curPos][2]!=-2	
			let g:selN = g:snipPos[s:curPos][2]
		endif
		if !a:entering && g:snipPos[s:curPos][2] != -1
			let g:snipPos[s:curPos][2] = -2
		endif

		let col = col('.')
		let lnum = line('.')
		let changeLine = line('$') - s:prevLen[0]
		if lnum == s:endLine||lnum==s:endLine+1
			let s:endCol += col('$') - s:prevLen[1]
			let s:prevLen = [line('$'), col('$')]
		endif
		if changeLine != 0
			let s:endLine += changeLine
			let s:endCol = col
		endif

	"	echoe lnum . '---' . s:endLine . '----' . g:snipPos[s:curPos][0]
		if (lnum == s:endLine && (col > s:endCol || col < g:snipPos[s:curPos][1]-1))
			\ || lnum > s:endLine || lnum < g:snipPos[s:curPos][0]

			let posL = g:snipPos[s:curPos][0] 
			let posC = g:snipPos[s:curPos][1]

			if lnum == posL+1
				let snipPosTmp = []
				call add(snipPosTmp,[0,0,-1])
				let num = 0
				for pos in g:snipPos
					call add(snipPosTmp,[0,0,-1])
					if pos[0] > posL
						let pos[0] += 1	
					elseif pos[0]==posL && pos[1]>=posC
						"echoe col.'--'.s:endCol
						let pos[0] += 1
						let oriCol = len(getline(lnum-1))
						let curCol = col('.')
						"let changedLen = oriCol-g:indent
						let changedLen = oriCol-curCol
						let pos[1] -= changedLen+1
					endif

					if exists('pos[3]')
						for pos3 in pos[3]
							if pos3[0] > posL
								let pos3[0] += 1
							elseif pos3[0]==posL&&pos3[1]>=posC
								let pos3[0] += 1
								let oriCol = len(getline(lnum-1))
								let curCol = col('.')
								let changedLen = oriCol-curCol
								let pos3[1] -= changedLen+1
							endif
						endfor
					endif
					if num < s:curPos
						let snipPosTmp[num]=g:snipPos[num]
					else
						let snipPosTmp[num+1]=g:snipPos[num]
					endif
					let num +=1
				endfor
					let snipPosTmp[s:curPos] = [lnum-1,len(getline(lnum-1))+1,-1]
					let g:snipPos = snipPosTmp
					call snipMate#setSnipLen(len(g:snipPos))
					let s:curPos +=1
			else
				call snipMate#removeSnippet()
			endif
		endif

		" Delete snippet if cursor moves out of it in insert mode
	endif
endf

" This updates the variables in a snippet when a placeholder has been edited.
" (e.g., each "$1" in "${1:foo} $1bar $1bar")
fun s:UpdateVars()
	let newWordLen = s:endCol - s:startCol + 1
	let newWord = strpart(getline('.'), s:startCol, newWordLen)
	if newWord == s:oldWord || empty(g:snipPos[s:curPos][3])
		return
	endif

	let changeLen = g:snipPos[s:curPos][2] - newWordLen
	let curLine = line('.')
	let startCol = col('.')
	let oldStartSnip = s:startCol
	let updateTabStops = changeLen != 0
	let i = 0

	for [lnum, col] in g:snipPos[s:curPos][3]
		if updateTabStops
			let start = s:startCol
			if lnum == curLine && col <= start
				let s:startCol -= changeLen
				let s:endCol -= changeLen
			endif
			for nPos in g:snipPos[s:curPos][3][(i):]
				" This list is in ascending order, so quit if we've gone too far.
				if nPos[0] > lnum | break | endif
				if nPos[0] == lnum && nPos[1] > col
					let nPos[1] -= changeLen
				endif
			endfor
			if lnum == curLine && col > start
				let col -= changeLen
				let g:snipPos[s:curPos][3][i][1] = col
			endif
			let i += 1
		endif

		" "Very nomagic" is used here to allow special characters.
		call setline(lnum, substitute(getline(lnum), '\%'.col.'c\V'.
						\ escape(s:oldWord, '\'), escape(newWord, '\&'), ''))
	endfor
	if oldStartSnip != s:startCol
		call cursor(0, startCol + s:startCol - oldStartSnip)
	endif

	let s:oldWord = newWord
	let g:snipPos[s:curPos][2] = newWordLen
endf
" vim:noet:sw=4:ts=4:ft=vim
" vim:noet:sw=4:ts=4:ft=vim
