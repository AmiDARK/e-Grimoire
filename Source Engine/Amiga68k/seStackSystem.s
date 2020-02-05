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

; ******************************************************************************************************************************
;
; ------------------------------------------------------------------------------------------------------------------------------
; Here is a small description of how the PARSER should integrate variables in the Source Engine
; ------------------------------------------------------------------------------------------------------------------------------
; STRINGNAME.dc.b                      It is the STRING definition like : STRINGNAME: dc.b "MyStringContent",0
;                                      It is a reference to the direct static string that should be insered in the gameEngine.s file
;                                      just after the label "ParserStringArea:"
; TEMPVARID.str 				       It is the ID (integer number) to tell the MACRO you use a temporar var from range 0-15 TempVars
;                                      TempVars are necessary for static STRINGS to store variable in the good format before sending
;                                      them to the MACROS and Engine
; CurrentLocalVariables.VARIABLENAME   Represent the label name of a variable located in the current Locale variables stack (current Procedure/Function)
; GlobalVariables.VARIABLENAME         Represent the label name of a global variable of the source code.
; STACK                                Represent the communication stack to send variables in the Engine or to receive them from the Engine
;                                      push and STACK+ mean that the information (variable, direct data) will be inserted as a TEMPVAR in the STACK
;                                      pull and -STACK mean that the variable will be extracted from the STACK and put inside the chosen locale/global variable.
;
; ------------------------------------------------------------------------------------------------------------------------------
; These MACRO handles all the STRING needs.
; ------------------------------------------------------------------------------------------------------------------------------
; pushStaticStringToStack STRINGNAME, TEMPVARID [MACRO]                   Push STRINGNAME.dc.b -> TEMPVARID.Str -> STACK+
; pushStaticStringToLocalVar STRINGNAME,VARIABLENAME [MACRO]              Push STRINGNAME.dc.b -> CurrentLocalVariables.VARIABLENAME.Str
; pushStaticStringToGlobalVar STRINGNAME,VARIABLENAME [MACRO]             Push STRINGNAME.dc.b -> GlobalVariables.VARIABLENAME.Str
; pushLocalVarStringToStack VARIABLENAME [MACRO]                          Push CurrentLovalVariables.VARIABLENAME.Str -> STACK+
; pushGlobalVarStringToStack VARIABLENAME [MACRO]                         Push GlobalVariables.VARIABLENAME/Str -> STACK+
; pushStaticStringToVarA4 [MACRO] [INTERNAL]                              Push STRINGNAME.dc.b -> A4.VARIABLE [Clearing previous String if required)]
; InternalPushA4String VARIABLENAME [MACRO] [INTERNAL]                    Push AReg.A4.VARIABLE -> STACK+
; getLocalStringVarFromStack VARIABLENAME [MACRO] [TODO]                  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Str
; getGlobalStringVarFromStack VARIABLENAME [MACRO] [TODO]                 Pull -STACK -> GlobalVariables.VARIABLENAME.Str
;
; ------------------------------------------------------------------------------------------------------------------------------
; These MACRO handles all the INTEGER numbers needs.
; ------------------------------------------------------------------------------------------------------------------------------
; pushStaticIntegerToStack INTEGERVALUE, TEMPVARID [MACRO]                Push DIRECT.Int -> TEMPVARID.Int -> STACK+
; pushStaticIntegerToLocalVar INTEGERVALUE, VARIABLENAME [MACRO]          Push DIRECT.InT -> CurrentLocalVariables.VARIABLENAME.Int
; pushStaticIntegerToGlobalVar INTEGERVALUE, VARIABLENAME [MACRO]         Push DIRECT.Int -> GlobalVariables.VARIABLENAME.Int
; pushLocalVarIntegerToStack VARIABLENAME [MACRO]                         Push CurrentLocalVariables.VARIABLENAME.Int -> STACK+ 
; pushGlobalVarIntegerToStack VARIABLENAME [MACRO]                        Push GlobalVariables.VARIABLENAME.Int -> STACK+
; pushStaticIntegerToVarA4 [MACRO]                             [INTERNAL] Push Direct.Int -> A4.VARIABLE
; InternalPushA4Integer VARIABLENAME [MACRO]                   [INTERNAL] Used by pushLocalVarIntegerToStack and pushGlobalVarIntegerToStack methods
; getLocalIntVarFromStack VARIABLENAME [MACRO]                            Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Int
; getGlobalIntVarFromStack VARIABLENAME [MACRO]                           Pull -STACK -> GlobalVariables.VARIABLENAME.Int
;
; ------------------------------------------------------------------------------------------------------------------------------
; These MACRO handles all the FLOATING numbers needs.
; ------------------------------------------------------------------------------------------------------------------------------
; pushStaticFloatToStack STRINGFLOATVALUE, TEMPVARID [MACRO] [TODO]
; pushStaticFloatToLocalVar STRINGFLOATVALUE, VARIBALENAME [MACRO] [TODO]
; pushStaticFloatToGlobalVar STRINGFLOATVALUE, VARIBALENAME [MACRO] [TODO]
; pushLocalVarFloatToStack VARIABLENAME [MACRO] [TODO]
; pushGlobalVarFloatToStack VARIABLENAME [MACRO] [TODO]
; pushStaticFloatToVarA4 [MACRO] [INTERNAL] [TODO]
; getLocalFloatVarFromStack VARIABLENAME [MACRO] [TODO]
; getGlobalFloatVarFromStack VARIABLENAME [MACRO] [TODO]
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

