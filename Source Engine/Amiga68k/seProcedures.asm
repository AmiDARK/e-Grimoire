; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.02.12              *
; * Version : 1.0                         *
; * File : BASIC Procedures System        *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the required MACROS to create Procedures/Functions similar to BASICS ones.
; It also contain complete variable definition for Procedures/Functions

;
; selocalDataReset ProcNAME                            ; Called by 'Procedure' MACRO it start Local Data Structure definition.
; setLocalInteger ProcNAME, VarNAME, VALUE             ; Create a local Integer variable and set it to VALUE.
; setLocalInteger ProcNAME, VarNAME                    ; Create a local Integer variable and set it to #0.
; setLocalFloat ProcNAME, VarNAME, <'VALUE'>           ; Create a local Floating number variable and set it to VALUE.
; setLocalFloat ProcNAME, VarNAME                      ; Create a local Floating number variable and set it to default 0.0f.
; setLocalStaticString ProcNAME, VarNAME, LABEL        ; Create a local String variable using a LABEL containing the dc.b "String",10,0 definition.
; setLocalStaticString ProcNAME, VarNAME               ; Create a local String variable defined as en Empty string.
; setLocalString ProcNAME, VarNAME, <'VALUE'>          ; Create a local String variable using direct String entered using VALUE.
; setLocalString ProcNAME, VarNAME                     ; Create a local String variable defined as en Empty string.
; endLocDatas ProcNAME                                 ; Called by 'EndProcedure' MACRO, it closes the Local Data Structure definition.
; buildLocalDatas ProcNAME                             ; Called by 'Procedure' MACRO, it allocate memory to create the Local Data Structure.
; DeleteLocal ProcNAME                                 ; Called by 'EndProcedure' MACRO, it releases the memory previously allocated by BuildLocalDatas



    include     "seVariablesType.asm"
    include     "seStackSystem.asm"

loadLocalDatas       MACRO
    Move.l      localDatas(a5),\1
                     ENDM

loadLocalData        MACRO
    loadLoalDatas a3
    Move.l      l\1\2,\3
                     ENDM

; *************************************************************** Internal Variables Counter
; 1.1 This macro reset data structure counter
; It must be used to initialize a new local data structure 
selocalDataReset     MACRO
varl\1Count     SET 0
    LoadSys a5                                         ; Be sure that Internal System Structure is loaded into a5
    buildLocalDatas \1
    loadLocalDatas a3
    setLocalInteger \1,_prev
    setLocalInteger \1,_next
    setLocalInteger \1,_Size
                ENDM

; *****************************************************
; 1.2 This macro insert a single integer in the local data system : setLocalInteger ProcNAME, VarNAME(, VALUE)
setLocalInteger MACRO
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeInt,l\1\2+4(a3)                   ; Setup the Global variable as Integer variable
    IFNC        '\3',''                                ; Si la valeur est définit, alors on l'entre dans la variable
    move.l      #\3,l\1\2(a3)                           ; Set the direct value of the Integer variable
    ENDC
                ENDM

; *****************************************************
; 1.3 This macro insert a single float in the local data system : setLocalFloat ProcNAME, VarNAME(, <'VALUE'>)
setLocalFloat   MACRO                                  ; Add a new Float number variable in the Global Datas Structure
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeFlt,l\1\2+4(a3)                   ; Setup the Global variable as Floating number variable.
    lea.l       lStr\1\2,a0                            ; Load the pointer of the String representation of the static floating number value into A0
    bsr         privConvertStrToFlt                    ; Call String to Floating number conversion method. Do not use stack but direct datas into A0.str -> D0.flt
    move.l      d0,l\1\2(a3)                           ; Set the floating number variable value.
    bra.s       Ste\1\2                                ; Jump to the end of the variable setup
    IFNC        '\3',''
lStr\1\2:   dc.b    \3,10,0                            ; Area where the string representation of the static floating number will be inserted
    ELSEIF
lStr\1\2:   dc.b "0.0",10,0                            ; Create the default 0.0f floating number value (setup)
            EVEN
lSte\1\2:                                              ; End of the floating number variable creation and setup
                ENDM

; *****************************************************
; 1.4 This macro insert a string in the local data system : setLocalStaticString ProcName, VarNAME (, LABEL)
setLocalStaticString MACRO                             ; Add a new String variable in the Global Datas Structure
l\1\2       equ varl\1Count                            ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count   SET varl\1Count+6                        ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeStr,l\1\2+4(a3)                   ; Setup the global variable as a String variable with static content (dc.b)
    IFNC        '\3',''
    lea.l       \3,a0                                  ; Load the pointer of the static string content into A0
    move.l      a0,l\1\2(a3)                           ; Save the pointer of the static String in the variable datas
    ENDC
                ENDM

