
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
; (A0=Buffer) = AllocClrChipMem(D0=Size)         Allocate cleared (filled with 0) chipram memory
; (A0=Buffer) = AllocChipMem(D0=Size)             Allocate not cleared chipram memory
; (A0=Buffer) = AllocClrFastMem(D0=Size)        Allocate cleared fastram (if available otherwise chip) memory
; (A0=Buffer) = AllocFastMem(D0=Size)           Allocate not cleared fastram (if available otherwise chip) memory
;               FreeMem(A1=Buffer,D0=Size)        Release a memory buffer previously allocated with Memory Allocation 




;    include "exec/types.i"
;    include "exec/initializers.i"
;    include "exec/lists.i"
;    include "exec/nodes.i"
;    include "exec/resident.i"
;    include "exec/alerts.i"
;    include "exec/memory.i"
;    include "exec/exec_lib.i"
;    include "exec/exec.s"
	include "LVO/exec_lib.i"

Chip:        equ $02
Fast:        equ $04
Clear:        equ $10000
Public:        equ $01
   
; *********************************************
; This MACRO load execBase into A6 register
; A6=loadExec
loadExec        MACRO
    move.l         $4,a6
                ENDM

; *********************************************
; This MACRO do a call to a method (parameter \1) of the ExecLibrary.
; Parameters must be set correctly before calling this MACRO
; exeCall FUNCITONNAME
exeCall         MACRO
    loadExec
    Jsr         _Exec_\1(a6)
                ENDM

; *********************************************
; (A0=Buffer)=AllocClrChipMem(D0=Size)
AllocClrChipMem:
    movem.l     d0-d1/a0-a1/a6,-(sp)
    move.l         #Chip|Clear,d1
    exeCall        AllocMem
    movem.l     (sp)+,d0-d1/a0-a1/a6
    rts

; *********************************************
; (A0=Buffer)=AllocChipMem(D0=Size)
AllocChipMem:
    movem.l     d0-d1/a0-a1/a6,-(sp)
    move.l         #Chip,d1
    exeCall        AllocMem
    movem.l     (sp)+,d0-d1/a0-a1/a6
    rts

; *********************************************
; (A0=Buffer)=AllocClrFastMem(D0=Size)
AllocClrFastMem:
    movem.l     d0-d1/a0-a1/a6,-(sp)
    move.l         #Public|Clear,d1
    exeCall        AllocMem
    movem.l     (sp)+,d0-d1/a0-a1/a6
    rts

; *********************************************
; (A0=Buffer)=AllocFastMem(D0=Size)
AllocFastMem:
    movem.l     d0-d1/a0-a1/a6,-(sp)
    move.l         #Public,d1
    exeCall        AllocMem
    movem.l     (sp)+,d0-d1/a0-a1/a6
    rts

; *********************************************
; FreeMem(A1=Buffer,D0=Size)
FreeMm:
    movem.l     d0-d1/a0-a1/a6,-(sp)
    exeCall        FreeMem
    movem.l     (sp)+,d0-d1/a0-a1/a6
    rts


