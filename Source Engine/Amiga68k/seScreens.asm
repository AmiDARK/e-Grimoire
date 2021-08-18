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

seMaxScreens        equ     16                  ; We currently handle a maximum of 16 screens

; *************************************************************** Internal Structures counter
; 1. This macro reset data structure counter
; It must be used to initialize a new structure (before the 1st data of the structure)
sedataReset MACRO
eCount         SET 0
    setL    \1_Previous,1
    setL    \1_Next,1
            ENDM

    sedataReset                                ; Reset counter for data list
    ; *************************************************************** Internal
seMaxPalette equ 256
    setL     EcPhysic,8                        ; Space to handle max 8 bitplanes
    setL     EcLogic,8                         ; Space to handle max 8 bitplanes
    setW     bplAmount,1                       ; Store the bitmaps amount 
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