; ******************************************** LoadGlobalVariableAREG
; LoadGlobalVariableAREG GLOBALVARIABLENAME AREG [MACRO] [INTERNAL]	Load the specified GLOBAL Variable pointer into A4
LoadGlobalVariableAREG		MACRO
	move.l	globalDatas(a5),\2
	add.l	#\1,\2 	; AReg\2 = Pointer to the chosen VARIABLENAME
    						ENDM

; ******************************************** LoadLocalVariableAREG
; LoadLocalVariableAREG GLOBALVARIABLENAME AREG [MACRO] [INTERNAL]	Load the specified GLOBAL Variable pointer into A4
LoadLocalVariableAREG		MACRO
	move.l	localDatas(a5),\2
	add.l	#\1,\2 	; AReg\2 = Pointer to the chosen VARIABLENAME
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

; ------------------------------------------------------------------------------------------------------------------------------
; These MACRO handles all the STRING needs.
; ------------------------------------------------------------------------------------------------------------------------------
; pushStaticStringToStack STRINGNAME, TEMPVARID [MACRO]                   Push STRINGNAME.dc.b -> TEMPVARID.Str -> STACK+ [2020.02.05]
; pushStaticStringToLocalVar STRINGNAME,VARIABLENAME [MACRO]              Push STRINGNAME.dc.b -> CurrentLocalVariables.VARIABLENAME.Str
; pushStaticStringToGlobalVar STRINGNAME,VARIABLENAME [MACRO]             Push STRINGNAME.dc.b -> GlobalVariables.VARIABLENAME.Str
; pushLocalVarStringToStack VARIABLENAME [MACRO]                          Push CurrentLovalVariables.VARIABLENAME.Str -> STACK+
; pushGlobalVarStringToStack VARIABLENAME [MACRO]                         Push GlobalVariables.VARIABLENAME/Str -> STACK+
; pushStaticStringToVarAREG STATICSTRING,AREG                  [Internal] Push STRINGNAME.dc.b -> A4.VARIABLE [Clearing previous String if required)] [2020.02.05]
; InternalPushA4String VARIABLENAME [MACRO]                    [Internal] Push AReg.A4.VARIABLE -> STACK+
; getLocalStringVarFromStack VARIABLENAME [MACRO] [TODO]                  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Str
; getGlobalStringVarFromStack VARIABLENAME [MACRO] [TODO]                 Pull -STACK -> GlobalVariables.VARIABLENAME.Str


