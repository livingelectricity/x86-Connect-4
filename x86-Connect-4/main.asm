;John-Elliot Stevens
;Final Project CSC2025
;Connect 4 - Made in Assembly
;5/4/2024 - Last Modified

.686P

.model flat

extern _GetStdHandle@4:near
extern _WriteConsoleA@20:near
extern _WriteConsoleW@20:near
extern _ReadConsoleA@20:near
extern _ExitProcess@4:near
extern _FillConsoleOutputCharacterA@20:near
extern _SetConsoleCursorPosition@8:near

extern stringToInt:proc

extern dropPlayerCircle:proc
extern updatePlayerCircleGraphics:proc

extern winConditionHorizontalPlayer:proc
extern winConditionVerticalPlayer:proc
extern winConditionDiagonalUpColumnPlayer:proc
extern winConditionDiagonalUpRowPlayer:proc
extern winConditionDiagonalDownColumnPlayer:proc
extern winConditionDiagonalDownRowPlayer:proc

extern winConditionHorizontalRightOpponent:proc
extern winConditionHorizontalLeftOpponent:proc
extern winConditionVerticalOpponent:proc
extern winConditionDiagonalUpColumnOpponent:proc
extern winConditionDiagonalUpRowOpponent:proc
extern winConditionDiagonalDownColumnOpponent:proc
extern winConditionDiagonalDownRowOpponent:proc

extern checkWinOpponent:proc

extern yesWinPlayer:proc
extern yesWinOpponent:proc
extern noWinOpponent:proc
extern fullConnect4Board:proc

.data

public winMessage
winMessage DW 263Bh,' ','Y','o','u',' ','W','i','n','!',' ', 263Bh
public loseMessage
loseMessage DW 2639h,' ',' ','Y','o','u',' ','L','o','s','e','.','.','.',' ', 2639h
public playAgainMessage
playAgainMessage DB 'Enter yes if you would like to play again! '
public drawMessage
drawMessage DB 'You Draw.'
invalidInputMsg DB 'Invalid Input. Enter number between 1 and 7 that matches a column with empty slots.'
beginGameMsg DB 'Welcome to Connect 4. Made in Assembly. Press ENTER to begin a new game.'
connect4Name DB 'Connect 4', 10
connect4Instruction1 DB 'Enter Column Number Here: ', 10, 10
connect4Instruction2 DW 'Y','o','u','r',' ','p','i','e','c','e','s',' ', 'a', 'r','e',':',' ', 25CFh, 10
connect4Instruction3 DW 'O','p','p','o','n','e','n','t',' ','p','i','e','c','e','s',' ','a','r','e',':',' ', 25CDh, 10
connect4Instruction4 DB 'To place a piece type 1 through 7 for the column you want and press enter.', 10, 10, 10
connect4Instruction5 DB 'Optional: To increase size of board (zoom-in), hold Ctrl and Scroll with your mouse wheel.', 10

connect4GraphicsLine1 DW 2533h,2501h,2501h,2501h,2501h,2501h,2501h,2501h,2533h, 10
public connect4GraphicsLine2
connect4GraphicsLine2 DW 2503h,25CBh,25CBh,25CBh,25CBh,25CBh,25CBh,25CBh,2503h, 10 	;7 rows 7 columns for circles (9 with borders)
connect4GraphicsLine2PlayAgainReset DW 2503h,25CBh,25CBh,25CBh,25CBh,25CBh,25CBh,25CBh,2503h, 10
connect4GraphicsLine3 DW 2517h,2501h,2501h,2501h,2501h,2501h,2501h,2501h,251Bh, 10
;25CFh player circle
;25CDh opponent circle
;25CBh empty circle

public connect4Matrix 
connect4Matrix DB 49 DUP(00h) ;game board matrix

public yesWinPlayerFlag
yesWinPlayerFlag DB 0
public invalidInputFlag
invalidInputFlag DB 0

public playerColumnEntry
playerColumnEntry DB 0
public playerWinChance
playerWinChance DB 0
public playerWinMove
playerWinMove DD 0
;public playerWinDirection
;playerWinDirection DD 0

public winVariable
winVariable DB 0

public opponentNextMove
opponentNextMove DD 0
public opponentWinWeight
opponentWinWeight DD 0
public opponentRowOutput
opponentRowOutput DD 0
public randomOpponentValue
randomOpponentValue DD 0
opponentInitialMove DB 0

numCharsToClear DD 30
public readBuffer
readBuffer DB 1 
public numCharsRead
numCharsRead DD ?
numCharsWritten DD ?


.code

