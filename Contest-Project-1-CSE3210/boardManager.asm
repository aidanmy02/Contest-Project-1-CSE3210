INCLUDE Chess.inc
INCLUDE Board.inc

PUBLIC board
PUBLIC curHL
PUBLIC prevHL
PUBLIC GetSqrContent

.data
; Initialize board
board BOARDSTRUCT <>

; For initialization
move MOVESTRUCT 64 DUP(<>)
curHL MOVESTRUCT <>
prevHL MOVESTRUCT <,<NULL,NULL>,,>

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
		CMP al, FALSE		; Exit if not valid move
		JZ bpDone

		; Move prevHL.piece into curHL.piece
		MOVZX eax, prevHL.piece
		MOV curHL.piece, al

		; Change dest board content
		PUSH eax
		MOV eax, curHL.coord
		CALL SetSqrContent

		; Change source board content
		XOR eax, eax
		PUSH eax
		MOV eax, prevHL.coord
		CALL SetSqrContent

		; Update window
		MOV prevHL.piece, NULL
		INVOKE SendMessageA,	hWndMain,\			; hWnd
								WM_SQR,\			; uMsg
								ADDR prevHL,\		; wParam
								NULL				; lParam
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
	
	prevBlack:
	; Check if cur selection is white or empty
	MOV al, curHL.piece
	CMP al, 'Z'
	JNA validateMove
	JMP invalidMove

	prevWhite:
	; Check if cur selection is black or empty
	MOV al, curHL.piece
	CMP al, 'a'
	JNB invalidMove
	JMP validateMove

	invalidMove:
	MOV al, FALSE
	JMP retMove

	; Cur selection has valid contents for move
	validateMove:
	CALL MoveProc
	retMove:
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

;
SetSqrContent PROC
;	@ Params:	ax - x coord
;				eax upper half - y coord
;				stack - piece
;
;	@ Return:	al - piece
	PUSH ebp
	MOV ebp, esp

	; Save registers
	PUSH esi
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

	; Set piece
	ADD eax, OFFSET board
	MOV esi, eax
	MOV al, [ebp + 8]
	MOV [esi], al

	; Restore registers
	POP edx
	POP ecx
	POP ebx
	POP esi
	POP ebp
	RET 4
SetSqrContent ENDP

END