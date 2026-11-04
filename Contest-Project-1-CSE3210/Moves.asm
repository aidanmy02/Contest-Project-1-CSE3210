INCLUDE Chess.inc

GetSqrContent PROTO

PUBLIC MoveProc
PUBLIC prevMove

EXTERN board:BOARDSTRUCT
EXTERNDEF curHL:MOVESTRUCT
EXTERNDEF prevHL:MOVESTRUCT

.data
prevMove MOVESTRUCT <>
isFwd2 BYTE FALSE

.code
MoveProc PROC
	PUSH esi		; Save ebx, ecx, edx, esi since they will be used in processing moves
	PUSH edx		;
	PUSH ecx		;
	PUSH ebx		; 

	MOVZX ebx, prevHL.coord.y		; store prevHL.coord as a word in bx
	SHL ebx, 8						; shift into bh
	MOVZX eax, prevHL.coord.x		;
	MOV bl, al						;
	MOVZX edx, curHL.coord.y		; store curHL.coord as a word in dx
	SHL edx, 8						; shift into dh
	MOV ax, curHL.coord.x			;
	MOV dl, al						;

	MOVZX ecx, prevHL.piece			; store prev piece in ch and cur piece in cl
	SHL ecx, 8						;
	MOV al, curHL.piece				;
	MOV cl, al						;

	MOV al, prevHL.piece
	OR al, 20h		; Make lower case
	CMP al, 'p'
	JZ pawnCheck
	CMP al, 'r'
	JZ rookCheck
	CMP al, 'n'
	JZ knightCheck
	CMP al, 'b'
	JZ bishopCheck
	CMP al, 'q'
	JZ queenCheck
	CMP al, 'k'
	JZ kingCheck

	kingCheck:
	CALL kMove
	JMP mvCheck

	queenCheck:
	CALL qMove
	JMP mvCheck

	bishopCheck:
	CALL bMove
	JMP mvCheck

	knightCheck:
	CALL nMove
	JMP mvCheck

	rookCheck:
	CALL rMove
	JMP mvCheck

	pawnCheck:
	CALL pMove
	JMP mvCheck

	mvCheck:
	CMP al, TRUE
	JNZ mvDone
	MOV esi, OFFSET curHL			; Save new position in prevMove
	MOV edi, OFFSET prevMove		;
	MOV ecx, SIZEOF MOVESTRUCT		;
	REP MOVSB						;
	MOV bl, prevHL.piece
	MOV prevMove.piece, bl			; Save moved piece in prevMove
	
	mvDone:
	POP ebx			; Restore registers
	POP ecx			;
	POP edx			;
	POP esi			;
	RET
MoveProc ENDP

; Pawn move
pMove PROC
	; Get diff in coords
	CMP ch, WPAWN	; Check piece is white
	JZ getPDiff

	; Black pawn
	PUSH edx		; Swap source and destination to get positive vertical movement
	PUSH ebx
	POP edx
	POP ebx

	getPDiff:
		MOVZX eax, dx	; Diff between source and destination
		SUB al, bl
		SUB ah, bh

	; Case: move 1 forward
	fwd1:
		CMP ah, 1		; Check fwd1
		JNZ fwd2
		CMP al, 0		; Check if stays in column
		JNZ capt
		CMP cl, NULL	; Check dest is empty
		JNZ invalidP
		JMP validP

	; Case: move 2 forward
	fwd2:
		CMP ah, 2		; Check fwd2 for white
		JNZ invalidP

		CMP bh, 2			; Check row validity
		JZ validateWhite	;
		CMP bh, 7			;
		JNZ validateBlack	;
		JMP invalidP		;

		fwd2Cont:
		CMP cl, NULL		; Check dest is empty
		JNZ invalidP
		PUSH eax
		MOV eax, 0FF00h		; Set eax up for GetSqrContent
		AND ax, bx
		SHL eax, 8
		MOV al, bl
		ADD eax, 10000h		; Add 1 to y coord
		CALL GetSqrContent	; Check if sqr between prev and cur is empty
		MOVZX esi, al
		POP eax
		CMP esi, NULL		; Check if empty
		JNZ invalidP
		MOV isFwd2, TRUE	; Fwd2 move was made
		JMP validFwd2

	validateWhite:
		CMP ch, WPAWN
		JNZ invalidP
		JMP fwd2Cont

	validateBlack:
		CMP ch, BPAWN
		JNZ invalidP
		JMP fwd2Cont

	capt:
		CMP al, 1			; Pawn takes right
		JG invalidP
		CMP al, -1			; Pawn takes left
		JL invalidP
		CMP cl, NULL		; Check en passant
		JZ enPassant
		JMP validP

	enPassant:
		MOV al, prevMove.piece
		OR al, 20h				; Make lower case
		CMP al, 'p'				; Check if previous move was a pawn move
		JNZ invalidP
		CMP isFwd2, TRUE		; Check if previous move was Fwd 2
		JNZ invalidP
		MOVZX eax, prevMove.coord.y
		CMP ax, prevHL.coord.y	; Check if prevHL y coord is same as prevMove coord
		JNZ invalidP
		MOV ax, prevMove.coord.x
		CMP ax, curHL.coord.x	; Check if prevMove and curHL are in the same column
		JNZ invalidP
		
		MOV prevMove.piece, NULL
		MOV prevMove.uMsg, BP_ENPASSANT
		MOV eax, OFFSET prevMove
		PUSH eax
		CALL BoardProc
		JMP validP

	validP:
		MOV isFwd2, FALSE
	validFwd2:
		MOV eax, TRUE
		JMP pMvFound

	invalidP:
	MOV eax, FALSE

	pMvFound:
	AND isFwd2, al
	RET