; ******************************************** pushStaticStringToStack
; Send a static String to Stack. A Static String is a string defined in the source Code
; using dc.b "zeString", 0. It is different from a Dynamic String that was created using the method CreateDeleteString.
; it uses a temporar var defined by an integer ID from 0-15
; pushStaticStringToStack STRNGNAME, TEMPVARID [MACRO]         Push in the stack a String defined in a dc.b "zeString",0 using its label reference and a Temporar Variable Index
pushStaticStringToStack        MACRO
    LoadTempVarAREG     \2,A3
    move.l     \1,(a3)                 ; Save String pointer
    move.w     #TypeStr,4(a3)             ; Save Static String type
    move.l     #-1,6(a3)                 ; Size = -1 (not evaluated)
    ; 2. push Direct Variables Stack
    Move.l     StackAdr(a5),a4        ; A4 = Direct Data Stacks
    move.l     a3,(a4)+                ; Push the Static String in the Stack
    move.l     a4,StackAdr(a5)         ; Update Stack
                        ENDM

; ******************************************** pushStaticStringToLocalVar
; This MACRO directly send a static string defined in the source code with a label and a dc.b "zestring",0
; into a local variable.
; pushStaticStringToLocalVar STRNGNAME,VARIABLENAME [MACRO]    Push a static String directly into a local variable [NOT A STACK MACRO]
pushStaticStringToLocalVar    MACRO
    LoadLocalVariableAREG     \2,A4
    pushStaticStringToVarA4 \1
                            ENDM

; ******************************************** pushStaticStringToGlobalVar
; This MACRO directly send a static string defined in the source code with a label and a dc.b "zestring",0
; into a local variable.
; pushStaticStringToGlobalVar STRNGNAME,VARIABLENAME [MACRO]    Push a static String directly into a Global variable [NOT A STACK MACRO]
pushStaticStringToGlobalVar    MACRO
    LoadGlobalVariableA4    \2
    pushStaticStringToVarA4 \1
                            ENDM

; ******************************************** pushLocalVarStringToStack
; Send a Local variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushLocalVarStringToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushLocalVarStringToStack    MACRO
    LoadLocalVariableA4    \1
    InternalPushA4String
                            ENDM

; ******************************************** pushGlobalVarStringToStack
; Send a global variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushGlobalVarStringToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushGlobalVarStringToStack    MACRO
    LoadGlobalVariableA4    \1
    InternalPushA4String
                            ENDM

; ********************************************
; pushStaticStringToVarAREG STATICSTRING,AREG [MACRO] [INTERNAL]    This macro use the A4 loaded var to push a Static string In. It is used by pushStaticStringToLocalVar and pushStaticStringToGlobalVar methods.
pushStaticStringToVarAREG       MACRO
	IsAREGVariableString \2
    move.l  (\2),a1                      ; A1 = Pointer to the previous dynamic String (Variable AREG \2)
    cmp.l   #0,a1                        ; Check if variable is NULL pointer
    beq.s   .pushStr2                    ; if asked variables is NULL then no need for release.
    move.l   #-1,d0                      ; D0 = -1 to force the CreateDeleteString to deleteString
    bsr     CreateDeleteString           ; Delete the previous Dynamic String available in the VARIABLENAME
.pushStr2:
    move.l  \1,(\2) 					 ; Save String pointer
    move.w  #TypeStr,4(\2)               ; Update Variable Type To Static String
    move.l  #-1,6(\2)                    ; String Size is not evaluated
                        ENDM

; ******************************************** InternalPushA4String
; InternalPushA4String VARIABLENAME [MACRO] [INTERNAL]         This method is for internal use and is called by the pushLocalVarStringToStack and pushGlobalVarStringToStack methods
InternalPushA4String       MACRO
	IsA4VariableString
    Move.l     StackAdr(a5),a3         ; A3 = Direct Data Stacks
    Move.l     a4,(a3)+                ; (A3)+ = String pointer
    Move.l     a3,StackAdr(a5)         ; Push New Stack Adress (A3) to StackAdr data
            ENDM


