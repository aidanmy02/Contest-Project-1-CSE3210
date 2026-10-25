INCLUDE Chess.inc

.data?
status DWORD ?

.code
init PROC
	PUSH ebp
	MOV ebp, esp

	INVOKE WndProc,	NULL,\				; hWnd
					WP_CREATE,\			; uMsg
					NULL,\				; wParam
					NULL				; lParam
	MOV status, eax

	POP ebp
	RET
init ENDP

END