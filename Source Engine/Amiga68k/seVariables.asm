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

; AsInteger VarName,Value,LocalReferency
AsInteger       MACRO
        ; If param #3 exists -> Local Variable
        IFNC    '\3',''
    setLocalInteger \3,\1,\2
        ELSEIF
    setInteger \1,\2
        ENDC
                ENDM

; AsFloat VarName,Value,LocalReferency
AsFloat         MACRO
        IFNC    '\3',''
    setLocalFloat \3,\1,\2
        ELSEIF
    setFloat \1,\2
        ENDC
                ENDM

; AsString VarName,Value,LocalReferency
AsString        MACRO
        IFNC    '\3',''
    setLocalString \3,\1,<\2>
        ELSEIF
    setString \1,<\2>
        ENDC
                ENDM


; Set VarName,Type,Value,LocalReferency
SetVar          MACRO
    \2      \1,<\3>,\4
                ENDM

; get Value,Type,VarName,LocalReferency
get             MACRO
        IFNC    '4',''
    getLocal \4,\3,\1,\2
        ELSEIF
    getGlobal \3,\1,\2
        ENDC
                ENDM