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
eCount          SET 0
    setL    \1_Previous,1
    setL    \1_Next,1
                ENDM

; *****************************************************
; 2. This macro insert an amount of integer to the counter
setL            MACRO
\1      equ     eCount
eCount          SET eCount+4*(\2)
                ENDM

; *****************************************************
; 3. This macro insert an amount of word to the counter
setW            MACRO
\1      equ     eCount
eCount          SET eCount+2*(\2)
                ENDM

; *****************************************************
; 4. This macro insert an amount of bytes to the counter
setB            MACRO
\1      equ     eCount
eCount          SET eCount+1*(\2)
                ENDM

; *****************************************************
; 5. This macro makes a variable to be set to reflect the counter value
; This macro must be used at the end of a structure definition to store the size of the structure
countData       MACRO
\1      equ     eCount
                ENDM

; **************************************************** Internal Source Engine system_structures

    sedataReset Global                         ; Reset counter for data list

    ; *************************************************************** Internal
    setL    Task,1                                   ; The Source Engine Task
    setW    sysDMA,1                                 ; Register to save Amiga System DMA
    setB    IsAgaDetected,1                          ; = 0 if ECS, =1 if AGA, =2 if RTG (not yet supported), =3 for VAMPIRE ? (not yet supported)
    setB    unused1,1                                ; To word alignment.

    ; *************************************************************** OS Libraries
    setL    DosBase,1                                ; Pointer to the dos.library
    setL    GraphicsBase,1                           ; Pointer to the graphics.library
    setL    IntuitionBase,1                          ; Pointer to the Intuition.library
    setL    LayersBase,1                             ; Pointer to the Layers.library
    setL    MathFFPBase,1                            ; Pointer to the mathFFP.library

    ; *************************************************************** Screens Datas
    setL    Screens,seMaxScreens                     ; Screens structures
    setL    ScrPri,seMaxScreens                      ; Screens priority list
    setW    CurrentScreen,1                          ; ScreenID ( 0-seMaxScreens-1) to Define in which screen drawing will be done

    ; *************************************************************** Copper List support
    setL    ForceRefresh,1                           ; Data to define the required level of refreshing (Coppers, Screens, etc.)
    setL    CopLogic,1                               ; Pointer of memory block for logic copper (non visible one)
    setL    CopView,1                                ; Pointer of memory block for current copper (used to display screen)
    setL    CopSprites,1                             ; Relative shifting from the start of copper to reach the 1st sprite.
    setL    CopPalettes,1                            ; Relative shifting from the start of copper to reach the 1st color of the palette.

    ; *************************************************************** Data Areas for global/local datas
    setW    noTypeCheck,1                            ; if set to 0, variables will work like in PYTHON with no type checking and overwrite data.
    setL    fullVarBuffer,1                          ; Set start of the whole variables buffer (contains all global & locals + recursives variables)
    setL    fvbPos,1                                 ; The position where to start the next variables buffer.
    setL    globalDatas,1                            ; Pointer to the global data definition of the program (deleted at the end of the program)
    setL    globalSize,1                             ; Size of the global Data Structure
    setL    localDatas,1                             ; Pointer to the current procedure/Function/ClassMethod data area (deleted when it is quitted)
    setL    localSize,1                              ; Size of the Local Data structure

    ; *************************************************************** Data Areas for global/local datas
    setL    StackAdr,1                               ; Current Position in the parameters, temp values Stack
    setL    ZeStackPos,1                             ; The Stack inside which StackAdr point to
    setL    StackSize,1                              ;
    setL    StackAdrPos,1                            ; Current Adress position in the Stack
    setL    ParametersList,1                         ; Pointer to the list of parameters to send to the method/function
    setL    ParamsSize,1                             ; Size of the stack in bytes
    setL    TempVars,1                               ; Memory Buffer where each TempVar is : 5*.w ( = 2*.l + 1*.w ) ( * MaxTempVarBuffer for total Temporar Variables )
    setW    procedureDepth,1                         ; Security to prevent any goto or gosub to be used from inside a procedure.
    setW    gosubDepth,1                             ; Security to prevent any goto or gosub to be used from inside a procedure.

    ; *************************************************************** Blitter Objects
    setL    BobBank,1                                ; Pointer of memory block that define Blitter obejcts

    ; *************************************************************** Debug datas
    setL     CurrentLine,1                           ; Where is the run in the current source code ?
    setL     FileName,1                              ; Pointer to the name of the CurrentFile
    
    ; *************************************************************** Global structure length
    countData    SysStructureLen                     ; The length in bytes of the structure defined above.


; *********************************************
; This method allocate memory for the Source Engine internal structure
AllocSys:
    ; [Constructor] Allocate memory for the Source Engine Internal Data Structure
    Move.l      #SysStructureLen,d0                    ; D0 = System Structure Bytes Length
    bsr         AllocClrFastMem
    lea.l       SysStructBackup(pc),a0                 ; Save System Structure buffer pointer.
    Move.l      d0,(a0)
    rts


; *********************************************
; This method release memory used for the Source Engine internal structure
FreeSys:
    ; [Destructor] Release memory allocated for the Source Engine internal Data Structure.
    lea.l       SysStructBackup(pc),a0             
    move.l      (a0),a1                                ; A1 = Pointer to the Internal System Structure
    cmp.l       #0,a1
    Beq.s       .fsEnd                                 ; A1 = 0 -> .fsEnd
    Move.l      #SysStructureLen,d0                    ; D0 = System Structure Bytes Length
    bsr         FreeMm                                 ; Release memory used by Internal System Structure
.fsEnd:
    lea.l       SysStructBackup(pc),a0
    Move.L      #0,(a0)                                ; Clear memory to be sure it will no more be used
    move.l      #0,a5                                  ; Clear the A5 register that uses
    rts

; This Macrp load the System Structure pointer -> A5
LoadSys         MACRO
    ; Load the Source Engine internal Data Structure pointer to A5 register
    lea.l       SysStructBackup(pc),\1
    Move.l      (\1),\1             ; \1 = Pointer to Internal System Structure
                ENDM



; Backup the memory pointer to the Source Engine Internal Structure
SysStructBackup:    dc.l    0
                    even
