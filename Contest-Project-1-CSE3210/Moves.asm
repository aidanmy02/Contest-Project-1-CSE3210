.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

INCLUDE Board.inc
BoardProc PROTO

PUBLIC MoveProc

NULL EQU 0
FALSE EQU 0
TRUE EQU 1

; Structs
; Coordinate
COORDSTRUCT STRUCT
	x WORD ?
	y WORD ?
COORDSTRUCT ENDS

; Move
MOVESTRUCT STRUCT
	uMsg DWORD ?
	coord COORDSTRUCT <>
	piece BYTE ?
	sqrColor BYTE ?
MOVESTRUCT ENDS

EXTERN board:BOARDSTRUCT
EXTERNDEF curHL:MOVESTRUCT
EXTERNDEF prevHL:MOVESTRUCT

.data
prevFwd2 COORDSTRUCT <>
isFwd2 BYTE FALSE
isEnPassant BYTE FALSE

.code
MoveProc PROC
	PUSH esi		; Save ebx, ecx, edx, esi since they will be used in processing moves
	PUSH edx		;
	PUSH ecx		;
	PUSH ebx		; 
	
	MOV isFwd2, FALSE				; Set to false for check at end

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
	JMP mvProcessed

	queenCheck:
	CALL qMove
	JMP mvProcessed

	bishopCheck:
	CALL bMove
	JMP mvProcessed

	knightCheck:
	CALL nMove
	JMP mvProcessed

	rookCheck:
	CALL rMove
	JMP mvProcessed

	pawnCheck:
	CALL pMove

	mvProcessed:
	PUSH eax
	MOV al, isFwd2			; Check if a forward 2 move was made for pawn
	CMP al, TRUE
	JZ enPassantProcessed
	MOV DWORD PTR prevFwd2, 0

	enPassantProcessed:
	POP eax
	POP ebx			; Restore ebx, ecx
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
		MOV eax, curHL.coord			; Save new position in prevFwd2 if valid Fwd2 move
		MOV DWORD PTR prevFwd2, eax		;
		MOV al, TRUE					;
		MOV isFwd2, al					;
		JMP valid

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
		MOVZX eax, prevFwd2.x	; Check if previous move was fwd2
		CMP eax, NULL
		JZ invalid
		SUB ax, prevHL.coord.x
		CMP ax, 1			; Check if prevHL and prevFwd2 are next to each other
		JG invalid			;
		CMP ax, -1			;
		JL invalid			;
		MOV ax, prevFwd2.x		; Check if prevFwd2 and curHL are in the same column
		CMP ax, curHL.coord.x	;
		JNZ invalid
		MOVZX eax, prevFwd2.y
		CMP ax, prevHL.coord.y	; Check if prevHL y coord is same as prevFwd2 coord
		JNZ invalid
		MOV eax, TRUE
		MOV isEnPassant, al
		JMP valid

	valid:
	MOV eax, TRUE
	JMP pMvFound

	invalid:
	MOV eax, FALSE

	pMvFound:
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