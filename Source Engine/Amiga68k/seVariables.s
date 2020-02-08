; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : variablesSystem_Macros         *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the methods to handle the Source Engine variables system.
; It is primarly devoted to be used by the parser MACRO to create datas in the main source code (global)
; and in procedures/function (local) for a fast and convenient access to datas.

; *****************************************************
; Datas types that can be used
; Available Variables Type Constant Bits values
bTypeInt		equ	0 		; Byte 0 for Integer 
bTypeFlt		equ 1		; Byte 1 for float
bTypeStr 		equ 2		; Byte 2 for Static String (dc.l)
bTypeNewStr		equ 3		; Byte 3 for String created with AllocMem (and that must be erased)
bTypeStakNewStr	equ 4		; Byte 4 Temporar New String (can be put to a variable without a real copy'n'paste)
bTypeDim		equ 8 		; Byte 8 for Dim (Integer, Float or String)
bTypeDynArr		equ 9 		; Byte 9 for Dynamic Array (Integer, Float or String)
bTypeMemBlock	equ 10		; Byte 10 for Memory Blocks (Exclusive)

; Available Variables Type Constant values
TypeInt			equ	2^bTypeInt
TypeFlt 		equ 2^bTypeFlt
TypeStr			equ 2^bTypeStr
TypeNewStr 		equ 2^bTypeNewStr
TypeStackNewStr	equ 2^bTypeStakNewStr
TypeDim			equ 2^bTypeDim
TypeDynArr		equ	2^bTypeDynArr
TypeMemBlock	equ 2^bTypeMemBlock

; sePushIntToGlobalVar 						Global.VariableD1(.Integer/.Float).optionnalIndex(D2) = D0.Int
; sePushIntToLocalVar 						 Local.VariableD1(.Integer/.Float).optionnalIndex(D2) = D0.Int
; sePushFltToGlobalVar 						Global.VariableD1(.Integer/.Float).optionnalIndex(D2) = D0.Flt
; sePushFltToLocalVar 						 Local.VariableD1(.Integer/.Float).optionnalIndex(D2) = D0.Flt
; sePushFltStrToGlobalVar					Global.VariableD1(.Integer/.Float).optionnalIndex(D2) = D0.Str
; sePushFltStrToLocalVar					 Local.VariableD1(.Integer/.Float).optionnalIndex(D2) = D0.Str

; ---------------------------------------------------------------------------------------------
; This method send a direct Integer into a Global variable (Integer/Float)
; ---------------------------------------------------------------------------------------------
; INPUT : D0 = Integer Value, D1 = LocalVar, (optional D2 = Local Var dim index)
sePushIntToGlobalVar:
	Move.l	GlobalVar(a5),a3 			; Load Global Variables Structure -> A3
	bra.s 	intPushIntToVar 			; Jump to the common method to push int to Global/Local Variable
; ---------------------------------------------------------------------------------------------
; This method send a direct Integer into a local variable (Integer/Float)
; ---------------------------------------------------------------------------------------------
; INPUT : D0 = Integer Value, D1 = LocalVar, (optional D2 = Local Var dim index)
sePushIntToLocalVar:
	Move.l	LocalVar(a5),a3 			; Load Local Variables Structure -> A3
intPushIntToVar:
	add.l 	d1,a3 						; A3 = Pointer to the Variable in the Local/Global structure
	move.w 	4(a3),d1 					; D1 = Variable Type
	btst 	#bTypeInt,d1 				; Check if variable is Integer
	beq.s	.p2 						; YES -> Jump .p2 (No converstion from Integer data To Float)
	btst	#bTypeFlt,d1 				; Check if Variable if Float
	bne.s 	.notACompatibleVarType 		; NO -> Variable is not Integer not Float -> Error NOT COMPATIBLE TYPE
	bsr 	privConvertIntToFlt 		; VariableType = Float -> Convert Float to Integer
.p2:
	and.w 	#TypeDim+TypeDynArr,d1 		; Check if current variable is a Static or Dynamic Array
	beq.s 	.p3 						; If Result = 0 -> Not an array -> Jump .p3
	move.l  (a3),a3 					; Var is an array so we load the Array pointer -> A3
	lsl.l	#2,d2 						; D2*4 to be .l pointer to the position in the array
	add.l	d2,a3 						; A3 = Pointer to the Index D2 of the Local Var
