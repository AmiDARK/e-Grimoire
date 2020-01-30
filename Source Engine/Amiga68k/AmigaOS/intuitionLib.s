
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS intuition.library      *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to intuition.library calls.
; See : https://wiki.amigaos.net/wiki/Intuition_Requesters

; openIntuitionLib()
; closeIntuitionLib()


openIntuitionLib:
    lea     intuitionName,a1     ; Load the "intuition.library" name to a1
    Moveq    #0,d0                    ; Open All versions of intuition.library
    exeCall    OpenLibrary
    move.l    d0,seIntuitionBase(a5)     ; Save intuition.library BASE to gfxBase
    rts

closeIntuitionLib:
    move.l     seIntuitionBase(a5),a1
    cmp.l     #0,a1
    beq.s     cILEnd
    exeCall CloseLibrary
cILEnd:
    rts


intuitionName:    dc.b    "intuition.library",0

