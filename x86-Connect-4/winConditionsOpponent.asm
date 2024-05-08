.686P

.model flat

extern noWinOpponent:proc
extern yesWinOpponent:proc

extern connect4Matrix:byte

extern winVariable:byte

extern opponentRowOutput:dword
extern opponentNextMove:dword
extern opponentWinWeight:dword
extern randomOpponentValue:dword

.code ;functions below check for opponent win condition (4 in a row) and are similar to player win condition check functions, with some extra features
;instead of only checking if win condition has been met, the win points act as weight to determine optimal move for opponent
;as win points are added, upcoming matrix position is checked for empty slots
;if slot empty and current weighted value of opponentWinWeight does not exceed counted win points in current function
;opponentWinWeight, opponentNextMove, and opponentRowOutput variables are updated

;last function checkWinOpponent ensures opponent piece not placed above empty slots, and sets win condition flag depending if piece wins game for opponent

winConditionHorizontalRightOpponent PROC near
_winConditionHorizontalRightOpponent:
		
		;horizontal right win condition opponent
		xor edx, edx 
		xor ebx, ebx ;column counter
		xor eax, eax ;matrix position
		xor ecx, ecx ;win points

		_loopHorizontalRightOpponent:
		cmp byte ptr [connect4Matrix + eax], 2 ;check if matrix position contains 2 value (opponent piece)
		je _winPointHorizontalRightOpponent ;if true, update win points
		xor ecx, ecx ;clear win points
		inc eax
		inc ebx 
		cmp ebx, 7
		je _notRowHorizontalRightOpponent
		jmp _loopHorizontalRightOpponent
		_notRowHorizontalRightOpponent: 
		xor ecx, ecx
		mov ebx, 0
		inc edx
		cmp edx, 7
		je _noWinHorizontalRightOpponent
		jmp _loopHorizontalRightOpponent
		_winPointHorizontalRightOpponent: ;win point added
		inc ebx ;column counter
		inc eax ;increment to next position in matrix to check if empty slot
		inc ecx ;increment win points
		cmp ebx, 7 ;check if column counter exceeded, if so win points become void and opponentWinWeight should not be updated
		je _notRowHorizontalRightOpponent
		cmp ecx, dword ptr [opponentWinWeight] ;check if current opponentWinWeight value is more than current win points
		jl _loopHorizontalRightOpponent 
		cmp byte ptr [connect4Matrix + eax], 0 ;and if next position contains empty slot
		jne _loopHorizontalRightOpponent
		mov dword ptr [opponentRowOutput], edx ;if conditions met, update row for next move
		mov dword ptr [opponentNextMove], eax ;if conditions met, update next move
		mov dword ptr [opponentWinWeight], ecx ;if conditions met, update weight value of opponent playing that piece next
		jmp _loopHorizontalRightOpponent

		_noWinHorizontalRightOpponent:
		ret

winConditionHorizontalRightOpponent ENDP

winConditionHorizontalLeftOpponent PROC near
_winConditionHorizontalLeftOpponent:
		
		;horizontal left win condition opponent
		xor edx, edx
		mov ebx, 2
		_verifyRandOpponentValueGenerated:
		rdrand eax
		jnc _verifyRandOpponentValueGenerated
		div ebx
		mov dword ptr [randomOpponentValue], edx

		xor edx, edx 
		xor ebx, ebx
		mov eax, 6
		xor ecx, ecx ;win points
		xor esi, esi

		_loopHorizontalLeftOpponent:
		cmp byte ptr [connect4Matrix + eax], 2
		je _winPointHorizontalLeftOpponent
		xor ecx, ecx ;clear win points
		dec eax
		inc ebx 
		cmp ebx, 7
		je _notRowHorizontalLeftOpponent
		jmp _loopHorizontalLeftOpponent
		_notRowHorizontalLeftOpponent: 
		xor ecx, ecx
		inc edx
		mov esi, edx
		inc edx
		mov eax, ebx
		mul edx
		sub eax, 1
		mov edx, esi
		mov ebx, 0
		cmp edx, 7
		je _noWinHorizontalLeftOpponent
		jmp _loopHorizontalLeftOpponent
		_winPointHorizontalLeftOpponent:
		inc ebx
		dec eax
		inc ecx
		cmp ebx, 7
		je _notRowHorizontalLeftOpponent
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopHorizontalLeftOpponent
		cmp ecx, dword ptr [opponentWinWeight]
		jl _loopHorizontalLeftOpponent
		jg _updateNextMoveLeftHorizontalOpponent
		cmp [opponentWinWeight], 0
		je _updateNextMoveLeftHorizontalOpponent
		cmp [randomOpponentValue], 0
		je _loopHorizontalLeftOpponent
		_updateNextMoveLeftHorizontalOpponent:
		mov dword ptr [opponentRowOutput], edx
		mov dword ptr [opponentNextMove], eax
		mov dword ptr [opponentWinWeight], ecx
		jmp _loopHorizontalLeftOpponent

		_noWinHorizontalLeftOpponent:
		ret

