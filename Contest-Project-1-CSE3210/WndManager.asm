INCLUDE Chess.inc

.data
exStyle DWORD 0								; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
className BYTE "STATIC",0
windowName BYTE "Testing Testing 123",0
style DWORD 10000000h						; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles
CW_USEDEFAULT EQU 80000000h					; Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createmdiwindowa

.code
createWnd PROC
PUSH ebp
MOV ebp, esp

; Soruce: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexa
INVOKE CreateWindowExA, exStyle, ADDR className, ADDR windowName, style, CW_USEDEFAULT, CW_USEDEFAULT, 400, 400, 0, 0, 0, 0

POP ebp
RET
createWnd ENDP
END