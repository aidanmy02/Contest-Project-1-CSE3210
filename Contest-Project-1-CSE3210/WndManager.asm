INCLUDE Chess.inc

WndProc PROTO, wpHWnd:DWORD, wpUMsg:DWORD, wpWParam:DWORD, wpLParam:DWORD

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
	fErase DWORD NULL				; BOOL
	rcPaint RECT <>					; RECT STRUCT
	fRestore DWORD NULL				; BOOL, reserved
	fIncUpdate DWORD NULL			; BOOL, reserved
	rgbReserved BYTE 32 DUP(NULL)	; reserveD
PAINTSTRUCT ENDS

MSGSTRUCT STRUCT
	hWnd DWORD ?
	message DWORD ?
	wParam DWORD ?
	lParam DWORD ?
	time DWORD ?
	point DWORD ?
	lPrivate DWORD ?
MSGSTRUCT ENDS

.data?
; Window Attributes
classAtom DWORD ?		; From RegisterClassA
hWndMain DWORD ?		; From CreateWindowExA
hdc DWORD ?				; From GetDC
wndWidth DWORD ?
wndHeight DWORD ?
hHeap DWORD ?
hThread DWORD ?
pid DWORD ?
wSqr DWORD ?
bSqr DWORD ?

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
						NULL,\					; hInstance
						NULL,\					; hIcon
						NULL,\					; hCursor
						COLOR_WINDOW + 1,\		; hbrBackground
						NULL,\					; lpszMenuName
						OFFSET className,\		; lpszClassName
						NULL	>				; hIconSm

; Params for AdjustWindowRect
clientLen EQU 400
sqrLen EQU 50
defaultRect RECT	<	0,\						; left
						0,\						; top
						clientlen,\				; right
						clientLen		>		; bottom

; For painting
updateRect RECT 64 DUP(<>)
wSqrColor DWORD 0FFCFCFh
bSqrColor DWORD 292817h
transColor DWORD 0FFFFFFh

; Initialize PAINTSTRUCT
paintParam PAINTSTRUCT <>

; Params for CreateWindowExA
wndName BYTE "Testing Testing 123", 0

; Params for GetMessage
msg MSGSTRUCT <>

; Piece BMP Images Paths
queenImgPath BYTE "C:\Users\aidan\source\repos\Contest-Project-1-CSE3210\Contest-Project-1-CSE3210\Pieces\queen.bmp", 0

; Piece BitMap handles
wQueenHBit DWORD ?

; Piece DC handles
wQueenDC DWORD ?

; Holds regions of pieces from SelectObject
hReg DWORD ?

; Piece 
; Error Messages for errWnd
errTitle BYTE "Error", 0
defaultErrMsg BYTE "Unknown Error", 0
createErrMsg BYTE "CreateWindowExA failed", 0
modHandleErrMsg BYTE "GetModuleHandleA failed", 0
loadCursorErrMsg BYTE "LoadCursorA failed", 0
regClassErrMsg BYTE "RegisterClassExA failed", 0
adjRectErrMsg BYTE "AdjustWindowRect failed", 0
beginPaintErrMsg BYTE "BeginPaint failed", 0

; Codes
; Error Codes
ERR_CREATE EQU 0
ERR_GETHANDLE EQU 1
ERR_CURSOR EQU 2
ERR_REGCLASS EQU 3
ERR_ADJRECT EQU 4
ERR_BEGINPAINT EQU 5
ERR_GETMSG EQU 6
ERR_DISPMSG EQU 7

; WNDCLASSEXA Codes
CS_NOCLOSE EQU 0200H	; style				; Source: http://learn.microsoft.com/en-us/windows/win32/winmsg/window-class-styles
COLOR_WINDOW EQU 5		; hbrBackground		; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor

; LoadCursorA Codes
IDC_ARROW EQU 32512		; lpCursorName		; Source: https://learn.microsoft.com/en-us/windows/win32/menurc/about-cursors

; CreateWindowExA Codes
WS_OVERLAPPEDWINDOW EQU 00CF0000h	; style		; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
CW_USEDEFAULT EQU 80000000h			; x, y		; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createmdiwindowa

; LoadImageA Codes
IMAGE_BITMAP EQU 0		; uType				; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-copyimage
LR_LOADFROMFILE EQU 10h	; fuLoad			; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadimagea

.code
; Implementation of WinMain for message passing to window
WinMain PROC, hInstance:DWORD, hPrevInstance:DWORD, lpCmdLine:DWORD, nShowCmd:DWORD
	MOV eax, hPrevInstance
	CMP eax, NULL
	JNZ msgLoop
	
	INVOKE GetModuleHandleA, NULL

	; Check if handle was successfully obtained
	CMP eax, NULL
	JNZ gotHandle

	; GetModuleHandleA failed
	MOV eax, ERR_GETHANDLE
	PUSH eax
	CALL errWnd

	gotHandle:
	MOV WndClass.hInstance, eax
	CALL createWnd

	MOV move.uMsg, BP_INIT
	INVOKE CreateThread,	NULL,\				; lpThreadAttributes
							NULL,\				; dwStackSize
							ADDR BoardProc,\	; lpStartAddress
							NULL,\				; lpParameter
							NULL,\				; dwCreationFlags
							ADDR pid			; lpThreadId
	MOV hThread, eax
	
	msgLoop:
	INVOKE GetMessageA,		ADDR msg,\			; lpMsg
							hWndMain,\			; hWnd
							NULL,\				; wMsgFilterMin
							NULL				; wMsgFilterMax
	
	; Check for WM_QUIT message
	CMP eax, 0
	JZ endLoop
	; Check for error
	CMP eax, -1
	JNZ dispatchMsg

	; GetMessage failed
	MOV eax, ERR_GETMSG
	PUSH eax
	CALL errWnd

	dispatchMsg:
	INVOKE DispatchMessageA, ADDR msg		; lpMsg
	JMP msgLoop

	endLoop:
	INVOKE WndProc,		NULL,\				; hWnd
						WM_DESTROY,\		; uMsg
						NULL,\				; wParam
						NULL				; lParam
	
	RET
WinMain ENDP

; Implementation of WndProc for message processing
; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
WndProc PROC, hWnd:DWORD, wpUMsg:DWORD, wpWParam:DWORD, wpLParam:DWORD
	; Get WP code
	MOV eax, wpUMsg
	
	; Jump to code action
	CMP eax, WM_PAINT
	JZ wpPaint
	CMP eax, WM_SQR
	JZ wpSqr
	CMP eax, WM_DESTROY
	JZ wpDestroy
	JMP wpSys

	wpPaint:
		INVOKE BeginPaint,		hWnd,\			; hWnd
								ADDR paintParam	; lpPaint
		
		; Check if BeginPaint returned hdc
		CMP eax, NULL
		JNZ beganPaint
		
		; BeginPaint failed
		MOV eax, ERR_BEGINPAINT
		PUSH eax
		CALL errWnd

		beganPaint:
		INVOKE EndPaint,		hWnd,\				; hWnd
								ADDR paintParam		; lpPaint
		JMP wpDone

	wpSqr:
		; Get MOVESTRUCT address from wParam
		MOV esi, wpWParam

		; Get square color
		XOR eax, eax
		MOV al, (MOVESTRUCT PTR [esi]).sqrColor
		CMP al, 0
		JZ isWhiteSqr
		MOV eax, bSqr
		JMP gotSqrColor
		isWhiteSqr:
			MOV eax, wSqr

		gotSqrColor:
		; Save brush handle
		PUSH eax

		; Get RECT of square
		MOV eax, (MOVESTRUCT PTR [esi]).coord
		CALL translateCoords
		MOV edi, eax

		; Get handle to DC
		INVOKE GetDC,			hWndMain			; hWnd
		MOV hdc, eax

		; Return brush handle to eax
		POP eax
		INVOKE FillRect,		hdc,\				; hDC
								edi,\				; lprc
								eax					; hbr

		XOR eax, eax
		MOV al, (MOVESTRUCT PTR [esi]).piece
		CALL getPieceDC
		CMP eax, NULL
		JZ wpDone

		INVOKE TransparentBlt,	hdc,\					; hdcDest
								(RECT PTR [edi]).left,\	; xoriginDest
								(RECT PTR [edi]).top,\	; yoriginDest
								sqrLen,\				; wDest
								sqrLen,\				; hDest
								eax,\					; hdcSrc
								0,\						; xoriginSrc
								0,\						; yoriginSrc
								sqrLen,\				; wSrc
								sqrLen,\				; hSrc
								transColor				; crTransparent

		JMP wpDone

	wpDestroy:
		INVOKE DestroyWindow,	hWnd			; hWnd
		JMP wpDone

	wpSys:
		INVOKE DefWindowProcA,	hWnd,\			; hWnd
								wpUMsg,\		; uMsg
								wpWParam,\		; wParam
								wpLParam		; lParam

	wpDone:
	RET