; ******************************************** getLocalStringVarFromStack
; getLocalStringVarFromStack VARIABLENAME [MACRO] [TODO]                  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Str
getLocalStringVarFromStack  MACRO
    ; 2. Read Stack
    Move.l     StackAdr(a5),a3         ; A4 = Direct Data Stacks
    move.l     (a3),a1                 ; Pull the stack data in the A1 register
    sub.l      #4,a3
    move.l     a3,StackAdr(a5)         ; Update Stack
    Move.l     (a1)+,a2                 ; A2 = Variable (String) pointer
    move.w     (a1)+,d6                 ; D0 = Variable Type
    move.l     (a1)+,d7                 ; D1 = Size
    LoadGlobalVariableA4 \1             ; Load local variable into A4
    cmp.w     #TypeStr,d0
    beq.s     .updStatic
    cmp.w     #TypeNewStr,d0
    beq.s     .updDynamic
    CastErrorID     ValueIsNotAString   ; The variable available in the Stack is not a String
.updStatic:



    bra.s   .ende
.upDynamic:




.ende:
                ENDM






; ------------------------------------------------------------------------------------------------------------------------------
; These MACRO handles all the INTEGER numbers needs.
; ------------------------------------------------------------------------------------------------------------------------------
; pushStaticIntegerToStack INTEGERVALUE, TEMPVARID [MACRO]                Push DIRECT.Int -> TEMPVARID.Int -> STACK+
; pushStaticIntegerToLocalVar INTEGERVALUE, VARIABLENAME [MACRO]          Push DIRECT.InT -> CurrentLocalVariables.VARIABLENAME.Int
; pushStaticIntegerToGlobalVar INTEGERVALUE, VARIABLENAME [MACRO]         Push DIRECT.Int -> GlobalVariables.VARIABLENAME.Int
; pushLocalVarIntegerToStack VARIABLENAME [MACRO]                         Push CurrentLocalVariables.VARIABLENAME.Int -> STACK+ 
; pushGlobalVarIntegerToStack VARIABLENAME [MACRO]                        Push GlobalVariables.VARIABLENAME.Int -> STACK+
; pushStaticIntegerToVarA4 [MACRO]                             [INTERNAL] Push Direct.Int -> A4.VARIABLE
; InternalPushA4Integer VARIABLENAME [MACRO]                   [INTERNAL] Used by pushLocalVarIntegerToStack and pushGlobalVarIntegerToStack methods
; getLocalIntVarFromStack VARIABLENAME [MACRO]        					  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Int
; getGlobalIntVarFromStack VARIABLENAME [MACRO]                           Pull -STACK -> GlobalVariables.VARIABLENAME.Int

; ******************************************** pushStaticIntegerToStack
; pushStaticIntegerToStack INTEGERVALUE, TEMPVARID [MACRO]          This method push a direct Integer into the stack using a temporar variable.
pushStaticIntegerToStack       MACRO
    LoadTempVarA4     \2
    Move.l     a4,a1                     ; A1 = Save TEMPVAR pointer from A4
    move.l     #\1,(a4)+                 ; Save directly the integer entered.
    move.w     #TypeStr,(a4)+             ; Save Static String type
    move.l     #-1,(a4)+                ; Size = -1 (not evaluated)
    ; 2. push Direct Variables Stack
    Move.l     StackAdr(a5),a3         ; A4 = Direct Data Stacks
    move.l     a4,(a3)+                ; Push the Static String in the Stack
    move.l     a3,StackAdr(a5)         ; Update Stack
                        ENDM

; ******************************************** pushStaticIntegerToLocalVar
; pushStaticIntegerToLocalVar INTEGERVALUE, VARIABLENAME [MACRO] [TODO]  Push DIRECT.InT -> CurrentLocalVariables.VARIABLENAME.Int
pushStaticIntegerToLocalVar		MACRO
    LoadLocalVariableA4      \2
	pushStaticIntegerToVarA4 \1
								ENDM

