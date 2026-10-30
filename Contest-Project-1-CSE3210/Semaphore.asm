.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

.code
InitSem PROC PUBLIC
	
	RET
InitSem ENDP

WaitSem PROC PUBLIC

	RET
WaitSem ENDP

SignalSem PROC PUBLIC

	RET
SignalSem ENDP

END