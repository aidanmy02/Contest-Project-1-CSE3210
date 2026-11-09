INCLUDE Chess.inc

GetSqrContent PROTO

PUBLIC MoveProc
PUBLIC prevMove
PUBLIC checkMove

EXTERN board:BOARDSTRUCT
EXTERN isWhiteMove:BYTE
EXTERN isWhitePiece:PROTO
EXTERNDEF curHL:MOVESTRUCT
EXTERNDEF prevHL:MOVESTRUCT

.data
prevMove MOVESTRUCT <>
checkMove MOVESTRUCT <>
isFwd2 BYTE FALSE

castle BYTE 8 DUP(0)		; 4 Bools each king:	1. True if king has moved
							;						2. True if a file rook has moved
							;						3. True if h file rook has moved
							;						4. Used return side of castle:
							;							- False = queenside
							;							- True = kingside

wKingPos MOVESTRUCT <NULL,<5,1>,'K',BLACK>
bKingPos MOVESTRUCT <NULL,<5,8>,'k',WHITE>

getKing MACRO
	LOCAL whiteKing, done
	TEST isWhiteMove, TRUE
	JNZ whiteKing
	MOV ebx, OFFSET bKingPos
	PUSH ebx
	MOV eax, bKingPos.coord
	JMP done

	whiteKing:
	MOV ebx, OFFSET wKingPos
	PUSH ebx
	MOV eax, wKingPos.coord
	
	done:
	ENDM

check4Check MACRO
	getKing
	CALL checkCheck
	POP ebx					; Discard if not check
ENDM

check4Checkmate MACRO
	getKing
	CALL checkCheckmate
	POP ebx					; Discard if not check
ENDM

