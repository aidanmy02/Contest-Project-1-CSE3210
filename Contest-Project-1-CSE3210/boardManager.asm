INCLUDE Chess.inc

BOARDSTRUCT STRUCT
	_a BYTE 8 DUP(0)
	_b BYTE 8 DUP(0)
	_c BYTE 8 DUP(0)
	_d BYTE 8 DUP(0)
	_e BYTE 8 DUP(0)
	_f BYTE 8 DUP(0)
	_g BYTE 8 DUP(0)
	_h BYTE 8 DUP(0)
BOARDSTRUCT ENDS

.data
; Initialize board
board BOARDSTRUCT <>

; For message passing
move MOVESTRUCT <>

.code
BoardProc PROC, movePtr:DWORD
	JZ bpInit

	bpInit:
	CALL initBoard
	bpDone:
	RET
BoardProc ENDP

initBoard PROC
	RET
initBoard ENDP

END