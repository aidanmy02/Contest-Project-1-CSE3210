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
move MOVESTRUCT 64 DUP(<>)

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
	INC ecx
	XOR ebx, ebx	; Store current MOVESTRUCT in move

	startCol:
	LOOP loopCol
	JMP endLoop
	loopCol:
		; Copy ecx into edx to move into move.coord.x after semaphore is locked
		MOV edx, ecx

		; Save ecx and move inner loop count into ecx
		PUSH ecx
		MOV ecx, numRows
		INC ecx

		startRow:
		LOOP loopRow
		JMP endRow
		loopRow:
			; Get position of current MOVESTRUCT
			MOV eax, SIZEOF MOVESTRUCT
			PUSH edx
			XOR edx, edx
			MUL ebx
			MOV esi, OFFSET move
			ADD esi, eax
			POP edx

			; Set uMsg
			MOV eax, WM_SQR
			MOV [esi], eax
			ADD esi, SIZEOF MOVESTRUCT.uMsg
			; Set x coordinate of board
			MOV [esi], edx		; edx contains col
			ADD esi, SIZEOF MOVESTRUCT.coord.x
			; Set y coordinate of board
			MOV [esi], ecx		; ecx contains row
			ADD esi, SIZEOF MOVESTRUCT.coord.y

			; TODO: implement move.piece
			MOV al, 0
			MOV [esi], al
			ADD esi, SIZEOF MOVESTRUCT.piece

			; Push x and y coordinates for GetSqrColor
			MOVZX eax, move.coord.x
			PUSH eax
			MOVZX eax, move.coord.y
			PUSH eax
			CALL GetSqrColor
			MOV move.sqrColor, al
			
			; Send WM_PAINT message to GetMessage
			INVOKE PostMessageA,	hWndMain,\			; hWnd
									WM_SQR,\			; uMsg
									ADDR move,\			; wParam
									NULL				; lParam

		JMP startRow
		
		endRow:
		; Return outer loop counter to ecx
		POP ecx
	JMP startCol

	endLoop:
	RET
InitBoard ENDP

GetSqrColor PROC
	PUSH ebp
	MOV ebp, esp

	; Add coordinates divide by two to check even/odd
	XOR edx, edx
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