; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.28                     *
; * Last Update : 2020.01.31              *
; * Version : 0.2                         *
; * File : Stack System for Source Engine *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all MACRO that are used to handle the direct variables | parameters stack
;
; Amiga OS System Stack (a7 or sp) can be used this way :
;    movem.l     REGISTERS_LIST,-(sp)         To push registers inside Stack
;    movem.l     (sp)+,REGISTERS_LIST         to pull registers off/from the stack
;
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
; 0x0(aX).L : Pointer to the Single String or the Array
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
; LoadTempVarA4 TEMPVARID [MACRO] [INTERNAL]                   This macro is for internal use only. It is used by pushStatic... MACRO
; LoadGlobalVariableA1 GLOBALVARIABLENAME [MACRO] [INTERNAL]   Load the specified GLOBAL Variable pointer into A4
; LoadLocalVariableA4 GLOBALVARIABLENAME [MACRO] [INTERNAL]    Load the specified LOCAL Variable pointer into A4
; IsA4VariableInteger [MACRO]                       [Internal] Check if variable set at (A4) is an integer or not.
; IsA4VariableString [MACRO]                        [Internal] Check if variable set at (A4) is a string or not.
;
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
; pushStaticIntegerToLocalVar, INTEGERVALUE, VARIABLENAME [MACRO] [TODO]  Push DIRECT.InT -> CurrentLocalVariables.VARIABLENAME.Int
; pushStaticIntegerToGlobalVar, INTEGERVALUE, VARIABLENAME [MACRO] [TODO] Push DIRECT.Int -> GlobalVariables.VARIABLENAME.Int
; pushLocalVarIntegerToStack VARIABLENAME [MACRO]                         Push CurrentLocalVariables.VARIABLENAME.Int -> STACK+ 
; pushGlobalVarIntegerToStack VARIABLENAME [MACRO]                        Push GlobalVariables.VARIABLENAME.Int -> STACK+
; pushStaticIntegerToVarA4 [MACRO] [INTERNAL] [TODO]					  Push Direct.Int -> A4.VARIABLE
; InternalPushA4Integer VARIABLENAME [MACRO]                   [Internal] [INTERNAL NO DESCRIPTION. LATER]
; getLocalIntVarFromStack VARIABLENAME [MACRO] [TODO] 					  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Int
; getGlobalIntVarFromStack VARIABLENAME [MACRO] [TODO]                    Pull -STACK -> GlobalVariables.VARIABLENAME.Int
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
; LoadTempVarA4 TEMPVARID [MACRO]                   [Internal] This macro is for internal use only. It is used by pushStatic... MACRO
; LoadGlobalVariableA1 GLOBALVARIABLENAME [MACRO]   [Internal] Load the specified GLOBAL Variable pointer into A4
; LoadLocalVariableA4 GLOBALVARIABLENAME [MACRO]    [Internal] Load the specified LOCAL Variable pointer into A4
; IsA4VariableInteger [MACRO]                       [Internal] Check if variable set at (A4) is an integer or not.

; ******************************************** LoadTempVarA4
; LoadTempVarA4 TEMPVARID [MACRO] [INTERNAL]                   This macro is for internal use only. It is used by pushStatic... MACRO
LoadTempVarA4            MACRO
    Move.l     #\1,d0                     ; D0 = TEMPVARID index number
    Tst.l     d0                         ; Compare D0 & 0
    bpl     .pssts1
    CastErrorID     InvalidStackVarID
.pssts1:
    cmp.l     #16,d0                     ; Compare DO & 15
    blt     .pssts2
    CastErrorID     InvalidStackVarID
.pssts2:
    Move.l     TempVars(a4),a4          ; A4 = Pointer to temporar variables buffer
    Mulu     #10,d0                     ; D0 = D0 * 10 = D0 shift to Point to the chosen TEMPVAR
    add.l    d0.w,a4                    ; A4 = Pointer to the chosen TEMPVAR
                ENDMACRO

; ******************************************** LoadGlobalVariableA4
; LoadGlobalVariableA4 GLOBALVARIABLENAME [MACRO]                Load the specified GLOBAL Variable pointer into A5
LoadGlobalVariableA4       MACRO
    move.l     globalDatas(a4),a4
    add.l      #\1,a4                     ; A5 = Pointer to the chosen VARIABLENAME
                        ENDM

; ******************************************** LoadLocalVariableA4
; LoadLocalVariableA4 GLOBALVARIABLENAME [MACRO]                Load the specified GLOBAL Variable pointer into A5
LoadLocalVariableA4       MACRO
    move.l     localDatas(a4),a4
    add.l      #\1,a4                     ; A5 = Pointer to the chosen VARIABLENAME
                        ENDM

; ******************************************** IsA4VariableInteger
; IsA4VariableInteger [MACRO]                        [Internal] Check if variable set at (A4) is an integer or not.
IsA4VariableInteger		MACRO
    cmp.w     #TypeInt,4(a4)
    beq.s     .contVI
    CastErrorID     VariableIsNotAnInteger
.contVI:
						ENDM

; ******************************************** IsA4VariableString
; IsA4VariableString [MACRO]                        [Internal] Check if variable set at (A4) is a string or not.
IsA4VariableString		MACRO
    cmp.w     #TypeStr,4(a4)             ; In case of static String, no need to delete it
    beq.s     .contVS
    cmp.w     #TypeNewStr,4(a4)          ; in case of dynamic one, it must be released before update
    beq.s      .contVS
    CastErrorID     VariableIsNotAString
