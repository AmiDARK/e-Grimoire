
; ***************************************************************************************************************************
; 																									USE LOCAL VARIABLES  ************
;
; dPushIntToLocalVar VALUE, NAME : Push directly an integer inside a local variable (allow cast INT->FLOAT if required)


dPushIntToLocalVar		MACRO
	move.l 		\1,d0
	move.l 		\2,d1
	bsr.w 		

; dPushToInt VALUE,NAME		Push a direct integer value directly inside an local integer variable
; dPushToFloat VALUE,NAME 	Push a direct float value (in String format) directly inside a local floating number variable 
; dPushToString VALUE,NAME 	Push a direct static String (between "") directly inside a local String variable

dPushToInt 		MACRO
	move.l 		localDatas(a5),a3
	cmp.w 		#TypeInt,\2+4(a3)
	beq.s		.ok\2
	jmp 		errHand_notInt
.ok\2:
	move.l 		#\1,\2(a3)
				ENDM

; Check sample here is issue with dc.b : https://wiki.amigaos.net/wiki/Math_Libraries
dPushToFloat 	MACRO
	move.l 		localDatas(a5),a3
	cmp.w 		#TypeFloat,\2+4(a3)
	beq 		.ok\2
	jmp 		errHand_notFlt
.strToFlt\2:
	dc.b 		\1,0
.ok\2:
	lea.l	.strToFlt\2,a0
	mathFFPCall 	afp
	move.l		d0,\2(a3)
				ENDM

; Direct quoted String to send to variable
dPushToString	MACRO
	move.l 		localDatas(a5),a3
	cmp.w 		#TypeString,\2+4(a3)
	beq.s		.ok\2
	jmp 		errHand_notStr
.static\2:
	dc.b 		\1,0					; To memorize temporar static string before inserting it as true allocated string.
.ok\2:
	cmp.l 		\1,\2(a3) 				; Verify that we do not try to overwrite the same String to itself
	beq.s 		.noc\2 					; if Old and New String equals, no update -> Jump to .noc\2
	Move.l 		\2(a3),a0 				; Get the pointer to the String currently in memory for this var
	cmp.l 		#0,a0
	beq.s 		.noe\2 					; if String is not set (empty==null), then we de not clear it
	Move.l 		\2+6(a3),d0 			; Get the size of the String currently in memory for this var
	exeCall 	FreeMem 				; Release the old String.
.noe\2:
	lea.l 		.static\2,a0 			; A0 = Pointer to the Static String to verify length
	StrToStack	static\2,-1
	Jsr			getStringSize
	pullStrFromStack 					; Get The String with correct size
	move.l 		d0,\2+6(a3) 			; Save final String length
	move.w 		#TypeString,\2+4(a3) 	; Save data as String (overwrite)
	Move.l 		#Public|Clear,d1 		; D1 = Datas will be stored in fast if available and must be clear
	exeCall 	AllocMem				; Allocate memory to create the String variable data
	Move.l 		a0,\2(a3)				; Save the String pointer inside the structure
	; To end, we must copy old string on new one.
	Sub.l		#1,d0
	lea.l 		.static\2,a1
.cpyL\2:
	move.b 		(a1)+,(a0)+
	Sub.l 		#1,d0
	bpl.s 		.cpyL\2
.noc\2:
				ENDM





; *****************************************************
; 8. Initialize a variable : integer
SetAsInteger 	MACRO
	Move.w 		#TypeInt,\1+4(a4)
	clr.l 		\1(a4)
				ENDM

; *****************************************************
; 9. Initialize a variable : float
SetAsFloat	 	MACRO
	Move.w 		#TypeFlt,\1+4(a4)
				ENDM

; *****************************************************
; 10. Initialize a variable : String (empty)
SetAsString 	MACRO
	move.w 		#TypeStr,\1+4(a4)
				ENDM

; *****************************************************
; 11. Initialize a variable : String (with string set)
SetAsString 	MACRO
	move.w 		#TypeStr,\1+4(a4)
	lea.l 		dcb\1,a0
	move.l 		a0, \1(a4) 				; Save the pointer to the dc.l where the default string is located
				ENDM

; *****************************************************
; 12. Initialize a variable ; Integer Dim(\2) 
SetAsDimInteger	MACRO
	move.w 		#TypeDim+TypeInt,\1+4(a4) 		; Set as type TypeDim+TypeInt = Dim Integer(FixedSize=\2)
	move.l 		\2,d0
	move.l 		d0,\1+6(a4) 					; Set the array size
	Lsl.l 		#2,d0 							; D0 Integer Count * 4 = Total Memory Required
	Move.l 		#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	Jsr 		AllocMem(a6) 					; A6 should already contains ExecBase as BuildDatas was previously called
	move.l 		a0,\1(a4) 						; Save the pointer to the Dim Integer(\2) Datas.
				ENDM

; *****************************************************
; 13. Initialize a variable ; Float Dim(\2)
SetAsDimFloat 	MACRO
	move.w 		#TypeDim+TypeFlt,\1+4(a4) 		; Set as type TypeDim+TypeFlt = Dim Float(FixedSize=\2)
	move.l 		\2,d0
	move.l 		d0,\1+6(a4) 					; Set the array size
	Lsl.l 		#2,d0 							; D0 Integer Count * 4 = Total Memory Required
	Move.l 		#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	Jsr 		AllocMem(a6) 					; A6 should already contains ExecBase as BuildDatas was previously called
	move.l 		a0,\1(a4) 						; Save the pointer to the Dim Float(\2) Datas.
				ENDM

; *****************************************************
; 14. Initialize a variable ; String Dim(\2)
SetAsDimString 	MACRO
	move.w 		#TypeDim+TypeStr,\1+4(a4) 		; Set as type TypeDim+TypeStr = Dim String(FixedSize=\2)
	move.l 		\2,d0
	move.l 		d0,\1+6(a4) 					; Set the array size
	Lsl.l 		#2,d0 							; D0 Integer Count * 4 = Total Memory Required
	Move.l 		#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	Jsr 		AllocMem(a6) 					; A6 should already contains ExecBase as BuildDatas was previously called
	move.l 		a0,\1(a4) 						; Save the pointer to the Dim Integer(\2) Datas.
				ENDM

; *****************************************************
; 15. Initialize a variable ; Integer Array() 
SetAsArrInteger	MACRO
	move.w 		#TypeDynArr+TypeInt,\1+4(a4) 	; Set as type TypeArr+TypeInt = Integer Array()
	; Dynamic arrays are empties at setup so, we do not do memory allocation now.
				ENDM

; *****************************************************
; 16. Initialize a variable ; Float Array()
SetAsArrFloat 	MACRO
	move.w 		#TypeDynArr+TypeFlt,\1+4(a4) 	; Set as type 8+2 = Float Array()
	; Dynamic arrays are empties at setup so, we do not do memory allocation now.
				ENDM

; *****************************************************
; 17. Initialize a variable ; String Array()
SetAsArrString	MACRO
	move.w 		#TypeDynArr+TypeStr,\1+4(a4) 	; Set as type 8+4 = Float String()
	; Dynamic arrays are empties at setup so, we do not do memory allocation now.
				ENDM

; Create the macro to modify and read datas (from DO, to D0) for integer, float, string, dim and arrays
; String must have a checking, if static then no freemem. if dynamic, uses freemem then allocate new string and copy the datas
; Make a size checking to cas error if length > 16384 for example.

; Also think about a temporar variable system (some sort of buffer)
; That may allow to be used for complex lines disassembling that do alternate calculations.
