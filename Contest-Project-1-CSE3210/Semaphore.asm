.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

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
	POP ebp
	RET 4
InitSem ENDP

SignalSem PROC
	MOV paintInit, al
	CMP eax, 0
	JMP signalErr
	
	INC paintMutex

	signalErr:
	RET
SignalSem ENDP

WaitSem PROC
	MOV paintInit, al
	CMP eax, 0
	JMP waitErr

	DEC paintMutex

	waitErr:
	RET
WaitSem ENDP

END