; ******************************************** pushStaticIntegerToGlobalVar
; pushStaticIntegerToGlobalVar INTEGERVALUE, VARIABLENAME [MACRO] [TODO] Push DIRECT.Int -> GlobalVariables.VARIABLENAME.Int
pushStaticIntegerToGlobalVar		MACRO
    LoadGlobalVariableA4     \2
    pushStaticIntegerToVarA4 \1
								ENDM

; ******************************************** pushLocalVarIntegerToStack
; Send a Local variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushLocalVarStringToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushLocalVarIntegerToStack    MACRO
    LoadLocalVariableA4    \1
    InternalPushA4Integer
                            ENDM

; ******************************************** pushGlobalVarIntegerToStack
; Send a global variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushGlobalVarIntegerToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushGlobalVarIntegerToStack    MACRO
    LoadGlobalVariableA4    \1
    InternalPushA4Integer
                            ENDM

; ******************************************** pushStaticIntegerToVarA4
; pushStaticIntegerToVarA4 [MACRO] [INTERNAL]       					 Push Direct.Int -> A4.VARIABLE
pushStaticIntegerToVarA4			MACRO
	IsA4VariableInteger
	move.l 		#\1,(a4)
									ENDM

; ******************************************** InternalPushA4Integer
; InternalPushA4Integer VARIABLENAME [MACRO] [INTERNAL]        used by pushLocalVarIntegerToStack and pushGlobalVarIntegerToStack methods
InternalPushA4Integer       MACRO
    IsA4VariableInteger
    Move.l     StackAdr(a5),a3         ; A3 = Direct Data Stacks
    Move.l     a4,(a3)+                ; (A3)+ = Integer pointer
    Move.l     a3,StackAdr(a5)         ; Push New Stack Adress (A3) to StackAdr data
            ENDM

; ******************************************** getLocalIntVarFromStack
; getLocalIntVarFromStack VARIABLENAME [MACRO]       					  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Int
getLocalIntVarFromStack		MACRO
	LoadLocalVariableA4	\1
    IsA4VariableInteger
    move.l 		StackAdr(a5),a3         ; A3 = Direct Data Stacks
    Sub.l 		#4,a3
    move.l 		a3,StackAdr(a5)         ; Push New Stack Adress (A3) to StackAdr data
    cmp.w 		#TypeInt,4(a3)
    beq.s 		.pushInt2
    CastErrorID		ValueIsNotAnInteger
.pushInt2:
    Move.l 		(a3),(a4)               ; (A4).VARIABLE = (A3).VARIABLE
    clr.l		(a3)+
    clr.w		(a3)+
    clr.l		(a3)
    		ENDM
; ******************************************** getGlobalIntVarFromStack
; getGlobalIntVarFromStack VARIABLENAME [MACRO]                          Pull -STACK -> GlobalVariables.VARIABLENAME.Int
getGlobalIntVarFromStack		MACRO
	LoadGloballVariableA4	\1
	IsA4VariableInteger
    move.l 		StackAdr(a5),a3         ; A3 = Direct Data Stacks
    Sub.l 		#4,a3
    move.l 		a3,StackAdr(a5)         ; Push New Stack Adress (A3) to StackAdr data
    cmp.w 		#TypeInt,4(a3)
    beq.s 		.pushInt2
    CastErrorID		ValueIsNotAnInteger
.pushInt2:
    Move.l 		(a3),(a4)               ; (A4).VARIABLE = (A3).VARIABLE
    clr.l		(a3)+
    clr.w		(a3)+
    clr.l		(a3)
    		ENDM

  



; ------------------------------------------------------------------------------------------------------------------------------
; These MACRO handles all the FLOATING numbers needs.
; ------------------------------------------------------------------------------------------------------------------------------




