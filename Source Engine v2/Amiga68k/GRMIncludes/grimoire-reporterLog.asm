
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
      movem.l     d0-d3/a0-a2,-(sp)
      move.l      a0,d1
      dosCall     PutStr
      movem.l     (sp)+,d0-d3/a0-a2
               ENDM

;sRprtrX:                                               ; d1 = String Pointer
;    dosCall     PutStr
;    rts

logStaticString MACRO
      movem.l     d0-d3/a0-a2,-(sp)
      lea.l       \1(pc),a0
      Move.l      a0,d1
;    bsr         sRprtrX
      dosCall     PutStr
      movem.l     (sp)+,d0-d3/a0-a2
                ENDM

logDirectString MACRO
      movem.l     d0-d3/a0-a2,-(sp)
      lea.l       \1(pc),a0
      move.l      a0,d1
      dosCall     PutStr
      movem.l     (sp)+,d0-d3/a0-a2
      bra         cnt\1
\1:
      dc.b        \2,10,0
      EVEN
cnt\1:
                ENDM

logDebugMessage MACRO
    IFNE debugMode
      movem.l     d0-d7/a0-a3,-(sp)
      lea.l       \1(pc),a0
      move.l      a0,d1
      dosCall     PutStr
      movem.l     (sp)+,d0-d7/a0-a3
      bra         cnt\1
\1:
      dc.b        \2,10,0
      EVEN
cnt\1:
    ENDC
                ENDM

logString       MACRO
      movem.l     d0-d3/a0-a2,-(sp)
      vmsGetPush  \1,d1
;      bsr         sRprtrX
      dosCall     PutStr
      movem.l     (sp)+,d0-d3/a0-a2
                ENDM

logGlobalString MACRO
      movem.l     d0-d3/a0-a2,-(sp)
      vmsGetPush  \1,d1
;      bsr         sRprtrX
      dosCall     PutStr
      movem.l     (sp)+,d0-d3/a0-a2
                ENDM

logLocalString MACRO
      movem.l     d0-d3/a0-a2,-(sp)
      vmsGetPush  \1,d1
;      bsr         sRprtrX
      dosCall     PutStr
      movem.l     (sp)+,d0-d3/a0-a2
                ENDM