main PROC near
_main:
		push -11
		call _GetStdHandle@4

		push 0 ;function to output beginning message to console
		push 0
		push 72
		push offset beginGameMsg
		push eax ;outputHandle
		call _writeConsoleA@20
		
		push -10
		call _GetStdHandle@4

		push 0 ;function to read user key entry to begin game
		push offset numCharsRead
		push 70
		push offset readBuffer
		push eax ;inputHandle
		call _ReadConsoleA@20

		_playAgainLoop: ;loop for full game reset
		mov byte ptr [yesWinPlayerFlag], 0
		mov dword ptr [opponentWinWeight], 0
		mov dword ptr [opponentNextMove], 0
		mov dword ptr [opponentRowOutput], 0
		mov byte ptr [opponentInitialMove], 0

		xor eax, eax ;function to reset connect4GraphicsLine2 to default as necessary when beginning a new game
		_graphicsLine2ResetLoop: 
		mov bx, word ptr [connect4GraphicsLine2PlayAgainReset + eax]
		mov word ptr [connect4GraphicsLine2 + eax], bx
		add eax, 2
		cmp eax, 20
		jne _graphicsLine2ResetLoop
			
		xor eax, eax ;function to reset connect4Matrix to default as necessary when beginning a new game
		_clearFullConnect4Board:
		mov byte ptr [connect4Matrix + eax], 0
		inc eax
		cmp eax, 49
		je _fullConnect4BoardClear
		jmp _clearFullConnect4Board
		_fullConnect4BoardClear:

		xor ebx, ebx ;function loop to fully clear screen
		_clearScreenLoop: 
		mov edx, ebx
		shl edx, 16 ;shift left 16 bits as row coordinate is determined by upper 16 bits in SetConsoleCursorPosition coordinates parameter

		push -11
		call _GetStdHandle@4

		push offset numCharsWritten 
		push edx
		push 100
		push ' '
		push eax
		call _FillConsoleOutputCharacterA@20

		inc ebx  ;row counter for rows that need to be cleared
		cmp ebx, 18
		je _endFill
		jmp _clearScreenLoop

		_endFill:

		push -11 ;functions below (primarily writeConsole) are to output Connect4 game graphics/text
		call _GetStdHandle@4

		push 0
		push eax
		call _SetConsoleCursorPosition@8

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 10
		push offset connect4Name
		push eax ;outputHandle
		call _writeConsoleA@20

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 10
		push offset connect4GraphicsLine1
		push eax ;outputHandle
		call _WriteConsoleW@20

		mov ebx, 7
		_initialGraphicsOutput: ;function loop for graphic of currently empty connect4matrix when beginning a new game
		push -11
		call _GetStdHandle@4

		push 0 
		push 0
		push 10
		push offset connect4GraphicsLine2
		push eax ;outputHandle
		call _WriteConsoleW@20
		dec ebx
		cmp ebx, 0
		jne _initialGraphicsOutput

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 10
		push offset connect4GraphicsLine3
		push eax ;outputHandle
		call _WriteConsoleW@20

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 28
		push offset connect4Instruction1
		push eax ;outputHandle
		call _WriteConsoleA@20

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 19
		push offset connect4Instruction2
		push eax ;outputHandle
		call _WriteConsoleW@20

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 23
		push offset connect4Instruction3
		push eax ;outputHandle
		call _WriteConsoleW@20

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 77
		push offset connect4Instruction4
		push eax ;outputHandle
		call _WriteConsoleA@20

		push -11
		call _GetStdHandle@4

		push 0
		push 0
		push 91
		push offset connect4Instruction5
		push eax ;outputHandle
		call _WriteConsoleA@20
		
		_playerInputLoop: ;loop for player input during an ongoing game
		push -11
		call _GetStdHandle@4

		push offset numCharsWritten ;function to clear previous input from player if present
		push 655386
		push numCharsRead
		push ' '
		push eax
		call _FillConsoleOutputCharacterA@20

		push -11
		call _GetStdHandle@4

		push 655386  ;This value adjusts cursor, upper 16 bits row (currently row 10), bottom 16 bits column (currently column 26) - adjusts to player input line for column selection
		push eax 
		call _SetConsoleCursorPosition@8 

		push -10
		call _GetStdHandle@4

		push 0 ;function to read player column entry
		push offset numCharsRead
		push 100
		push offset playerColumnEntry
		push eax ;inputHandle
		call _ReadConsoleA@20
		
		cmp numCharsRead, 3 ;input validation if player enters more than one char
		jg _InvalidInput

		push -11
		call _GetStdHandle@4

		push offset numCharsWritten ;function to clear invalid input message if one is present in console output
		push 720896
		push 83
		push ' '
		push eax
		call _FillConsoleOutputCharacterA@20

		call stringToInt ;player input ascii to int and input validation that ascii char is numeral from 1-7

		cmp invalidInputFlag, 0 ;check if flag from stringToInt set
		jne _invalidInput

		call dropPlayerCircle ;function to place player piece, function within playerCircle.asm
		cmp invalidInputFlag, 0
		je _skipInvalidInput

		_invalidInput: ;invalid input function - triggered from flag set in either stringToInt or dropPlayerCircle function
		push -11 
		call _GetStdHandle@4

		push 720896  ;This value adjusts cursor, upper 16 row (currently row 11), bottom 16 column (currently column 0) invalid input msg line
		push eax 
		call _SetConsoleCursorPosition@8 

		push -11 
		call _GetStdHandle@4

		push 0 ;output of invalid player input message and reset invalidInputFlag to false
		push 0
		push 83
		push offset invalidInputMsg
		push eax ;outputHandle
		call _WriteConsoleA@20 
		mov invalidInputFlag, 0
		jmp _playerInputLoop

		_skipInvalidInput:

		call updatePlayerCircleGraphics ;function to update graphics for player piece, function within playerCircle.asm

		mov byte ptr [playerWinChance], 0
		mov dword ptr [playerWinMove], 0

		call winConditionHorizontalPlayer ;functions to check if player piece has won game
		cmp yesWinPlayerFlag, 1
		je _yesWinPlayer

		call winConditionVerticalPlayer
		cmp yesWinPlayerFlag, 1
		je _yesWinPlayer

		call winConditionDiagonalUpColumnPlayer
		cmp yesWinPlayerFlag, 1
		je _yesWinPlayer

		call winConditionDiagonalUpRowPlayer
		cmp yesWinPlayerFlag, 1
		je _yesWinPlayer

		call winConditionDiagonalDownColumnPlayer
		cmp yesWinPlayerFlag, 1
		je _yesWinPlayer

		call winConditionDiagonalDownRowPlayer
		cmp yesWinPlayerFlag, 1
		je _yesWinPlayer
		
		cmp byte ptr [opponentInitialMove], 1 ;function for initial move of opponent
		je _skipInitialMoveOpponent
		inc byte ptr [opponentInitialMove] ;once opponentInitialMove variable triggered, initial opponent move function no longer activates
		xor edx, edx
		mov ebx, 7
		_verifyRandGenerated:
		rdrand eax
		jnc _verifyRandGenerated
		div ebx
		cmp byte ptr[connect4Matrix + edx], 0 ;if connect4Matrix at offset not full
		jne _initialMoveOpponent
		mov dword ptr [opponentNextMove], edx ;set opponent value to offset
		jmp _checkWinOpponent
		_initialMoveOpponent:
		cmp edx, 6
		je _randAddTooLarge
		add edx, 1
		mov dword ptr [opponentNextMove], edx ;else set next move at offset + 1
		jmp _checkWinOpponent
		_randAddTooLarge:
		sub edx, 1
		mov dword ptr [opponentNextMove], edx ;or set next move at offset - 1
		jmp _checkWinOpponent
		_skipInitialMoveOpponent:
		mov dword ptr [opponentWinWeight], 0 ;reset values for opponent play loop
		mov dword ptr [opponentNextMove], 0
		mov dword ptr [opponentRowOutput], 0

		xor eax, eax				;function to check if Connect4 board is full
		_checkFullBoard:
		cmp byte ptr [connect4Matrix + eax], 0
		je _notFullBoard
		inc eax
		cmp eax, 49
		je _fullConnect4Board
		jmp _checkFullBoard
		_notFullBoard:

		call winConditionHorizontalRightOpponent ;functions to check opponent win conditions for "ideal" opponent move, functions contained within winConditionsOpponent.asm
		call winConditionHorizontalLeftOpponent
		call winConditionVerticalOpponent
		call winConditionDiagonalUpColumnOpponent
		call winConditionDiagonalUpRowOpponent
		call winConditionDiagonalDownColumnOpponent
		call winConditionDiagonalDownRowOpponent

		_checkWinOpponent:
		call checkWinOpponent ;function to check if opponent has win, function within winConditionsOpponent.asm 
		
		cmp winVariable, 0 ;value returned from checkWinOpponent function
		jne _yesWinOpponent
		call noWinOpponent ;function to call if no win opponent
		jmp _playerInputLoop ;function to loop for player input if no winner

		_yesWinOpponent:
		call yesWinOpponent ;function to call if yes win opponent
		jmp _playAgainLoop

		_yesWinPlayer:
		call yesWinPlayer ;function to call if yes win player
		jmp _playAgainLoop

		_fullConnect4Board: 
		call fullConnect4Board ;function to call if full Connect4 board
		jmp _playAgainLoop

main ENDP

END
