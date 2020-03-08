
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
main:
    bra     seGameEngine

    include "seErrorEquates.asm"

; OS System Libraries;
	include "AmigaOS/execLib.asm"
    include "AmigaOS/dosLib.asm"
	include "AmigaOS/graphicsLib.asm"
	include "AmigaOS/intuitionLib.asm"
    include "AmigaOS/mathFFPLib.asm"
    include "AmigaOS/cliOrWorkbench.asm"

; Source Engine Reporter.log system (output to CLI)
    include "seReporter.asm"

; String support
    include "seStrings.asm"

; Source Engine Internal Structures
    include "seInternalStructures.asm"                 ; Includes all Source Engine internal data structures
    
; Source Engine Stack System (Direct Datas)
	include "seStackSystem.asm"

; Includes the Source Engine users methods by categories.
    include "seStrings.asm"

; Include the Global Data Structure file created by the Parser
    include "seGlobalVariables.asm"
    include "seProcedures.asm"

coldStart:
    bsr         cliOrWbStartup                         ; Cli & WorkBench Startup
    bsr         AllocSys                               ; (seInternalStructures.s) Allocate memory for the internal Structure and save it into SysStructBackup
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    bsr         seCreateStack
    ; Start the Engine *** Open all libraries/deices/etc.
    bsr         openDosLib
    bsr         openGraphicsLib                        ; Open Graphics.library and save its base in the SysStructDatas
    bsr         openIntuitionLib
    bsr         openMathFFPLib                         ; Open MathFFP.library and save its base in the SysStructDatas
    ; **********************
    rts

hotEnd:
    bsr        closeMathFFPLib
    bsr        closeIntuitionLib
    bsr        closeGraphicsLib
    bsr        closeDosLib
    ; **********************
    bsr         seReleaseStack
    ; Release internal structure and quit properly
    bsr         FreeSys                                ; (seSetup.s) Release memory of the Internal Structure
    bsr         cliOrWbFinish                          ; Cli & Workbench proper ends
    rts

; Source Engine Error Handler system
    include "seErrorHandler.asm"

seGameEngine:
    ; Start properly and allocate memory for internal structure
    bsr         coldStart
    ; Start the user/develope emulated/transformed source code run here
    bsr         startHere
    ; **********************
    ; Quit the Engine *** Close all libraries/devices/etc.
    ; **********************
    bsr         hotEnd
    rts
