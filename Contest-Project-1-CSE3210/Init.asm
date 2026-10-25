INCLUDE Chess.inc

.code
init PROC
	PUSH ebp
	MOV ebp, esp

	INVOKE WndProc,	NULL,\				; hWnd
					WP_CREATE,\			; uMsg
					NULL,\				; wParam
					NULL				; lParam

	POP ebp
	RET
init ENDP

END