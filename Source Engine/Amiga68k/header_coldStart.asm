
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
    include "seVariables.asm"
    include "seGlobalVariables.asm"
    include "seLocalVariables.asm"
    include "seProcedures.asm"

coldStart:
    bsr         cliOrWbStartup                         ; Cli & WorkBench Startup
    bsr         AllocSys                               ; (seInternalStructures.s) Allocate memory for the internal Structure and save it into SysStructBackup
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    bsr         seCreateStack                          ; Create the stack used to send/receive variables
    ; Start the Engine *** Open all libraries/deices/etc.
    bsr         openDosLib                             ; Open dos.library and save its base in the SysStructDatas
    bsr         openGraphicsLib                        ; Open graphics.library and save its base in the SysStructDatas
    bsr         openIntuitionLib                       ; Open intuition.library and save its base in the SysStructDatas
    bsr         openMathFFPLib                         ; Open mathffp.library and save its base in the SysStructDatas
    ; **********************
    rts

hotEnd:
    LoadSys    a5
    bsr        closeMathFFPLib                         ; Close mathffp.library and remove it's pointer from the SysStructDatas
    bsr        closeIntuitionLib                       ; Close intuition.library and remove it's pointer from the SysStructDatas
    bsr        closeGraphicsLib                        ; Close graphics.library and remove it's pointer from the SysStructDatas
    bsr        closeDosLib                             ; Close dos.library and remove it's pointer from the SysStructDatas
    ; **********************
    bsr         seReleaseStack                         ; Release the stack used to send/receive variables
    bsr         FreeSys                                ; (seSetup.s) Release memory of the Internal Structure
    bsr         cliOrWbFinish                          ; Cli & Workbench proper ends
    rts

; Source Engine Error Handler system
    include "seErrorHandler.asm"

seGameEngine:
    ; **********************
    ; 1st thing to do in case error occured in the program.
    SaveSP                                             ; Uses a MACRO to not have any Bsr/Jsr in the go.
    ; **********************
    ; Start properly and allocate memory for internal structure
    bsr         coldStart
    ; **********************
    ; Start the user/develope emulated/transformed source code run here
    bsr         startHere
    ; Quit the Engine *** Close all libraries/devices/etc.
    ; **********************
    bsr         hotEnd
    ; If program leave correctly, no need to restore SP as it should be ok. But for security
    LoadSP
    rts