.contVS:
						ENDM

; ------------------------------------------------------------------------------------------------------------------------------
; These MACRO handles all the STRING needs.
; ------------------------------------------------------------------------------------------------------------------------------
; pushStaticStringToStack STRINGNAME, TEMPVARID [MACRO]                   Push STRINGNAME.dc.b -> TEMPVARID.Str -> STACK+
; pushStaticStringToLocalVar STRINGNAME,VARIABLENAME [MACRO]              Push STRINGNAME.dc.b -> CurrentLocalVariables.VARIABLENAME.Str
; pushStaticStringToGlobalVar STRINGNAME,VARIABLENAME [MACRO]             Push STRINGNAME.dc.b -> GlobalVariables.VARIABLENAME.Str
; pushLocalVarStringToStack VARIABLENAME [MACRO]                          Push CurrentLovalVariables.VARIABLENAME.Str -> STACK+
; pushGlobalVarStringToStack VARIABLENAME [MACRO]                         Push GlobalVariables.VARIABLENAME/Str -> STACK+
; pushStaticStringToVarA4 [MACRO]                              [Internal] Push STRINGNAME.dc.b -> A4.VARIABLE [Clearing previous String if required)]
; InternalPushA4String VARIABLENAME [MACRO]                    [Internal] Push AReg.A4.VARIABLE -> STACK+
; getLocalStringVarFromStack VARIABLENAME [MACRO] [TODO]                  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Str
; getGlobalStringVarFromStack VARIABLENAME [MACRO] [TODO]                 Pull -STACK -> GlobalVariables.VARIABLENAME.Str


; ******************************************** pushStaticStringToStack
; Send a static String to Stack. A Static String is a string defined in the source Code
; using dc.b "zeString", 0. It is different from a Dynamic String that was created using the method CreateDeleteString.
; it uses a temporar var defined by an integer ID from 0-15
; pushStaticStringToStack STRNGNAME, TEMPVARID [MACRO]         Push in the stack a String defined in a dc.b "zeString",0 using its label reference and a Temporar Variable Index
pushStaticStringToStack        MACRO
    LoadTempVarA4     \2
    Move.l     a4,a1                     ; A1 = Save TEMPVAR pointer from A4
    Lea.l     \1,a0
    move.l     a0,(a4)+                 ; Save String pointer
    move.w     #TypeStr,(a4)+             ; Save Static String type
    move.l     #-1,(a4)+                 ; Size = -1 (not evaluated)
    ; 2. push Direct Variables Stack
    Move.l     StackAdr(a5),a3         ; A4 = Direct Data Stacks
    move.l     a1,(a3)+                ; Push the Static String in the Stack
    move.l     a3,StackAdr(a5)         ; Update Stack
                        ENDM

; ******************************************** pushStaticStringToLocalVar
; This MACRO directly send a static string defined in the source code with a label and a dc.b "zestring",0
; into a local variable.
; pushStaticStringToLocalVar STRNGNAME,VARIABLENAME [MACRO]    Push a static String directly into a local variable [NOT A STACK MACRO]
pushStaticStringToLocalVar    MACRO
    LoadLocalVariableA4     \2
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
; pushStaticStringToVarA4 [MACRO] [INTERNAL]    This macro use the A4 loaded var to push a Static string In. It is used by pushStaticStringToLocalVar and pushStaticStringToGlobalVar methods.
pushStaticStringToVarA4       MACRO
	IsA4VariableString
    move.l  (a4),a1                      ; A1 = Pointer to the previous dynamic String
    cmp.l   #0,a1                        ; Check if variable is NULL pointer
    beq.s   .pushStr2                    ; if asked variables is NULL then no need for release.
    move.l   #-1,d0                      ; D0 = -1 to force the CreateDeleteString to deleteString
    bsr     CreateDeleteString           ; Delete the previous Dynamic String available in the VARIABLENAME
.pushStr2:
    Lea.l   \1,a1
    move.l  a1,(a4)+
    move.w  #TypeStr,(a4)+              ; Update Variable Type To Static String
    bsr     getStringSize
    move.l  d0,(a4)                    ; String Size is saved
                        ENDM

; ******************************************** InternalPushA4String
; InternalPushA4String VARIABLENAME [MACRO] [INTERNAL]         This method is for internal use and is called by the pushLocalVarStringToStack and pushGlobalVarStringToStack methods
InternalPushA4String       MACRO
	IsA4VariableString
    Move.l     StackAdr(a5),a3         ; A3 = Direct Data Stacks
    Move.l     a4,(a3)+                ; (A3)+ = String pointer
    Move.l     a3,StackAdr(a5)         ; Push New Stack Adress (A3) to StackAdr data
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
; getLocalIntVarFromStack VARIABLENAME [MACRO] [TODO] 					  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Int
; getGlobalIntVarFromStack VARIABLENAME [MACRO] [TODO]                    Pull -STACK -> GlobalVariables.VARIABLENAME.Int

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
; getLocalIntVarFromStack VARIABLENAME [MACRO] [TODO] 					  Pull -STACK -> CurrentLocalVariables.VARIABLENAME.Int
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
; getGlobalIntVarFromStack VARIABLENAME [MACRO] [TODO]                    Pull -STACK -> GlobalVariables.VARIABLENAME.Int
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
