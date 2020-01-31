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

; ****************************************************************************************************************
; Here are the PARSER Macro availables for the Stack System
;
; LoadTempVarA4 TEMPVARID [MACRO] [INTERNAL]                   This macro is for internal use only. It is used by pushStatic... MACRO
; LoadGlobalVariableA1 GLOBALVARIABLENAME [MACRO] [INTERNAL]   Load the specified GLOBAL Variable pointer into A4
; LoadLocalVariableA4 GLOBALVARIABLENAME [MACRO] [INTERNAL]    Load the specified LOCAL Variable pointer into A4
; InternalPushA4String VARIABLENAME [MACRO] [INTERNAL]         This method is for internal use and is called by the pushLocalVarStringToStack and pushGlobalVarStringToStack methods
; InternalPushA4Integer VARIABLENAME [MACRO] [INTERNAL]        This method is for internal use and is called by the pushLocalVarIntegerToStack and pushGlobalVarIntegerToStack methods

; pushStaticStringToStack STRNGNAME, TEMPVARID [MACRO]         Push in the stack a String defined in a dc.b "zeString",0 using its label reference and a Temporar Variable Index
; pushLocalVarStringToStack VARIABLENAME [MACRO]               Push a local variable (TypeStr or TypeNewStr) into the direct data stack
; pushGlobalVarStringToStack VARIABLENAME [MACRO]              Push a global variable (TypeStr or TypeNewStr) into the direct data stack

; pushStaticIntegerToStack INTEGERVALUE, TEMPVARID [MACRO]     This method push a direct Integer into the stack using a temporar variable.
; pushLocalVarIntegerToStack VARIABLENAME [MACRO]              Push a local variable (TypeInt) into the direct data stack
; pushGlobalVarIntegerToStack VARIABLENAME [MACRO]             Push a global variable (TypeInt) into the direct data stack

; pushStaticFloatToStack STRINGFLOATVALUE, TEMPVARID [MACRO] [TODO]
; pushLocalVarFloatToStack VARIABLENAME [MACRO] [TODO]
; pushGlobalVarFloatToStack VARIABLENAME [MACRO] [TODO]

; These MACROS are NOT STACK ONES, they are fully PARSER MACRO :
; pushStaticStringToLocalVar STRNGNAME,VARIABLENAME [MACRO]    Push a static String directly into a local variable [NOT A STACK MACRO]
; pushStaticStringToGlobalVar STRNGNAME,VARIABLENAME [MACRO]    Push a static String directly into a Global variable [NOT A STACK MACRO]
; pushStaticStringToVarA4 [MACRO] [INTERNAL]                   This macro use the A4 loaded var to push a Static string In. It is used by pushStaticStringToLocalVar and pushStaticStringToGlobalVar methods.

; pushStaticIntegerToLocalVar, INTEGERVALUE, VARIABLENAME [MACRO] [TODO]
; pushStaticIntegerToGlobalVar, INTEGERVALUE, VARIABLENAME [MACRO] [TODO]
; pushStaticIntegerToVarA4 [MACRO] [INTERNAL] [TODO]

; pushStaticFloatToLocalVar STRINGFLOATVALUE, VARIBALENAME [MACRO] [TODO]
; pushStaticFloatToGlobalVar STRINGFLOATVALUE, VARIBALENAME [MACRO] [TODO]
; pushStaticFloatToVarA4 [MACRO] [INTERNAL] [TODO]


; getLocalStringVarFromStack VARIABLENAME [MACRO] [TODO]
; getGlobalStringVarFromStack VARIABLENAME [MACRO] [TODO]
; getLocalIntVarFromStack VARIABLENAME [MACRO] [TODO]
; getGlobalIntVarFromStack VARIABLENAME [MACRO] [TODO]

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

; ******************************************** InternalPushA4String
; InternalPushA4String VARIABLENAME [MACRO] [INTERNAL]         This method is for internal use and is called by the pushLocalVarStringToStack and pushGlobalVarStringToStack methods
InternalPushA4String       MACRO
    cmp.w     #TypeStr,4(a4)
    beq.s     .pushStr
    cmp.w     #TypeNewStr,4(a4)
    beq.s     .pushStr
    CastErrorID     VariableIsNotAString
.pushStr:
    Move.l     StackAdr(a5),a3         ; A3 = Direct Data Stacks
    Move.l     a4,(a3)+                ; (A3)+ = String pointer
    Move.l     a3,StackAdr(a5)         ; Push New Stack Adress (A3) to StackAdr data
            ENDM

