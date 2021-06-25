
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS dos.library            *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to dos library calls.
;
; A6=loadDos (MACRO)
; dosCall FUNCTIONNAME (MACRO)
;
; openDosLib : Open the dos.library
; closeDosLib : Close the dos.library

    include     "dos/dos.i"
    include     "LVO/dos_lib.i"
 
; *********************************************
; This MACRO load dosBase into A6 register
; A6=loadDos
loadDos         MACRO
    move.l      DosBase(a5),a6
                ENDM

; *********************************************
; This MACRO do a call to a method (parameter \1) of the ExecLibrary.
; Parameters must be set correctly before calling this MACRO
; exeCall FUNCITONNAME
dosCall         MACRO
    loadDos
    jsr         _LVO\1(a6)
                ENDM
                
openDosLib:
    lea.l       dosName(pc),a1                         ; Load the "dos.library" name to a1
    Move.l      #0,d0                                  ; Open All versions of graphics.library
    exeCall     OpenLibrary
    tst.l       d0
    beq.s       .noLib3
    move.l      d0,DosBase(a5)                         ; Save dos.library BASE to gfxBase
    rts
.noLib3:
    CastErrorID CannotOpenDOSLibrary


closeDosLib:
    movem.l     a5,-(sp)                               ; Save Regs.
    move.l      DosBase(a5),a1
    cmp.l       #0,a1
    beq.s       cdsEnd
    exeCall     CloseLibrary
cdsEnd:
    movem.l     (sp)+,a5                               ; Save Regs.
    rts

dosName:    dc.b    "dos.library",0
            even