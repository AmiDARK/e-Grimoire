; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.28                     *
; * Last Update : 2020.02.05              *
; * Version : 0.3                         *
; * File : Stack System for Source Engine *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all MACRO that are used to handle the direct variables | parameters stack
;
; Amiga OS System Stack (a7 or sp) can be used this way :
;    movem.l     REGISTERS_LIST,-(sp)         To push registers inside Stack
;    movem.l     (sp)+,REGISTERS_LIST         to pull registers off/from the stack
;
; TO DO : Optimise to put parts of MACRO inside methods to not copy'n'paste them several time in the source code.
;
; ***********************************************************************************
; The Source Engine Stack handle all the variables types handled by the Engine and that are defined in the seVariables.s file
;
; The stack is composed of pointers to variables (local, global, temporars)
; This mean that push the stack pointer to an Ax register will allow to get access to the variables using the set details :
;
; Integer & Float Direct Datas :
;-------------------------------
; 0x0(aX).L : Variable itself (Integer,Float) or its pointer (string)
; 0x4(aX).W : Variable type ( TypeFlt, TypeInt )
;
; Single String, or Static and Dynamic Dimensionned arrays of Integer, Float or String :
;---------------------------------------------------------------------------------------
; 0x0(aX).L : Pointer to the Single String or the Arra
; 0x4(aX).w : Variable type ( TypeStr, TypeNewStr, (TypeDim|TypeDynArr)+(TypeInt|TypeFlt|TypeStr)
; 0x6(aX).l : Length of Single String, or length of the Array
;
; It is simplest that what was previously planed and makes things easier to work with.
; To push a variable to store it in the stack use (aX is a A registers in range 1-4, a0 is pointer to the variable):
;    Move.l     StackAdr(A5),aX         ; A3 = Direct Data Stacks
;    move.l     a0,(aX)+                ; Push the Static String in the Stack
;    move.l     aX,StackAdr(a5)         ; Update Stack
; Now reading the variable type is easy:
;    Move.l     StackAdr(A5),aX         ; A3 = Direct Data Stacks
;    move.l     -(aX),a0                ; Push the Static String in the Stack
;    move.l     aX,StackAdr(a5)         ; Update Stack
;
;
; ****************************************************************************************************************
; Here are the PARSER Macro availables for the Stack System
;
; ------------------------------------------------------------------------------------------------------------------------------
; These MACROS are INTERNAL. They MUST NOT be used by the PARSER. In fact they are used by others MACROS available in this file.
; In this file, all the macro containing [INTERNAL] must not be used by the PARSER. They are used by other MACRO of the system.
; ------------------------------------------------------------------------------------------------------------------------------
; LoadTempVarAREG TEMPVARID AREG [MACRO]                   [Internal] This macro is for internal use only. It is used by pushStatic... MACRO [2020.02.05]
; LoadGlobalVariableAREG GLOBALVARIABLENAME AREG [MACRO]   [Internal] Load the specified GLOBAL Variable pointer into A4 [2020.02.05]
; LoadLocalVariableAREG GLOBALVARIABLENAME AREG [MACRO]    [Internal] Load the specified LOCAL Variable pointer into A4 [2020.02.05]
; IsAREGVariableInteger AREG [MACRO]                       [Internal] Check if variable set at (A4) is an integer or not. [2020.02.05]
; IsAREGVariableString AREG [MACRO]                        [Internal] Check if variable set at (A4) is a string or not. [2020.02.05]
; IsAREGVariableFloat AREG [MACRO]                         [Internal] Check if variable set at (A4) is a floating number or not. [2020.02.05]

; ******************************************** LoadTempVarAREG
; LoadTempVarAREG TEMPVARID AREG [MACRO] [INTERNAL]                   This macro is for internal use only. It is used by pushStatic... MACRO
LoadTempVarAREG				MACRO
	move.w	#10*\1,d0
	bpl.s	.ok
	cmp.l	#10*(MaxTempVarBuffer-1),d0
	blt.s	.ok
	CastErrorID		InvalidTempVarID
.ok
	move.l	TempVars(a5),\2 			; AREG\2 = Internal Source Engine Structure pointer
	add.l	d0.w,\2						; AREG\2 = Pointer to the specified TEMPVAR
							ENDM

; ******************************************** LoadGlobalVariableAREG
; LoadGlobalVariableAREG GLOBALVARIABLENAME AREG [MACRO] [INTERNAL]	Load the specified GLOBAL Variable pointer into A4
LoadGlobalVariableAREG		MACRO
	move.l	globalDatas(a5),\2
	add.l	#\1,\2 	; A5 = Pointer to the chosen VARIABLENAME
    						ENDM

; ******************************************** LoadLocalVariableAREG
; LoadLocalVariableAREG GLOBALVARIABLENAME AREG [MACRO] [INTERNAL]	Load the specified GLOBAL Variable pointer into A4
LoadLocalVariableAREG		MACRO
	move.l	localDatas(a5),\2
	add.l	#\1,\2 	; A5 = Pointer to the chosen VARIABLENAME
    						ENDM

; ******************************************** IsAREGVariableInteger
; IsAREGVariableInteger AREG [MACRO]                       [Internal] Check if variable set at (A4) is an integer or not.
IsAREGVariableInteger		MACRO
	cmp.w	#TypeInt,4(\1)
	beq.s	.ok
	CastErrorID		VariableIsNotAnInteger
.ok:
							ENDM

; ******************************************** IsAREGVariableString
; IsAREGVariableString AREG [MACRO]                        [Internal] Check if variable set at (A4) is a string or not.
IsAREGVariableString		MACRO
	cmp.w	#TypeStr,4(\1) 					; if variable is a Static String (located by a label with dc.b "zeString",0 )
	beq.s	.ok
	cmp.w	#TypeNewStr,4(\1) 				; if Variable is a Dynamic String (created with createDeleteString)
	beq.s	.ok
	cmp.w	#TypeStackNewStr,4(\1) 			; If variable is a String created from Stack or action with createDeleteString
	beq.s	.ok
	CastErrorID		VariableIsNotAString
.ok:
							ENDM

; ******************************************** IsAREGVariableFloat
; IsAREGVariableFloat AREG [MACRO]                         [Internal] Check if variable set at (A4) is a floating number or not.
IsAREGVariableFloat			MACRO
	cmp.w	#TypeFlt,4(\1)
	beq.s	.ok
	CastErrorID		VariableIsNotAnInteger
.ok:
							ENDM

