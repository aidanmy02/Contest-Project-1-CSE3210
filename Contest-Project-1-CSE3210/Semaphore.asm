.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

PUBLIC InitSem
PUBLIC SignalSem
PUBLIC WaitSem

.data?
paintSem SBYTE ?

.code
InitSem PROC
	PUSH ebp
	MOV ebp, esp
	MOV eax, [ebp + 8]
	MOV paintSem, al
	POP ebp
	RET 4
InitSem ENDP

SignalSem PROC

	RET
SignalSem ENDP

WaitSem PROC

	RET
WaitSem ENDP

END