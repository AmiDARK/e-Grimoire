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
; seGlobDataReset                             ; // Start setup of Global data structure
; addGlobVariable VARNAME                     ; // Add a new Primitive Variable in the global data structure
; addGlobCpxVariable VARNAME                 ; // Add a new Complex variable (arrays) in the Global data Structure
; endGlobDatas                                ; // Finalize the global data structure
; buildGlobalDatas                             ; // Allocate memory for the global data structure -> globalDatas(a5)
; DeleteGlobal                                 ; // Remove from memory the global Data Structure and clear globalDatas(a5)
; addGlobStaticString LOCALNAME, VARNAME    ; // Add the static string representation to use for a global variables

; *****************************************************************************************************************************
; 2. MACROS for Local Variables Data Structure :
;-----------------------------------------------
; selocalDataReset LOCALNAME                ; // Start setup of a local data structure
; addLocVariable LOCALNAME,VARNAME             ; // Add a new Primitive Variable in the global data structure
; addLocCpxVariable LOCALNAME,VARNAME         ; // Add a new Complex variable (arrays) in the Global data Structure
; endLocDatas LOCALNAME                        ; // Finalize the global data structure
; buildLocalDatas                             ; // Allocate memory for the global data structure -> globalDatas(a5)
; DeleteLocal                                 ; // Remove from memory the current Local data Structure, and push the previous one in -> localDatas(a5)
; addLocStaticString LOCALNAME, VARNAME     ; // Add the static string representation to use for a local variable
; LOCALNAME = Name of the Local Variables Data Structure (can be the name of the procedure/function for example)

; *****************************************************************************************************************************
; 3. MACROS for Procedures and Functions :
;-----------------------------------------------
; Procedure PROCEDURENAME                     ; // Add the header for a new "Procedure" of "Function"
; Function PROCEDURENAME                     ; // Add the header for a new "Procedure" of "Function"
; Label LABELNAME                            ; // Add a new Label that can be called using GOTO or GOSUB
; EndProcedure                                 ; // Add the closure of a Procedure that release Local Data Structure memory. Before calling EndProcedure, the data returned must be pushed in the Stack
; CallProcedure PROCEDURENAME                ; // Call a procedure using its name, before calling a procedure, parameters it needs must be pushed in the Stack (reverse order)
; Gosub LABELNAME                             ; // do a GOSUB to a LABELNAME (will require a RETURN to come back)
; Goto LABELNAME                             ; // do a simple GOTO jump to a LABELNAME (No return as no return can be done)
; Return                                     ; // do a RETURN to go back to the initial GOSUB call, or to the initial Procedure call. if called from a procedure, the data returned must be pushed in the Stack


; *************************************************************** Internal Variables Counter
; 1.1 This macro reset data structure counter
; It must be used to initialize a new local/global data structure (before the 1st data of the structure)
seGlobDataReset     MACRO
varCount    SET 0
    buildGlobalDatas             ; Create data structure. Equates are handled before compilation so they are defined when code run at this position
    loadGlobalDatas a3             ; Load global datas into A4 so all data can be allocated at creation
                    ENDM

; *****************************************************
; 1.2 This macro insert a single integer in the GLOBAL data system
addGlobIntVariable        MACRO                 ; Add a new Integer variable in the Global Datas Structure
varCount     SET     varCount-6                 ; Any data as they re direct or pointer uses 6 bytes.
gl\1         equ     varCount                 ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
            move.w  #TypeInt,gl\1+4(a3)        ; Setup the Global variable as Integer variable
            move.l     #\2,gl\1(a3)             ; Set the direct value of the Integer variable
                    ENDM

; *****************************************************
; 1.3 This macro insert a single float in the GLOBAL data system
AddGlobalFloatVariable    MACRO                 ; Add a new Float number variable in the Global Datas Structure
varCount     SET     varCount-6                 ; Any data as they re direct or pointer uses 6 bytes.
gl\1         equ     varCount                 ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
            move.w  #TypeFlt,gl\1+4(a3)     ; Setup the Global variable as Floating number variable.
            lea.l    glStr\1,a0                 ; Load the pointer of the String representation of the static floating number value into A0
            bsr     privConvertStrToFlt     ; Call String to Floating number conversion method. Do not use stack but direct datas into A0.str -> D0.flt
            move.l     d0,gl\1(a3)             ; Set the floating number variable value.
            bra.s    glSte\1                 ; Jump to the end of the variable setup
glStr\1:    dc.b    \2,0                     ; Area where the string representation of the static floating number will be inserted
            EVEN
glSte\1:                                     ; End of the floating number variable creation and setup
                    ENDM

; *****************************************************
; 1.4 This macro insert a single string in the GLOBAL data system
AddGlobalStringVariable    MACRO                 ; Add a new String variable in the Global Datas Structure
varCount     SET     varCount-6                 ; Any data as they re direct or pointer uses 6 bytes.
gl\1         equ     varCount                 ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
            move.w  #TypeStr,gl\1+4(a3)        ; Setup the global variable as a String variable with static content (dc.b)
            lea.l    glStr\1,a0                 ; Load the pointer of the static string content into A0
            move.l     a0,gl\1(a3)                ; Save the pointer of the static String in the variable datas
            bra.s    glSte\1                 ; Jump to the end of the variable setup
