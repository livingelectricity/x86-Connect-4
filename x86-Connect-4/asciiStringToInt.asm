.386P

.model flat

extern playerColumnEntry:byte
extern invalidInputFlag:byte

.code

stringToInt PROC near
_stringToInt:
		
		mov al, byte ptr [playerColumnEntry] ;player input for desired column to insert piece
	
		cmp al, 30h ;ascii input lower that 1 dectected, input not valid
		jle _invalidInput
		cmp al, 38h ;ascii input higher than 7 detected, input not valid
		jge _invalidInput
		sub eax, '0'
		ret

		_invalidInput: 
		mov invalidInputFlag, 1 ;invalidInputFlag sets trigger to output invalid input msg and jump to _loopPlayerInput
		ret

stringToInt ENDP

END