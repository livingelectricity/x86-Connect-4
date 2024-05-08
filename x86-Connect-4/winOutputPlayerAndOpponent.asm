.386P

.model flat

extern _GetStdHandle@4:near
extern _WriteConsoleW@20:near
extern _WriteConsoleA@20:near
extern _ReadConsoleA@20:near
extern _SetConsoleCursorPosition@8:near
extern _ExitProcess@4:near

extern connect4Matrix:byte

extern winMessage:word
extern loseMessage:word
extern playAgainMessage:byte
extern drawMessage:byte

extern readBuffer:byte

extern numCharsRead:dword

extern opponentRowOutput:dword
extern opponentNextMove:dword
extern opponentWinWeight:dword

extern connect4GraphicsLine2:word

.code

noWinOpponent PROC near
_noWinOpponent:
		
		;opponent no win function

		mov eax, dword ptr [opponentNextMove] ;nextMove variables moved into registers for manipulation, and graphics updated for opponent move
		mov byte ptr [connect4Matrix + eax], 2
		mov edx, dword ptr [opponentRowOutput]
		imul edx, 7 ;for matrix row offset
		mov eax, 2 ;for connect4GraphicsLine2 (two bytes)

		_graphicsLoopOpponent:
		cmp byte ptr [connect4Matrix + edx], 0
		jne _playerCompareOpponent
		mov word ptr [connect4GraphicsLine2 + eax], 25CBh ;25CBh empty circle
		jmp _incOpponent
		_playerCompareOpponent:
		cmp byte ptr [connect4Matrix + edx], 1
		jne _opponentCompareOpponent
		mov word ptr [connect4GraphicsLine2 + eax], 25CFh ;25CFh player circle
		jmp _incOpponent
		_opponentCompareOpponent:
		mov word ptr [connect4GraphicsLine2 + eax], 25CDh ;25CDh opponent circle
		_incOpponent:
		cmp eax, 14
		je _endGraphicsLoopOpponent
		inc edx
		add eax, 2
		jmp _graphicsLoopOpponent

		_endGraphicsLoopOpponent:

		push -11
		call _GetStdHandle@4

		mov ecx, dword ptr [opponentRowOutput]
		neg ecx ;two's compelement negation of row for graphical output, added to cursor position at bottom of graphic to adjust value
		shl ecx, 16 ;shift left 16 bits as row coordinate is determined by upper 16 bits in SetConsoleCursorPosition coordinates parameter
		add ecx, 524288 ;cursor position adjusted, immediate value represents row 8 bottom of graphic, negated edx offsets that row

		push ecx  ;this value adjusts cursor, upper 16 row, bottom 16 column (currently column 0)
		push eax 
		call _SetConsoleCursorPosition@8 

		push -11 
		call _GetStdHandle@4

		push 0 ;graphic output to console
		push 0
		push 10
		push offset connect4GraphicsLine2
		push eax ;outputHandle
		call _WriteConsoleW@20

		ret

noWinOpponent ENDP

