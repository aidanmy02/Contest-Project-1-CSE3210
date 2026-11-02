.386
.model flat,stdcall
.stack 4096
OPTION PROC:PRIVATE

INCLUDE Board.inc

PUBLIC MoveProc

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
	RET
MoveProc ENDP

; Pawn move
pMove PROC

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