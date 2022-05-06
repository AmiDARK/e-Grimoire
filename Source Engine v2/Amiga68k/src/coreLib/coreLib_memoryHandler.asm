; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Memory Handler functions         *
; * Author : Frederic Cordier                             *
; *********************************************************

Chip:           equ $02
Fast:           equ $04
Clear:          equ $10000
Public:         equ $01

; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
; This method allocate memory for the Source Engine internal structure
AllocSys:
    ; [Constructor] Allocate memory for the Source Engine Internal Data Structure
    Move.l      #SysStructureLen,d0                    ; D0 = System Structure Bytes Length
    bsr         AllocClrFastMem
    lea.l       SysStructBackup(pc),a0                 ; Save System Structure buffer pointer.
    Move.l      d0,(a0)
    rts

; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
; This method release memory used for the Source Engine internal structure
FreeSys
    ; [Destructor] Release memory allocated for the Source Engine internal Data Structure.
    lea.l       SysStructBackup(pc),a0             
    move.l      (a0),a1                                ; A1 = Pointer to the Internal System Structure
    cmp.l       #$0,a1
    Beq.s       .fsEnd                                 ; A1 = 0 -> .fsEnd
    Move.l      #SysStructureLen,d0                    ; D0 = System Structure Bytes Length
    bsr         FreeMm                                 ; Release memory used by Internal System Structure
.fsEnd:
    lea.l       SysStructBackup(pc),a0
    Move.L      #0,(a0)                                ; Clear memory to be sure it will no more be used
    move.l      #0,a5                                  ; Clear the A5 register that uses
    rts



; *********************************************
; (D0=Buffer)=AllocClrChipMem(D0=Size)
AllocClrChipMem:
    tst.l       d0
    beq.s       execErr1                               ; Buffer Size = 0 -> Error
    move.l      #Chip|Clear,d1
    exeCall     AllocMem
    rts

; *********************************************
; (D0=Buffer)=AllocChipMem(D0=Size)
AllocChipMem:
    tst.l       d0
    beq.s       execErr1                               ; Buffer Size = 0 -> Error
    move.l      #Chip,d1
    exeCall     AllocMem
    rts

; *********************************************
; (D0=Buffer)=AllocClrFastMem(D0=Size)
AllocClrFastMem:
    tst.l       d0
    beq.s       execErr1                               ; Buffer Size = 0 -> Error
    move.l      #Public|Clear,d1
    exeCall     AllocMem
    rts

; *********************************************
; (D0=Buffer)=AllocFastMem(D0=Size)
AllocFastMem:
    tst.l       d0
    beq.s       execErr1                               ; Buffer Size = 0 -> Error
    move.l      #Public,d1
    exeCall     AllocMem
    rts

; *********************************************
; FreeMem(A1=Buffer,D0=Size)
FreeMm:
    tst.l       d0
    beq.s       execErr2                               ; Buffer Size = 0 -> Error
    cmp.l       #0,a1
    beq.s       execErr3                               ; Pointer = NULL -> Error
    exeCall     FreeMem
noFM:
    rts

execErr1:
    CastErrorID CannotAllocateZeroBytesBuffer
execErr2:
    CastErrorID CannotReleaseZeroBytesBuffer
execErr3:
    CastErrorID CannotReleaseNullPointerBuffer

; *********************************************
; ClearSmallMemory(A1=Buffer,D0=Size)
clearSmallMemory:
    cmp.l       #1,d0
    bgt.s       clr1
clrS:
    clr.b       (a1)+                                  ; 1 byte to clear
    bra         clrEnd
clr1:
    sub.l       #2,d0
clrM:
    clr.w       (a1)+
    sub.l       #2,d0
    cmp.l       #1,d0
    beq.s       clrS
    cmp.l       #0,d0
    bpl.s       clrM
clrEnd:
    rts
