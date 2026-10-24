INCLUDE Chess.inc

.data
; Params for WNDCLASSEXA Struct
CS_NOCLOSE EQU 0200H						;Source: http://learn.microsoft.com/en-us/windows/win32/winmsg/window-class-styles


; Params for CreateWindowExA
exStyle DWORD 0								; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
className BYTE "STATIC",0
windowName BYTE "Testing Testing 123",0
style DWORD 10000000h						; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
CW_USEDEFAULT EQU 80000000h					; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createmdiwindowa

WNDCLASSEXA STRUCT
	cbSize DWORD SIZEOF WNDCLASSEXA
	style DWORD CS_NOCLOSE
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
INVOKE CreateWindowExA, exStyle, ADDR className, ADDR windowName, style, CW_USEDEFAULT, CW_USEDEFAULT, 400, 400, 0, 0, 0, 0

POP ebp
RET
createWnd ENDP
END