.p3:
	Move.l  d0,(a3) 					; Finally push the integer in the data
	rts

; ---------------------------------------------------------------------------------------------
; This method send a direct Floating number into a Global variable (Integer/Float)
; ---------------------------------------------------------------------------------------------
; INPUT : D0 = Floating number Value, D1 = LocalVar, (optional D2 = Local Var dim index)
sePushFltToGlobalVar:
	Move.l	GlobalVar(a5),a3 			; Load Global Variables Structure -> A3
	bra.s	intPushFltToVar			; Jump to the common method to push float to Global/Local Variable
; ---------------------------------------------------------------------------------------------
; This method send a direct Floating number into a local variable (Integer/Float)
; ---------------------------------------------------------------------------------------------
; INPUT : D0 = Floating number Value, D1 = LocalVar, (optional D2 = Local Var dim index)
sePushFltToLocalVar:
	Move.l	LocalVar(a5),a3 			; Load Local Variables Structure -> A3
intPushFltToVar:
	add.l 	d1,a3 						; A3 = Pointer to the target variable
	btst	#bTypeFlt,d1 				; Check if Variable if Float
	beq.s	.p4		                    ; YES -> Direct sent
	btst 	#bTypeInt,d1 				; Check if variable is Integer
	bne.s 	.notACompatibleVarType 		; NO -> no int nor float -> Error
	bsr 	privConvertFltToInt
.p4:
	and.w 	#TypeDim+TypeDynArr,d1 		; Check if current variable is a Static or Dynamic Array
	beq.s 	.p5 						; If Result = 0 -> Not an array -> Jump .p3
	move.l  (a3),a3 					; Var is an array so we load the Array pointer -> A3
	lsl.l	#2,d2 						; D2*4 to be .l pointer to the position in the array
	add.l	d2,a3 						; A3 = Pointer to the Index D2 of the Local Var
.p5:
	Move.l  d0,(a3)
	rts

; ---------------------------------------------------------------------------------------------
; This method send a direct String (number or text) into a Global variable (Integer/Float)
; ---------------------------------------------------------------------------------------------
; INPUT : D0 = String, D1 = LocalVar, (optional D2 = Local Var dim index)
sePushStrToGlobalVar:
	Move.l	GlobalVar(a5),a3
	bra.s 	intPushStrToVar
; ---------------------------------------------------------------------------------------------
; This method send a direct String (number or text) into a local variable (Integer/Float)
; ---------------------------------------------------------------------------------------------
; INPUT : D0 = String, D1 = LocalVar, (optional D2 = Local Var dim index)
sePushStrToLocalVar:
	Move.l	LocalVar(a5),a3
intPushStrToVar:
	add.l 	d1,a3 						; A3 = Pointer to the target variable
	move.l  d1,d3 						; D3 = D1 = Variable Type
	and.l 	#TypeStr+TypeNewStr+TypeStackNewStr,d3 ; Filter D3 to check if it uses any of the String Type
	bne.s 	.p6 						; YES it is a String -> No Conversion required -> jump .p6
	btst 	#bTypeInt,d1 				; Otherwise, is the variable Type Integer ?
	bne.s 	.p8 						; NO -> Jump to .p8
	jsr 	privConvertStrToInt 		; YES -> Try to convert String to Integer
.p8:
	btst 	#bTypeFlt,d1 				; Otherwise, is the variable Type Floating Number ?
	bne.s 	.notACompatibleVarType 		; NO -> Unknown Variable Type ERROR
	jst 	privConvertStrToFlt 		; YES -> Try to convert String to Floating Number
.p6:
	and.w 	#TypeDim+TypeDynArr,d1 		; Check if current variable is a Static or Dynamic Array
	beq.s 	.p7 						; If Result = 0 -> Not an array -> Jump .p3
	move.l  (a3),a3 					; Var is an array so we load the Array pointer -> A3
	lsl.l	#2,d2 						; D2*4 to be .l pointer to the position in the array
	add.l	d2,a3 						; A3 = Pointer to the Index D2 of the Local Var
.p7:
	Move.l  d0,(a3)
	rts

	privConvertStrToFlt

; *********************************************************************************************
; Generic error handling for incompatible data types.
.notACompatibleVarType:
    CastErrorID     NotACompatibleVarType      ; CAST ERROR
