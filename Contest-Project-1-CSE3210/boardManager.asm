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
move MOVESTRUCT 64 DUP(<>)

numCols EQU 8
numRows EQU 8

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
	; Loop over all columns
	MOV ecx, numCols
	INC ecx
	MOV esi, OFFSET move	; Use esi to keep track of the current field of each MOVESTRUCT

	startCol:
	LOOP loopCol
	JMP endLoop
	loopCol:
		; Copy ecx into edx to use for move.coord.x and save before inner loop
		MOV ebx, ecx

		; Inner loop count
		MOV ecx, numRows
		INC ecx

		startRow:
		LOOP loopRow
		JMP endRow
		loopRow:
			; Set uMsg
			MOV (MOVESTRUCT PTR [esi]).uMsg, WM_SQR
			; Set x coordinate of board
			MOV (MOVESTRUCT PTR [esi]).coord.x, bx		; ebx contains col
			; Set y coordinate of board
			MOV (MOVESTRUCT PTR [esi]).coord.y, cx		; ecx contains row

			; Save values of ecx and edx
			PUSH ebx
			PUSH ecx

			; Set piece
			CALL GetSqrContent
			MOV (MOVESTRUCT PTR [esi]).piece, al

			; Get square Color
			CALL GetSqrColor
			MOV (MOVESTRUCT PTR [esi]).sqrColor, al
			
			; Save current address
			PUSH esi

			; Send WM_PAINT message to GetMessage
			INVOKE PostMessageA,	hWndMain,\			; hWnd
									WM_SQR,\			; uMsg
									esi,\				; wParam
									NULL				; lParam
			
			POP esi
			POP ecx
			POP ebx
			ADD esi, SIZEOF MOVESTRUCT		; Move to next MOVESTRUCT
		JMP startRow
		endRow:
		; Return outer loop counter to ecx
		MOV ecx, ebx
	JMP startCol

	endLoop:
	RET
InitBoard ENDP

GetSqrColor PROC
	; ebx contains columns and ecx contains rows
	MOV eax, ebx
	ADD eax, ecx
	
	; If even, then white
	TEST eax, 1
	JZ whiteSqr

	; Else, black
	MOV eax, 1
	JMP gotColor

	whiteSqr:
	XOR eax, eax

	gotColor:
	RET
GetSqrColor ENDP

;
GetSqrContent PROC
;	@ Params:	ecx - column coord
;				ebx - row coord
;
;	@ Return:	eax - piece

	; Get column offset
	MOV eax, numCols
	DEC eax			; 0-based index
	XOR edx, edx
	MUL ebx
	; Add row offset
	ADD eax, ecx
	DEC eax			; 0-based index

	; Get piece
	ADD eax, OFFSET board
	MOV al, [eax]
	RET
GetSqrContent ENDP
END