.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE
main PROTO
init PROTO
ExitProcess PROTO,		dwExitCode:DWORD
CreateWindowExA PROTO,	dwExStyle:DWORD, lpClassName:DWORD, lpWindowName:DWORD, dwStyle:DWORD, x:DWORD, y:DWORD, \
						nWidth:DWORD, nHeight:DWORD, hWndParent:DWORD, hMenu:DWORD, hInstance:DWORD, lpParam:DWORD