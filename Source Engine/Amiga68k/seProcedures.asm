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
DepthBufferSize     equ     16384                      ; Procedure recursive calls limits.

; *****************************************************
; 2.4 Start a new procedure or function 
Procedure       MACRO
    ; ******************************** 1nd compiler PASS
paramCount      SET 0
    ; ******************************** 2nd compiler PASS
    bra         ep\1
proc_\1:
    add.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    cmp.w       #DepthBufferSize,procedureDepth(a5)
    blt.s       .ok
    CastErrorID TooMuchProcedureCallsWithoutReturn
.ok:
    ; Reset also handle the build of the local datas
    buildLocalDatas \1                                 ; Start to create local variables datas (should contains at mimum the next/prev/size variables )
    ; **************** Parameter #1
    IFNC        '\2','' and '\3',''
        addParamSupport \1,\2,\3                       ; 1st parameter : ProcName,VarName,VarType (AsInteger,AsFloat,...)
    ENDC
    ; **************** Parameter #2
    IFNC        '\4','' and '\5',''
        addParamSupport \1,\4,\5                       ; 2nd parameter
    ENDC
    ; **************** Parameter #3
    IFNC        '\6','' and '\7',''
        addParamSupport \1,\6,\7                       ; 3rd parameter
    ENDC
    ; **************** Parameter #4
    IFNC        '\8','' and '\9',''
        addParamSupport \1,\8,\9                       ; 4th parameter
    ENDC
    ; **************** Parameter #5
    IFNC        '\a','' and '\b',''
        addParamSupport \1,\a,\b                       ; 5th parameter
    ENDC
    ; **************** Parameter #6
    IFNC        '\c','' and '\d',''
        addParamSupport \1,\c,\d                       ; 6th parameter
    ENDC
    ; **************** Parameter #7
    IFNC        '\e','' and '\f',''
        addParamSupport \1,\e,\f                       ; 7th parameter
    ENDC
    ; **************** Parameter #8
    IFNC        '\g','' and '\h',''
        addParamSupport \1,\g,\h                       ; 8th parameter
    ENDC
    ; **************** Parameter #9
    IFNC        '\i','' and '\j',''
        addParamSupport \1,\i,\j                       ; 8th parameter
    ENDC
    ; **************** Parameter #10
    IFNC        '\k','' and '\l',''
        addParamSupport \1,\k,\l                       ; 8th parameter
    ENDC
    ; **************** Parameter #11
    IFNC        '\m','' and '\n',''
        addParamSupport \1,\m,\n                       ; 8th parameter
    ENDC
    ; **************** Parameter #12
    IFNC        '\o','' and '\p',''
        addParamSupport \1,\o,\p                       ; 8th parameter
    ENDC
    ; **************** Parameter #13
    IFNC        '\q','' and '\r',''
        addParamSupport \1,\q,\r                       ; 8th parameter
    ENDC
    ; **************** Parameter #14
    IFNC        '\s','' and '\t',''
        addParamSupport \1,\s,\t                       ; 8th parameter
    ENDC
    ; **************** Parameter #15
    IFNC        '\u','' and '\v',''
        addParamSupport \1,\u,\v                       ; 8th parameter
    ENDC
    ; **************** Parameter #16
    IFNC        '\w','' and '\x',''
        addParamSupport \1,\w,\x                       ; 8th parameter
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
; 3 cases can occur when leaving a procedure. 1. Return a local variable, 2. Return a direct value (integer, string, float), 3. Return a global variable
EndProcedure     MACRO
endProc_\1_closing:
    LoadSys    a5
    ; ******************* Check if any return is done when leaving the procedure *******************
    IFNC        '\1',''                                ; if param1 != null -> At least 1 parameter is set. Case 3 is possible (global var)
      IFNC        '\2',''                              ; If param2 != null -> At least 2 parameters are set, Case 2 is possible (local var)
        IFNC        '\3',''                            ; If param3 != null -> Return a direct Value param1=ProcedureName, param2=VarType, param3=Value
          ; ******** Case 1 Return a Direct Value param1=ProcedureName, param2=Type, param3=Value
          IFC     '\2','AsString' or '\2','SetString'
            lea.l   endproc_\1_tOutput(pc),a0            ; Load the pointer of the static string content into A0
            move.l  a0,endProcVar(a5)
            move.w  #TypeStr,endproc_\1_tOutput+4(a5)    ; Save the variable type as String
          ELSEIF
            IFC     '\2','AsFloat' or '\2','SetFloat'
              lea.l   endproc_\1_tOutput(pc),a0        ; Load the pointer of the String representation of the static floating number value into A0
              bsr     privConvertStrToFlt              ; Call String to Floating number conversion method. Do not use stack but direct datas into A0.str -> D0.flt
              move.l  d0,endProcVar(a5)                ; Set the floating number variable value.
              move.w  #TypeFlt,endproc_\1_tOutput+4(a5) ; Setup the Global variable as Floating number variable.
            ELSEIF
            ; Last case is for direct integer value.
              move.l  #\3,endProcVar(a5)
              move.w  #TypeInt,endproc_\1_tOutput+4(a5) ; Save the variable type as Integer
            ENDC
          ENDC
        ELSEIF                                         ; param1 + param2 + !param3 = Return a local variable \1=ProcedureName, \2=LocalVarName
          ; ******** Case 2 Return a local variable param1=Procedure, param2=localVarName
          LoadLocalVar \1,\2,d6,d7
          move.l       d6,endProcVar(a5)
          move.w       d7,endProcVar+4(a5)
      ELSEIF
        ; ******** Case 3 Return a global variable param1=GlobalVarName
        LoadGlobalVar  \1,d6,d7
        move.l         d6,endProcVar(a5)
        move.w         d7,endProcVar+4(a5)
      ENDC
    ENDC
    ; ************************ RELEASE BUFFER USED TO STORE LOCAL VARIABLES ************************
    DeleteLocal \1                                     ; Delete local variables datas if exists.
    ; ****************************** Check Calls<>Returns integrity ********************************
    sub.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    bpl.s       ep\1return
    CastErrorID TooMuchEndProcedureReached
    ; ******** Here we can put the String/Flt(String) datas used for direct output when created
    IFNC        '\3',''
endproc_\1_tOutput:
    dc.b        \3,10,0
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
    add.l       #varStart\1,a3                         ; A3 = Pointer to 1st true parameter of the procedure
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
; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
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
    ; **************** Parameter #1
    IFC    '\3','AsString' or '\3','AsFloat'
            addParamCall <\2>,\3,1,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \2,\3,1,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #2
    IFC    '\5','AsString' or '\5','AsFloat'
            addParamCall <\4>,\5,2,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \4,\5,2,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #3
    IFC    '\7','AsString' or '\7','AsFloat'
            addParamCall <\6>,\7,3,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \6,\7,3,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #4
    IFC    '\9','AsString' or '\9','AsFloat'
            addParamCall <\8>,\9,4,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \8,\9,4,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #5
    IFC    '\b','AsString' or '\b','AsFloat'
            addParamCall <\a>,\b,5,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \a,\b,5,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #6
    IFC    '\d','AsString' or '\d','AsFloat'
            addParamCall <\c>,\d,6,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \c,\d,6,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #7
    IFC    '\f','AsString' or '\f','AsFloat'
            addParamCall <\e>,\f,7,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \e,\f,7,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #8
    IFC    '\h','AsString' or '\h','AsFloat'
            addParamCall <\g>,\h,8,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \g,\h,8,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #9
    IFC    '\i','AsString' or '\j','AsFloat'
            addParamCall <\i>,\j,9,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \i,\j,9,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #10
    IFC    '\k','AsString' or '\l','AsFloat'
            addParamCall <\k>,\l,10,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \k,\l,10,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #11
    IFC    '\m','AsString' or '\n','AsFloat'
            addParamCall <\m>,\n,11,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \m,\n,11,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #12
    IFC    '\o','AsString' or '\p','AsFloat'
            addParamCall <\o>,\p,12,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \o,\p,12,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #13
    IFC    '\q','AsString' or '\r','AsFloat'
            addParamCall <\q>,\r,13,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \q,\r,13,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #14
    IFC    '\s','AsString' or '\t','AsFloat'
            addParamCall <\s>,\t,14,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \s,\t,14,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #15
    IFC    '\u','AsString' or '\v','AsFloat'
            addParamCall <\u>,\v,15,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \u,\v,15,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ENDC
    ; **************** Parameter #16
    IFC    '\w','AsString' or '\x','AsFloat'
            addParamCall <\w>,\x,16,d7,errTMPrms\@,\1        ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
    ELSEIF
            addParamCall \w,\x,16,d7,errTMPrms\@,\1          ; addParamCall Variable,Type,DestRegValue,DestRegType, ProcedureNAME
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
    IFNC         '\2',''                               ; If we have two parameters, then the data will be received inside a local variable

    ELSEIF                                             ; If we have only 1 parameter, then the data will be received inside a global variable

    ENDC



                    ENDM