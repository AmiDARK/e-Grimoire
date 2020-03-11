; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.02.12              *
; * Version : 1.0                         *
; * File : variablesSystem PARSER MACROs  *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the macro to handle the Source Engine global and locales variables system.
; It is primarly devoted to be used by the parser to create datas in the main source code (global)
; and in procedures/function (local) for a fast and convenient access to datas.
; Support for multi-depth local variables is now available.

;
; TO DO :
; - Add EndProcedure that return Int/Float/String/Dynamic Array
; - Add Return (from procedure) that return Int/Float/String/Dynamic Array
; - Check which cases need to create a copy of the variables and which one not when pushing variable to Stack.

; *****************************************************************************************************************************
; 1. MACROS for Global Variables Data Structure :
;------------------------------------------------
; seGlobDataReset                                      ; // Start setup of Global data structure
; setInteger VARNAME,VALUE                             ; // Add a new Primitive Integer variable in the Global Data Structure
; setFloat VARNAME,VALUE(.str)                         ; // Add a new Primitive Floating Number variable in the GDS. Static String is entered directly 
; setStaticString VARNAME,VALUELABEL                   ; // Add a new Primitive Floating Number variable in the GDS. Static String must be defined manually with a label + dc.b
; setString VARNAME,<"STRING">                         ; // Add a new Primitive Floating Number variable in the GDS. Static String must be defined manually with a label + dc.b
; endGlobDatas                                         ; // Finalize the global data structure
; buildGlobalDatas                                     ; // Allocate memory for the global data structure -> globalDatas(a5)
; DeleteGlobal                                         ; // Remove from memory the global Data Structure and clear globalDatas(a5)
; loadGlobalDatas AReg                                 ; // Load global Datas in an address Register
; getGlobalData VarNAME, DestVar_DReg, DestVarType_DReg; // Load a global variable in registes. Only Integer and Float are copied. String are clones of the original ones.

; *****************************************************************************************************************************
; 3. MACROS for Procedures and Functions :
;-----------------------------------------------
; Label LABELNAME                                      ; // Add a new Label that can be called using GOTO or GOSUB
; Gosub LABELNAME                                      ; // do a GOSUB to a LABELNAME (will require a RETURN to come back)
; Goto LABELNAME                                       ; // do a simple GOTO jump to a LABELNAME (No return as no return can be done)
; Return                                               ; // do a RETURN to go back to the initial GOSUB call, or to the initial Procedure call. if called from a procedure, the data returned must be pushed in the Stack

    include     "seVariablesType.asm"

; *****************************************************
; 1.8 Prepare the global Variables.

buildGlobalVariables MACRO
    ; ******************************** 1nd compiler PASS
varCount        SET 0
    ; ******************************** 2nd compiler PASS
            LoadSys a5                                 ; Be sure that Internal System Structure is loaded into a5
globalDatasBuild:
            move.l  globalDatas(a5),d0
            tst.l   d0
            beq.s   .bgdNullIsOk
            CastErrorID globalDataDefinedTwice
.bgdNullIsOk:
            Move.l  #glblSize,d1                       ; D1 = Memory size
            tst.l   d1                                 ; Are some variables defined ?
            beq.s   .bgdEnd                            ; No global variables at all.
            ; Will now affect the next slot from WholeVariablesBuffer for the global variables structure
            move.l  fvbPos(a5),d0                      ; D0 = Next free position for variables group.
            move.l  d0,globalDatas(a5)                 ; Save pointer to the GlobalDatas Structure 
            move.l  d1,globalSize(a5)                  ; Save Global Data Structure size in the internal engine data structure object "globalSize"
            add.l   d1,d0                              ; Moves D0 to the next free starting position for a variables group
            move.l  d0,fvbPos(a5)                      ; fvbPos(a5) = position for the next variables group.
;            move.l  fullVarBuffer(a5),d1
;            add.l   #varBufferSize,d1                  ; d1 = Position of the last byte of memory of the WholeVariablesBuffer
;            cmp.l   d1,d0
;            blt.s   .bgdEnd
;            CastErrorID WholeVariablesBufferExceeded
            loadGlobalDatas a3                         ; Load global datas into A4 so all data can be allocated at creation
.bgdEnd:
                    ENDM

; *****************************************************
; 1.2 This macro insert a single integer in the GLOBAL data system
setGlobalInteger          MACRO                        ; Add a new Integer variable in the Global Datas Structure
    ; ******************************** 1nd compiler PASS
gl\1        equ     varCount                           ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varCount    SET     varCount+6                         ; Any data as they re direct or pointer uses 6 bytes.
    ; ******************************** 2nd compiler PASS
gl\1labl:
            loadGlobalDatas a3                         ; Load global datas into A4 so all data can be allocated at creation
            move.w  #TypeInt,gl\1+4(a3)                ; Setup the Global variable as Integer variable
            move.l  #\2,gl\1(a3)                       ; Set the direct value of the Integer variable
                    ENDM

; *****************************************************
; 1.3 This macro insert a single float in the GLOBAL data system
setGlobalFloat            MACRO                        ; Add a new Float number variable in the Global Datas Structure
    ; ******************************** 1nd compiler PASS
gl\1        equ     varCount                           ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varCount    SET     varCount+6                         ; Any data as they re direct or pointer uses 6 bytes.
    ; ******************************** 2nd compiler PASS
gl\1labl:
            loadGlobalDatas a3                         ; Load global datas into A4 so all data can be allocated at creation
            move.w  #TypeFlt,gl\1+4(a3)                ; Setup the Global variable as Floating number variable.
            lea.l   glStr\1(pc),a0                     ; Load the pointer of the String representation of the static floating number value into A0
            bsr     privConvertStrToFlt                ; Call String to Floating number conversion method. Do not use stack but direct datas into A0.str -> D0.flt
            move.l  d0,gl\1(a3)                        ; Set the floating number variable value.
            bra.s   glSte\1                            ; Jump to the end of the variable setup
