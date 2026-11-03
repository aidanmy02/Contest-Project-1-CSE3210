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
	JZ pawnCheck
	CMP al, 'b'
	JZ rookCheck
	CMP al, 'q'
	JZ pawnCheck
	CMP al, 'k'
	JZ rookCheck

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
		JNZ invalid
		JMP valid

	; Case: move 2 forward
	fwd2:
		CMP ah, 2		; Check fwd2 for white
		JNZ invalid

		CMP bh, 2			; Check row validity
		JZ validateWhite	;
		CMP bh, 7			;
		JNZ validateBlack	;
		JMP invalid			;

		fwd2Cont:
		CMP cl, NULL		; Check dest is empty
		JNZ invalid
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
		JNZ invalid
		MOV isFwd2, TRUE	; Fwd2 move was made
		JMP validFwd2

	validateWhite:
		CMP ch, WPAWN
		JZ fwd2Cont
		JMP invalid

	validateBlack:
		CMP ch, BPAWN
		JZ fwd2Cont
		JMP invalid

	capt:
		CMP al, 1			; Pawn takes right
		JG invalid
		CMP al, -1			; Pawn takes left
		JL invalid
		CMP cl, NULL		; Check en passant
		JZ enPassant
		JMP valid

	enPassant:
		MOV al, prevMove.piece
		OR al, 20h				; Make lower case
		CMP al, 'p'				; Check if previous move was a pawn move
		JNZ invalid
		CMP isFwd2, TRUE		; Check if previous move was Fwd 2
		JNZ invalid
		MOVZX eax, prevMove.coord.y
		CMP ax, prevHL.coord.y	; Check if prevHL y coord is same as prevMove coord
		JNZ invalid
		MOV ax, prevMove.coord.x
		CMP ax, curHL.coord.x	; Check if prevMove and curHL are in the same column
		JNZ invalid
		
		MOV prevMove.piece, NULL
		MOV prevMove.uMsg, BP_ENPASSANT
		MOV eax, OFFSET prevMove
		PUSH eax
		CALL BoardProc
		JMP valid

	valid:
		MOV isFwd2, FALSE
	validFwd2:
		MOV eax, TRUE
		JMP pMvFound

	invalid:
	MOV eax, FALSE

	pMvFound:
	AND isFwd2, al
	RET
pMove ENDP

; Rook move
rMove PROC

	RET
rMove ENDP

; Knight move
nMove PROC

	RET
nMove ENDP

; Bishop move
bMove PROC

	RET
bMove ENDP

; Queen move
qMove PROC

	RET
qMove ENDP

; King move
kMove PROC

	RET
kMove ENDP

END