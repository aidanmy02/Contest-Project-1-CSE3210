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

; WndProc Codes
WP_CREATE EQU 0
WP_DESTROY EQU 1

; Subroutine Prototypes
main PROTO
init PROTO
WndProc PROTO			hWnd:DWORD,\
						uMsg:DWORD,\
						wParam:DWORD,\
						lParam:DWORD

; System Call Prototypes and Sources for Information
; TODO: For debugging; remove later
GetClassNameA PROTO,	hWnd:DWORD,\
						lpClassName:DWORD,\
						nMaxCount:DWORD

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

ExitProcess PROTO,		dwExitCode:DWORD

GetClientRect PROTO,	hWnd:DWORD,\
						lpRect:DWORD

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

WinMain PROTO,			hInstance:DWORD,\
						hPrevInstance:DWORD,\
						lpCmdLine:DWORD,\
						nShowCmd:DWORD