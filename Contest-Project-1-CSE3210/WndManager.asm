INCLUDE Chess.inc

.data
exStyle DWORD 0
className BYTE "STATIC",0
windowName BYTE "Testing Testing 123",0
style DWORD 10000000h						; Source: https://learn.microsoft.com/en-us/windows/win32/winmsg/window-styles

.code
createWnd PROC
PUSH ebp
MOV ebp, esp

INVOKE CreateWindowExA, exStyle, ADDR className, ADDR windowName, style, 100, 100, 400, 400, 0, 0, 0, 0

POP ebp
RET
createWnd ENDP
END