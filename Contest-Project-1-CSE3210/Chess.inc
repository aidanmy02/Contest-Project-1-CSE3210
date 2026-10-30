; Assembler Directives
.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

; Windows SDK Libraries
INCLUDELIB User32.lib	; Sources:	Textbook and https://learn.microsoft.com/en-us/cpp/assembler/masm/includelib-masm?view=msvc-170
						;			https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassa
INCLUDELIB Gdi32.lib	; Source:	https://learn.microsoft.com/en-us/windows/win32/gdi/windows-gdi

;Global Constants
NULL EQU 0
FALSE EQU 0
TRUE EQU 1

; CODES
; WndProc Codes
; Source: https://www.autoitscript.com/autoit3/docs/appendix/WinMsgCodes.htm
WM_CREATE EQU 1
WM_DESTROY EQU 2
WM_PAINT EQU 0Fh

; BoardProc Codes
BP_INIT EQU 0

; HeapAlloc Codes
HEAP_ZERO_MEMORY EQU 8

; ShowWindow Codes
SW_NORMAL EQU 1
SW_SHOWDEFAULT EQU 10

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
	x BYTE ?
	y BYTE ?
COORDSTRUCT ENDS

; Move
MOVESTRUCT STRUCT
	uMsg DWORD ?
	coord COORDSTRUCT <>
	piece DWORD ?
MOVESTRUCT ENDS

EXTERNDEF move:MOVESTRUCT
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

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadcursora
LoadCursorA PROTO,		hInstance:DWORD,\
						lpCursorName:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-messageboxa					;
MessageBoxA PROTO,		hWnd:DWORD,\
						lpTEXT:DWORD,\
						lpCaption:DWORD,\
						uType:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassa
RegisterClassExA PROTO,	wndClassPTR:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
ShowWindow PROTO,		hWnd:DWORD,\
						nCmdShow:DWORD

UpdateWindow PROTO,	hWnd:DWORD