.code
MoveProc PROC
	PUSH esi		; Save ebx, ecx, edx, esi since they will be used in processing moves
	PUSH edx		;
	PUSH ecx		;
	PUSH ebx		; 

	CMP eax, MV_CHECK
	JZ checkCheckMv
	CMP eax, MV_TESTCHECK
	JZ testCheck
	CMP eax, MV_TESTMATE
	JZ testMate

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

	testCheck:
	check4Check						;
	JMP doneMvProc					; Return result of check inquiry to board proc

	testMate:
	check4Checkmate
	JMP doneMvProc

	mvCheck:
 	CMP al, FALSE					; Check if new position is valid
	JZ doneMvProc

	PUSH eax						; Change board to new position to check if still in check
	MOV prevHL.uMsg, BP_TESTCHECK	;
	MOV eax, OFFSET prevHL			;
	PUSH eax						;
	INVOKE BoardProc				;

									; eax contains truth value of check
	POP ecx							; ecx contains true move is valid for moving piece
	XOR eax, ecx					; True if valid move and not check, false if valid move and still check
	JZ doneMvProc

	MOV esi, OFFSET curHL			; Save new position in prevMove
	MOV edi, OFFSET prevMove		;
	MOV ecx, SIZEOF MOVESTRUCT		;
	REP MOVSB						;
	MOV bl, prevHL.piece
	MOV prevMove.piece, bl			; Save moved piece in prevMove
	JMP mvDone

	checkCheckMv:
	PUSH eax
	check4Check						; Check if the move puts the opponent in check
	MOV ecx, eax					; Put check status in ecx
	POP eax							; Put return value of move validity in eax
	TEST cl, TRUE
	JZ mvDone

	PUSH eax							; Copy checked kingPos into checkMove
	PUSH edi							;
	MOV edi, OFFSET checkMove			;
	MOV esi, ebx						;
	MOV ecx, SIZEOF MOVESTRUCT			;
	REP MOVSB							;
	POP edi
	MOV checkMove.uMsg, BP_TESTMATE		; Call BoardProc to remove king for testing and then add back
	MOV eax, OFFSET checkMove			;
	PUSH eax							;
	CALL BoardProc						;
	POP eax

	SUB esi, SIZEOF MOVESTRUCT
	MOV (MOVESTRUCT PTR [esi]).uMsg, MV_CHECKED

	MOV checkMove.uMsg, BP_CHECK
	MOV checkMove.sqrColor, CHECKHL
	MOV eax, OFFSET checkMove
	PUSH eax
	CALL BoardProc
	JMP doneMvProc

	mvDone:
	MOV esi, OFFSET wKingPos
	CMP wKingPos.uMsg, MV_CHECKED
	JZ whiteChecked
	CMP bKingPos.uMsg, MV_CHECKED
	JNZ doneMvProc
	MOV esi, OFFSET bKingPos
	
	whiteChecked:
	PUSH edi
	MOV edi, OFFSET checkMove
	MOV ecx, SIZEOF MOVESTRUCT
	REP MOVSB
	POP edi

	SUB esi, SIZEOF MOVESTRUCT
	MOV checkMove.uMsg, BP_COLOR
	MOV eax, OFFSET checkMove
	PUSH eax
	PUSH eax			; Push for second proc
	CALL BoardProc
	MOV al, checkMove.sqrColor
	MOV (MOVESTRUCT PTR [esi]).sqrColor, al
	MOV checkMove.uMsg, BP_CHECK
	CALL BoardProc

	doneMvProc:
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
		CMP al, 0		; Check if stays in column
		JNZ capt
		CMP ah, 1		; Check fwd1
		JNZ fwd2
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
	PUSH ebx
	MOV ebx, OFFSET castle + 1			; Get correct color rook flags for movement
	CMP prevHL.piece, 'R'				;
	JZ setRStat							;
	CMP prevHL.piece, 'r'				;
	JNZ castleStatusSet					; If it is castle method calling this, it does not mutate castle
	ADD ebx, 4							;
	setRStat:
	MOV ax, WORD PTR [ebx]
	XOR ax, 0101h						; Check if both flags have been set
	JZ castleStatusSet					;
	CALL setRookStatus					; Set move status if not both have moved
	castleStatusSet:
	POP ebx
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
	; Get diff between source and dest
	PUSH edx				; Save for castle call since it uses rMove
	PUSH ebx				;
	
	MOV eax, curHL.coord	; If castle, checkCastle sends message for erasing
	CALL checkCastle		;
	POP edx					;
	POP ebx					;
	PUSH esi				;
	TEST al, TRUE			;
	JNZ validK				;

	MOVZX eax, dx
	SUB al, bl
	SUB ah, bh

	CMP al, NULL			; Get abs value of coords
	JNL gotAbsXK			;
	NEG al					;
							;
	gotAbsXK:				;
		CMP ah, NULL		;
		JNL gotAbsYK		;
		NEG ah				;

	gotAbsYK:
	CMP al, 1				; Check x limitation
	JG invalidK
	CMP ah, 1				; Check y limitation
	JG invalidK

	MOV eax, curHL.coord
	CALL checkCheck
 	TEST al, TRUE
	JNZ invalidK

	MOV eax, curHL.coord
	CALL checkConflictK
	TEST al, TRUE
	JNZ invalidK

	validK:
		TEST isWhiteMove, TRUE
		JNZ setWKingPos
		MOV edi, OFFSET bKingPos
		JMP copyKingPos
		setWKingPos:
		MOV edi, OFFSET bKingPos
		
		copyKingPos:
		PUSH edi
		MOV esi, OFFSET curHL
		MOV ecx, SIZEOF MOVESTRUCT
		REP MOVSB
		POP edi

		POP esi
		MOV BYTE PTR [esi], TRUE		; King has moved
		MOV eax, TRUE
		JMP kMoveFound

	invalidK:
		MOV eax, FALSE
		POP esi

	kMoveFound:
	RET
kMove ENDP

;
setRookStatus PROC
; @Comment: Used to set movement status for castle if both rooks have not moved yet
	PUSH esi
	MOV esi, OFFSET castle
	MOV al, prevHL.piece
	CMP al, 'R'
	JZ castleStatus

	ADD esi, 4

	castleStatus:
	CMP prevHL.coord.x, 1			; Check if prevHL is in the a file
	JNZ setHRookStatus				;

	MOV BYTE PTR [esi + 1], TRUE
	JMP setStatus

	setHRookStatus:
	MOV BYTE PTR [esi + 2], TRUE

	setStatus:
	POP esi
	RET
setRookStatus ENDP

