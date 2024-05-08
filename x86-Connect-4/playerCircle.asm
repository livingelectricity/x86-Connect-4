.386P

.model flat

extern _GetStdHandle@4:near
extern _WriteConsoleW@20:near
extern _SetConsoleCursorPosition@8:near

extern connect4Matrix:byte

extern invalidInputFlag:byte

extern connect4GraphicsLine2:word

.code

dropPlayerCircle PROC near
_dropPlayerCircle:
		
		;Fuction To Drop Player Circle: player enters column #, column is scanned starting from bottom row, 
		;if contains 2 value (opponent) or 1 value (player), next row up is scanned, once empty slot (0 value) found, 1 (player) value is inserted
		;if 7 rows have been checked with no empty spots, invalid column message output
		xor ecx, ecx
		sub al, 1 ;change playerInput contained in eax to array position # 0-6
		cmp byte ptr [connect4Matrix + eax], 0 ;first row checked
		je _matrixLoopEnd
		_matrixLoop:
		inc ecx ;row counter
		add eax, 7 ;iterate to next line in matrix
		cmp byte ptr [connect4Matrix + eax], 0 ;rows iterated through
		je _matrixLoopEnd
		cmp ecx, 6
		jl _matrixLoop
		mov invalidInputFlag, 1 ;invalidInputFlag set, function returned
		ret 

		_matrixLoopEnd:
		mov byte ptr [connect4Matrix + eax], 1 ;update array with player input, function returned
		ret

dropPlayerCircle ENDP

updatePlayerCircleGraphics PROC near
_updatePlayerCircleGraphics:
		
	
		;Function To Update Player Circle Graphic: Using row and column value in combination with SetConsoleCursorPosition, 
		;graphic for ONLY the matrix row that needs to update is changed

		mov edx, ecx ;ecx row value moved into edx to preserve for adjusting cursor position
		imul ecx, 7 ;for matrix row offset, value from previous function
		mov eax, 2 ;for connect4GraphicsLine2 (two bytes)

		_graphicsLoop: ;function to read connect4Matrix row that needs graphic update, starting at the first column and iterating to the last, updating connect4GraphicsLine2
		cmp byte ptr [connect4Matrix + ecx], 0 ;if 0 value
		jne _playerCompare
		mov word ptr [connect4GraphicsLine2 + eax], 25CBh ;update with 25CBh empty circle 
		jmp _inc
		_playerCompare:
		cmp byte ptr [connect4Matrix + ecx], 1 ;if 1 value
		jne _opponentCompare
		mov word ptr [connect4GraphicsLine2 + eax], 25CFh ;update with 25CFh player circle
		jmp _inc
		_opponentCompare: ;if else
		mov word ptr [connect4GraphicsLine2 + eax], 25CDh ;update with 25CDh opponent circle
		_inc:
		cmp eax, 14
		je _endGraphicsLoop
		inc ecx
		add eax, 2
		jmp _graphicsLoop

		_endGraphicsLoop:

		push -11
		call _GetStdHandle@4
		
		neg edx ;two's compelement negation of row (value saved previously) for graphical output, added to cursor position at bottom of graphic in console to adjust value
		shl edx, 16 ;shift left 16 bits as row coordinate is determined by upper 16 bits in SetConsoleCursorPosition coordinates parameter
		add edx, 524288 ;cursor position adjusted, immediate value represents row 8 bottom of graphic, negated edx offsets that row

		push edx  ;value has been adjusted for correct cursor position, upper 16 row (updated value), bottom 16 column (currently column 0)
		push eax 
		call _SetConsoleCursorPosition@8 

		push -11 
		call _GetStdHandle@4

		push 0 ;graphic output
		push 0
		push 10
		push offset connect4GraphicsLine2
		push eax ;outputHandle
		call _WriteConsoleW@20
		ret


updatePlayerCircleGraphics ENDP

END
