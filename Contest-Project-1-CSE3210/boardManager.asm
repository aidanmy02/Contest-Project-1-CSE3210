INCLUDE Chess.inc

; Structs
; Chess coordinate
CCOORD STRUCT
	col DWORD ?
	row DWORD ?
CCOORD ENDS

.code
BoardProc PROC, bpUMsg:DWORD, col:DWORD, row:DWORD
	MOV eax, bpUMsg
	CMP bpUMsg, BP_INIT
	JZ bpInit

	bpInit:
	JMP bpDone

	bpDone:
	RET
BoardProc ENDP

initBoard PROC

	RET
initBoard ENDP

END