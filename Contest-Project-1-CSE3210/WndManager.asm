INCLUDE Chess.inc

.data?
; Params for WNDCLASSEXA Struct
hInstance DWORD ?

; Params for RegisterClassExA
classAtom DWORD ?		; Output Param

; Params for CreateWindowExA
hWnd DWORD ?			; Output Param

; Params for MessageBoxA
errMsg DWORD ?			; Input Param
errTitle DWORD ?		; Input Param

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
COLOR_WINDOW EQU 5

; Instance of WNDCLASSEXA
WndClass WNDCLASSEXA <	SIZEOF WNDCLASSEXA,\	; cbSize
						CS_NOCLOSE,\			; style
						OFFSET WndProc,\		; lpfnWndProc
						NULL,\					; cbClsExtra
						NULL,\					; cbWndExtra
						hInstance,\				; hInstance
						NULL,\					; hIcon
						NULL,\					; hCursor
						COLOR_WINDOW + 1,\		; hbrBackground
						NULL,\					; lpszMenuName
						OFFSET className,\		; lpszClassName
						NULL  >					; hIconSm

; Params for LoadCursorA
IDC_ARROW EQU 32512							; https://learn.microsoft.com/en-us/windows/win32/menurc/about-cursors

; Params for CreateWindowExA
exStyle DWORD NULL							; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
wndName BYTE "Testing Testing 123", 0
style DWORD 10000000h						; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
CW_USEDEFAULT EQU 80000000h					; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createmdiwindowa
wndLen EQU 400

; Error Codes
ERR_CREATE EQU 0

; Error Messages for errWnd
defaultErrMsg BYTE "Unknown Error", 0
defaultErrTitle BYTE "Error: Unknown", 0
createErrMsg BYTE "CreateWindowExA failed", 0
createErrTitle BYTE "Error: CreateWindowExA", 0

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
	; Get instance handle for current module and register window class
	INVOKE GetModuleHandleA, NULL
	MOV hInstance, eax
	MOV WndClass.hInstance, eax

	INVOKE LoadCursorA, hInstance, IDC_ARROW
	MOV WndClass.hCursor, eax

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
	
	; Check if window was successfully created
	CMP eax, 0
	JNZ windowCreated

	; CreateWindowExA failed
	MOV eax, ERR_CREATE
	PUSH eax
	CALL errWnd

	windowCreated:
	MOV hWnd, eax

	RET
createWnd ENDP

; Creates error popup window
errWnd PROC
	default:
	PUSH ebp
	MOV ebp, esp
	
	; Get error code
	MOV eax, [ebp + 8]

	; Creation error
	CMP eax, 0
	JZ createErr

	JMP default

	createErr:
	PUSH OFFSET createErrMsg
	POP errMsg
	PUSH OFFSET createErrTitle
	POP errTitle
	JMP postMsg

	PUSH OFFSET defaultErrMsg
	POP errMsg
	PUSH OFFSET defaultErrTitle
	POP errTitle

	postMsg:
	INVOKE MessageBoxA,		NULL,\				; hWnd
							errMsg,\			; lpText
							errTitle,\			; lpCaption
							NULL				; uType

	POP ebp
	INVOKE ExitProcess, 0
errWnd ENDP

END