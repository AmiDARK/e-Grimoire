; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.28                     *
; * Version : 0.1                         *
; * File : Stack System for Source Engine *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all MACRO and METHODS that are used to handle the direct variables | parameters stack
;
; Amiga OS System Stack can be used this way :
; 	movem.l 	REGISTERS,-(sp) 		To push registers inside Stack
;	movem.l 	(sp)+,REGISTERS 		to pull registers off/from the stack
;

; ***********************************************************************************
; The Stack handle all the variables types handled by the Engine and that are defined in the seVariables.s file
; Here are the details of the 2 sets for informations :
;
; Integer & Float Direct Datas :
;-------------------------------
; 0x0.L : Variable itself (Integer,Float) or its pointer (string)
; 0x4.W : Variable type ( TypeFlt, TypeInt )
;
; Single String, or Static and Dynamic Dimensionned arrays of Integer, Float or String :
;---------------------------------------------------------------------------------------
; 0x0.L : Pointer to the Single String or the Array
; 0x4.l : Length of Single String, or length of the Array
; 0x8.w : Variable type ( TypeStr, TypeNewStr, (TypeDim|TypeDynArr)+(TypeInt|TypeFlt|TypeStr)
;
; The last WORD represent the Data Type so, when a data must be read from the Stack,
; we can directly read .w at offset -2 of the stack pointer to know the size of the stack data to read.

; ****************************************************************************************************************

; (A0=String Pointer) = CreateDeleteString( A0=String Pointer, D0=String Length or -1 To Delete A0 String)

; pushStaticStringToStack STRNGNAME (MACRO)			Push a String defined in a dc.b "zeString",0 using its label reference
; pushStaticStringToLocalVar STRNGNAME,VARIABLENAME (MACRO)	Push a static String directly into a local variable
; pushLocalVarStringToStack VARIABLENAME (MACRO)	Push a variable (TypeStr or TypeNewStr) into the direct variables stack

: ********************************************
; This method can create or delete a string depending on entered parameters.
; The String length must contain the null terminated (0) character.
; INPUT : AO = String Pointer, D0 = String Length (or <0 (neg) to delete an existing String)
; OUTPUT : A0 = String Pointer
CreateDeleteString:
	movem.l a1,-(sp)
	tst.l 	d0
	beq.s	.errorStringLenIsNull
	bmi.s	.deleteStr
createStr:
	bsr 	AllocClrFastMem			; Allocate memory for String
	movem.l (sp)+,a1
	rts
.deleteStr:
	bsr		getStringSize 			; Call seString.s to evaluate the size of the String to delete
	addq	#1,d0 					; To contain the null terminated character (0)
	move.l 	a0,a1 					; FreeMem requires buffer pointer to be located into a1 (not a0)
	bsr		FreeMem
	clr.l 	a0 						; A0 = Null String Pointer
	clr.l 	d0 						; D0 = empty, no character at all. Nothing in.
	movem.l (sp)+,a1
	rts
.errorStringLenIsNull:
	bra 	ERROR                                                                                        ; NOT YET HANDLED !! ERROR HANDLER
	rts

: ********************************************
; Send a static String to Stack. A Static String is a string defined in the source Code
; using dc.b "zeString", 0. It is different from a Dynamic String that was created using the method CreateDeleteString.
; pushStaticStringToStack STRINGNAME,TEMPVARID (MACRO)			Push a String defined in a dc.b "zeString",0 using its label reference
; it uses a temporar var defined by an integer ID from 0-15
pushStaticStringToStack		MACRO
	movem.l 	d0/a0-a3,-(sp) 		; Save registers to amiga Stack
	; 1. Firstly we must point A2 to the chosen TEMPVAR
	Move.l 	TempVars(a5),a2 		; A2 = Pointer to temporar variables buffer
	Move.l 	#\2,d0 					; D0 = TEMPVARID index number
	Tst.l 	d0 						; Compare D0 & 0
	bmi 	ERROR                   ; <0 -> ERROR                                                        ; NOT YET HANDLED !! ERROR HANDLER
	cmp.l 	#15,d0 					; Compare DO & 15
	bgt 	ERROR                   ; >15 -> ERROR                                                       ; NOT YET HANDLED !! ERROR HANDLER
	Mulu 	#10,d0 					; D0 = D0 * 10 = D0 shift to Point to the chosen TEMPVAR
	add.l	d0.w,a2 				; A2 = Pointer to the chosen TEMPVAR
	; 2. We save the string informations inside the TEMPVAR
	Move.l 	a2,a1 					; A1 = Save TEMPVAR pointer from A2
	Lea.l 	\1,a0
	move.l 	a0,(a2)+ 				; Save String pointer
	move.w 	#TypeStr,(a2)+ 			; Save Static String type
	move.l 	#-1,(a2)+ 				; Size = -1 (not evaluated)
	; 2. Load Direct Variables Stack
	Move.l 	StackAdr(a5),a3 		; A3 = Direct Data Stacks
	move.l 	a1,(a3)+ 				; Push the Static String in the Stack
	move.l 	a3,StackAdr(a5) 		; Update Stack
	movem.l  (sp)+,d0/a0-a3 		; Load registers from Amiga Stack
							ENDM

: ********************************************
; This MACRO directly send a static string defined in the source code with a label and a dc.b "zestring",0
; into a local variable.
; pushLStaticStringToLocalVar STRNGNAME,VARIABLENAME (MACRO)	Push a static String directly into a local variable
pushStaticStringToLocalVar	MACRO
	movem.l 	d0/a0-a3,-(sp) 		; Save registers to amiga Stack
	move.l 	localDatas(a5),a1
	add.l 	#\2,a1 					; A1 Point to the existing String VARIABLENAME
	cmp.w 	#TypeStr,4(a1) 			; In case of static String, no need to delete it
	beq.s 	.pushStr
	cmp.w 	#TypeNewStr,4(a1) 		; in case of dynamic one, it must be released before update
	bne.s 	ERROR                   ; Not a STRING at all                                                ; NOT YET HANDLED !! ERROR HANDLER
	move.l  (a1),a0 				; A0 = Pointer to the previous dynamic String
	move.l 	#-1,d0 					; D0 = -1 to force the CreateDeleteString to deleteString
	bsr 	CreateDeleteString 		; Delete the previous Dynamic String available in the VARIABLENAME
.pushStr:
	Lea.l 	\1,a0
	move.l  a0,(a1)+
	move.w 	#TypeStr,(a1)+
	bsr		 getStringSize
	move.l 	d0,(a1)					; String Size is saved
	movem.l  (sp)+,d0/a0-a3 		; Load registers from Amiga Stack
							ENDM

: ********************************************
; Send a Local variable String to stack. A variable String is a variable with the format TypeStr in case of a Static String,
; or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushLocalVarStringToStack VARIABLENAME (MACRO)	Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushLocalVarStringToStack	MACRO
	movem.l d0/a0-a3,-(sp) 			; Save registers to amiga Stack
	move.l 	localDatas(a5),a0
	add.l 	#\1,a0 					; A0 = Pointer to the chosen VARIABLENAME
	cmp.w 	#TypeStr,4(a0)
	beq.s 	.pushStr
	cmp.w 	#TypeNewStr,4(a0)
	beq.s 	.pushStr
	bra 	ERROR                                                                                        ; NOT YET HANDLED !! ERROR HANDLER
.pushStr:
	Move.l 	StackAdr(a5),a3 		; A3 = Direct Data Stacks
	Move.l 	a0,(a3)+				; (A3)+ = String VARIABLENAME pointer
	Move.l 	a3,StackAdr(a5) 		; Push New Stack Adress (A3) to StackAdr data
	movem.l  (sp)+,d0/a0-a3 		; Load registers from Amiga Stack
							ENDM

	
getLocalVarStringFromStack	MACRO
	movem.l 	d0/a0-a3,-(sp) 		; Save registers to amiga Stack
	Move.l 	StackAdr(a5),a3 		; A3 = Direct Data Stacks


	
	movem.l  (sp)+,d0/a0-a3 		; Load registers from Amiga Stack
		ENDM