glStr\1:    dc.b    \2,0                     ; Area where the Static String will be inserted for use in the String variable
            EVEN
glSte\1:                                     ; End of the String variable creation and setup
                    ENDM


; *****************************************************
; 1.7 This macro terminate the data structure counter and affect its size to a variable
endGlobDatas         MACRO
glblSize:         equ    varCount                 ; End of the Global Data Structure setup.
                    ENDM

; *****************************************************
; 1.8 Allocate the data in memory -> Output = A0
buildGlobalDatas MACRO                         ; This MACRO is now directly called by the "seGlobDataReset" MACRO to simplify the PARSER conversion job.
    tst.l     globalDatas(a5)
    beq.s    bgdOk
    CastErrorID globalDataDefinedTwice
bgdOk:
    Move.l     #glblSize,d0                    ; D0 = Memory size
    bsr.w     AllocClrFastMem                 ; Alloc Cleared Fast Mem
    move.l     a0,globalDatas(a5)                 ; Save pointer to the GlobalDatas Structure 
    move.l     #glblSize,globalSize(a5)         ; Save Global Data Structure size in the internal engine data structure object "globalSize"
                    ENDM

; *****************************************************
; 1.9 Clear the global Variables.
DeleteGlobal     MACRO
    move.l         globalDatas(a5),a0
    Move.l         #globalSize,d0
    exeCall     FreeMem
    Clr.l         globalDatas(a5)
                ENDM

; *****************************************************
; 1.7 Add the static string to the string buffer. Used to setup a globalVariable string datas from direct String input
addGlobStaticString    MACRO
glob/1:
    dc.b    \2, 0
                    ENDM

; *****************************************************
; 1.8 Load Global Datas into A4 register
loadGlobalDatas        MACRO
    move.l     globalDatas(a5),\1
                    ENDM

; *************************************************************** Internal Variables Counter
; 2.1 This macro reset data structure counter
; It must be used to initialize a new local data structure 
selocalDataReset     MACRO
varlCount    SET 0
addlVariable     \1,prev_\1
addlVariable     \1,next_\1
addlVariable    \1,finalSize
                ENDM

; *****************************************************
; 2.2 This macro insert a single integer, float or string in the local data system
addLocVariable    MACRO
varlCount     SET varlCount-6             ; Any data as they re direct or pointer uses 6 bytes.
\1\2:         equ varlCount                 ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
                ENDM

; *****************************************************
; 2.3 This macro insert a single String or a dimensionned (static or dynamic) integer, float or string in the local data system
addLocCpxVariable    MACRO
varCount     SET varlCount-10             ; Any data as they re direct or pointer uses 6 bytes.
\1\2:         equ varlCount                 ; 4 bytes = data/pointer itself + 2 bytes = data type identifier + 4 Bytes dim/array size
                    ENDM

; *****************************************************
; 2.4 This macro terminate the data structure counter and affect it s size to a variable
endLocDatas        MACRO
\1_Size:         equ    varlCount
                ENDM

; *****************************************************
; 2.5 Allocate the data in memory -> Output = A0
buildLocalDatas MACRO
    Move.l     #\1_size,d0                ; D0 = Memory size
    bsr.w     AllocClrFastMem
    move.l     #\1_Size,8(a0)             ; Save final structure size inside the memory itself
    move.l     localDatas(a5),(a0)     ; A0.prev = previous local variables
    cmp.l     #0,(a0)                 ; If no previous local variables is available
    beq.s     .bld1                     ; then Jump -> bld1
    move.l     (a0),a1                 ; A1 = previous local variables
    move.l     a0,4(a1)                  ; A1.Next = A0
.bld1:
    move.l a0,localDatas(a5)
                ENDM

; *****************************************************
; 2.6 Clear the current local Variables.
DeleteLocal     MACRO
    move.l         localDatas(a5),a1     ; A1 = Memory block
    cmp.l         #0,a1                 ; No memory block ?
    beq.s        .noLD                 ; -> Jump .noLD
    Move.l         (a1),localDatas(a5)    ; A5 = A1.Prev = Previous local block
    Move.l         8(a1),d0             ; D0 = Memory block size to remove
    exeCall     FreeMem
.noLD:
                ENDM

; *****************************************************
; 2.7 Add the static string to the string buffer. Used to setup a localVariable string datas from direct String input
addLocStaticString    MACRO
/1/2:
    dc.b    \2, 0
                    ENDM

; *****************************************************
; 3.1 Start a new procedure or function 
Procedure         MACRO
proc_\1:
                ENDM

; *****************************************************
; 3.2 Start a new procedure or function 
Function         MACRO
proc_\1:
                ENDM

; *****************************************************
; 3.3 Add a new label
Label         MACRO
lab_\1:
                ENDM

; *****************************************************
; 3.4 End a procedure or function
EndProcedure     MACRO
    sub.w     #1,procedureDepth(a5)             ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    bpl.s    .ok
    CastErrorID        TooMuchEndProcedureReached
.ok:
    DeleteLocal
    rts
                ENDM

; *****************************************************
; 3.5 call a procedure of function
callProcedure    MACRO
    add.w     #1,procedureDepth(a5)             ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    cmp.w    #16384,procedureDepth(a5)
    blt.s    .ok
    CastErrorID        TooMuchProcedureCallsWithoutReturn
    bsr.l     proc_\1
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