;
checkCastle PROC
; @Params:	eax - coordinate to check for castle
; @Return:	esi - castle array at correct offset for color
	LOCAL buf[SIZEOF MOVESTRUCT * 2]

	MOV esi, OFFSET castle
	CMP prevHL.piece, 'K'
	JZ castleCheck
	
	ADD esi, 4

	castleCheck:
		PUSH esi
		TEST BYTE PTR [esi], TRUE		; If king has moved
		JNZ invalidCastle
		MOVZX eax, dl
		SUB al, bl
		CMP al, NULL
		JG gotAbs
		NEG al
		gotAbs:
		CMP al, 2
		JNZ invalidCastle
		CMP curHL.coord.y, 1			; Check for correct rows
		JZ checkCastleType				;
		CMP curHL.coord.y, 8			;
		JNZ invalidCastle				;
		checkCastleType:
		CMP dl, bl
		JA kingSideCastle
		CMP BYTE PTR[esi + 1], TRUE		; a file rook has moved if true
		JZ invalidCastle				;
		
		MOV BYTE PTR [esi + 3], FALSE	; Set queenside castle
		MOV cl, 1						; For setting end coord
		JMP checkEmpty

	kingSideCastle:
		TEST BYTE PTR [esi + 2], TRUE
		JNZ invalidCastle
		MOV BYTE PTR [esi + 3], TRUE	; Set kingside castle
		MOV cl, 8						; For setting end coord

	checkEmpty:
		PUSH esi
		PUSH edx
		PUSH ebx
		MOV dl, cl
		CALL rMove
		POP ebx
		POP edx
		POP esi
		TEST al, TRUE
		JZ invalidCastle

		PUSH esi
		MOV esi, OFFSET prevHL			; Save prev position
		LEA edi, buf					;
		MOV ecx, SIZEOF MOVESTRUCT		;
		REP MOVSB

		MOV esi, OFFSET curHL			; Save new position
		MOV ecx, SIZEOF MOVESTRUCT		;
		REP MOVSB
		POP esi

		MOV al, prevHL.piece
		MOV ah, 'R'
		CMP al, 'K'
		JZ whiteCastle
		ADD ah, 20h		
		whiteCastle:
			PUSH esi
			TEST BYTE PTR [esi + 3], TRUE
			JNZ castleKingside
		
		SUB prevHL.coord.x, 4	; Queenside rook 4 away from king
		ADD curHL.coord.x, 1	; Rook ends up to right of king
		JMP doCastle

		castleKingside:
			ADD prevHL.coord.x, 3	; Queenside rook 4 away from king
			SUB curHL.coord.x, 1	; Rook ends up to right of king

		doCastle:
			MOV curHL.piece, ah
			MOV prevHL.piece, NULL
			
			MOV prevHL.uMsg, BP_COLOR
			MOV eax, OFFSET prevHL
			PUSH eax
			CALL BoardProc

			MOV curHL.uMsg, BP_COLOR
			MOV eax, OFFSET curHL
			PUSH eax
			CALL BoardProc

			MOV prevHL.uMsg, BP_CASTLE
			MOV eax, OFFSET prevHL
			PUSH eax
			CALL BoardProc

		POP esi
		PUSH esi

		LEA esi, buf					; Return prev position
		MOV edi, OFFSET prevHL			;
		MOV ecx, SIZEOF MOVESTRUCT		;
		REP MOVSB

		MOV edi, OFFSET curHL			; Return new position
		MOV ecx, SIZEOF MOVESTRUCT		;
		REP MOVSB

		POP esi

		MOV DWORD PTR [esi], 10101h
		MOV eax, TRUE
		JMP castleFound
			
	invalidCastle:
		MOV eax, FALSE

	castleFound:
	POP esi
	RET
checkCastle ENDP

; @Desc: Checks for checkmate
check4Mate MACRO
; @Params:	eax - contains DWORD coord
;			dx  - contains one or two pieces in high and low bytes
;					if one piece, upper byte contains 1
; @Comment: The caller must pop the leftover original coord
;			Caller must have isCheck label implemented
	LOCAL done		; Prevent symbol redefinition error

	PUSH eax
	CALL isValidCoord
	CMP eax, -1
	JZ done
	POP eax
	PUSH eax
	CALL GetSqrContent
	CMP al, NULL
	JNZ done
	POP eax
	PUSH eax
	CALL checkCheck
	CMP al, FALSE
	JZ notCheckmate

	done:
	ENDM