; *****************************************************
; 1.5 This macro insert a string in the local data system : setLocalString ProcName, VarNAME (, <'VALUE'>)
setLocalString  MACRO                                  ; Add a new String variable in the Global Datas Structure
gl\1\2      equ varl\1Count                            ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count   SET varl\1Count+6                        ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeStr,l\1\2+4(a3)                   ; Setup the global variable as a String variable with static content (dc.b)
    IFNC        '\3',''
    lea.l       lStr\1\2,a0                            ; Load the pointer of the static string content into A0
    move.l      a0,l\1\2(a3)                           ; Save the pointer of the static String in the variable datas
ENDC
    bra.s       lSte\1\2
    IFNC        '\3',''
lStr\1\2:
    dc.b         \3,10,0                               ; Insert String if available
    ENDC
                EVEN
lSte\1\2:
                ENDM

; *****************************************************
; 1.6 This macro terminate the data structure counter and affect it s size to a variable
endLocDatas        MACRO
\1Size      equ    varl\1Count
                   ENDM

; *****************************************************
; 1.7 Allocate the data in memory -> Output = A0
buildLocalDatas MACRO
build\1:
    Move.l      #\1Size,d0                             ; D0 = Memory size
    cmp.l       #0,d0
    beq.s       .bld2
    bsr         AllocClrFastMem
    move.l      d0,a0                                  ; A0 = D0 = Freshly created memblock
    move.l      #\1Size,8(a0)                          ; Save final structure size inside the memory itself
    move.l      localDatas(a5),(a0)                    ; A0.prev = localDatas(a5).previous local variables
    cmp.l       #0,(a0)                                ; If no previous local variables is available
    beq.s       .bld1                                  ; then Jump -> bld1
    move.l      (a0),a1                                ; A1 = previous local variables
    move.l      a0,4(a1)                               ; A1.Next = A0
.bld1:
    move.l      a0,localDatas(a5)                      ; The new localDatas(a5) = The new current one freshly created.
.bld2:
                ENDM


; *****************************************************
; 1.8 Clear the current local Variables.
DeleteLocal     MACRO
del\1:
    move.l      localDatas(a5),a1                      ; A1 = Memory block
    cmp.l       #0,a1                                  ; No memory block ?
    bne.s       .LocDel                                ; -> Jump .noLD
    CastErrorID noLocalDataToErase                     ; There should always be local datas to handle multi-depth-level datas (should contain at minima prev/next/size)
.LocDel:
    Move.l      (a1),localDatas(a5)                    ; A5 = A1.Prev = Previous local block (restore previous local variables to be current ones)
    Move.l      8(a1),d0                               ; D0 = Memory block size to remove
    bsr         FreeMm
                ENDM


; *****************************************************
; 2.1 Parameters type handled as Procedures Parameter.
; example : myProcedure ProcName,myInt,AsInteger,myFlt,AsFloat,myStr,AsString
AsInteger       MACRO
    setLocalInteger \1,\2,0
                ENDM
AsFloat       MACRO
    setLocalFloat \1,\2,"0.0"
                ENDM
AsString       MACRO
    setLocalString \1,\2,0
                ENDM

; *****************************************************
; 2.2 Internal MACRO used by 'Procedure' one to support parameters in Procedure
addParamSupport MACRO
        \3      \1,\2
paramCount SET paramCount+1
                ENDM

; *****************************************************
; 2.3 Internal MACRO used by 'Procedure' one to load parameters that were detected by addParamSuppor
loadParams      MACRO
loadParams_\1:
    Move.l      #\2,d7                                 ; D7 = Amount of params to load.
    tst.l       d7
    beq         lpEnd_\1                               ; No params ? YES -> Jump directly at the end
    sub.l       #1,d7                                  ; D7 -1 to count limits with positive value
    add.l       #18,a3                                 ; A3 = Pointer to 1st true parameter of the procedure
    move.l      d7,d0
    mulu        #6,d0                                  ; D0 = index (in bytes) of the last parameter to update
    add.l       d0,a3                                  ; A3 = Pointer to the Last parameter of the procedure.
lpLoop\1:
    sePullFromStack d5,d6                              ; D5 = Variable, D6 = VariableType
    cmp.w       #TypeStr,d6
    beq.s       .lClone
    cmp.w       #TypeNewStr,d6
    bne.s       .lpload
.lClone:
    move.l      d5,a0
    bsr         cloneString
    move.l      #TypeNewStr,d6
    move.l      a0,d5
.lpload:
    move.l      d5,(a3)
    move.w      d6,4(a3)
    sub.l       #6,a3                                  ; A3 = previous parameters (parameters are written in order and read in reversed order)
    sub.l       #1,d7                                  ; Next parameters ?
    bpl.w       lpLoop\1                               ; YES -> Continue reading from Stack.
