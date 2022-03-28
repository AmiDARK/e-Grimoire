
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.29                     *
; * Last Update :                         *
; * Version : 0.1                         *
; * File : seVariablesStack.asm           *
; * Author : Frederic Cordier             *
; *****************************************


sePushToStack   MACRO
    move.l      \1,d6
    move.l      \2,d7
    grmCall     grmSePushToStack
                ENDM

seGetFromStack  MACRO
    grmCall     grmSeGetFromStack
;    move.l      d6,\1                         ; d6,d7 already contain value,type
;    move.l      d7,\2                         ; directly from the function
                ENDM

seGetFromStackP MACRO
    grmCall     grmSeGetFromStack
    exg.l       d6,d7
;    move.l      d7,\1
;    move.l      d6,\2
                ENDM

seResetStack    MACRO
;    move.l      d7,tempSave(a5)
;    move.l      StackAdr(a5),d7
;    move.l      d7,ZeStackPos(a5)
;    move.l      tempSave(a5),d7
                ENDM
        