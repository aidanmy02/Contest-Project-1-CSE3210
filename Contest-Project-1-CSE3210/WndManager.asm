INCLUDE Chess.inc

.data?
; Params for WNDCLASSEXA Struct
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
CS_NOCLOSE EQU 0200H						; Source: http://learn.microsoft.com/en-us/windows/win32/winmsg/window-class-styles
className BYTE "Wnd",0

; Instance of WNDCLASSEXA
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
						className,\				; lpszClassName
						NULL  >					; hIconSm

; Params for CreateWindowExA
exStyle DWORD NULL							; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
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

	; Get instance handle for current module and register window class
	INVOKE GetModuleHandleA, NULL
	MOV hInstance, eax
	MOV WndClass.hInstance, eax

	INVOKE CreateWindowExA, exStyle, ADDR className, ADDR windowName, style, CW_USEDEFAULT, CW_USEDEFAULT, 400, 400, NULL, NULL, hInstance, NULL

	POP ebp
	RET
createWnd ENDP

END