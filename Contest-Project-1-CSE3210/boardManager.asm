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
	CMP eax, BP_CONT
	JZ bpCont
	CMP eax, BP_COLOR
	JZ bpColor
	CMP eax, BP_MOVE
	JZ bpMove
	CMP eax, BP_INIT
	JZ bpInit

	bpInit:
		CALL InitBoard
		INVOKE ExitThread,	NULL

	bpCont:
		MOV eax, (MOVESTRUCT PTR [esi]).coord
		CALL getSqrContent
		MOV (MOVESTRUCT PTR [esi]).piece, al
		JMP bpDone

	bpColor:
		MOV eax, (MOVESTRUCT PTR [esi]).coord
		CALL getSqrColor
		MOV (MOVESTRUCT PTR [esi]).sqrColor, al
		JMP bpDone

	bpMove:
		CALL isValidMove

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

			; Set piece
			MOV eax, (MOVESTRUCT PTR [esi]).coord
			CALL GetSqrContent
			MOV (MOVESTRUCT PTR [esi]).piece, al


			; Get square Color
			MOV eax, (MOVESTRUCT PTR [esi]).coord
			CALL GetSqrColor
			MOV (MOVESTRUCT PTR [esi]).sqrColor, al
			
			; Save counters
			PUSH ebx
			PUSH ecx
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

;
isValidMove PROC
;	@ Return:	al - True if valid, else false
	; Check if prev selection was white
	MOVZX eax, prevHL.piece
	CMP al, 'Z'
	JNA prevWhite
	
	; Else black
	JMP prevBlack

	prevWhite:
	; Check if cur selection is black or empty
	MOV al, curHL.piece
	CMP al, 'a'
	JNB validCont
	JMP invalidMove

	prevBlack:
	; Check if cur selection is white or empty
	MOV al, curHL.piece
	CMP al, 'Z'
	JNA validCont
	JMP invalidMove


	; Cur selection has valid contents for move
	validCont:

	; Valid Move
	validMove:
	MOV al, TRUE
	JMP validatedMove

	invalidMove:
	MOV al, FALSE

	validatedMove:
	RET
isValidMove ENDP
;
GetSqrColor PROC
;	@ Params:	ax - x coord
;				eax upper half - y coord
;	@ Return:	al - color code
	; Save registers
	PUSH ebx
	PUSH ecx

	MOVZX ebx, ax
	SHR eax, 16
	ADD eax, ebx

	; If even, then white
	TEST eax, 1
	JZ whiteSqr

	; Else, black
	MOV eax, BLACK
	JMP gotColor

	whiteSqr:
	MOV eax, WHITE

	gotColor:
	; Restor registers
	POP ecx
	POP ebx
	RET
GetSqrColor ENDP

;
GetSqrContent PROC
;	@ Params:	ax - x coord
;				eax upper half - y coord
;
;	@ Return:	al - piece
	; Save registers
	PUSH ebx
	PUSH ecx
	PUSH edx

	; Get coords out of eax
	MOVZX ebx, ax
	SHR eax, 16
	MOV ecx, eax

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

	; Restore registers
	POP edx
	POP ecx
	POP ebx
	RET
GetSqrContent ENDP
END