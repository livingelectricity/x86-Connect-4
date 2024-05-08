.386P

.model flat

extern connect4Matrix:byte
extern yesWinPlayerFlag:byte
extern playerWinChance:byte
extern playerWinMove:dword

.code ;all functions below check if player win condition is met (4 in a row), using the values entered into connect4Matrix by dropPlayerCircle function

winConditionHorizontalPlayer PROC near 
_winConditionHorizontalPlayer:
		
		;horizontal win condition player
		xor edx, edx ;row counter
		xor ebx, ebx ;column counter
		xor eax, eax ;matrix position
		xor ecx, ecx ;win points
		mov edi, 3
	
		_loopHorizontal:
		cmp byte ptr [connect4Matrix + eax], 1 ;check if matrix position contains player value
		je _winPointHorizontal ;if true, jump to add win point
		xor ecx, ecx ;clear win points if no consecutive player pieces
		inc eax ;increment matrix positoin
		inc ebx ;increment column counter
		cmp ebx, 7
		je _notRowHorizontal ;jump if not row
		jmp _loopHorizontal
		_notRowHorizontal: ;not row, next row iterated
		xor ecx, ecx
		mov ebx, 0
		inc edx
		cmp edx, 7
		je _noWinHorizontal ;if all rows checked, exit function
		jmp _loopHorizontal ;else loop function
		_winPointHorizontal: ;consective player pieces add win points
		inc ecx
		cmp ecx, 4
		je _yesWinPlayer ;yes win player condition hit, jump to set yesWinPlayerFlag and return from function
		inc eax ;else continue loop by incrementing necessary values
		inc ebx
		cmp ebx, 7
		je _notRowHorizontal
		cmp ecx, 2
		jne _loopHorizontal
		cmp byte ptr [connect4Matrix + eax], 0 ;check right for empty slot
		je _addHorizontalWinRight
		cmp ebx, 3
		jl _loopHorizontal
		cmp byte ptr [connect4Matrix + eax - 3], 0 ;check left for empty slot
		jne _loopHorizontal
		mov byte ptr [playerWinChance], 3 ;if high player win chance and empty slot left, update playerWinMove for opponent block
		sub eax, edi
		mov dword ptr [playerWinMove], eax
		add eax, edi
		jmp _loopHorizontal
		_addHorizontalWinRight:
		mov byte ptr [playerWinChance], 3 ;if high player win chance and empty slot right, update playerWinMove for opponent block
		mov dword ptr [playerWinMove], eax
		jmp _loopHorizontal
		

		_noWinHorizontal: ;if no player win, function returns and next win condition function called
		ret
		
		_yesWinPlayer: ;else yesWinPlayerFlag set, function returns
		mov yesWinPlayerFlag, 1
		ret

winConditionHorizontalPlayer ENDP


winConditionVerticalPlayer PROC near
_winConditionVerticalPlayer:
		
		;vertical win condition player
		xor eax, eax ;matrix position
		xor ebx, ebx ;win points
		mov ecx, 7 ;row counter
		xor edx, edx ;column counter

		_loopVertical:
		mov eax, edx

		_columnLoopVertical:
		cmp byte ptr [connect4Matrix + eax], 1
		je _winPointVertical
		xor ebx, ebx ;clear win points
		add eax, 7
		dec ecx
		cmp ecx, 0
		jne _columnLoopVertical
		mov ecx, 7
		inc edx
		cmp edx, 7
		jle _loopVertical
		jmp _noWinVertical
		_winPointVertical:
		inc ebx ;add win point
		cmp ebx, 4
		je _yesWinPlayer
		add eax, 7
		dec ecx
		cmp ecx, 0
		je _incColumn
		cmp ebx, 3
		jne _columnLoopVertical
		cmp byte ptr [connect4Matrix + eax], 0
		jne _columnLoopVertical
		mov byte ptr [playerWinChance], 3 ;if high player win chance and empty slot vertical, update playerWinMove for opponent block
		mov dword ptr [playerWinMove], eax
		jmp _columnLoopVertical
		_incColumn:
		mov ecx, 7
		inc edx
		cmp edx, 6
		jle _loopVertical

		_noWinVertical:
		ret
		
		_yesWinPlayer:
		mov yesWinPlayerFlag, 1
		ret

winConditionVerticalPlayer ENDP

