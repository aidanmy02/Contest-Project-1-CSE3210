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
BoardProc PROC
	MOV eax, move.uMsg
	CMP eax, BP_INIT
	JZ bpInit
	
	bpInit:
		CALL initBoard
		INVOKE ExitThread,	NULL
	bpDone:
	RET
BoardProc ENDP

initBoard PROC
	XOR ecx, ecx
	XOR edx, edx
	MOV eax, SIZEOF board
	MOV ebx, SIZEOF board._a
	DIV ebx
	MOV ecx, eax
	loopCol:
		CALL waitSem
		MOV move.uMsg, WM_PAINT
		MOV move.coord.x, cx
		MOV eax, ecx
		MOV ebx, SIZEOF board
		MUL ebx
		MOV esi, eax
		ADD esi, OFFSET move
		PUSH ecx
		MOV ecx, LENGTHOF board._a
		loopRow:
			MOV move.coord.y, cx
			MOV edi, ecx
			MOV eax, [esi + edi]
			MOV move.piece, al
			; call for paint
			CALL signalSem
		loop loopRow
		POP ecx
	loop loopCol
	CALL signalSem
	RET
initBoard ENDP

END