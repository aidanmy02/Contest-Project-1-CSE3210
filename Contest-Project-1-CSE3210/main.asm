INCLUDE Chess.inc

.code
main PROC
	CALL init

	INVOKE WndProc,	NULL,\				; hWnd
					WM_DESTROY,\		; uMsg
					NULL,\				; wParam
					NULL				; lParam

	INVOKE ExitProcess, 0
main ENDP
END main