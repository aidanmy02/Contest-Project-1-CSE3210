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

	; Get sem code and put sem address in esi
	MOV eax, [ebp + 8]
	CALL GetSem
	MOV esi, eax

	; Initilize sem with value and set the init boolean to true
	MOV eax, [ebp + 12]
	MOV [esi], al
	INC DWORD PTR [esi + 1]

	POP ebp
	RET 8
InitSem ENDP

SignalSem PROC
	PUSH ebp
	MOV ebp, esp

	; Get sem code and put sem address in esi
	MOV eax, [ebp + 8]
	CALL GetSem
	MOV esi, eax

	MOV al, [esi + 1]
	CMP al, 0
	JZ signalErr
	
	INC DWORD PTR [esi]

	signalErr:
	POP ebp
	RET 4
SignalSem ENDP

WaitSem PROC
	PUSH ebp
	MOV ebp, esp

	; Get sem code and put sem address in esi
	MOV eax, [ebp + 8]
	CALL GetSem
	MOV esi, eax

	MOV al, [esi + 1]
	CMP al, 0
	JZ waitErr

	DEC paintSem

	waitLoop:
	CMP DWORD PTR [esi], 0
	JNL cont
	INVOKE Sleep,	1		; dwMilliseconds
	JMP waitLoop


	waitErr:
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