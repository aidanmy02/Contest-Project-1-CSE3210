INCLUDE Chess.inc

BOARDSTRUCT STRUCT
	_a BYTE 8 DUP(0)
	_b BYTE 8 DUP(0)
	_c BYTE 8 DUP(0)
	_d BYTE 8 DUP(0)
	_e BYTE 8 DUP(0)
	_f BYTE 8 DUP(0)
	_g BYTE 8 DUP(0)
	_h BYTE 8 DUP(0)
BOARDSTRUCT ENDS

; Packages information for changing a square's state in the window
WNDPACK STRUCT
	bc BYTE ?		; background color
	peice BYTE ?	; peice
	pos COORD <>	; board coordinates
WNDPACK ENDS

.data
; Initialize board
board BOARDSTRUCT <>

; Initialize coord for use as parameter
PUBLIC pack
pack WNDPACK <>

.code
BoardProc PROC, bpUMsg:DWORD, col:DWORD, row:DWORD, piece:DWORD
	MOV eax, bpUMsg
	CMP bpUMsg, BP_INIT
	JZ bpInit

	bpInit:
	bpDone:
	RET
BoardProc ENDP

initBoard PROC
	RET
initBoard ENDP

END