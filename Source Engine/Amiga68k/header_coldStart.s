
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

; Source Engine Error Handler system
    include "seErrorHandler.s"
    
; Source Engine Stack System (Direct Datas)
	include "seStackSystem.s"


; Source Engine Setup 
    include "seSetup.s"

; Includes the Source Engine users methods by categories.
    include "seStrings.s"

main:
    bsr.s    coldStart
    bsr.s    startHere
    bsr.s    quitEngine
    rts


; ********************************************* coldStart
; This method will setup the Source Engine
coldStart:
    AllocSys                                           ; (seSetup.s) Allocate memory for the internal Structure and save it into SysStructBackup
    LoadSysA5                                          ; (seSetup.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    OpenSysLibs                                        ; (seSetup.s) to open all requireds .library
    rts

; ********************************************* quitEngine
; This method will release all used memories to leave the Source Engine and go back to Amiga OS System (Workbench or CLI)
quitEngine:


    CloseSysLibs                                       ; (seSetup.s) Close all previously opened .library
    FreeSys                                            ; (seSetup.s)Release memory of the Internal Structure
    rts

; Backup the memory pointer to the Source Engine Internal Structure
SysStructBackup:    ds.l    0
