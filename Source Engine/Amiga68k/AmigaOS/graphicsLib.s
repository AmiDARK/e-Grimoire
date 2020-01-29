
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS Graphics.library       *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to Graphics.library calls.
;
; openGraphicsLib()
; closeGraphicsLib()

openGraphicsLib:
    lea     graphicsName(pc),a1     ; Load the "graphics.library" name to a1
    Moveq    #0,d0                    ; Open All versions of graphics.library
    exeCall    OpenLibrary
    move.l    d0,seGraphicsBase(a5)     ; Save Graphics.library BASE to gfxBase
    rts

closeGraphicsLib:
    move.l    seGraphicsBase(a5),a1
    cmp.l     #0,a1
    beq.s     cglEnd
    exeCall    CloseLibrary
cglEnd:
    rts

graphicsName:    dc.b    "graphics.library",0,0
