; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.02.12              *
; * Version : 1.0                         *
; * File : variablesSystem PARSER MACROs  *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains specific MACRO that can be used for both Local and Global variables 

; AsInteger VarName(, Value, LocalReferency)
; AsFloat VarName(, Value, LocalReferency)
; AsString VarName(, Value, LocalReferency)
; Set VarName, Type(, Value, LocalReferency) // Exemple : Set myVar,AsFloat,"0.5f",MyProcedure for a local Floating number

; Source Engine Internal Structures
;    include "seInternalStructures.asm"                 ; Includes all Source Engine internal data structures

extraVarBuffer  equ     3000*6                         ; Allow to handle 3000 extra variables (to handle recussive calls)

buildFullVariablesBuffer     MACRO
    ; ******************************** 1nd compiler PASS
varBuffer       SET 0
    ; ******************************** 2nd compiler PASS
    move.l      #varBufferSize,d0                      ; D0 = Size required to allocate all variables
    add.l       #extraVarBuffer,d0                     ; D0 = D0 + Extra variable buffer (to handle recursive calls)
    bsr         AllocClrFastMem                        ; Allocate memory for the whole variables buffer
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      d0,fullVarBuffer(a5)
    move.l      d0,fvbPos(a5)
                            ENDM

DeleteFullVariablesBuffer   MACRO
    ; ******************************** 1nd compiler PASS
varBufferSize   equ varBuffer
    ; ******************************** 2nd compiler PASS
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      #varBufferSize,d0
    add.l       #extraVarBuffer,d0                     ; D0 = D0 + Extra variable buffer (to handle recursive calls)
    move.l      fullVarBuffer(a5),a1
    bsr         FreeMm
    move.l      #0,fullVarBuffer(a5)
    move.l      #0,fvbPos(a5)
                            ENDM
    

; AsInteger VarName,Value,LocalReferency
AsInteger       MACRO
    ; If param #3 exists -> Local Variable
        IFNC    '\3',''
    setLocalInteger \3,\1,\2
        ELSEIF
    setGlobalInteger \1,\2
        ENDC
                ENDM

; AsInteger VarName,Value,LocalReferency
SetInteger       MACRO
    ; If param #3 exists -> Local Variable
        IFNC    '\3',''
    setLocalInteger \3,\1,\2
        ELSEIF
    setGlobalInteger \1,\2
        ENDC
                ENDM

; AsFloat VarName,Value,LocalReferency
AsFloat         MACRO
        IFNC    '\3',''
    setLocalFloat \3,\1,\2
        ELSEIF
    setGlobalFloat \1,\2
        ENDC
                ENDM

; AsFloat VarName,Value,LocalReferency
SetFloat         MACRO
        IFNC    '\3',''
    setLocalFloat \3,\1,\2
        ELSEIF
    setGlobalFloat \1,\2
        ENDC
                ENDM

; AsString VarName,Value,LocalReferency
AsString        MACRO
        IFNC    '\3',''
    setLocalString \3,\1,<\2>
        ELSEIF
    setGlobalString \1,<\2>
        ENDC
                ENDM

; AsString VarName,Value,LocalReferency
SetString        MACRO
        IFNC    '\3',''
    setLocalString \3,\1,<\2>
        ELSEIF
    setGlobalString \1,<\2>
        ENDC
                ENDM

; Set VarName,Type,Value,LocalReferency
SetVar          MACRO
    \2      \1,\3,\4
                ENDM

; get Variable,Type,TargetVarReg,TargetTypeReg
get             MACRO
        ; **************** Get a local variable of the current procedure that call a new procedure
        IFD     l\1\2Labl
    loadLocalDatas a3
    move.l      \2\1(a3),\3
    move.w      \2\1+4(a3),\4
        ENDC
        ; **************** get a global variable
        IFD     gl\1labl
    loadGlobalDatas a3
    move.l      gl\1(a3),\3
    move.w      gl\1+4(a3),\4
        ENDC
        ; **************** Direct Integer value
        IFC    '\2','AsInteger'
    move.l      #\1,\3
    move.l      #TypeInt,\4
        ENDC
        ; **************** Direct Floating number value
        IFC    '\2','AsFloat'
tmpFlt\1\@:
    move.l      #TypeFloat,\4
    lea.l       .fltStr(pc),a0
    bsr         prixConvertStrToFlt
    move.l      d0,\3
    bra         .fltEnd
.fltStr:
        dc.b   \1,0
.fltEnd:
        ENDC
        IFC    '\2','AsString'
tmpStr\1\@:
    move.l      #TypeStr,\4
    lea.l       .strStr(pc),\3
    bra         .strEnd
.strStr:
        dc.b   \1,10,0
.strEnd:
        ENDC
                ENDM

