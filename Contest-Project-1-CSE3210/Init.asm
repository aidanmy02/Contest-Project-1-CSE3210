INCLUDE Chess.inc

.data?
status DWORD ?

.code
init PROC
	PUSH ebp
	MOV ebp, esp

	INVOKE WinMain,		NULL,\				; hInstance
						NULL,\				; hPrevInstance
						NULL,\				; lpCmdLine
						SW_SHOWDEFAULT		; nShowCmd
	MOV status, eax

	COMMENT @
	INVOKE BoardProc,	BP_INIT,\			; uMsg
						NULL,\				; col
						NULL,\				; row
						NULL				; piece
	COMMENT @
	POP ebp
	RET
init ENDP

END