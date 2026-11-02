INCLUDE Chess.inc

BOARDSTRUCT STRUCT
	_a BYTE WROOK,	WPAWN,	0,	0,	0,	0,	BPAWN,	BROOK
	_b BYTE WKNIGHT,WPAWN,	0,	0,	0,	0,	BPAWN,	BKNIGHT
	_c BYTE WBISHOP,WPAWN,	0,	0,	0,	0,	BPAWN,	BBISHOP
	_d BYTE WQUEEN,	WPAWN,	0,	0,	0,	0,	BPAWN,	BQUEEN
	_e BYTE WKING,	WPAWN,	0,	0,	0,	0,	BPAWN,	BKING
	_f BYTE WBISHOP,WPAWN,	0,	0,	0,	0,	BPAWN,	BBISHOP
	_g BYTE WKNIGHT,WPAWN,	0,	0,	0,	0,	BPAWN,	BKNIGHT
	_h BYTE WROOK,	WPAWN,	0,	0,	0,	0,	BPAWN,	BROOK
BOARDSTRUCT ENDS

.data
; Initialize board
board BOARDSTRUCT <>

; For initialization
move MOVESTRUCT 64 DUP(<>)

numCols EQU 8
numRows EQU 8

.code
BoardProc PROC
	PUSH ebp
	MOV ebp, esp
	MOV esi, [ebp + 8]		; MOVESTRUCT
	MOV eax, (MOVESTRUCT PTR [esi]).uMsg
	CMP eax, BP_INIT
	JZ bpInit
	CMP eax, BP_HL
	JZ bpHL

	bpInit:
		CALL InitBoard
		INVOKE ExitThread,	NULL

	bpHL:
		MOV eax, (MOVESTRUCT PTR [esi]).coord
		MOVZX ebx, ax
		SHR eax, 16
		MOV ecx, eax
		CALL getSqrContent
		MOV (MOVESTRUCT PTR [esi]).piece, al
		JMP bpDone

	bpDone:
	POP ebp
	RET 4
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
	MOV eax, BLACK
	JMP gotColor

	whiteSqr:
	MOV eax, WHITE

	gotColor:
	RET
GetSqrColor ENDP

;
GetSqrContent PROC
;	@ Params:	ecx - row coord
;				ebx - column coord
;
;	@ Return:	eax - piece

	; Get column offset
	MOV eax, numCols
	DEC ebx			; 0-based index
	XOR edx, edx
	MUL ebx
	INC ebx			; restore ebx to 1-based index
	; Add row offset
	ADD eax, ecx
	DEC eax			; 0-based index

	; Get piece
	ADD eax, OFFSET board
	MOV al, [eax]
	RET
GetSqrContent ENDP
END