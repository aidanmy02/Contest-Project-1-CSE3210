; Assembler Directives
.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

; Windows SDK Libraries
INCLUDELIB User32.lib	; Sources:	Textbook and https://learn.microsoft.com/en-us/cpp/assembler/masm/includelib-masm?view=msvc-170
						;			https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassa

;Global Constants
NULL EQU 0
FALSE EQU 0
TRUE EQU 1

; WndProc Codes
WM_CREATE EQU 1
WM_DESTROY EQU 2

; ShowWindow Codes
SW_NORMAL EQU 1
SW_SHOWDEFAULT EQU 10

; BoardProc Codes
BP_INIT EQU 0

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
COORD STRUCT
	x BYTE ?
	y BYTE ?
COORD ENDS

; Subroutine Prototypes
BoardProc PROTO			bpUMsg:DWORD,\
						col:DWORD,\
						row:DWORD,\
						peice:DWORD

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
DispatchMessage PROTO,	lpMsg:DWORD

ExitProcess PROTO,		dwExitCode:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect
GetClientRect PROTO,	hWnd:DWORD,\
						lpRect:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdc
GetDC PROTO,			hWnd:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getmessage
GetMessage PROTO,		lpMsg:DWORD,\
						hWnd:DWORD,\
						uMsgFilterMin:DWORD,\
						wMsgFilterMax:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandlea
GetModuleHandleA PROTO,	lpModuleName:DWORD

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