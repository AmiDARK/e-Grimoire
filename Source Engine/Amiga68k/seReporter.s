
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

seGetOriginalOutput:
    movem.l        a1-a6/d1-d7,-(sp)         ; Save Regs.
    dosCall        Output
    tst.l        d0
    bne.s         .set
    move.l         conName,d1
    move.l         #MODE_NEWFILE,d2
    dosCall        Open
.set:
    move.l         d0,loggerFile(a5)
    movem.l     (sp)+,a1-a6/d1-d7
    rts


; ****************************************************
; input :
;      A0 = String pointer
seReporter_log:
    movem.l        a1-a6/d1-d7,-(sp)         ; Save Regs.
    bsr         getStringSize             ; D0 = String Length
    move.l         d0,d3                     ; D3 = String Length
    move.l         a0,d2                    ; D2 = Pointer buffer
    move.l         loggerFile(a5),d1         ; D1 = Output
    dosCall     Write
    movem.l     (sp)+,a1-a6/d1-d7
    rts

logStaticString        MACRO
    lea.l     \1,a0
    bsr     seReporter_log
                    ENDM

conName:     dc.b "CON:0,0,640,256,Source Engine Output Window", 0