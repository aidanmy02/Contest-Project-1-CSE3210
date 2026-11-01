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
	MOV esi, OFFSET move	; Use esi to keep track of the current field of each MOVESTRUCT

	startCol:
	LOOP loopCol
	JMP endLoop
	loopCol:
		; Copy ecx into edx to use for move.coord.x and save before inner loop
		MOV edx, ecx

		; Inner loop count
		MOV ecx, numRows
		INC ecx

		startRow:
		LOOP loopRow
		JMP endRow
		loopRow:
			MOV ebx, esi	; Store the offset of the current MOVESTRUCT

			; Set uMsg
			MOV eax, WM_SQR
			MOV [esi], eax
			ADD esi, SIZEOF MOVESTRUCT.uMsg
			; Set x coordinate of board
			MOV [esi], dx		; edx contains col
			ADD esi, SIZEOF MOVESTRUCT.coord.x
			; Set y coordinate of board
			MOV [esi], cx		; ecx contains row
			ADD esi, SIZEOF MOVESTRUCT.coord.y

			; TODO: implement move.piece
			MOV al, 0
			MOV [esi], al
			ADD esi, SIZEOF MOVESTRUCT.piece

			; Save values of ecx and edx
			PUSH edx
			PUSH ecx

			; Get square Color
			CALL GetSqrColor
			MOV [esi], al
			ADD esi, SIZEOF MOVESTRUCT.sqrColor
			
			; Save current address
			PUSH esi

			; Send WM_PAINT message to GetMessage
			INVOKE PostMessageA,	hWndMain,\			; hWnd
									WM_SQR,\			; uMsg
									ebx,\				; wParam
									NULL				; lParam
			
			POP esi
			POP ecx
			POP edx
		JMP startRow
		endRow:
		; Return outer loop counter to ecx
		MOV ecx, edx
	JMP startCol

	endLoop:
	RET
InitBoard ENDP

GetSqrColor PROC
	; edx contains columns and ecx contains rows
	MOV eax, edx
	ADD eax, ecx
	
	; If even, then white
	TEST eax, 1
	JZ whiteSqr

	; Else, black
	MOV eax, 1
	JMP gotColor

	whiteSqr:
	XOR eax, eax

	gotColor:
	RET
GetSqrColor ENDP
END