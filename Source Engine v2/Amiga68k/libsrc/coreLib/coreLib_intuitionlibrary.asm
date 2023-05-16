
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

    include     "LVO/intuition_lib.i"

loadIntuiBase   MACRO
    move.l      IntuitionBase(a5),a6
                ENDM

intuiCall       MACRO
    loadIntuiBase
    jsr         _LVO\1(a6)
                ENDM

AutoReqM        MACRO
    move.l      \1,a0                                  ; pointer to window structure
    lea         \2,a1                                  ; IntuiText for the body 
    lea         \3,a2                                  ; Intuitext for pos text
    lea         \4,a3                                  ; Intuitext for NegText, must be valid
    move.l      #\5,d0                                 ; PosFlags left activates by clicking
    move.l      #\6,d1                                 ; NegFlags activates by clicking
    move.l      #\7,d2                                 ; Width of the requester in pixels
    move.l      #\8,d3                                 ; height of requester in pixels
    intuiCall   AutoRequest
                ENDM

openIntuitionLib:
    move.l      $4.w,a6
    lea         intuitionName(pc),a1                       ; Load the "intuition.library" name to a1
    Moveq       #0,d0                                  ; Open All versions of intuition.library
    exeCall     OpenLibrary
    tst.l       d0
    bne.s       .Lib2
    CastErrorID CannotOpenIntuitionLibrary
.Lib2:
    rts

closeIntuitionLib: 
    move.l      $4.w,a6
    move.l      IntuitionBase(a5),a1
    cmp.l       #0,a1
    beq.s       cinEnd
    exeCall     CloseLibrary
cinEnd:
    rts
