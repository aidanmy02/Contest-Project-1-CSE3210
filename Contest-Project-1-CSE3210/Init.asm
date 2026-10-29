INCLUDE Chess.inc

.data?
status DWORD ?

.code
init PROC
	PUSH ebp
	MOV ebp, esp

	INVOKE WndProc,		NULL,\				; hWnd
						WP_INIT,\			; uMsg
						NULL,\				; wParam
						NULL				; lParam
	MOV status, eax

	INVOKE BoardProc,	BP_INIT,\			; uMsg
						NULL,\				; col
						NULL,\				; row
						NULL				; piece

	POP ebp
	RET
init ENDP

END