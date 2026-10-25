INCLUDE Chess.inc

.code
init PROC
	PUSH ebp
	MOV ebp, esp

	CALL createWnd

	POP ebp
	RET
init ENDP

END