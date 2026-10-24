; Configuration Settings
.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

; Windows SDK Libraries
INCLUDELIB User32.lib	; Sources:	Textbook and https://learn.microsoft.com/en-us/cpp/assembler/masm/includelib-masm?view=msvc-170
						;			https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerclassa


; Subroutine Prototypes
main PROTO
init PROTO
createWnd PROTO

; System Call Prototypes and Sources for Information
ExitProcess PROTO,		dwExitCode:DWORD

; Soruce: https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
CreateWindowExA PROTO,	dwExStyle:DWORD, lpClassName:DWORD, lpWindowName:DWORD, dwStyle:DWORD, x:DWORD, y:DWORD, \
						nWidth:DWORD, nHeight:DWORD, hWndParent:DWORD, hMenu:DWORD, hInstance:DWORD, lpParam:DWORD

; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa
CallWindowProcA PROTO,	lpPrevWndFunc:DWORD, hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD