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

; Procedure ProcName(,param1Name,param1Type)...(,param'n'Name,param'n'Type)...(,param8Name,param8Type)
; EndProcedure ProcName(ReturnedValue,Type)

; Function ProcName(,param1Name,param1Type)...(,param'n'Name,param'n'Type)...(,param8Name,param8Type)
; EndFunction ProcName(ReturnedValue,Type)

    include     "seVariablesType.asm"
    include     "seStackSystem.asm"

; *****************************************************
; 2.1 Parameters type handled as Procedures Parameter.
; example : myProcedure ProcName,myInt,AsInteger,myFlt,AsFloat,myStr,AsString


; *****************************************************
; 2.4 Start a new procedure or function 
Procedure       MACRO
    ; ******************************** 1nd compiler PASS
paramCount      SET 0
    ; ******************************** 2nd compiler PASS
    bra         ep\1
proc_\1:
    add.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    cmp.w       #16384,procedureDepth(a5)
    blt.s       .ok
    CastErrorID TooMuchProcedureCallsWithoutReturn
.ok:
    ; Reset also handle the build of the local datas
    buildLocalDatas \1                                 ; Start to create local variables datas (should contains at mimum the next/prev/size variables )
    IFNC        '\2','' and '\3',''
        addParamSupport \1,\2,\3                       ; 1st parameter : ProcName,VarName,VarType (AsInteger,AsFloat,...)
    ENDC
    IFNC        '\4','' and '\5',''
        addParamSupport \1,\4,\5                       ; 2nd parameter
    ENDC
    IFNC        '\6','' and '\7',''
        addParamSupport \1,\6,\7                       ; 3rd parameter
    ENDC
    IFNC        '\8','' and '\9',''
        addParamSupport \1,\8,\9                       ; 4th parameter
    ENDC
    IFNC        '\a','' and '\b',''
        addParamSupport \1,\a,\b                       ; 5th parameter
    ENDC
    IFNC        '\c','' and '\d',''
        addParamSupport \1,\c,\d                       ; 6th parameter
    ENDC
    IFNC        '\e','' and '\f',''
        addParamSupport \1,\e,\f                       ; 7th parameter
    ENDC
    IFNC        '\g','' and '\h',''
        addParamSupport \1,\g,\h                       ; 8th parameter
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
    IFNC        '\2',''
    IFNC        '\3',''                                ; Si le type de variable est défini, on l'envoie, sinon on envoie la méthode
        SetVar   \2,\3,d6,d7
    ELSEIF
        SetVar   \2,\1,d6,d7
    ENDC
    sePushToStack d6,d7
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
; 2.2 Internal MACRO used by 'Procedure' one to support parameters in Procedure \1=ProcName, \2=VarName, \3=Type
addParamSupport MACRO 
paramCount SET paramCount+1
        \3      \2,,\1                      ; Example : AsInteger  VarName,(Value),ProcName
                ENDM

; *****************************************************
; 2.3 Internal MACRO used by 'Procedure' one to load parameters that were detected by addParamSupport
loadParams      MACRO
loadParams_\1:
    loadLocalDatas a3
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
;    cmp.w       #TypeStr,d6
;    beq.s       .lClone
;    cmp.w       #TypeNewStr,d6
;    bne.s       .lpload
;.lClone:
;    move.l      d5,a0
;    bsr         cloneString
;    move.l      #TypeNewStr,d6
;    move.l      a0,d5
.lpload:
    move.l      d5,(a3)
    move.w      d6,4(a3)
    sub.l       #6,a3                                  ; A3 = previous parameters (parameters are written in order and read in reversed order)
    sub.l       #1,d7                                  ; Next parameters ?
    bpl.w       lpLoop\1                               ; YES -> Continue reading from Stack.
lpEnd_\1:
                ENDM



; *****************************************************
; 3.6 Internal MACRO used by callProcedure to handle Parameters
; addParamCall Variable,Type,DestRegValue,DestRegType
addParamCall     MACRO
    IFC         '\2','AsString' or '\2','AsFloat'
        cmp.w   #\3,\4
        blt     \5
        get     <\1>,\2,d4,d5
        sePushToStack d4,d5
        bra     .\6tmp\@
    ENDC
    IFNC        '\1','' and '\2',''
        cmp.w   #\3,\4
        blt     \5
        get     \1,\2,d4,d5
        sePushToStack d4,d5
    ENDC
.\6tmp\@:
                ENDM

; *****************************************************
; 3.7 call a procedure of function
callProcedure    MACRO
callProc_\1\@:                                              ; Auto increment of local pointer
    getLocalData paramsCount,d7,d6,\1                       ; D7=\1.paramsCount D6=\1.paramsCount.Type
    tst.l        d7                                         ; No parameters ?
    beq          noParams\1\@                               ; YES -> Jump to .noParams
    IFC    '\3','AsString' or '\3','AsFloat'
            addParamCall <\2>,\3,1,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \2,\3,1,d7,errTMPrms\@,\1
    ENDC
    IFC    '\5','AsString' or '\5','AsFloat'
            addParamCall <\4>,\5,2,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \4,\5,2,d7,errTMPrms\@,\1
    ENDC
    IFC    '\7','AsString' or '\7','AsFloat'
            addParamCall <\6>,\7,3,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \6,\7,3,d7,errTMPrms\@,\1
    ENDC
    IFC    '\9','AsString' or '\9','AsFloat'
            addParamCall <\8>,\9,4,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \8,\9,4,d7,errTMPrms\@,\1
    ENDC
    IFC    '\b','AsString' or '\b','AsFloat'
            addParamCall <\a>,\b,5,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \a,\b,5,d7,errTMPrms\@,\1
    ENDC
    IFC    '\d','AsString' or '\d','AsFloat'
            addParamCall <\c>,\d,6,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \c,\d,6,d7,errTMPrms\@,\1
    ENDC
    IFC    '\f','AsString' or '\f','AsFloat'
            addParamCall <\e>,\f,7,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \e,\f,7,d7,errTMPrms\@,\1
    ENDC
    IFC    '\h','AsString' or '\h','AsFloat'
            addParamCall <\g>,\h,8,d7,errTMPrms\@,\1
    ELSEIF
            addParamCall \g,\h,8,d7,errTMPrms\@,\1
    ENDC
    bra.b       callProc\@
errTMPrms\@:
    CastErrorID TooMuchProcedureCallParams
noParams\1\@:
    IFNC        '\2',''
    CastErrorID ProcedureRequiresNoParameters
    ENDC
callProc\@:
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

getProcedureReturn  MACRO


                    ENCM