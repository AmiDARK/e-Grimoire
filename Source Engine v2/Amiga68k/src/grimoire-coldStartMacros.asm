
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.01.28              *
; * Version : 0.2                         *
; * File : header_coldStart               *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the hearth of the Amiga68k Source Engine.
; It handle all setup stuffs, and all releases.
    incdir  "includes/"                                ; From basedir where the Amiga SDK is located for includes.


grimoireStartupSequence MACRO
; **** 1. Open Dos.library
    moveq      #0,d0
    lea        gCore.library(pc),a1
    move.l     $4.w,a6
    jsr        _LVOOpenLibrary(a6)
; **** 2. Save dosbase
    tst.l      d0
    beq        DirectEnd
    lea.l      temp_gCore.Base(pc),a4
    move.l     d0,(a4)
; **** As gCore.Base(a5) is not yet populated because not created, we must call the grmStartGrimoire manually
    move.l     d0,a6
    jsr        grmStartGrimoire(a6)

    lea.l      temp_gCore.Base(pc),a4
    move.l     (a4),gCore.Base(a5)       ; Save the grimoire-core.library base inside the internal structure for later use.

; **** 3. Save the gCore.library base inside the gCore internal structure
; -----------------> a5 = System Structure pointer ****


; ******************************************************************** GRIMOIRE STARTUP SEQUENCE **********
    ; **********************
    ; Create buffers for all loops systems
    buildAllLoopsBuffer                        ; Prepare the for/next buffer inside the global buffer
    ; **********************
    ; Create buffers for global variables
    buildGlobalVariables                               ; Start global data Structure here.
; ******************************************************************** GRIMOIRE STARTUP SEQUENCE **********
  ENDM

grimoireLeaveEngine MACRO

; ******************************************************************** GRIMOIRE STARTUP SEQUENCE **********
    ; **********************
    ; Release global variables buffers
    deleteGlobal                   ; Remove all global datas from memory before leaving main source code
    ; **********************
    ; Release all loops systems buffers
    deleteAllLoopsBuffer
; ******************************************************************** GRIMOIRE STARTUP SEQUENCE **********

CloseEngine:
    grmCall    grmHotEndGrimoire

    move.l     $4.w,a6
    lea.l      temp_gCore.Base(pc),a4
    move.l     (a4),a1
    jsr        _LVOCloseLibrary(a6)
DirectEnd:
    rts                                                ; End of the Execution
; Once the "rts" call is done, the 'gameStart' program is finished. Engine will go back to the
; header_coldStart.s to execute methods to release all memories remaining under use on the engine.
; You must not includes any files at this points. Source code includes for additional procedures, classes, must be
; done before the "startHere" label, and after the "header_coldStart.s" include
gCore.library:
    dc.b    "System/grimoire-core.library",0
    EVEN
temp_gCore.Base:
    dc.l    0
    EVEN
dosBase:
    dc.l    0
    EVEN
  ENDM