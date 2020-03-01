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

MaxTempVarBuffer    equ     16                  ; Set the maximum of TempVariables that can be pushed in Stack (must allocate memory buffer)
seMaxScreens        equ     16                  ; We currently handle a maximum of 16 screens
StackBufferSize     equ     256

; *************************************************************** Internal Structures counter
; 1. This macro reset data structure counter
; It must be used to initialize a new structure (before the 1st data of the structure)
sedataReset MACRO
eCount         SET 0
    setL    \1_Previous,1
    setL    \1_Next,1
            ENDM

; *****************************************************
; 2. This macro insert an amount of integer to the counter
setL         MACRO
eCount         SET eCount-4*(\2)
\1         equ eCount
            ENDM

; *****************************************************
; 3. This macro insert an amount of word to the counter
setW         MACRO
eCount         SET eCount-2*(\2)
\1        equ eCount
            ENDM

; *****************************************************
; 4. This macro insert an amount of bytes to the counter
setB         MACRO
eCount         SET eCount-1*(\2)
\1         equ eCount
            ENDM


; *****************************************************
; 5. This macro makes a variable to be set to reflect the counter value
; This macro must be used at the end of a structure definition to store the size of the structure
countData     MACRO
se\1        equ eCount
            ENDM

; **************************************************** Internal Source Engine system_structures

    sedataReset Global                         ; Reset counter for data list

    ; *************************************************************** Internal
    setL    Task,1                             ; The Source Engine Task
    setW    sysDMA,1                           ; Register to save Amiga System DMA
    setB    IsAgaDetected,1                    ; = 0 if ECS, =1 if AGA, =2 if RTG (not yet supported), =3 for VAMPIRE ? (not yet supported)
    setB    unused1,1                          ; To word alignment.

    ; *************************************************************** OS Libraries
    setL    DosBase,1                          ; Pointer to the dos.library
    setL    GraphicsBase,1                     ; Pointer to the graphics.library
    setL    IntuitionBase,1                    ; Pointer to the Intuition.library
    setL    LayersBase,1                       ; Pointer to the Layers.library
    setL    MathFFPBase,1                      ; Pointer to the mathFFP.library

    ; *************************************************************** Screens Datas
    setL    Screens,seMaxScreens               ; Screens structures
    setL    ScrPri,seMaxScreens                ; Screens priority list
    setW    CurrentScreen,1                    ; ScreenID ( 0-seMaxScreens-1) to Define in which screen drawing will be done

    ; *************************************************************** Copper List support
    setL    ForceRefresh,1                     ; Data to define the required level of refreshing (Coppers, Screens, etc.)
    setL    CopLogic,1                         ; Pointer of memory block for logic copper (non visible one)
    setL    CopView,1                          ; Pointer of memory block for current copper (used to display screen)
    setL    CopSprites,1                       ; Relative shifting from the start of copper to reach the 1st sprite.
    setL    CopPalettes,1                      ; Relative shifting from the start of copper to reach the 1st color of the palette.

    ; *************************************************************** Data Areas for global/local datas
    setW    noTypeCheck,1                      ; if set to 0, variables will work like in PYTHON with no type checking and overwrite data.
    setL    globalDatas,1                      ; Pointer to the global data definition of the program (deleted at the end of the program)
    setL    globalSize,1                       ; Size of the global Data Structure
    setL    localDatas,1                       ; Pointer to the current procedure/Function/ClassMethod data area (deleted when it is quitted)
    setL    localSize,1                        ; Size of the Local Data structure
    setL    StackAdr,1                         ; Current Position in the parameters, temp values Stack
    setL    ZeStack,StackBufferSize            ; The Stack inside which StackAdr point to
    setL    ParametersList,1                   ; Pointer to the list of parameters to send to the method/function
    setL    ParamsSize,1                       ; Size of the stack in bytes
    setL    TempVars,1                         ; Memory Buffer where each TempVar is : 5*.w ( = 2*.l + 1*.w ) ( * MaxTempVarBuffer for total Temporar Variables )
    setW    procedureDepth,1                   ; Security to prevent any goto or gosub to be used from inside a procedure.
    setW    gosubDepth,1                       ; Security to prevent any goto or gosub to be used from inside a procedure.

    ; *************************************************************** Blitter Objects
    setL    BobBank,1                          ; Pointer of memory block that define Blitter obejcts

    ; *************************************************************** Debug datas
    setL     CurrentLine,1                     ; Where is the run in the current source code ?
    setL     FileName,1                        ; Pointer to the name of the CurrentFile
    setL     loggerFile,1                      ; BPCL to the Output CLI: CON: for debug & messages.
    
    ; *************************************************************** Global structure length
    countData    SysStructureLen               ; The length in bytes of the structure defined above.

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
