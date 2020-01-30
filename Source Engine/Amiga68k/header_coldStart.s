
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

; OS System Libraries
	include "AmigaOS/execLib.s"
	include "AmigaOS/graphicsLib.s"
	include "AmigaOS/intuitionLib.s"
    include "AmigaOS/mathFFPLib.s"

; Source Engine Internal Structures
	include "seInternalStructures.s"             ; Includes all Source Engine internal data structures

; Source Engine Stack System (Direct Datas)
	include "seStackSystem.s"

; Includes the Source Engine users methods by categories.
    include "seStrings.s"

main:
    bsr.s    coldStart
    bsr.s gameEngine
    bsr.s    quitEngine
    rts


; ********************************************* coldStart
; This method will setup the Source Engine
coldStart:
    bsr.w     AllocSys                                 ; Allocate memory for the internal Structure and save it into SysStructBackup
    bsr.w     loadSys                                  ; A5 = SysStructBackup (pointer to the buffer of the structure)
    bsr.w     openGraphicsLib                          ; Open Graphics.library and save its base in the SysStructDatas
    bsr.w     openIntuitionLib
    bsr.w     openMathFFPLib                           ; Open MathFFP.library and save its base in the SysStructDatas

    rts

; ********************************************* quitEngine
; This method will release all used memories to leave the Source Engine and go back to Amiga OS System (Workbench or CLI)
quitEngine:



    bsr.w     closeMathFFPLib
    bsr.w     closeIntuitionLib
    bsr.w     closeGraphicsLib
    bsr.w     FreeSys                                  ; Release memory of the Internal Structure
    rts

; Backup the memory pointer to the Source Engine Internal Structure
SysStructBackup:    ds.l    0
