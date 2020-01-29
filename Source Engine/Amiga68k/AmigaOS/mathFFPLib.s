
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS mmathFFP.library       *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to mmathFFP.library calls.
;
; openMathFFPLib()
; closeMathFFPLib()

openMathFFPLib:
    lea     mathFFPName(pc),a1     ; Load the "intuition.library" name to a1
    Moveq    #0,d0                ; Open All versions of intuition.library
    exeCall    OpenLibrary
    move.l    d0,seMathFFPBase(a5)     ; Save intuition.library BASE to gfxBase
    rts

closeMathFFPLib
    move.l     seMathFFPBase(a5),a1
    cmp.l     #0,a1
    beq.s     cMFFPEnd
    exeCall CloseLibrary
cMFFPEnd:
    rts

mathFFPName:    dc.b    "mathffp.library",0

