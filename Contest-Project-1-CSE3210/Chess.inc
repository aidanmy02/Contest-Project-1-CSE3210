; Configuration Settings
.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

; Subroutine Prototypes
main PROTO
init PROTO
createWnd PROTO

; System Call Prototypes
ExitProcess PROTO,		dwExitCode:DWORD
CreateWindowExA PROTO,	dwExStyle:DWORD, lpClassName:DWORD, lpWindowName:DWORD, dwStyle:DWORD, x:DWORD, y:DWORD, \
						nWidth:DWORD, nHeight:DWORD, hWndParent:DWORD, hMenu:DWORD, hInstance:DWORD, lpParam:DWORD