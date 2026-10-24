INCLUDE Chess.inc

.data?
hInstance DWORD ?

.data
; Structs
; Source: http://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa
WNDCLASSEXA STRUCT
	cbSize DWORD ?
	style DWORD ?
	lpfnWndProc DWORD ?
	cbClsExtra DWORD ?
	cbWndExtra DWORD ?
	hInstance DWORD ?
	hIcon DWORD ?
	hCursor DWORD ?
	hbrBackground DWORD ?
	lpszMenuName DWORD ?
	lpszClassName DWORD ?
	hIconSm DWORD ?
WNDCLASSEXA ENDS

; Params for WNDCLASSEXA Struct
CS_NOCLOSE EQU 0200H						;Source: http://learn.microsoft.com/en-us/windows/win32/winmsg/window-class-styles
lpszClassName BYTE "Wnd",0
WndClass WNDCLASSEXA <	SIZEOF WNDCLASSEXA,\	; cbSize
						CS_NOCLOSE,\			; style
						OFFSET WndProc,\		; lpfnWndProc
						NULL,\					; cbClsExtra
						NULL,\					; cbWndExtra
						hInstance,\				; hInstance
						NULL,\					; hIcon
						NULL,\					; hCursor
						NULL,\					; hbrBackground
						NULL,\					; lpszMenuName
						lpszClassName,\			; lpszClassName
						NULL  >					; hIconSm

; Params for CreateWindowExA
exStyle DWORD NULL								; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
className BYTE "STATIC",0
windowName BYTE "Testing Testing 123",0
style DWORD 10000000h						; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
CW_USEDEFAULT EQU 80000000h					; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createmdiwindowa

.code
; WndProc for WNDCLASSEXA
; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
WndProc PROC
	PUSH ebp
	MOV ebp, esp

	POP ebp
	RET
WndProc ENDP

	; Registers window class and creates window
	createWnd PROC
	PUSH ebp
	MOV ebp, esp

	; Soruce: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexa
	INVOKE CreateWindowExA, exStyle, ADDR className, ADDR windowName, style, CW_USEDEFAULT, CW_USEDEFAULT, 400, 400, NULL, NULL, NULL, NULL

	POP ebp
	RET
createWnd ENDP

END