; @Desc: If the king has no legal moves, this checks if any pieces can block check
checkBlock PROC
; @Params:	eax - ptr to MOVESTRUCT containing correct king info

	RET
checkBlock ENDP

;
checkCheckMate PROC
; @Params:	eax - coordinate to check for checkmate
	PUSH edx
	MOV edx, 'K'		; Piece to check for
	MOV dh, 1			; To not conflict with NULL for empty space

	TEST isWhiteMove, TRUE
	JZ startCheckK

	ADD dl, 20h			; Make lower case if it is white's turn

	startCheckK:
		PUSH edx		; Save piece

		ADD eax, 10001h	; Check (1,1)
		check4Mate		;
		POP eax			; Leftover from macro
		
		DEC ax			; Check (1, 0)
		check4Mate		;
		POP eax			; Leftover from macro

		DEC ax			; Check (1, -1)
		check4Mate		;
		POP eax			; Leftover from macro

		SUB eax, 10000h	; Check (0, -1)
		check4Mate		;
		POP eax			; Leftover from macro

		SUB eax, 10000h	; Check (-1, -1)
		check4Mate		;
		POP eax			; Leftover from macro

		INC ax			; Check (-1, 0)
		check4Mate		;
		POP eax			; Leftover from macro

		INC ax 			; Check (-1, 1)
		check4Mate		;
		POP eax			; Leftover from macro

		ADD eax, 10000h	; Check (0, 1)
		check4Mate		;
		POP eax			; Leftover from macro

		POP eax						; Char for king
		CALL isWhitePiece
		CMP al, TRUE				; Get offset of MOVESTRUCT with king info
		JNZ blackKing				;
		MOV eax, OFFSET wKingPos	;
		blackKing:					;
		MOV eax, OFFSET bKingPos	;
		CALL checkBlock				;

	isCheckmate:
		MOV eax, TRUE
		JMP checked4Mate

	notCheckmate:
		POP eax			; Leftover, discard
		POP eax			;
		MOV eax, FALSE

	checked4Mate:
	POP edx
	RET
checkCheckMate ENDP

;
checkCheck PROC
; @Params:	eax - coordinate to check for check
	PUSH eax
	CALL checkCheckP
	TEST al, TRUE
	JNZ gotCheckStatus
	
	POP eax
	PUSH eax
	CALL checkCheckRQ
	TEST al, TRUE
	JNZ gotCheckStatus

	POP eax
	PUSH eax
	CALL checkCheckN
	TEST al, TRUE
	JNZ gotCheckStatus

	POP eax
	PUSH eax
	CALL checkCheckBQ
	TEST al, TRUE
	JNZ gotCheckStatus

	MOV eax, FALSE

	gotCheckStatus:
	ADD esp, 4			; Always have a leftover push at the end
	RET
checkCheck ENDP

; @Desc: Checks for check
checkCoord MACRO
; @Params:	eax - contains DWORD coord
;			dx  - contains one or two pieces in high and low bytes
;					if one piece, upper byte contains 1
; @Comment: The caller must pop the leftover original coord
;			Caller must have isCheck label implemented
	LOCAL done		; Prevent symbol redefinition error

	PUSH eax
	CALL isValidCoord
	CMP eax, -1
	JZ done
	POP eax
	PUSH eax
	CALL GetSqrContent
	CMP al, dl
	JZ isCheck
	CMP al, dh
	JZ isCheck

	done:
	ENDM

