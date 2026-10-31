INCLUDE Chess.inc

BOARDSTRUCT STRUCT
	_a BYTE WROOK, WKNIGHT, WBISHOP, WQUEEN, WKING, WBISHOP, WKNIGHT, WROOK
	_b BYTE 8 DUP(WPAWN)
	_c BYTE 8 DUP(0)
	_d BYTE 8 DUP(0)
	_e BYTE 8 DUP(0)
	_f BYTE 8 DUP(0)
	_g BYTE 8 DUP(BPAWN)
	_h BYTE BROOK, BKNIGHT, BBISHOP, BQUEEN, BKING, BBISHOP, BKNIGHT, BROOK
BOARDSTRUCT ENDS

.data
; Initialize board
board BOARDSTRUCT <>

; For message passing
move MOVESTRUCT <>

numCols EQU 8
numRows EQU 8

.code
BoardProc PROC
	MOV eax, move.uMsg
	CMP eax, BP_INIT
	JZ bpInit
	
	bpInit:
		CALL InitBoard
		INVOKE ExitThread,	NULL
	bpDone:
	RET
BoardProc ENDP

InitBoard PROC
	; Loop over all columns
	MOV ecx, numCols
	loopCol:
		; Lock mutex
		CALL waitSem

		; Set paint message
		MOV move.uMsg, WM_PAINT

		; Set x coordinate of board
		MOV move.coord.x, cx

		; Get the address of the current column and store in esi
		MOV eax, numCols
		MUL ecx
		SUB eax, numCols			; Make zero based index
		MOV esi, OFFSET board
		ADD esi, eax

		; Save ecx and move inner loop count into ecx
		PUSH ecx
		MOV ecx, numRows
		loopRow:
			; Set y coordinate of board
			MOV move.coord.y, cx

			; Get the address of the current square on the board
			MOV edi, ecx
			DEC edi					; Make zero based index
			MOV al, [esi + edi]

			; Set the piece at the current square
			MOV move.piece, al

			; Push x and y coordinates for GetSqrColor
			MOVZX eax, move.coord.x
			PUSH eax
			MOVZX eax, move.coord.y
			PUSH eax
			CALL GetSqrColor
			MOV move.sqrColor, al
			
			; Send WM_PAINT message to GetMessage
			INVOKE PostMessageA,	hWndMain,\			; hWnd
									WM_PAINT,\			; uMsg
									ADDR move,\			; wParam
									NULL				; lParam

			; Unlock mutex
			CALL signalSem
		loop loopRow
		
		; Return outer loop counter to ecx
		POP ecx
	loop loopCol
	RET
InitBoard ENDP

GetSqrColor PROC
	PUSH ebp
	MOV ebp, esp

	; Add coordinates divide by two to check even/odd
	MOV eax, [ebp + 8]
	ADD eax, [ebp + 12]
	MOV ebx, 2
	DIV ebx

	; If even, then the square is white
	CMP edx, 0
	JZ whiteSqr

	; Else, square is black
	MOV eax, 1
	JMP gotColor

	whiteSqr:
	XOR eax, eax

	gotColor:
	POP ebp
	RET 8
GetSqrColor ENDP
END