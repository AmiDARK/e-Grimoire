
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
seReporter_log MACRO
    move.l      a0,d1
    dosCall     PutStr
               ENDM

;sRprtrX:                                               ; d1 = String Pointer
;    dosCall     PutStr
;    rts

logStaticString MACRO
    lea.l       \1(pc),a0
    Move.l      a0,d1
;    bsr         sRprtrX
    dosCall     PutStr
                ENDM

logDirectString MACRO
    lea.l       \1(pc),a0
    move.l      a0,d1
    dosCall     PutStr
    bra         cnt\1
\1:
    dc.b        \2,10,0
    EVEN
cnt\1:
                ENDM

logDebugMessage MACRO
    IFNE debugMode
      lea.l       \1(pc),a0
      move.l      a0,d1
      dosCall     PutStr
      bra         cnt\1
\1:
      dc.b        \2,10,0
      EVEN
cnt\1:
    ENDC
                ENDM

logString       MACRO
    vmsGetPush  \1,d1
;    bsr         sRprtrX
    dosCall     PutStr
                ENDM

logGlobalString MACRO
    vmsGetPush  \1,d1
;    bsr         sRprtrX
    dosCall     PutStr
                ENDM

logLocalString MACRO
    vmsGetPush  \1,d1
;    bsr         sRprtrX
    dosCall     PutStr
                ENDM