WndProc ENDP

; Registers window class and creates window
createWnd PROC
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
	MOV eax, ERR_REGCLASS
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
							WndClass.hInstance,\	; hInstance
							NULL					; lpParam
	
	; Check if window was successfully created
	CMP eax, 0
	JNZ windowCreated

	; CreateWindowExA failed
	MOV eax, ERR_CREATE
	PUSH eax
	CALL errWnd

	windowCreated:
	MOV hWndMain, eax

	INVOKE ShowWindow,			hWndMain,				; hWnd
								SW_SHOWDEFAULT			; nCmdShow

	INVOKE LoadImageA,			NULL,\	; hInst
								ADDR queenImgPath,\		; lpszName
								IMAGE_BITMAP,\			; uType
								sqrLen,\				; cxDesired
								sqrLen,\				; cyDesired
								LR_LOADFROMFILE			; fuLoad
	MOV wQueenHBit, eax

	INVOKE CreateCompatibleDC,	NULL					; hDC
	MOV wQueenDC, eax

	INVOKE SelectObject,		wQueenDC,\				; hDC
								wQueenHBit				; hObject
	MOV hReg, eax

	INVOKE GetDC,				hWndMain				; hWnd
	MOV hdc, eax

	INVOKE TransparentBlt,		hdc,\					; hdcDest
								0,\						; xoriginDest
								0,\						; yoriginDest
								sqrLen,\				; wDest
								sqrLen,\				; hDest
								wQueenDC,\				; hdcSrc
								0,\						; xoriginSrc
								0,\						; yoriginSrc
								sqrLen,\				; wSrc
								sqrLen,\				; hSrc
								transColor				; crTransparent

	INVOKE CreateSolidBrush,	wSqrColor				; color
	MOV wSqr, eax

	INVOKE CreateSolidBrush,	bSqrColor				; color
	MOV bSqr, eax
	
	RET 
createWnd ENDP

;
getPieceDC PROC
;	@ Params:	eax - piece
;	@ Return:	eax - piece DC handle
	CMP al, NULL			; Empty square
	JZ gotPieceDC
	COMMENT @		; TODO: add back when more pieces available
	CMP al, PIECE_WQUEEN
	JZ getWQueenDC
	@
	getWQueenDC:
		MOV eax, wQueenDC
		JMP gotPieceDC

	gotPieceDC:
	RET
getPieceDC ENDP

;
translateCoords PROC
;	@ Params:	eax upper half - x coordinate
;				ax - y coordinate
;	@ Return:	eax - address of RECT
	PUSH esi		; Save esi

	; Get offset of RECT
	; Conserves coords in ecx
	MOV ecx, eax
	SHR eax, 16
	DEC eax
	MOV ebx, 8
	MUL ebx
	ADD ax, cx
	DEC eax
	MOV ebx, SIZEOF RECT
	MUL ebx
	MOV esi, OFFSET updateRect
	ADD esi, eax

	; Get right and left sides of the square
	MOV eax, ecx
	SHR eax, 16
	MOV ebx, sqrLen
	MUL ebx
	MOV (RECT PTR [esi]).right, eax
	SUB eax, sqrLen
	MOV (RECT PTR [esi]).left, eax

	; Flip y coordinate to align with window coord layout
	MOVZX eax, cx
	NEG eax
	ADD eax, 8
	MOV ebx, sqrLen
	MUL ebx
	MOV (RECT PTR [esi]).top, eax
	ADD eax, sqrLen
	MOV (RECT PTR [esi]).bottom, eax

	; Return address of RECT
	MOV eax, esi
	POP esi			; Restore esi
	RET
translateCoords ENDP

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
	CMP eax, ERR_GETHANDLE
	JZ getHandleErr
	CMP eax, ERR_CURSOR
	JZ cursorErr
	CMP eax, ERR_REGCLASS
	JZ regClassErr
	CMP eax, ERR_ADJRECT
	JZ adjRectErr
	CMP eax, ERR_BEGINPAINT
	JZ beginPaintErr
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

	beginPaintErr:
	PUSH OFFSET beginPaintErrMsg
	JMP postMsg

	errDefault:
	PUSH OFFSET defaultErrMsg
	POP errMsg

	postMsg:
	POP errMsg
	INVOKE MessageBoxA,		NULL,\				; hWnd
							errMsg,\			; lpText
							ADDR errTitle,\		; lpCaption
							NULL				; uType

	POP ebp
	INVOKE ExitProcess, 0
errWnd ENDP

END