pMove ENDP

; Rook move
rMove PROC
	MOVZX eax, dx
	SUB al, bl
	SUB ah, bh

	CMP al, NULL			; Check if move is vertical
	JZ setVerticalR
	CMP ah, NULL			; Check if move is horizontal
	JNZ invalidR

	MOV ebx, 1				; Change in x coord = 1
	CMP al, NULL			; If diff in x is positive, set positive loop
	JNL initLoopR

	NEG ebx					; Negtive, set x coord to decrement
	JMP initLoopRNeg

	; Vertical check that all squares between source and dest are empty
	setVerticalR:
		MOV ebx, 10000h		; set y coord change
		SHR ax, 8			; Shift a byte for when loop counter is declared in initLoopR
		CMP al, NULL		; If positive diff, rook moves up
		JNL initLoopR		;

		NEG ebx				; Negtive, set y coord to decrement
		JMP initLoopRNeg

	initLoopRNeg:
		NEG al
	initLoopR:
		MOV edx, prevHL.coord	; Start at next sqr after prevHL
		MOVZX ecx, al			; Use diff to loop check sqrs between source and dest

		startLoopR:
			LOOP checkLoopR
			JMP validR
		checkLoopR:
			ADD edx, ebx		; Add increment to changing coord
			MOV eax, edx
			CALL GetSqrContent
			CMP al, NULL		; Check if square is empty
			JNZ invalidR
			JMP startLoopR

	validR:
	MOV eax, TRUE
	JMP rMvFound

	invalidR:
	MOV eax, FALSE

	rMvFound:
	RET
rMove ENDP

; Knight move
nMove PROC
	; Get diff between source and dest
	MOVZX eax, dx
	SUB al, bl
	SUB ah, bh

	CMP al, NULL			; Get abs value of coords
	JNL gotAbsXN			;
	NEG al					;
							;
	gotAbsXN:				;
		CMP ah, NULL		;
		JNL gotAbsYN		;
		NEG ah				;

	gotAbsYN:
		CMP al, 1			; If x diff = 1, check y diff = 2
		JZ checkYN
		CMP ah, 1			; If x diff and y diff not 1, invalid
		JNZ invalidN
		CMP al, 2
		JNZ invalidN		; If x diff != 2 and y diff = 1, invalid
		JMP validN

		checkYN:
			CMP ah, 2		; If x diff = 1 and y diff != 2, invalid
			JNZ invalidN
		
	validN:
	MOV eax, TRUE
	JMP nMvFound

	invalidN:
	MOV eax, FALSE

	nMvFound:
	RET
nMove ENDP

; Bishop move
bMove PROC
	; Get diff between source and dest
	MOVZX eax, dx
	SUB al, bl
	SUB ah, bh

	MOV ebx, 10001h				; Set up ebx for add change to coords in loop
	CMP al, ah					; If x diff != y diff, check for decreasing slope
	JNZ decSlopeMoveB
	CMP al, NULL				; Check if change is positive
	JG initLoopB
	MOV ebx, 0FFFFFFFFh
	NEG al						; Prep al for loop counter
	JMP initLoopB

	decSlopeMoveB:
		NEG al
		CMP al, ah				; Check if neg diff x = diff y
		JNZ invalidB
		MOV bx, 0FFFFh			; Make slope of ebx -1
		CMP ah, NULL			; Check if y change is positive
		JG initLoopB
		MOV ebx, 0FFFF0001h
		NEG al					; Prep al for loop counter

	initLoopB:
		MOV edx, prevHL.coord	; Start at next sqr after prevHL
		MOVZX ecx, al			; Use diff to loop check sqrs between source and dest
	startLoopB:
			LOOP checkLoopB
			JMP validB
		checkLoopB:
			MOV eax, edx
			ADD ax, bx
			JNC noCarryB		; If carry from low word to high word, decrement high word
			SUB edx, 10000h		;
			noCarryB:
			ADD edx, ebx		; Add increment to changing coord
			MOV eax, edx
			CALL GetSqrContent
			CMP al, NULL		; Check if square is empty
			JNZ invalidB
			JMP startLoopB

	validB:
		MOV eax, TRUE
		JMP bMvFound

	invalidB:
		MOV eax, FALSE

	bMvFound:
	RET
bMove ENDP

; Queen move
qMove PROC
	PUSH edx		; Save for rMove call
	PUSH ebx

	CALL bMove		; Check diagonal moves
	POP ebx
	POP edx
	CMP eax, TRUE	; Return true if valid
	JZ qMvFound		;

	CALL rMove		; Check horizontal/vertical moves
					; return value of rMove

	qMvFound:
	RET
qMove ENDP

; King move
kMove PROC

	RET
kMove ENDP

END