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
	MOV al, curHL.piece
	OR al, 20h		; Make lower case

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