winConditionDiagonalUpColumnPlayer PROC near
_winConditionDiagonalUpColumnPlayer:
		
		;diagonal up column win condition player
		xor eax, eax ;matrix position
		mov ebx, 6 ;total diagonal moves needed stop trigger
		xor ecx, ecx ;diagonal move counter
		xor edx,edx ;win points
		mov esi, 1 ;column counter

		_loopDiagonalUpColumn:
		cmp byte ptr [connect4Matrix + eax], 1
		je _winPointDiagonalUpColumn
		xor edx, edx ;clear win points
		add eax, 8
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalUpColumn
		jmp _loopDiagonalUpColumn
		_incDiagonalUpColumn:
		xor ecx, ecx ;not column, win points cleared
		mov eax, esi ;next beginning column value moved into eax
		inc esi ;column counter iterated for next add
		dec ebx ;once ebx hits 2, all diagonal up columns have been checked
		cmp ebx, 2
		je _noWinDiagonalUpColumn
		jmp _loopDiagonalUpColumn
		_winPointDiagonalUpColumn:
		inc edx ;add win point
		cmp edx, 4
		je _yesWinPlayer
		add eax, 8
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalUpColumn
		cmp edx, 3
		jne _loopDiagonalUpColumn
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalUpColumn
		mov byte ptr [playerWinChance], 3
		mov dword ptr [playerWinMove], eax
		jmp _loopDiagonalUpColumn

		_noWinDiagonalUpColumn:
		ret

		_yesWinPlayer:
		mov yesWinPlayerFlag, 1
		ret

winConditionDiagonalUpColumnPlayer ENDP


winConditionDiagonalUpRowPlayer PROC near
_winConditionDiagonalUpRowPlayer:
		
		;diagonal up row win condition player
		xor eax, eax ;matrix position
		mov ebx, 6 ;total diagonal moves needed stop trigger
		xor ecx, ecx ;diagonal move counter
		xor edx,edx ;win points
		mov esi, 7 ;row counter

		_loopDiagonalUpRow:
		cmp byte ptr [connect4Matrix + eax], 1
		je _winPointDiagonalUpRow
		xor edx, edx ;clear win points
		add eax, 8
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalUpRow
		jmp _loopDiagonalUpRow
		_incDiagonalUpRow:
		xor ecx, ecx 
		mov eax, esi
		add esi, 7
		dec ebx
		cmp ebx, 2
		je _noWinDiagonalUpRow
		jmp _loopDiagonalUpRow
		_winPointDiagonalUpRow:
		inc edx
		cmp edx, 4
		je _yesWinPlayer
		add eax, 8
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalUpRow
		cmp edx, 3
		jne _loopDiagonalUpRow
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalUpRow
		mov byte ptr [playerWinChance], 3
		mov dword ptr [playerWinMove], eax
		jmp _loopDiagonalUpRow

		_noWinDiagonalUpRow:
		ret

		_yesWinPlayer:
		mov yesWinPlayerFlag, 1
		ret

winConditionDiagonalUpRowPlayer ENDP

winConditionDiagonalDownColumnPlayer PROC near
_winConditionDiagonalDownColumnPlayer:
		
		;diagonal down column win condition player
		mov eax, 42 ;matrix position
		mov ebx, 6 ;total diagonal moves needed stop trigger
		xor ecx, ecx ;diagonal counter
		xor edx,edx ;win points
		mov esi, 1 ;column counter

		_loopDiagonalDownColumn:
		cmp byte ptr [connect4Matrix + eax], 1
		je _winPointDiagonalDownColumn
		xor edx, edx ;clear win points
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownColumn
		jmp _loopDiagonalDownColumn
		_incDiagonalDownColumn:
		xor ecx, ecx
		mov eax, 42
		add eax, esi
		inc esi
		dec ebx
		cmp ebx, 2
		je _noWinDiagonalDownColumn
		jmp _loopDiagonalDownColumn
		_winPointDiagonalDownColumn:
		inc edx
		cmp edx, 4
		je _yesWinPlayer
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownColumn
		cmp edx, 3
		jne _loopDiagonalDownColumn
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalDownColumn
		mov byte ptr [playerWinChance], 3
		mov dword ptr [playerWinMove], eax
		jmp _loopDiagonalDownColumn

		_noWinDiagonalDownColumn:
		ret

		_yesWinPlayer:
		mov yesWinPlayerFlag, 1
		ret

winConditionDiagonalDownColumnPlayer ENDP

winConditionDiagonalDownRowPlayer PROC near
_winConditionDiagonalDownRowPlayer:
		
		;diagonal down row win condition player
		mov eax, 42
		mov ebx, 6
		xor ecx, ecx
		xor edx,edx ;win points
		mov esi, 7

		_loopDiagonalDownRow:
		cmp byte ptr [connect4Matrix + eax], 1
		je _winPointDiagonalDownRow
		xor edx, edx ;clear win points
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownRow
		jmp _loopDiagonalDownRow
		_incDiagonalDownRow:
		xor ecx, ecx
		mov eax, 42
		sub eax, esi
		add esi, 7
		dec ebx
		cmp ebx, 2
		je _noWinDiagonalDownRow
		jmp _loopDiagonalDownRow
		_winPointDiagonalDownRow:
		inc edx
		cmp edx, 4
		je _yesWinPlayer
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownRow
		cmp edx, 3
		jne _loopDiagonalDownRow
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalDownRow
		mov byte ptr [playerWinChance], 3
		mov dword ptr [playerWinMove], eax
		jmp _loopDiagonalDownRow

		_noWinDiagonalDownRow:
		ret

		_yesWinPlayer:
		mov yesWinPlayerFlag, 1
		ret

winConditionDiagonalDownRowPlayer ENDP

END