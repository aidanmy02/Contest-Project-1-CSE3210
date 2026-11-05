; Assembler Directives
.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

; Windows SDK Libraries
INCLUDELIB Kernel32.lib
INCLUDELIB User32.lib	; Sources:	Textbook and https://learn.microsoft.com/en-us/cpp/assembler/masm/includelib-masm?view=msvc-170
						;			https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassa
INCLUDELIB Gdi32.lib	; Source:	https://learn.microsoft.com/en-us/windows/win32/gdi/windows-gdi
INCLUDELIB Msimg32.lib	; Source:	https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-transparentblt

; Global Constants
NULL EQU 0
FALSE EQU 0
TRUE EQU 1

; CODES
; WndProc Codes
; Source: https://www.autoitscript.com/autoit3/docs/appendix/WinMsgCodes.htm
WM_CREATE EQU 1
WM_DESTROY EQU 2
WM_PAINT EQU 0Fh
WM_SQR EQU 8001h

; BoardProc Codes
BP_INIT EQU 0
BP_CONT EQU 1
BP_COLOR EQU 2
BP_MOVE EQU 3
BP_ENPASSANT EQU 4
BP_CASTLE EQU 5
BP_CHECK EQU 7

; MoveProc Codes
MV_CHECK EQU 1
MV_CHECKED EQU 2

; HeapAlloc Codes
HEAP_ZERO_MEMORY EQU 8

; ShowWindow Codes
SW_NORMAL EQU 1
SW_SHOWDEFAULT EQU 10

; Colors
COLOR_WHITE EQU 0FFCFCFh
COLOR_BLACK EQU 292817h
COLOR_TRANS EQU 0FFFFFFh
COLOR_HL EQU 03131A0h
COLOR_CHECKHL EQU 077342Eh

; Color Codes
WHITE EQU 0
BLACK EQU 1
HL EQU 2
CHECKHL EQU 3

; Semaphore Codes
EXTERN SEM_PAINT:ABS
EXTERN SEM_MOVE:ABS

; Piece Codes
WPAWN EQU 'P'
WROOK EQU 'R'
WKNIGHT EQU 'N'
WBISHOP EQU 'B'
WQUEEN EQU 'Q'
WKING EQU 'K'
BPAWN EQU 'p'
BROOK EQU 'r'
BKNIGHT EQU 'n'
BBISHOP EQU 'b'
BQUEEN EQU 'q'
BKING EQU 'k'

; Structs
; Coordinate
COORDSTRUCT STRUCT
	x WORD ?
	y WORD ?
COORDSTRUCT ENDS

; Move
MOVESTRUCT STRUCT
	uMsg DWORD ?
	coord COORDSTRUCT <>
	piece BYTE ?
	sqrColor BYTE ?
MOVESTRUCT ENDS

MSGSTRUCT STRUCT
	hWnd DWORD ?
	message DWORD ?
	wParam DWORD ?
	lParam DWORD ?
	time DWORD ?
	pt DWORD ?
	lPrivate DWORD ?
MSGSTRUCT ENDS

BOARDSTRUCT STRUCT
	_a BYTE WROOK,	WPAWN,	0,	0,	0,	0,	BPAWN,	BROOK
	_b BYTE WKNIGHT,WPAWN,	0,	0,	0,	0,	BPAWN,	BKNIGHT
	_c BYTE WBISHOP,WPAWN,	0,	0,	0,	0,	BPAWN,	BBISHOP
	_d BYTE WQUEEN,	WPAWN,	0,	0,	0,	0,	BPAWN,	BQUEEN
	_e BYTE WKING,	WPAWN,	0,	0,	0,	0,	BPAWN,	BKING
	_f BYTE WBISHOP,WPAWN,	0,	0,	0,	0,	BPAWN,	BBISHOP
	_g BYTE WKNIGHT,WPAWN,	0,	0,	0,	0,	BPAWN,	BKNIGHT
	_h BYTE WROOK,	WPAWN,	0,	0,	0,	0,	BPAWN,	BROOK
BOARDSTRUCT ENDS

EXTERNDEF move:MOVESTRUCT
EXTERNDEF hWndMain:DWORD
EXTERNDEF prevMove:MOVESTRUCT

; For passing messages
EXTERNDEF msg:MSGSTRUCT

; Subroutine Prototypes
BoardProc PROTO

main PROTO

init PROTO

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-winmain
;		  https://learn.microsoft.com/en-us/windows/win32/winmsg/using-messages-and-message-queues
WinMain PROTO,			hInstance:DWORD,\
						hPrevInstance:DWORD,\
						lpCmdLine:DWORD,\
						nShowCmd:DWORD

; Sempaphore function declarations
InitSem EQU <InitSem@0>
SignalSem EQU <SignalSem@0>
WaitSem EQU <WaitSem@0>
EXTERN InitSem:PROC
EXTERN SignalSem:PROC
EXTERN WaitSem:PROC

; System Call Prototypes and Sources for Information
; TODO: For debugging; remove later
GetClassNameA PROTO,	hWnd:DWORD,\
						lpClassName:DWORD,\
						nMaxCount:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-adjustwindowrect
