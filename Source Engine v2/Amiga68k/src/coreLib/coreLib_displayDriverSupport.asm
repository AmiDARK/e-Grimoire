; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Internal System branchments list *
; * Author : Frederic Cordier                             *
; *********************************************************

openDisplayDriverSupportLib:
    move.l      $4.w,a6
    lea         displayDriverName(pc),a1                    ; Load the "graphics.library" name to a1
    Moveq       #0,d0                                 ; Open All versions of graphics.library
    exeCall     OpenLibrary
    tst.l       d0
    beq.s       .noLib1
    move.l      d0,gDisplayDriverSupport.Base(a5)           ; Save Graphics.library BASE to gfxBase
    rts
.noLib1:
    CastErrorID CannotOpen_grm_displayDriverSupport.library
    rts

closeDisplayDriverSupportLib:
    move.l      $4.w,a6
    move.l      gScreensSupport.Base(a5),a1
    cmp.l       #0,a1
    beq.s       .cglEnd
    exeCall     CloseLibrary
.cglEnd:
    rts
