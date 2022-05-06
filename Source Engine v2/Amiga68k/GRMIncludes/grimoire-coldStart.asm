
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

    include     "exec/types.i"
    include     "exec/initializers.i"
    include     "exec/lists.i"
    include     "exec/nodes.i"
    include     "exec/resident.i"
    include     "exec/alerts.i"
    include     "exec/memory.i"
;    include    "exec/exec_lib.i"
;    include    "exec/exec.s"
    include     "LVO/exec_lib.i"

    include     "dos/dos.i"
    include     "LVO/dos_lib.i"

    include "GRMIncludes/grimoire-configuration.asm"              ; Internal Engine configurations (variables buffers, etc.)
    include "GRMIncludes/grimoire-structure.asm"         ; Includes all Source Engine internal data structures
    include "GRMIncludes/grimoire-errorHandler.asm"               ; Equates to define the existing errors messages.

; ******** Special labels for multiple systems supports
inProcedure     SET 0                                  ; Used to define if we are inside a procedure (=8) or not (=0)
inProcName      SET 0                                  ; Used for Procedure Unique ID
procCallName    SET 0                                  ; Used for CallProcedure unique ID
nextProcReturn  SET 0                                  ; Used for unique labels for getProcedureReturn macro.

; ******** For / Next blocks
;higherForNext   SET seMaxForNext                       ; Used to count the maximum recursive amount of imbricated For/Next system.
higherForNext   SET 32                                 ; Used to count the maximum recursive amount of imbricated For/Next system.
blockForNext    SET -1                                 ; Used to identify forNext blocks.
blockForNextB   SET -1

; ******** Do Loop blocks.
;higherDo        SET seMaxDoLWU
higherDo        SET 32
blockDo         SET -1                                 ; sed to identify DoLoopWhileUntil blocks.
blockDoB        SET -1                                 ; The ID of the Do Loop we are in.

; ******** Variables secondaries methods labels 
newUpdateVar    SET 0                                  ; Used for unique labels for macro to update a variable.
chkIntCount     SET -1                                 ; Used for labels on 'loadIntegerVar' macro

LoadSys        MACRO
    grmCall    grmLoadSys \1
               ENDM

dosCall        MACRO
    move.l     DosBase(a5),a6
    jsr        _LVO\1(a6)
               ENDM


; **********************************************************
; * Method Name : main                                     *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   main <args>                                          *
; *--------------------------------------------------------*
; * Description : This is the entry point of the executable*
; *   It will call the engine initializing routines then it*
; *   will call the engine execution to finally came back  *
; *   to close the engine and release all allocated memory *
; *   banks.                                               *
; *--------------------------------------------------------*
; * Version : 0.1                                          *
; * Last update date : 2021.07.04                          *
; **********************************************************
main:
    bra     seGameEngine

; OS System Libraries;
;    include "src/AmigaOS/execLib.asm"
;    include "src/AmigaOS/dosLib.asm"
;    include "src/AmigaOS/graphicsLib.asm"
;    include "src/AmigaOS/intuitionLib.asm"
;    include "src/AmigaOS/mathFFPLib.asm"

;    include "GRMIncludes/grimoire-structure.asm"         ; Includes all Source Engine internal data structures

; Include the stack system used to cast parameters to a procedure or an engine method.
    include "GRMIncludes/grimoire-stackSystem.asm"                    ; seCreateStack/seReleaseStack/sePushToStack/seGetFromStack/seGetFromStackP(/seResetStack) MACROS

; Source Engine Reporter.log system (output to CLI)
    include "GRMIncludes/grimoire-reporterLog.asm"                       ; MACROS

    include "GRMIncludes/grimoire-procedures.asm"

; Variables Management System
    include "GRMIncludes/grimoire-vms.asm"                              ; Include the Variable Management System (it includes sub files)

    include "GRMIncludes/grimoire-basics.asm"                    ; Include the BASIC languages specific commands support (for/Next/Repeat/Until)

seGameEngine:


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
