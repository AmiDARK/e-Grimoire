
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.31                     *
; * Last Update : 2020.02.08              *
; * Version : 0.2                         *
; * File : Source Engine Setup MACROs     *
; * Author : Frederic Cordier             *
; *****************************************

; *********************************************
; This method allocate memory for the Source Engine internal structure
AllocSys        MACRO
    ; [Constructor] Allocate memory for the Source Engine Internal Data Structure
    Move.l  #seSysStructureLen,d0             ; D0 = System Structure Bytes Length
    bsr     AllocClrFastMem
    lea     SysStructBackup,a0             ; Save System Structure buffer pointer.
    Move.l    a1,(a0)
.asEnd:
                ENDM

; *********************************************
; This method load the System Structure pointer -> A5
LoadSysA5       MACRO
    ; Load the Source Engine internal Data Structure pointer to A5 register
    lea     SysStructBackup,a5
    Move.l     (a5),a5             ; A5 = Pointer to Internal System Structure
                ENDM

; *********************************************
; This method release memory used for the Source Engine internal structure
FreeSys         MACRO
    ; [Destructor] Release memory allocated for the Source Engine internal Data Structure.
    Move.l    SysStructBackup,a1             ; A0 = Pointer to the Internal System Structure
    Beq.s     .fsEnd                             ; A0 = 0 -> .fsEnd
    Move.l    #seSysStructureLen,d0             ; D0 = System Structure Bytes Length
    bsr   FreeMm                              ; Release memory used by Internal System Structure
.fsEnd:
    Move.L    #0,SysStructBackup             ; Clear memory to be sure it will no more be used
                ENDM

; *********************************************
; This methods open all required libraires for the Source Engine
OpenSysLibs        MACRO
    ; [Constructor] Open all the system .library(-ies) required by the Source Engine
    bsr       openDosLib
    bsr       openGraphicsLib                          ; Open Graphics.library and save its base in the SysStructDatas
    bsr       openIntuitionLib
    bsr       openMathFFPLib                           ; Open MathFFP.library and save its base in the SysStructDatas
                ENDM

; *********************************************
; This methods close all libraires used by the Source Engine
CloseSysLibs    MACRO
    ; [Destructor] Close all the system .library(-ies) previously opened by the Source Engine
    bsr     closeMathFFPLib
    bsr     closeIntuitionLib
    bsr     closeGraphicsLib
    bsr     closeDosLib
                ENDM