glStr\1:    dc.b    \2,0                               ; Area where the string representation of the static floating number will be inserted
            EVEN
glSte\1:                                               ; End of the floating number variable creation and setup
                    ENDM

; *****************************************************
; 1.4 This macro insert a single string in the GLOBAL data system
setGlobalStaticString     MACRO                        ; Add a new String variable in the Global Datas Structure
    ; ******************************** 1nd compiler PASS
gl\1        equ     varCount                           ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varCount    SET     varCount+6                         ; Any data as they re direct or pointer uses 6 bytes.
    ; ******************************** 2nd compiler PASS
gl\1labl:
            loadGlobalDatas a3                         ; Load global datas into A4 so all data can be allocated at creation
            move.w  #TypeStr,gl\1+4(a3)                ; Setup the global variable as a String variable with static content (dc.b)
            lea.l   \2,a0                              ; Load the pointer of the static string content into A0
            move.l  a0,gl\1(a3)                        ; Save the pointer of the static String in the variable datas
                    ENDM

setGlobalString           MACRO                        ; Add a new String variable in the Global Datas Structure
    ; ******************************** 1nd compiler PASS
gl\1        equ     varCount                           ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varCount    SET     varCount+6                         ; Any data as they re direct or pointer uses 6 bytes.
    ; ******************************** 2nd compiler PASS
gl\1labl:
            loadGlobalDatas a3                         ; Load global datas into A4 so all data can be allocated at creation
            move.w  #TypeStr,gl\1+4(a3)                ; Setup the global variable as a String variable with static content (dc.b)
            lea.l   glStr\1,a0                         ; Load the pointer of the static string content into A0
            move.l  a0,gl\1(a3)                        ; Save the pointer of the static String in the variable datas
            bra.s   glSte\1
glStr\1:    dc.b    \2,10,0
            EVEN
glSte\1:
                    ENDM

; *****************************************************
; 1.9 Clear the global Variables.
DeleteGlobal     MACRO
    ; ******************************** 1nd compiler PASS
glblSize    equ     varCount                      ; End of the Global Data Structure setup.
varBuffer   SET     varBuffer+varCount
    ; ******************************** 2nd compiler PASS
globalDatasDelete:
    move.l      globalDatas(a5),a1
    cmp.l       #0,a1
    beq.s       .noGlobalDataIsPossible
    Move.l      globalSize(a5),d1
    tst.l       d1
    bne.s       .globalDataSizeDefinedIsOk
    move.l      #glblSize,d1
    tst.l       d1
    bne.s       .globalDataSizeDefinedIsOk
    CastErrorID globalDataSetWithoutSize
.globalDataSizeDefinedIsOk:
    move.l      a1,fvbPos(a5)                          ; Removes GlobalDatas from fullVarBuffer by updating fvbPos pointer.
.noGlobalDataIsPossible:
    Move.l      #0,globalDatas(a5)                     ; Clear old registers
    move.l      #0,globalSize(a5)                      ; Clear old registers
                ENDM

; *****************************************************
; 1.10 Load Global Datas into an aX register
loadGlobalDatas MACRO
    move.l      globalDatas(a5),\1
    cmp.l       #0,\1
    bne.s       .lGB
    CastErrorID noGlobalDataDefined  
.lGB:
                ENDM

; *****************************************************
; 1.11 Load a global variable inside registers   getGlobalData VarName, Variable_DReg, VariableType_DReg
getGlobalData  MACRO
lgd\@-+:
    loadGlobalDatas a3
    clr.l       \3
    move.w      gl\1+4(a3),\3
    move.l      gl\1(a3),\2                            ; Load the Integer number into \2
    bra.s       .finiLoad
.er
    CastErrorID globalDataTypeNotRecognized
.finiLoad:
                ENDM


; *****************************************************
; 3.3 Add a new label
Label         MACRO
lab_\1:
                ENDM


; *****************************************************
; 3.6 add a GOSUB to a Label
Gosub             MACRO
    cmp.w     #0,procedureDepth(a5)             ; Check if we are inside a Procedure or Function
    beq.s    .ok                             ; NO -> Jump .ok
    CastErrorID        GosubNotAllowedFromInsideAProcedure
.ok:
    add.w     #1,gosubDepth(a5)
    cmp.w    #16384,gosubDepth(a5)
    blt.s    .ok2
    CastErrorID        TooMuchGosubCalledWithoutReturn
.ok2:
    bsr.l     lab_\1
                ENDM

; *****************************************************
; 3.7 add a GOTO to a label (must not be used on Procedure nor function)
Goto             MACRO
    cmp.w     #0,procedureDepth(a5)             ; Check if we are inside a Procedure or Function
    beq.s    .ok                             ; NO -> Jump .ok
    CastErrorID        GosubNotAllowedFromInsideAProcedure
.ok:
    bra.l     lab_\1
                ENDM

; *****************************************************
; 3.8 add a RETURN from a label (called with Gosub) or from inside a Procedure
Return             MACRO
    cmp.w     #0,procedureDepth(a5)             ; Check if we are inside a Procedure or Function
    beq.s    .fromGosub
    sub.w    #1,procedureDepth(a5)
    DeleteLocal
    rts
.fromGosub:
    sub.w     #1,gosubDepth(a5)
    bpl.s    .ok
    CastErrorID        TooMuchReturnReached
.ok:
    rts
                ENDM