lpEnd_\1:
                ENDM
; *****************************************************
; 2.4 Start a new procedure or function 
Procedure       MACRO
    bra         ep\1
proc_\1:
    add.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    cmp.w       #16384,procedureDepth(a5)
    blt.s       .ok
    CastErrorID TooMuchProcedureCallsWithoutReturn
.ok:
paramCount      SET 0
    ; Reset also handle the build of the local datas
    selocalDataReset \1                                ; Start to create local variables datas (should contains at mimum the next/prev/size variables )
    IFNC        '\2','' and '\3',''
        addParamSupport \1,\2,\3                           ; 1st parameter
    ENDC
    IFNC        '\4','' and '\5',''
        addParamSupport \1,\4,\5                           ; 2nd parameter
    ENDC
    IFNC        '\6','' and '\7',''
        addParamSupport \1,\6,\7                           ; 3rd parameter
    ENDC
    IFNC        '\8','' and '\9',''
        addParamSupport \1,\8,\9                           ; 4th parameter
    ENDC
    IFNC        '\a','' and '\b',''
        addParamSupport \1,\a,\b                           ; 5th parameter
    ENDC
    IFNC        '\c','' and '\d',''
        addParamSupport \1,\c,\d                           ; 6th parameter
    ENDC
    IFNC        '\e','' and '\f',''
        addParamSupport \1,\e,\f                           ; 7th parameter
    ENDC
    IFNC        '\g','' and '\h',''
        addParamSupport \1,\g,\h                           ; 8th parameter
    ENDC
    setLocalInteger \1,paramsCount,paramCount
    loadParams  \1,paramCount
                ENDM

; *****************************************************
; 3.3 Start a new procedure or function 
Function        MACRO
    Procedure   \1
                ENDM

; *****************************************************
; 3.4 End a procedure or function
EndProcedure     MACRO
endProc_\1_closing:
    endLocDatas \1                                     ; To close the procedure local datas / Handled by compiler on 1st pass (MACRO/EQUATES) compilation
    ; *********************** ADD HERE THE PARAMETER TO RETURN WHEN REQUIRED ***********************
    DeleteLocal \1                                     ; Delete local variables datas if exists.
    sub.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    bpl.s       ep\1return
    CastErrorID TooMuchEndProcedureReached
ep\1return:
    rts
ep\1:
                ENDM

; *****************************************************
; 3.5 End a procedure or function
EndFunction     MACRO
    EndProcedure \1
                ENDM

; *****************************************************
; 3.6 Internal MACRO used by callProcedure to handle Parameters
addParamCall     MACRO
    IFNC        '\2','' and '\3',''
        logStaticString addNewParameterToProcedureCall
        cmp.w   #\4,\5
        blt.s   .errorTooMuchParams
        get\2\3,d0,d1,\1
        sePushToStack d0,d1
    ENDC
                ENDM

; *****************************************************
; 3.7 call a procedure of function
callProcedure    MACRO
callProc_\1\@:                                              ; Auto increment of local pointer
    getLocalData paramsCount,d7,d6,\1                       ; Load the amount of parameters required by the Procedure/Function
    tst.l        d7
    beq.s        .noParams
    addParamCall \1,\2,\3,1,d7
    addParamCall \1,\4,\5,2,d7
    addParamCall \1,\6,\7,3,d7
    addParamCall \1,\8,\9,4,d7
    addParamCall \1,\a,\b,5,d7
    addParamCall \1,\c,\d,6,d7
    addParamCall \1,\e,\f,7,d7
    addParamCall \1,\g,\h,8,d7
    bra.b       .callProc
.errorTooMuchParams:
    CastErrorID TooMuchProcedureCallParams
.noParams:
    IFNC        '\2',''
    CastErrorID ProcedureRequiresNoParameters
    ENDC
.callProc:
    bsr         proc_\1                                ; Finally Call the procedure
                ENDM



; *****************************************************
; 1.11 Load a global variable inside registers   getlocalData VarName, Variable_DReg, VariableType_DReg, ProcName
getLocalData    MACRO
lgd\@:
    loadLocalDatas a3
    clr.l       \3
    move.l      l\4\1(a3),\2                            ; Load the variable value into \2
    move.w      l\4\1+4(a3),\3                          ; Load the variable Type into \3
    bra.s       .ctu
.er
    CastErrorID globalDataTypeNotRecognized
.ctu:
                ENDM

addNewParameterToProcedure:
    dc.b        "Add a new parameter to procedure",10,0
addNewParameterToProcedureCall:
    dc.b        "Add a new parameter to procedure call",10,0
    EVEN