AdjustWindowRect PROTO,	lpRect:DWORD,\
						dwStyle:DWORD,\
						bMenu:BYTE				; BOOL

; Source: https://learn.microsoft.com/en-us/previous-versions/ms961291(v=msdn.10)
BeginPaint PROTO,		hWnd:DWORD,\
						lpPaint:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createcompatibledc
;		  https://learn.microsoft.com/en-us/previous-versions/windows/embedded/ee504566(v=winembedded.60)?redirectedfrom=MSDN
CreateCompatibleDC PROTO,	hDC:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createsolidbrush
CreateSolidBrush PROTO,	color:DWORD

; Sources: https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createthread
;		   https://learn.microsoft.com/en-us/windows/win32/procthread/creating-threads
CreateThread PROTO,		lpThreadAttributes:DWORD,\
						dwStackSize:DWORD,\
						lpStartAddress:DWORD,\
						lpParameter:DWORD,\
						dwCreationFlags:DWORD,\
						lpThreadId:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexa
CreateWindowExA PROTO,	dwExStyle:DWORD,\
						lpClassName:DWORD,\
						lpWindowName:DWORD,\
						dwStyle:DWORD,\
						x:DWORD,\
						y:DWORD,\
						nWidth:DWORD,\
						nHeight:DWORD,\
						hWndParent:DWORD,\
						hMenu:DWORD,\
						hInstance:DWORD,\
						lpParam:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-defwindowproca
DefWindowProcA PROTO,	hWnd:DWORD,\
						uMsg:DWORD,\
						wParam:DWORD,\
						lParam:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-destroywindow
DestroyWindow PROTO,	hWnd:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-dispatchmessage
DispatchMessageA PROTO,	lpMsg:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess
ExitProcess PROTO,		dwExitCode:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitthread
ExitThread PROTO,		dwExitCode:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-endpaint
EndPaint PROTO,			hWnd:DWORD,\
						lpPaint:DWORD			; pointer to PAINTSTRUCT

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-fillrect
FillRect PROTO,			hDC:DWORD,\
						lprc:DWORD,\			; pointer to RECT
						hbr:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect
GetClientRect PROTO,	hWnd:DWORD,\
						lpRect:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdc
GetDC PROTO,			hWnd:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmessage
GetMessageA PROTO,		lpMsg:DWORD,\
						hWnd:DWORD,\
						wMsgFilterMin:DWORD,\
						wMsgFilterMax:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandlea
GetModuleHandleA PROTO,	lpModuleName:DWORD

; TODO: remove
; Source: https://learn.microsoft.com/en-us/windows/win32/api/heapapi/nf-heapapi-getprocessheap
GetProcessHeap PROTO

; TODO: remove
; Source: https://learn.microsoft.com/en-us/windows/win32/api/heapapi/nf-heapapi-heapalloc
HeapAlloc PROTO,		hHeap:DWORD,\
						dwFlags:DWORD,\
						dwBytes:DWORD

; TODO: remove if unnecessary
; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-invalidaterect
InvalidateRect PROTO,	hWnd:DWORD,\
						lpRect:DWORD,\
						bErase:BYTE			; BOOL

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadcursora
LoadCursorA PROTO,		hInstance:DWORD,\
						lpCursorName:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadimagea
LoadImageA PROTO,		hInstance:DWORD,\
						lpName:DWORD,\
						uType:DWORD,\
						cxDesired:DWORD,\
						cyDesired:DWORD,\
						uFlags:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-messageboxa					;
MessageBoxA PROTO,		hWnd:DWORD,\
						lpTEXT:DWORD,\
						lpCaption:DWORD,\
						uType:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-postmessagea
PostMessageA PROTO,		hWnd:DWORD,\
						msg:DWORD,\
						wParam:DWORD,\
						lParam:DWORD
; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-redrawwindow
RedrawWindow PROTO,		hWnd:DWORD,\
						lprcUpdate:DWORD,\
						hrgnUpdate:DWORD,\
						flags:DWORD	

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassa
RegisterClassExA PROTO,	wndClassPTR:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-selectobject
;		  https://learn.microsoft.com/en-us/previous-versions/windows/embedded/ee504566(v=winembedded.60)?redirectedfrom=MSDN
SelectObject PROTO,		hDC:DWORD,\
						hObject:DWORD
; Source: https://learn.microsoft.com/en-us/cpp/c-runtime-library/lock?view=msvc-170
SendMessageA PROTO,		hWnd:DWORD,\
						Msg:DWORD,\
						wParam:DWORD,\
						lParam:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
ShowWindow PROTO,		hWnd:DWORD,\
						nCmdShow:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-sleep
Sleep PROTO,			dwMilliseconds:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-transparentblt
TransparentBlt PROTO,	hdcDest:DWORD,\
						xoriginDest:DWORD,\
						yoriginDest:DWORD,\
						wDest:DWORD,\
						hDest:DWORD,\
						hdcSrc:DWORD,\
						xoriginSrc:DWORD,\
						yoriginSrc:DWORD,\
						wSrc:DWORD,\
						hSrc:DWORD,\
						crTransparent:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-updatewindow
UpdateWindow PROTO,		hWnd:DWORD