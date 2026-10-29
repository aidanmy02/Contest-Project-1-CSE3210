INCLUDE Chess.inc

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

; Source: https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect
RECT STRUCT
	left DWORD ?
	top DWORD ?
	right DWORD ?
	bottom DWORD ?
RECT ENDS

; Source: https://learn.microsoft.com/en-us/previous-versions/ms961291(v=msdn.10)
PAINTSTRUCT STRUCT
	hdc DWORD ?
	fErase BYTE ?					; BOOL
	rcPaint RECT <>					; RECT STRUCT
	fRestore BYTE NULL				; BOOL, reserved
	fIncUpdate BYTE NULL			; BOOL, reserved
	rgbReserved BYTE 32 DUP(NULL)	; reserveD
PAINTSTRUCT ENDS

.data?
; Window Attributes
hInstance DWORD ?		; From GetModuleHandleA
classAtom DWORD ?		; From RegisterClassA
hWnd DWORD ?			; From CreateWindowExA
hdc DWORD ?				; From GetDC
wndWidth DWORD ?
wndHeight DWORD ?

; Params for MessageBoxA
errMsg DWORD ?			; Input Param

.data
;TODO: For tests remove later
buffer BYTE 128 DUP(0)
bufferSize DWORD SIZEOF buffer

; Params for WNDCLASSEXA Struct
className BYTE "Wnd",0

; Params for RegisterClassA
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
						NULL	>				; hIconSm

; Params for AdjustWindowRect
clientLen EQU 400
defaultRect RECT	<	0,\						; left
						0,\						; top
						clientlen,\					; right
						clientLen		>				; bottom

; Params for CreateWindowExA
wndName BYTE "Testing Testing 123", 0

; Error Messages for errWnd
errTitle BYTE "Error", 0
defaultErrMsg BYTE "Unknown Error", 0
createErrMsg BYTE "CreateWindowExA failed", 0
modHandleErrMsg BYTE "GetModuleHandleA failed", 0
loadCursorErrMsg BYTE "LoadCursorA failed", 0
regClassErrMsg BYTE "RegisterClassExA failed", 0
adjRectErrMsg BYTE "AdjustWindowRect failed", 0
getDCErrMsg BYTE "GetDC failed", 0

; Codes
; Error Codes
ERR_CREATE EQU 0
ERR_GET_HANDLE EQU 1
ERR_CURSOR EQU 2
ERR_REG_CLASS EQU 3
ERR_ADJRECT EQU 4
ERR_GETDC EQU 5

; WNDCLASSEXA Codes
CS_NOCLOSE EQU 0200H	; style				; Source: http://learn.microsoft.com/en-us/windows/win32/winmsg/window-class-styles
COLOR_WINDOW EQU 5		; hbrBackground		; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor

; LoadCursorA Codes
IDC_ARROW EQU 32512		; lpCursorName		; Source: https://learn.microsoft.com/en-us/windows/win32/menurc/about-cursors

; CreateWindowExA Codes
WS_OVERLAPPEDWINDOW EQU 00CF0000h	; style		; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
CW_USEDEFAULT EQU 80000000h			; x, y		; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createmdiwindowa

; ShowWindow Codes
SW_SHOWDEFAULT EQU 10

.code
; WndProc for WNDCLASSEXA
; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
WndProc PROC, wpHWnd:DWORD, wpUMsg:DWORD, wpWParam:DWORD, wpLParam:DWORD
	; Get WP code
	MOV eax, wpUMsg
	
	; Jump to code action
	CMP eax, WP_INIT
	JZ wpInit
	CMP eax, WP_PAINT
	JZ wpPaint
	CMP eax, WP_DESTROY
	JZ wpDestroy
	JMP wpDefault

	wpInit:
		CALL initWnd
		MOV eax, 0
		JMP wpDone

	wpPaint:
		CALL paintSquare
		JMP wpDone

	wpDestroy:
		INVOKE DestroyWindow, hWnd			; hWnd
		JMP wpDone

	wpDefault:
		INVOKE DefWindowProcA,	wpHWnd,\	; hWnd
								wpUMsg,\	; uMsg
								wpWParam,\	; wParam
								wpLParam	; lParam

	wpDone:
	RET
WndProc ENDP