yesWinOpponent PROC near
_yesWinOpponent:

		;opponent yes win function

		mov eax, dword ptr [opponentNextMove] ;nextMove variables moved into registers for manipulation, and graphics updated for opponent move
		mov byte ptr [connect4Matrix + eax], 2
		mov edx, dword ptr [opponentRowOutput]
		imul edx, 7 ;for matrix row offset
		mov eax, 2 ;for connect4GraphicsLine2 (two bytes)

		_graphicsLoopOpponentYesWin:
		cmp byte ptr [connect4Matrix + edx], 0
		jne _playerCompareOpponentYesWin
		mov word ptr [connect4GraphicsLine2 + eax], 25CBh ;25CBh empty circle
		jmp _incOpponentYesWin
		_playerCompareOpponentYesWin:
		cmp byte ptr [connect4Matrix + edx], 1
		jne _opponentCompareOpponentYesWin
		mov word ptr [connect4GraphicsLine2 + eax], 25CFh ;25CFh player circle
		jmp _incOpponentYesWin
		_opponentCompareOpponentYesWin:
		mov word ptr [connect4GraphicsLine2 + eax], 25CDh ;25CDh opponent circle
		_incOpponentYesWin:
		cmp eax, 14
		je _endGraphicsLoopOpponentYesWin
		inc edx
		add eax, 2
		jmp _graphicsLoopOpponentYesWin

		_endGraphicsLoopOpponentYesWin:

		push -11
		call _GetStdHandle@4

		mov ecx, dword ptr [opponentRowOutput]
		neg ecx ;two's compelement negation of row for graphical output, added to cursor position at bottom of graphic to adjust value
		shl ecx, 16 ;shift left 16 bits as row coordinate is determined by upper 16 bits in SetConsoleCursorPosition coordinates parameter
		add ecx, 524288 ;cursor position adjusted, immediate value represents row 8 bottom of graphic, negated edx offsets that row

		push ecx  ;this value adjusts cursor, upper 16 row, bottom 16 column (currently column 0)
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

		push -11
		call _GetStdHandle@4

		push 393252
		push eax
		call _SetConsoleCursorPosition@8

		push -11
		call _GetStdHandle@4

		push 0 ;function to output player lose message
		push 0
		push 16
		push offset loseMessage
		push eax ;outputHandle
		call _writeConsoleW@20

		push -11
		call _GetStdHandle@4

		push 458772
		push eax
		call _SetConsoleCursorPosition@8
		
		push -11
		call _GetStdHandle@4

		push 0 ;function to output play againn message
		push 0
		push 43
		push offset playAgainMessage
		push eax ;outputHandle
		call _writeConsoleA@20

		push -10
		call _GetStdHandle@4

		push 0 ;read input from player on if new game desired
		push offset numCharsRead
		push 70
		push offset readBuffer
		push eax ;inputHandle
		call _ReadConsoleA@20

		cmp byte ptr [readBuffer], 59h ;'Y' uppercase
		je _playAgainLoop ;jump to playAgainLoop

		cmp byte ptr [readBuffer], 79h ;'y' lowercase
		je _playAgainLoop

		push -11 ;else exit
		call _GetStdHandle@4

		push 1179648
		push eax
		call _SetConsoleCursorPosition@8
		
		push	0
		call	_ExitProcess@4

		_playAgainLoop:
		ret

yesWinOpponent ENDP

yesWinPlayer PROC near
_yesWinPlayer:

		;player win function

		push -11
		call _GetStdHandle@4

		push 393252
		push eax
		call _SetConsoleCursorPosition@8

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 12
		push offset winMessage
		push eax ;outputHandle
		call _writeConsoleW@20
		
		push -11
		call _GetStdHandle@4

		push 458772
		push eax
		call _SetConsoleCursorPosition@8
		
		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 43
		push offset playAgainMessage
		push eax ;outputHandle
		call _writeConsoleA@20

		push -10
		call _GetStdHandle@4

		push 0 
		push offset numCharsRead
		push 70
		push offset readBuffer
		push eax ;inputHandle
		call _ReadConsoleA@20

		cmp byte ptr [readBuffer], 59h
		je _playAgainLoop

		cmp byte ptr [readBuffer], 79h
		je _playAgainLoop

		push -11
		call _GetStdHandle@4

		push 1179648
		push eax
		call _SetConsoleCursorPosition@8

		push	0
		call	_ExitProcess@4

		_playAgainLoop:
		ret

yesWinPlayer ENDP

fullConnect4Board PROC near
_fullConnect4Board:

		;player & opponent draw function

		push -11
		call _GetStdHandle@4

		push 393252
		push eax
		call _SetConsoleCursorPosition@8

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 12
		push offset playAgainMessage
		push eax ;outputHandle
		call _writeConsoleW@20
		
		push -11
		call _GetStdHandle@4

		push 458772
		push eax
		call _SetConsoleCursorPosition@8
		
		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 43
		push offset drawMessage
		push eax ;outputHandle
		call _writeConsoleA@20

		push -10
		call _GetStdHandle@4

		push 0 
		push offset numCharsRead
		push 70
		push offset readBuffer
		push eax ;inputHandle
		call _ReadConsoleA@20

		cmp byte ptr [readBuffer], 59h
		je _playAgainLoop

		cmp byte ptr [readBuffer], 79h
		je _playAgainLoop

		push -11
		call _GetStdHandle@4

		push 1179648
		push eax
		call _SetConsoleCursorPosition@8

		push	0
		call	_ExitProcess@4

		_playAgainLoop:
		ret

fullConnect4Board ENDP

END