;
checkConflictK PROC
; @Comment:		Although it is not technically check two kings touch, the ease of simply using
;					using the checkCoord MACRO outweighed my internal conflict with using the
;					misnomer labels notCheck and isCheck. I hope you can forgive me.

	PUSH edx
	MOV edx, 'K'		; Piece to check for
	MOV dh, 1			; To not conflict with NULL for empty space
	
	TEST isWhiteMove, TRUE
	JZ startCheckK

	ADD dl, 20h			; Make lower case if it is white's turn

	startCheckK:
		ADD eax, 10001h	; Check (1,1)
		checkCoord		;
		POP eax			; Leftover from macro
		
		DEC ax			; Check (1, 0)
		checkCoord		;
		POP eax			; Leftover from macro

		DEC ax			; Check (1, -1)
		checkCoord		;
		POP eax			; Leftover from macro

		SUB eax, 10000h	; Check (0, -1)
		checkCoord		;
		POP eax			; Leftover from macro

		SUB eax, 10000h ; Check (-1, -1)
		checkCoord		;
		POP eax			; Leftover from macro

		INC ax			; Check (-1, 0)
		checkCoord		;
		POP eax			; Leftover from macro

		INC ax			; Check (-1, 1)
		checkCoord		;
		POP eax			; Leftover from macro

		ADD eax, 10000h	; Check (0, 1)
		checkCoord		;
		POP eax			; Leftover from macro

	notCheck:
		MOV eax, FALSE
		JMP checkedK

	isCheck:
		POP eax			; Leftover, discard
		MOV eax, TRUE

	checkedK:
	POP edx
	RET
checkConflictK ENDP

checkCheckBQ PROC
	
; @ Return: eax - if coord is checked by rook or queen, return TRUE, else FALSE
	LOCAL	incs[16],
			numIncs:BYTE,
			numSqrs:BYTE

	MOV DWORD PTR incs, 00010001h
	MOV DWORD PTR incs[4], 0FFFEFFFFh		; Prevent overflow
	MOV DWORD PTR incs[8], 0000FFFFh		; Carry accounts for adding to y coord
	MOV DWORD PTR incs[12], 0FFFF0001h
	MOV numIncs, 4
	MOV numSqrs, 9		; Max squares = 8 - 1 = 7, add buffer of 1 to prevent 
						;	stack misalignment in startOutLoop

	PUSH edx
	PUSH ecx
	PUSH ebx

	MOV edx, 'B'		; Pieces to check for
	MOV dh, 'Q'			;
	XOR ecx, ecx		; Outer loop initilization

	TEST isWhiteMove, TRUE
	JZ startOutLoopBQ

	ADD edx, 2020h		; Make lower case for check 
	
	startOutLoopBQ:
		MOV ebx, incs[ecx * TYPE DWORD]
		PUSH ecx		; Save counter and coord for next loop
		PUSH eax		;
		MOV cl, numSqrs
	startInLoopBQ:
		LOOP inLoopBQ
		JMP endOutLoopBQ
	inLoopBQ:
		ADD eax, ebx		; Add increment
		checkCoord

		CMP al, NULL		; Check for non-checking pieces (blocking pieces)
		JNZ endOutLoopBQ	;	or for -1 returned from isValidCoord

		POP eax				; Coord from macro
		JMP startInLoopBQ	; One of the above cases must be hit for inLoop to exit
	endOutLoopBQ:
		POP eax			; Leftover from previous loop, discard
		POP eax			; Original coord
		POP ecx			; Outer loop count
		INC ecx
		CMP cl, numIncs
		JZ notCheck
		JMP startOutLoopBQ

	notCheck:
		MOV eax, FALSE
		JMP checkedBQ

	isCheck:
		ADD esp, 12		; 3 leftover dwords in stack
		MOV eax, TRUE

	checkedBQ:
	PUSH ebx
	POP ecx
	POP edx
	RET
checkCheckBQ ENDP

checkCheckN PROC
	PUSH edx
	PUSH ebx
	MOV ebx, 10002h
	MOV edx, 'N'		; Piece to check for
	MOV dh, 1			; To not conflict with NULL for empty space
	
	TEST isWhiteMove, TRUE
	JZ startCheckN

	ADD dl, 20h			; Make lower case if it is white's turn

	startCheckN:
		ADD eax, ebx	; Check (1,2)
		checkCoord		;
		POP eax			; Leftover from macro
		
		NEG bx			; Check (1, -2)
		checkCoord		;
		POP eax			; Leftover from macro

		ROL ebx, 16		; Check (-2, 1)
		checkCoord		;
		POP eax			; Leftover from macro

		NEG bx			; Check (-2, -1)
		checkCoord		;
		POP eax			; Leftover from macro

		ROL ebx, 16		; Check (-1, -2)
		checkCoord		;
		POP eax			; Leftover from macro

		NEG bx			; Check (-1, 2)
		checkCoord		;
		POP eax			; Leftover from macro

		ROL ebx, 16		; Check (2, -1)
		checkCoord		;
		POP eax			; Leftover from macro

	notCheck:
		MOV eax, FALSE
		JMP checkedN

	isCheck:
		POP eax			; Leftover, discard
		MOV eax, TRUE

	checkedN:
	POP ebx
	POP edx
	RET
