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
PUBLIC SEM_PAINT
PUBLIC SEM_MOVE

SEM_PAINT EQU 0
SEM_MOVE EQU 1

Semaphore STRUCT
	sem SBYTE ?
	bInit BYTE ?		; BOOL for initialization check
Semaphore ENDS

.data
paintSem Semaphore <>
moveSem Semaphore <>

.code
InitSem PROC
	PUSH ebp
	MOV ebp, esp
	MOV eax, [ebp + 8]
	MOV paintSem.sem, al
	MOV paintSem.bInit, 1
	POP ebp
	RET 4
InitSem ENDP

SignalSem PROC
	MOV al, paintSem.bInit
	CMP al, 0
	JZ signalErr
	
	INC paintSem

	signalErr:
	RET
SignalSem ENDP

WaitSem PROC
	MOV al, paintSem.bInit
	CMP al, 0
	JZ cont

	DEC paintSem

	waitLoop:
	CMP paintSem.sem, 0
	JNL cont
	INVOKE Sleep,	1		; dwMilliseconds
	JMP waitLoop

	cont:
	RET
WaitSem ENDP

GetSem PROC
	CMP eax, SEM_PAINT
	JZ getPaint
	
	MOV eax, OFFSET moveSem
	
	getPaint:

	MOV eax, OFFSET paintSem

	gotSem:
	RET
GetSem ENDP


END