
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS exec.library           *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to exec calls.
;
; A6=loadExec (MACRO)
; exeCall FUNCITONNAME (MACRO)
;
; (D0=Buffer) = AllocClrChipMem(D0=Size)         Allocate cleared (filled with 0) chipram memory
; (D0=Buffer) = AllocChipMem(D0=Size)             Allocate not cleared chipram memory
; (D0=Buffer) = AllocClrFastMem(D0=Size)        Allocate cleared fastram (if available otherwise chip) memory
; (D0=Buffer) = AllocFastMem(D0=Size)           Allocate not cleared fastram (if available otherwise chip) memory
;               FreeMem(A1=Buffer,D0=Size)        Release a memory buffer previously allocated with Memory Allocation 

    include     "exec/types.i"
    include     "exec/initializers.i"
    include     "exec/lists.i"
    include     "exec/nodes.i"
    include     "exec/resident.i"
    include     "exec/alerts.i"
    include     "exec/memory.i"
;    include    "exec/exec_lib.i"
;    include    "exec/exec.s"
	include     "LVO/exec_lib.i"

Chip:           equ $02
Fast:           equ $04
Clear:          equ $10000
Public:         equ $01
   
; *********************************************
; This MACRO load execBase into A6 register
; A6=loadExec
loadExec        MACRO
    move.l      $4,a6
                ENDM

; *********************************************
; This MACRO do a call to a method (parameter \1) of the ExecLibrary.
; Parameters must be set correctly before calling this MACRO
; exeCall FUNCTIONNAME
exeCall         MACRO
    loadExec
    Jsr         _LVO\1(a6)
                ENDM

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