; ******************************************** InternalPushA4Integer
; InternalPushA4Integer VARIABLENAME [MACRO] [INTERNAL]        This method is for internal use and is called by the pushLocalVarIntegerToStack and pushGlobalVarIntegerToStack methods
InternalPushA4Integer       MACRO
    cmp.w     #TypeInt,4(a4)
    beq.s     .pushStr
    CastErrorID     VariableIsNotAnInteger
.pushStr:
    Move.l     StackAdr(a5),a3         ; A3 = Direct Data Stacks
    Move.l     a4,(a3)+                ; (A3)+ = Integer pointer
    Move.l     a3,StackAdr(a5)         ; Push New Stack Adress (A3) to StackAdr data
            ENDM


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

; ********************************************
; Send a Local variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushLocalVarStringToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushLocalVarStringToStack    MACRO
    LoadLocalVariableA4    \1
    InternalPushA4String
                            ENDM

; ********************************************
; Send a global variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushLocalVarStringToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushGlobalVarStringToStack    MACRO
    LoadGlobalVariableA4    \1
    InternalPushA4String
                            ENDM



; ********************************************
; pushStaticIntegerToStack INTEGERVALUE, TEMPVARID [MACRO]          This method push a direct Integer into the stack using a temporar variable.
pushStaticIntegerToStack       MACRO
    LoadTempVarA4     \2
    Move.l     a4,a1                     ; A1 = Save TEMPVAR pointer from A4
    move.l     #\1,(a4)+                 ; Save directly the integer entered.
    move.w     #TypeStr,(a4)+             ; Save Static String type
    move.l     #-1,(a4)+                 ; Size = -1 (not evaluated)
    ; 2. push Direct Variables Stack
    Move.l     StackAdr(a5),a3         ; A4 = Direct Data Stacks
    move.l     a1,(a3)+                ; Push the Static String in the Stack
    move.l     a3,StackAdr(a5)         ; Update Stack
                        ENDM


; ********************************************
; Send a Local variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushLocalVarStringToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushLocalVarIntegerToStack    MACRO
    LoadLocalVariableA4    \1
    InternalPushA4Integer
                            ENDM

; ********************************************
; Send a global variable String to stack. A variable String is a variable with the one of the following formats:
; TypeStr in case of a Static String or TypeNewStr in the case of a string created using the method CreateDeleteString.
; This macro does not create the String, it just copy the String variable information in the Stack.
; This mean that the String data sent to the MACRO is the NAME of the Variable that stores the String
; pushLocalVarStringToStack VARIABLENAME [MACRO]    Push a variable (TypeStr or TypeNewStr) into the direct variables stack
pushGlobalVarIntegerToStack    MACRO
    LoadGlobalVariableA4    \1
    InternalPushA4Integer
                            ENDM

; ********************************************
; This MACRO directly send a static string defined in the source code with a label and a dc.b "zestring",0
; into a local variable.
; pushStaticStringToLocalVar STRNGNAME,VARIABLENAME [MACRO]    Push a static String directly into a local variable [NOT A STACK MACRO]
pushStaticStringToLocalVar    MACRO
    LoadLocalVariableA4     \2
    pushStaticStringToVar   \1
                            ENDM

; ********************************************
; This MACRO directly send a static string defined in the source code with a label and a dc.b "zestring",0
; into a local variable.
; pushStaticStringToGlobalVar STRNGNAME,VARIABLENAME [MACRO]    Push a static String directly into a Global variable [NOT A STACK MACRO]
pushStaticStringToGlobalVar    MACRO
    LoadGlobalVariableA4    \2
    pushStaticStringToVar   \1
                            ENDM
  
; ********************************************
; pushStaticStringToVarA4 [MACRO] [INTERNAL]    This macro use the A4 loaded var to push a Static string In. It is used by pushStaticStringToLocalVar and pushStaticStringToGlobalVar methods.
pushStaticStringToVarA4       MACRO
    cmp.w     #TypeStr,4(a4)             ; In case of static String, no need to delete it
    beq.s     .pushStr2
    cmp.w     #TypeNewStr,4(a4)          ; in case of dynamic one, it must be released before update
    beq.s      .pushStrRel
    CastErrorID     VariableIsNotAString
.pushStrRel:
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