winConditionHorizontalLeftOpponent ENDP

winConditionVerticalOpponent PROC near
_winConditionVerticalOpponent:
		
		;vertical win condition opponent
		xor edx, edx
		mov ebx, 2
		_verifyRandOpponentValueGenerated:
		rdrand eax
		jnc _verifyRandOpponentValueGenerated
		div ebx
		mov dword ptr [randomOpponentValue], edx

		xor eax, eax
		xor ebx, ebx ;win points
		mov ecx, 7
		xor edx, edx
		xor edi, edi
		
		_loopVerticalOpponent:
		mov eax, edx
		
		_columnLoopVerticalOpponent:
		cmp byte ptr [connect4Matrix + eax], 2
		je _winPointVerticalOpponent
		xor ebx, ebx
		add eax, 7
		dec ecx
		inc edi
		cmp ecx, 0
		jne _columnLoopVerticalOpponent
		xor edi, edi
		mov ecx, 7
		inc edx
		cmp edx, 7
		jle _loopVerticalOpponent
		jmp _noWinVerticalOpponent
		_winPointVerticalOpponent:
		inc ebx
		add eax, 7
		inc edi
		cmp byte ptr [connect4Matrix + eax], 0
		jne _noIdealMoveVerticalOpponent
		cmp ebx, dword ptr [opponentWinWeight]
		jl _noIdealMoveVerticalOpponent
		jg _updateNextMoveVerticalOpponent
		cmp [opponentWinWeight], 0
		je _updateNextMoveVerticalOpponent
		cmp [randomOpponentValue], 0
		je _noIdealMoveVerticalOpponent
		_updateNextMoveVerticalOpponent:
		mov dword ptr [opponentRowOutput], edi
		mov dword ptr [opponentNextMove], eax
		mov dword ptr [opponentWinWeight], ebx
		_noIdealMoveVerticalOpponent:
		dec ecx
		cmp ecx, 0
		jne _columnLoopVerticalOpponent
		mov ecx, 7
		inc edx
		cmp edx, 6
		jle _loopVerticalOpponent

		_noWinVerticalOpponent:
		ret

winConditionVerticalOpponent ENDP

winConditionDiagonalUpColumnOpponent PROC near
_winConditionDiagonalUpColumnOpponent:
		
		;diagonal up column win condition opponent
		xor edx, edx
		mov ebx, 2
		_verifyRandOpponentValueGenerated:
		rdrand eax
		jnc _verifyRandOpponentValueGenerated
		div ebx
		mov dword ptr [randomOpponentValue], edx

		xor eax, eax ;matrix position
		mov ebx, 6   ;total diagonal moves needed to stop trigger
		xor ecx, ecx ;diagonal move counter
		xor edx,edx ;win points
		mov esi, 1 ;column counter

		_loopDiagonalUpColumnOpponent:
		cmp byte ptr [connect4Matrix + eax], 2
		je _winPointDiagonalUpColumnOpponent
		xor edx, edx ;win points
		add eax, 8 ;matrix position updated by 8 to reflect correct position
		inc ecx 
		cmp ecx, ebx
		jg _incDiagonalUpColumnOpponent
		jmp _loopDiagonalUpColumnOpponent
		_incDiagonalUpColumnOpponent:
		xor ecx, ecx
		mov eax, esi ;next column iterator esi value carried to eax
		inc esi
		dec ebx
		cmp ebx, 2
		je _noWinDiagonalUpColumnOpponent
		jmp _loopDiagonalUpColumnOpponent
		_winPointDiagonalUpColumnOpponent:
		inc edx ;win points
		add eax, 8
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalUpColumnOpponent
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalUpColumnOpponent
		cmp edx, dword ptr [opponentWinWeight]
		jl _loopDiagonalUpColumnOpponent
		jg _updateNextMoveUpColumnOpponent
		cmp [opponentWinWeight], 0
		je _updateNextMoveUpColumnOpponent
		cmp [randomOpponentValue], 0
		je _loopDiagonalUpColumnOpponent
		_updateNextMoveUpColumnOpponent:
		mov dword ptr [opponentNextMove], eax
		mov dword ptr [opponentRowOutput], ecx
		mov dword ptr [opponentWinWeight], edx
		jmp _loopDiagonalUpColumnOpponent

		_noWinDiagonalUpColumnOpponent:
		ret

