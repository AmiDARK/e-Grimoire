
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.29                     *
; * Last Update :                         *
; * Version : 0.1                         *
; * File : seReporter.log                 *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the reporterlog system that will output
; to CLI when ran from newcli window, or to a new CON when ran from Workbench

    include "dos/dos.i"

; ****************************************************
; input :
;      A0 = String pointer
seReporter_log:
    move.l      a0,d1
sRprtrX:                                               ; d1 = String Pointer
    dosCall     PutStr
    rts

logStaticString MACRO
    lea.l       \1(pc),a0
    Move.l      a0,d1
    bsr         sRprtrX
                ENDM

logGlobalString MACRO
\1\@:
    loadGlobalDatas a2
    add.l       #gl\1,a2
    cmp.w       #TypeStr,4(a2)
    beq.s       .lgOk
    cmp.w       #TypeNewStr,4(a2)
    beq.s       .lgOk
    CastErrorID VariableTypeIsNotString                ; CAST ERROR
.lgOk:
    move.l      (a2),d1
    bsr         sRprtrX
                ENDM

logLocalString MACRO
logLS\1\2\@:
    loadLocalDatas a2
    add.l       #l\1\2,a2
    cmp.w       #TypeStr,4(a2)
    beq.s       .lgOk
    cmp.w       #TypeNewStr,4(a2)
    beq.s       .lgOk
    CastErrorID VariableTypeIsNotString                ; CAST ERROR
.lgOk:
    move.l      (a2),d1
    bsr         sRprtrX
                ENDM
