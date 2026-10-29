INCLUDE Chess.inc

.data?
status DWORD ?

.code
init PROC
	PUSH ebp
	MOV ebp, esp

	INVOKE WndProc,		NULL,\				; hWnd
						WM_CREATE,\			; uMsg
						NULL,\				; wParam
						NULL				; lParam
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