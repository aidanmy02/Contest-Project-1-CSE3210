INCLUDE Chess.inc

.data?
; Params for WNDCLASSEXA Struct
hInstance DWORD ?

; Params for RegisterClassExA
classAtom DWORD ?		; Output Param

; Params for CreateWindowExA
hWnd DWORD ?			; Output Param

.data
;TODO: For tests remove later
buffer BYTE 128 DUP(0)
bufferSize DWORD SIZEOF buffer

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
wndName BYTE "Testing Testing 123",0
style DWORD 10000000h						; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
CW_USEDEFAULT EQU 80000000h					; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createmdiwindowa
wndLen EQU 400

.code
; WndProc for WNDCLASSEXA
; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
WndProc PROC
	PUSH ebp
	MOV ebp, esp

	INVOKE DefWindowProcA,	[ebp+8],\	; hWnd
							[ebp+12],\	; uMsg
							[ebp+16],\	; wParam
							[ebp+20]	; lParam

	POP ebp
	RET 16
WndProc ENDP

; Registers window class and creates window
createWnd PROC
	PUSH ebp
	MOV ebp, esp

	; Get instance handle for current module and register window class
	INVOKE GetModuleHandleA, NULL
	MOV hInstance, eax
	MOV WndClass.hInstance, eax

	INVOKE RegisterClassExA, ADDR WndClass
	MOV classAtom, eax

	INVOKE CreateWindowExA, exStyle,\			; dwExStyle
							ADDR className,\	; lpClassName
							ADDR wndName,\		; lpWindowName
							style,\				; dwStyle
							CW_USEDEFAULT,\		; x
							CW_USEDEFAULT,\		; y
							wndLen,\			; nWidth
							wndLen,\			; nHeight
							NULL,\				; hWndParent
							NULL,\				; hMenu
							hInstance,\			; hInstance
							NULL				; lpParam
	MOV hWnd, eax

	POP ebp
	RET
createWnd ENDP

END