; Registers window class and creates window
initWnd PROC
	; Get instance handle for current module and register window class
	INVOKE GetModuleHandleA, NULL

	; Check if module handle was successfully obtained
	CMP eax, NULL
	JNZ gotModuleHandle

	; GetModuleHandleA failed
	MOV eax, ERR_GET_HANDLE
	PUSH eax
	CALL errWnd

	gotModuleHandle:
	MOV hInstance, eax
	MOV WndClass.hInstance, eax

	INVOKE LoadCursorA, NULL,\					; hInstance
						IDC_ARROW				; lpCursorName

	; Check if cursor was successfully loaded
	CMP eax, NULL
	JNZ cursorLoaded

	; LoadCursorA failed
	MOV eax, ERR_CURSOR
	PUSH eax
	CALL errWnd

	cursorLoaded:
	MOV WndClass.hCursor, eax

	INVOKE RegisterClassExA, ADDR WndClass

	; Check if class was registered
	CMP eax, NULL
	JNZ classRegistered

	; RegisterClassExA failed
	MOV eax, ERR_REG_CLASS
	PUSH eax
	CALL errWnd

	classRegistered:
	MOV classAtom, eax

	INVOKE AdjustWindowRect,ADDR defaultRect,\
							WS_OVERLAPPEDWINDOW,\
							FALSE
	
	; Check if window dimensions were received
	CMP eax, NULL
	JNZ windowAdjusted

	; AdjustWindowRect failed
	MOV eax, ERR_ADJRECT
	PUSH eax
	CALL errWnd

	windowAdjusted:
	MOV eax, defaultRect.right
	SUB eax, defaultRect.left
	MOV wndWidth, eax

	MOV eax, defaultRect.bottom
	SUB eax, defaultRect.top
	MOV wndHeight, eax

	INVOKE CreateWindowExA, NULL,\					; dwExStyle
							ADDR className,\		; lpClassName
							ADDR wndName,\			; lpWindowName
							WS_OVERLAPPEDWINDOW,\	; dwStyle
							CW_USEDEFAULT,\			; x
							CW_USEDEFAULT,\			; y
							wndWidth,\				; nWidth
							wndHeight,\				; nHeight
							NULL,\					; hWndParent
							NULL,\					; hMenu
							hInstance,\				; hInstance
							NULL					; lpParam
	
	; Check if window was successfully created
	CMP eax, 0
	JNZ windowCreated

	; CreateWindowExA failed
	MOV eax, ERR_CREATE
	PUSH eax
	CALL errWnd

	windowCreated:
	MOV hWnd, eax

	INVOKE ShowWindow,		hWnd,					; hWnd
							SW_SHOWDEFAULT			; nCmdShow

	RET
initWnd ENDP

paintSquare PROC
	INVOKE GetDC,			hWnd					; hWnd
	
	; Check if device context was obtained
	CMP eax, NULL
	JNZ gotDC

	; GetDC failed
	MOV eax, ERR_GETDC
	PUSH eax
	CALL errWnd

	gotDC:
	MOV hdc, eax
	RET
paintSquare ENDP

; Creates error popup window
errWnd PROC
	default:
	PUSH ebp
	MOV ebp, esp
	
	; Get error code
	MOV eax, [ebp + 8]

	; Identifying error type
	CMP eax, ERR_CREATE
	JZ createErr
	CMP eax, ERR_GET_HANDLE
	JZ getHandleErr
	CMP eax, ERR_CURSOR
	JZ cursorErr
	CMP eax, ERR_REG_CLASS
	JZ regClassErr
	CMP eax, ERR_ADJRECT
	JZ adjRectErr
	CMP eax, ERR_GETDC
	JZ getDCErr
	JMP errDefault

	createErr:
	PUSH OFFSET createErrMsg
	JMP postMsg

	getHandleErr:
	PUSH OFFSET modHandleErrMsg
	JMP postMsg

	cursorErr:
	PUSH OFFSET loadCursorErrMsg
	JMP postMsg

	regClassErr:
	PUSH OFFSET regClassErrMsg
	JMP postMsg

	adjRectErr:
	PUSH OFFSET adjRectErrMsg
	JMP postMsg

	getDCErr:
	PUSH OFFSET getDCErrMsg
	JMP postMsg

	errDefault:
	PUSH OFFSET defaultErrMsg
	POP errMsg

	postMsg:
	POP errMsg
	INVOKE MessageBoxA,		NULL,\				; hWnd
							errMsg,\			; lpText
							ADDR errTitle,\			; lpCaption
							NULL				; uType

	POP ebp
	INVOKE ExitProcess, 0
errWnd ENDP

END