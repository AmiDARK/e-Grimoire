
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

    include "src/seConfiguration_equ.Asm"              ; Internal Engine configurations (variables buffers, etc.)
    include "src/seInternalStructures_equ.asm"         ; Includes all Source Engine internal data structures
    include "src/seErrorHandler_Equ.asm"               ; Equates to define the existing errors messages.

; ******** Special labels for multiple systems supports
inProcedure     SET 0                                  ; Used to define if we are inside a procedure (=8) or not (=0)
inProcName      SET 0                                  ; Used for Procedure Unique ID
procCallName    SET 0                                  ; Used for CallProcedure unique ID
main:
    bra     seGameEngine

; OS System Libraries;
    include "src/AmigaOS/execLib.asm"
    include "src/AmigaOS/dosLib.asm"
    include "src/AmigaOS/graphicsLib.asm"
    include "src/AmigaOS/intuitionLib.asm"
    include "src/AmigaOS/mathFFPLib.asm"
    include "src/AmigaOS/cliOrWorkbench.asm"

; Includes internal structure setup/release methods
    include "src/seInternalSetup.asm"                  ; Includes all Source Engine internal data structures

; Include the stack system used to cast parameters to a procedure or an engine method.
    include "src/seStackSystem.asm"

; Source Engine Reporter.log system (output to CLI)
    include "src/seReporter.asm"

    include "src/seProceduresSupport.asm"

; Variables Management System
    include "src/vms.asm"                              ; Include the Variable Management System (it includes sub files)
    

coldStart:
    bsr         cliOrWbStartup                         ; Cli & WorkBench Startup
    bsr         AllocSys                               ; (seInternalStructures.s) Allocate memory for the internal Structure and save it into SysStructBackup
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    vmsbuildFullVariablesBuffer                        ; Allocate memory for the whole variables (global+local+ local recursive calls)
    bsr         seCreateStack                          ; Create the stack used to send/receive variables
;    ; Start the Engine *** Open all libraries/deices/etc.
    bsr         openDosLib                             ; Open dos.library and save its base in the SysStructDatas
    bsr         openGraphicsLib                        ; Open graphics.library and save its base in the SysStructDatas
    bsr         openIntuitionLib                       ; Open intuition.library and save its base in the SysStructDatas
    bsr         openMathFFPLib                         ; Open mathffp.library and save its base in the SysStructDatas
;    ; **********************
    rts

hotEnd:
    LoadSys    a5
    bsr        closeMathFFPLib                         ; Close mathffp.library and remove it's pointer from the SysStructDatas
    bsr        closeIntuitionLib                       ; Close intuition.library and remove it's pointer from the SysStructDatas
    bsr        closeGraphicsLib                        ; Close graphics.library and remove it's pointer from the SysStructDatas
    bsr        closeDosLib                             ; Close dos.library and remove it's pointer from the SysStructDatas
;    ; **********************
    bsr         seReleaseStack                        ; Release the stack used to send/receive variables
    vmsDeleteFullVariablesBuffer                       ; Release the memory buffer allocated for all datas.
    bsr         FreeSys                                ; (seSetup.s) Release memory of the Internal Structure
    bsr         cliOrWbFinish                          ; Cli & Workbench proper ends
    rts

; Source Engine Error Handler system
    include "src/seErrorHandler.asm"

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