checkCheckN ENDP

checkCheckRQ PROC
; @ Return: eax - if coord is checked by rook or queen, return TRUE, else FALSE
	LOCAL	incs[16],
			numIncs:BYTE,
			numSqrs:BYTE

	MOV DWORD PTR incs, 00010000h
	MOV DWORD PTR incs[4], 0FFFF0000h
	MOV DWORD PTR incs[8], 1
	MOV DWORD PTR incs[12], 0FFFFFFFFh		; Overflow not possible of interval of loop
	MOV numIncs, 4
	MOV numSqrs, 9		; Max squares = 8 - 1 = 7, add buffer of 1 to prevent 
						;	stack misalignment in startOutLoop

	PUSH edx
	PUSH ecx
	PUSH ebx

	MOV edx, 'R'		; Pieces to check for
	MOV dh, 'Q'			;
	XOR ecx, ecx		; Outer loop initilization

	TEST isWhiteMove, TRUE
	JZ startOutLoopRQ

	ADD edx, 2020h		; Make lower case for check 
	
	startOutLoopRQ:
		MOV ebx, incs[ecx * TYPE DWORD]
		PUSH ecx		; Save counter and coord for next loop
		PUSH eax		;
		MOV cl, numSqrs
	startInLoopRQ:
		LOOP inLoopRQ
		JMP endOutLoopRQ
	inLoopRQ:
		ADD eax, ebx		; Add increment
		checkCoord

		CMP al, NULL		; Check for non-checking pieces (blocking pieces)
		JNZ endOutLoopRQ	;	or for -1 returned from isValidCoord

		POP eax				; Coord from macro
		JMP startInLoopRQ	; One of the above cases must be hit for inLoop to exit
	endOutLoopRQ:
		POP eax			; Leftover from previous loop, discard
		POP eax			; Original coord
		POP ecx			; Outer loop count
		INC ecx
		CMP cl, numIncs
		JZ notCheck
		JMP startOutLoopRQ

	notCheck:
		MOV eax, FALSE
		JMP checkedRQ

	isCheck:
		ADD esp, 12		; 3 leftover dwords in stack
		MOV eax, TRUE

	checkedRQ:
	PUSH ebx
	POP ecx
	POP edx
	RET
checkCheckRQ ENDP

checkCheckP PROC
; @ Return: eax - if coord is checked by pawn, return TRUE, else FALSE
	PUSH edx
	PUSH ecx
	PUSH ebx
	MOV ebx, 0FFFEFFFFh		; Check left first; overflow gives correct y coord if coord is valid
	MOV ecx, eax			; Save coord in ecx
	MOV edx, 'P'
	MOV dh, 1

	TEST isWhiteMove, TRUE
	JZ checkP
	
	MOV ebx, 0FFFFh		; To account for overflow
	ADD edx, 20h

	checkP:
		; Check first pawn pos
		ADD eax, ebx
		checkCoord
		POP eax			; Leftover

		; Check second pawn pos
		MOV eax, ecx
		ADD ebx, 2		; Shift x coord by 2
		ADD eax, ebx
		checkCoord
		POP eax			; Leftover

	notCheck:
		MOV eax, FALSE
		JMP checkedP
	
	isCheck:
		POP eax			; Leftover
		MOV eax, TRUE

	checkedP:
	POP ebx
	POP ecx
	POP edx
	RET
checkCheckP ENDP

;
isValidCoord PROC
; @Params: If true, returns coord, else returns -1
	PUSH eax
	CMP ax, 1
	JL invalidMv
	CMP ax, 8
	JG invalidMv
	SHR eax, 16
	CMP ax, 1
	JL invalidMV
	CMP ax, 8
	JG invalidMv
	POP eax
	JMP checkedValidity

	invalidMv:
	POP eax
	MOV eax, -1

	checkedValidity:
	RET
isValidCoord ENDP

END