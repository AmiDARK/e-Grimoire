; ***************************************************
; * Source Engine                                   *
; *-------------------------------------------------*
; * Date : 2020.01.24                               *
; * Last Update : 2020.01.28                        *
; * Version : 0.2                                   *
; * File : Source Engine Internal System Structures *
; * Author : Frederic Cordier                       *
; ***************************************************
; This file contains macros and informations to create internal Structures
; for the Source Engine. This file is devoted to be 'included' by the parser
; in the final source code, and used directly by the header_coldStart.s file
; when the Source Engine is used directly from a 68k assembler.

; MACROS to setup structure contents :
; sedataReset             Tell that we start to define a new internal Structures
; setL NAME,COUNT         Add COUNT Integer(s) (.l) variables under the name NAME
; setW NAME,COUNT         Add COUNT Word(s) (.w) variables under the name NAME
; setB NAME,COUNT         Add COUNT Byte(s) (.b) variables under the name NAME
; countData NAME         Save the current size of the structure under a constant named NAME
;
; MACROS to allocate memory for structures :
; A0=AllocSys
; A0=AllocScreen

; *************************************************************** Internal Structures counter
; 1. This macro reset data structure counter
; It must be used to initialize a new structure (before the 1st data of the structure)
sedataReset MACRO
eCount         SET 0
            ENDM

; *****************************************************
; 2. This macro insert an amount of integer to the counter
setL         MACRO
eCount         SET eCount-4*(\2)
se\1         equ eCount
            ENDM

; *****************************************************
; 3. This macro insert an amount of word to the counter
setW         MACRO
eCount         SET eCount-2*(\2)
se\1        equ eCount
            ENDM

; *****************************************************
; 4. This macro insert an amount of bytes to the counter
setB         MACRO
eCount         SET eCount-1*(\2)
se\1         equ eCount
            ENDM

; *****************************************************
; 5. This macro makes a variable to be set to reflect the counter value
; This macro must be used at the end of a structure definition to store the size of the structure
countData     MACRO
se\1        equ eCount
            ENDM

; **************************************************** Internal Source Engine system_structures

    sedataReset                             ; Reset counter for data list
    ; *************************************************************** Internal
    setL    Task,1                             ; The Source Engine Task
    setW    sysDMA,1                         ; Register to save Amiga System DMA
    setB    IsAgaDetected,1                    ; = 0 if ECS, =1 if AGA
    setB    unused1,1                         ; To word alignment.
    ; *************************************************************** OS Libraries
    setL     DosBase,1                         ; Pointer to the dos.library
    setL    GraphicsBase,1                    ; Pointer to the graphics.library
    setL    IntuitionBase,1                    ; Pointer to the Intuition.library
    setL    LayersBase,1                     ; Pointer to the Layers.library
    setL     MathFFPBase,1                    ; Pointer to the mathFFP.library

    ; *************************************************************** Data Areas for global/local datas
    setL     globalDatas,1                     ; Pointer to the global data definition of the program (deleted at the end of the program)
    setL     globalSize,1                      ; Size of the global Data Structure
    setL     localDatas,1                     ; Pointer to the current procedure/Function/ClassMethod data area (deleted when it is quitted)
    setL     localSize,1                     ; Size of the Local Data structure
    setL    ParametersList,1                 ; Pointer to the list of parameters to send to the method/function
    setL     StackAdr,1                         ; Current Position in the parameters, temp values Stack
    setL     ParamsSize,1                     ; Size of the stack in bytes
    setW     TempVars,5*16                    ; 5*.w ( = 2*.l + 1*.w ) * 16 Temporar Variables
    ; *************************************************************** Screens Datas
seMaxScreens    equ        16                    ; We currently handle a maximum of 16 screens
    setL    Screens,seMaxScreens            ; Screens structures
    setL    ScrPri,seMaxScreens                ; Screens priority list
    setW    CurrentScreen,1                     ; ScreenID ( 0-seMaxScreens-1) to Define in which screen drawing will be done

    ; *************************************************************** Copper List support
    setL    ForceRefresh,1                     ; Data to define the required level of refreshing (Coppers, Screens, etc.)
    setL    CopLogic,1                        ; Pointer of memory block for logic copper (non visible one)
    setL    CopView,1                        ; Pointer of memory block for current copper (used to display screen)
    setL    CopSprites,1                     ; Relative shifting from the start of copper to reach the 1st sprite.
    setL    CopPalettes,1                     ; Relative shifting from the start of copper to reach the 1st color of the palette.

    ; *************************************************************** Blitter Objects
    setL    BobBank,1                         ; Pointer of memory block that define Blitter obejcts

    ; *************************************************************** Debug datas
    setL     CurrentLine,1                     ; Where is the run in the current source code ?
    setL     FileName,1                         ; Pointer to the name of the CurrentFile
    ; *************************************************************** Global structure length
    countData    SysStructureLen                ; The length in bytes of the structure defined above.

; *********************************************
; This method allocate memory for the Source Engine internal structure
AllocSys:
    cmp.l    #0,SysStructBackup             ; Verify is System Structure was already allocated or not
    bne.s     .asEnd                            ; If != 0 -> .asEnd (no new allocation)
    Move.l    #seSysStructureLen,d0             ; D0 = System Structure Bytes Length
    bsr.w   AllocClrFastMem
    lea     SysStructBackup,a0             ; Save System Structure buffer pointer.
    Move.l    a1,(a0)
.asEnd:
    rts

loadSys:
    Move.l     SysStructBackup,a5             ; A5 = Pointer to Internal System Structure
    rts

; *********************************************
; This method release memory used for the Source Engine internal structure
FreeSys:
    Move.l    SysStructBackup,a1             ; A0 = Pointer to the Internal System Structure
    Beq.s     .fsEnd                             ; A0 = 0 -> .fsEnd
    Move.l    #seSysStructureLen,d0             ; D0 = System Structure Bytes Length
    bsr.w   FreeMm                              ; Release memory used by Internal System Structure
.fsEnd:
    Move.L    #0,SysStructBackup             ; Clear memory to be sure it will no more be used
    rts

; **************************************************** Screen Source Engine system_structures

    sedataReset                             ; Reset counter for data list
    ; *************************************************************** Internal
seMaxPalette     equ        256
    setL     EcPhysic,8                         ; Space to handle max 8 bitplanes
    setL     EcLogic,8                        ; Space to handle max 8 bitplanes
    setW     bplAmount,1                     ; Store the bitmaps amount 
    setL     ColorAmount,1                     ; Store the amount of colors in the screen
    setL     scrCon0,1                         ; BplCon0 datas
    setL     scrCon1,1                         ; BplCon1 datas
    setL     scrCon2,1                         ; BplCon2 datas
    setL     scrCon3,1                         ; BplCon3 datas
    setW     dpf2cshift,1                     ; Define which color palette is used for 2nd layer in dual playfield

    setL     colPalette,seMaxPalette            ; Store the 256 colors of the screen
    countData    ScrStructureLen                ; The length in bytes of the structure defined above.

; ********************************************* AllocScreen
; This macro allocate memory for 1 Screen Structure.
; Input : D0 = Screen Number
AllocScreen 	MACRO
    Move.l    #ScrStructureLen,d0
    bsr.l   AllocClrFastMem
    	ENDM

; ********************************************* FreeScreen
; This macro allocate memory for 1 Screen Structure.
FreeScreen 		MACRO
    bsr.l   FreeMm
    Clr.l    a0
            ENDM
