.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

INCLUDELIB Kernel32.lib

; Source: https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-sleep
Sleep PROTO,			dwMilliseconds:DWORD

PUBLIC InitSem
PUBLIC SignalSem
PUBLIC WaitSem

.data?
paintMutex SBYTE ?

.data
paintInit BYTE 0		; BOOL for initialization check

.code
InitSem PROC
	PUSH ebp
	MOV ebp, esp
	MOV eax, [ebp + 8]
	MOV paintMutex, al
	MOV paintInit, 1
	POP ebp
	RET 4
InitSem ENDP

SignalSem PROC
	MOV al, paintInit
	CMP al, 0
	JZ signalErr
	
	INC paintMutex

	signalErr:
	RET
SignalSem ENDP

WaitSem PROC
	MOV al, paintInit
	CMP al, 0
	JZ waitErr

	waitLoop:
	CMP paintMutex, 0
	JNL cont
	INVOKE Sleep,	1		; dwMilliseconds
	JMP waitLoop

	cont:
	DEC paintMutex

	waitErr:
	RET
WaitSem ENDP

END