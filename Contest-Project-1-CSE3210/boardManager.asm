INCLUDE Chess.inc

BOARDSTRUCT STRUCT
	_a BYTE WROOK, WKNIGHT, WBISHOP, WQUEEN, WKING, WBISHOP, WKNIGHT, WROOK
	_b BYTE 8 DUP(WPAWN)
	_c BYTE 8 DUP(0)
	_d BYTE 8 DUP(0)
	_e BYTE 8 DUP(0)
	_f BYTE 8 DUP(0)
	_g BYTE 8 DUP(BPAWN)
	_h BYTE BROOK, BKNIGHT, BBISHOP, BQUEEN, BKING, BBISHOP, BKNIGHT, BROOK
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
		CALL InitBoard
		INVOKE ExitThread,	NULL
	bpDone:
	RET
BoardProc ENDP

InitBoard PROC
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
InitBoard ENDP

GetSqrColor PROC
	PUSH ebp
	MOV ebp, esp

	XOR eax, eax

	MOV eax, [ebp + 8]
	ADD eax, [ebp + 12]
	MOV ebx, 2
	DIV ebx

	CMP edx, 0
	JZ whiteSqr

	MOV eax, 1
	JMP gotColor

	whiteSqr:
	XOR eax, eax

	gotColor:
	POP ebp
	RET 8
GetSqrColor ENDP
END