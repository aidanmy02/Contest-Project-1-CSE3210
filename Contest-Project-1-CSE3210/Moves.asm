.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

INCLUDE Board.inc

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

.code
MoveProc PROC
	PUSH edx		; Save ebx, ecx, edx since they will be used in processing moves
	PUSH ecx		;
	PUSH ebx		; 
	
	MOVZX ebx, prevHL.coord.y		; store prevHL.coord as a word in bx
	SHL ebx, 8						; shift into bh
	MOVZX eax, prevHL.coord.x		;
	MOV bl, al						;
	MOVZX edx, curHL.coord.y		; store prevHL.coord as a word in dx
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
	POP ebx			; Restore ebx, ecx
	POP ecx			;
	POP edx			;
	RET
MoveProc ENDP

; Pawn move
pMove PROC
	; Get diff in coords
	MOVZX eax, dx
	SUB ax, bx

	; Case: x coord diff - check for capture
	CMP al, 0
	JNZ pCapture

	; Case: move 1 forward
	CMP ah, 1		; Check fwd1 for white
	JNZ fwd1B
	CMP cl, NULL	; Check dest is empty
	JNZ invalid
	JMP validateWhite

	fwd1B:
	CMP ah, -1		; Check fwd1 for black
	JNZ fwd2		
	CMP cl, NULL	; Check dest is empty
	JNZ invalid
	JMP validateBlack

	fwd2:
		CMP ah, 2
		JNZ invalid
		CMP ah, -2
		JMP invalid

	pCapture:
		
		JMP invalid

	validateWhite:
		CMP ch, WPAWN	; Check piece is white
		JNZ invalid
		JMP valid

	validateBlack:
		CMP ch, BPAWN	; Check piece is white
		JNZ invalid
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