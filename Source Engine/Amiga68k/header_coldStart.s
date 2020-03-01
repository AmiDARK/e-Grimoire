
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

; OS System Libraries;
	include "AmigaOS/execLib.s"
    include "AmigaOS/dosLib.s"
	include "AmigaOS/graphicsLib.s"
	include "AmigaOS/intuitionLib.s"
    include "AmigaOS/mathFFPLib.s"

main:
    bsr    coldStart
    bsr      startHere
    bsr    quitEngine
    rts

; Source Engine Error Handler system
    include "seErrorHandler.s"

; Source Engine Reporter.log system (output to CLI)
    include "seReporter.s"

; String support
    include "seStrings.s"

; Source Engine Internal Structures
	include "seInternalStructures.s"             ; Includes all Source Engine internal data structures

    
; Source Engine Stack System (Direct Datas)
;	include "seStackSystem.s"


; Source Engine Setup 
    include "seSetup.s"

; Includes the Source Engine users methods by categories.
;    include "seStrings.s"

; Include the Global Data Structure file created by the Parser
;   include "parserGlobalVariables.s"
    
	include "parserVariables.s"


; ********************************************* coldStart
; This method will setup the Source Engine
coldStart:
    AllocSys                                           ; (seSetup.s) Allocate memory for the internal Structure and save it into SysStructBackup
    LoadSysA5                                          ; (seSetup.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    OpenSysLibs                                        ; (seSetup.s) to open all requireds .library
    bsr seGetOriginalOutput                            ; (seReporter.s) open default output CLI: or create a new CON: if required

    rts

; ********************************************* quitEngine
; This method will release all used memories to leave the Source Engine and go back to Amiga OS System (Workbench or CLI)
quitEngine:


    CloseSysLibs                                       ; (seSetup.s) Close all previously opened .library
    FreeSys                                            ; (seSetup.s)Release memory of the Internal Structure
    rts

; Backup the memory pointer to the Source Engine Internal Structure
SysStructBackup:    dc.l    0