winConditionDiagonalUpColumnOpponent ENDP

winConditionDiagonalUpRowOpponent PROC near
_winConditionDiagonalUpRowOpponent:
		
		;diagonal up row win condition opponent
		xor edx, edx
		mov ebx, 2
		_verifyRandOpponentValueGenerated:
		rdrand eax
		jnc _verifyRandOpponentValueGenerated
		div ebx
		mov dword ptr [randomOpponentValue], edx

		xor eax, eax
		mov ebx, 6
		xor ecx, ecx ;row
		xor edx,edx ;win points
		mov esi, 7

		_loopDiagonalUpRowOpponent:
		cmp byte ptr [connect4Matrix + eax], 2
		je _winPointDiagonalUpRowOpponent
		xor edx, edx ;win points
		add eax, 8
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalUpRowOpponent
		jmp _loopDiagonalUpRowOpponent
		_incDiagonalUpRowOpponent:
		xor ecx, ecx
		mov eax, esi
		add esi, 7
		dec ebx
		cmp ebx, 2
		je _noWinDiagonalUpRowOpponent
		jmp _loopDiagonalUpRowOpponent
		_winPointDiagonalUpRowOpponent:
		inc edx
		add eax, 8
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalUpRowOpponent
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalUpRowOpponent
		cmp edx, dword ptr [opponentWinWeight]
		jl _loopDiagonalUpRowOpponent
		jg _updateNextMoveUpRowOpponent
		cmp [opponentWinWeight], 0
		je _updateNextMoveUpRowOpponent
		cmp [randomOpponentValue], 0
		je _loopDiagonalUpRowOpponent
		_updateNextMoveUpRowOpponent:
		mov dword ptr [opponentNextMove], eax
		mov dword ptr [opponentRowOutput], ecx
		mov dword ptr [opponentWinWeight], edx
		jmp _loopDiagonalUpRowOpponent

		_noWinDiagonalUpRowOpponent:
		ret

winConditionDiagonalUpRowOpponent ENDP

winConditionDiagonalDownColumnOpponent PROC near
_winConditionDiagonalDownColumnOpponent:
		
		;diagonal down column win condition opponent
		xor edx, edx
		mov ebx, 2
		_verifyRandOpponentValueGenerated:
		rdrand eax
		jnc _verifyRandOpponentValueGenerated
		div ebx
		mov dword ptr [randomOpponentValue], edx

		mov eax, 42
		mov ebx, 6
		xor ecx, ecx
		xor edx,edx ;win points
		xor edi, edi
		mov esi, 1

		_loopDiagonalDownColumnOpponent:
		cmp byte ptr [connect4Matrix + eax], 2
		je _winPointDiagonalDownColumnOpponent
		xor edx, edx ;win points
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownColumnOpponent
		jmp _loopDiagonalDownColumnOpponent
		_incDiagonalDownColumnOpponent:
		xor ecx, ecx
		mov eax, 42
		add eax, esi
		inc esi
		dec ebx
		cmp ebx, 2
		je _noWinDiagonalDownColumnOpponent
		jmp _loopDiagonalDownColumnOpponent
		_winPointDiagonalDownColumnOpponent:
		inc edx ;win points
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownColumnOpponent
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalDownColumnOpponent
		cmp edx, dword ptr [opponentWinWeight]
		jl _loopDiagonalDownColumnOpponent
		jg _updateNextMoveDownColumnOpponent
		cmp [opponentWinWeight], 0
		je _updateNextMoveDownColumnOpponent
		cmp [randomOpponentValue], 0
		je _loopDiagonalDownColumnOpponent
		_updateNextMoveDownColumnOpponent:
		mov dword ptr [opponentNextMove], eax
		mov edi, 7
		sub edi, ecx
		mov dword ptr [opponentRowOutput], edi
		mov dword ptr [opponentWinWeight], edx
		jmp _loopDiagonalDownColumnOpponent

		_noWinDiagonalDownColumnOpponent:
		ret

