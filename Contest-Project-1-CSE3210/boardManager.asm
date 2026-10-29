INCLUDE Chess.inc

; Structs
; Chess coordinate
CCOORD STRUCT
	col DWORD ?
	row DWORD ?
CCOORD ENDS

BOARD STRUCT
	_a BYTE 8 DUP(0)
	_b BYTE 8 DUP(0)
	_c BYTE 8 DUP(0)
	_d BYTE 8 DUP(0)
	_e BYTE 8 DUP(0)
	_f BYTE 8 DUP(0)
	_g BYTE 8 DUP(0)
	_h BYTE 8 DUP(0)
BOARD ENDS

.code
BoardProc PROC, bpUMsg:DWORD, col:DWORD, row:DWORD
	MOV eax, bpUMsg
	CMP bpUMsg, BP_INIT
	JZ bpInit

	bpInit:
	CALL initBoard
	JMP bpDone

	bpDone:
	RET
BoardProc ENDP

initBoard PROC
	

	RET
initBoard ENDP

END