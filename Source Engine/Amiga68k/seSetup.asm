
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.31                     *
; * Last Update : 2020.02.08              *
; * Version : 0.2                         *
; * File : Source Engine Setup MACROs     *
; * Author : Frederic Cordier             *
; *****************************************

; *********************************************
; This Macrp load the System Structure pointer -> A5
LoadSys         MACRO
    ; Load the Source Engine internal Data Structure pointer to A5 register
    lea.l       SysStructBackup(pc),\1
    Move.l      (\1),\1             ; \1 = Pointer to Internal System Structure
                ENDM

; *********************************************
; This method allocate memory for the Source Engine internal structure
AllocSys:
    ; [Constructor] Allocate memory for the Source Engine Internal Data Structure
    Move.l      #SysStructureLen,d0             ; D0 = System Structure Bytes Length
    bsr         AllocClrFastMem
    lea.l       SysStructBackup(pc),a0             ; Save System Structure buffer pointer.
    Move.l      d0,(a0)
.asEnd:
    rts


; *********************************************
; This method release memory used for the Source Engine internal structure
FreeSys:
    ; [Destructor] Release memory allocated for the Source Engine internal Data Structure.
    lea.l       SysStructBackup(pc),a0             
    move.l      (a0),a1                                ; A1 = Pointer to the Internal System Structure
    cmp.l       #0,a1
    Beq.s       .fsEnd                                 ; A1 = 0 -> .fsEnd
    Move.l      #SysStructureLen,d0                ; D0 = System Structure Bytes Length
    bsr         FreeMm                                 ; Release memory used by Internal System Structure
.fsEnd:
    lea.l       SysStructBackup(pc),a0
    Move.L      #0,(a0)                                ; Clear memory to be sure it will no more be used
    move.l      #0,a5                                  ; Clear the A5 register that uses
    rts


openLibs:
    bsr         openDosLib
    bsr         openGraphicsLib                        ; Open Graphics.library and save its base in the SysStructDatas
    bsr         openIntuitionLib
    bsr         openMathFFPLib                         ; Open MathFFP.library and save its base in the SysStructDatas
    rts

closeLibs:
    bsr        closeMathFFPLib
    bsr        closeIntuitionLib
    bsr        closeGraphicsLib
    bsr        closeDosLib
    rts