winConditionDiagonalDownColumnOpponent ENDP

winConditionDiagonalDownRowOpponent PROC near
_winConditionDiagonalDownRowOpponent:
		
		;diagonal down row win condition opponent
		xor edx, edx
		mov ebx, 2
		_verifyRandOpponentValueGenerated:
		rdrand eax
		jnc _verifyRandOpponentValueGenerated
		div ebx
		mov dword ptr [randomOpponentValue], edx

		mov eax, 42
		mov ebx, 6
		xor ecx, ecx
		xor edx,edx ;win points
		xor edi, edi
		mov esi, 7

		_loopDiagonalDownRowOpponent:
		cmp byte ptr [connect4Matrix + eax], 2
		je _winPointDiagonalDownRowOpponent
		xor edx, edx ;win points
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownRowOpponent
		jmp _loopDiagonalDownRowOpponent
		_incDiagonalDownRowOpponent:
		xor ecx, ecx
		mov eax, 42
		sub eax, esi
		add esi, 7
		dec ebx
		cmp ebx, 2
		je _noWinDiagonalDownRowOpponent
		jmp _loopDiagonalDownRowOpponent
		_winPointDiagonalDownRowOpponent:
		inc edx
		sub eax, 6
		inc ecx
		cmp ecx, ebx
		jg _incDiagonalDownRowOpponent
		cmp byte ptr [connect4Matrix + eax], 0
		jne _loopDiagonalDownRowOpponent
		cmp edx, dword ptr [opponentWinWeight]
		jl _loopDiagonalDownRowOpponent
		jg _updateNextMoveDownRowOpponent
		cmp [opponentWinWeight], 0
		je _updateNextMoveDownRowOpponent
		cmp [randomOpponentValue], 0
		je _loopDiagonalDownRowOpponent
		_updateNextMoveDownRowOpponent:
		mov dword ptr [opponentNextMove], eax
		mov edi, 7
		sub edi, ecx
		mov dword ptr [opponentRowOutput], edi
		mov dword ptr [opponentWinWeight], edx
		jmp _loopDiagonalDownRowOpponent

		_noWinDiagonalDownRowOpponent:
		ret

winConditionDiagonalDownRowOpponent ENDP

checkWinOpponent PROC near ;function to ensure placement of piece is not above empty slots, and to set win condition flag depending if piece wins game for opponent
_checkWinOpponent:
		
		mov edi, dword ptr [opponentRowOutput] ;move variables containing next move into registers for manipulation in function
		mov eax, dword ptr [opponentNextMove]
		mov ebx, dword ptr [opponentWinWeight]
		cmp ebx, 3
		je _possibleWinOpponent ;if winWeight is 3, next move could be opponent win, jump to possibleWin loop
		_checkBelowOpponent:;if row is 0, no further rows below. placement of piece final
		cmp edi, 0 
		je _iterationDoneOpponentNoAdd 
		sub eax, 7 ;else check positon below in column
		dec edi
		cmp eax, 0
		jl _iterationDoneOpponent
		cmp byte ptr [connect4Matrix + eax], 0 ;check if lower position is empty
		je _checkBelowOpponent
		_iterationDoneOpponent: ;once lowest available slot found, ensure correct values returned into opponentNextMove variables
		add eax, 7
		inc edi
		_iterationDoneOpponentNoAdd:
		mov dword ptr [opponentRowOutput], edi
		mov dword ptr [opponentNextMove], eax
		jmp _noWinOpponent ;if position changed, no win opponent
		_possibleWinOpponent: ;possible win loop
		cmp edi, 0
		je _yesWinOpponent ;if already lowest row and winWeight 3, opponent next move win
		sub eax, 7
		dec edi
		cmp eax, 0
		jl _yesWinIterationDoneOpponent
		cmp byte ptr [connect4Matrix + eax], 0
		jne _yesWinOpponent
		add eax, 7
		inc edi
		jmp _checkBelowOpponent
		_yesWinIterationDoneOpponent:
		add eax, 7
		inc edi
		jmp _yesWinOpponent

		_noWinOpponent:
		mov winVariable, 0 ;win flag set false
		ret

		_yesWinOpponent:
		mov winVariable, 2 ;win flag set true
		ret

checkWinOpponent ENDP

END