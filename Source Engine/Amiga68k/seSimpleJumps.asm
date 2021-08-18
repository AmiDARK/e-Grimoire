; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.03.20                     *
; * Last Update : ----.--.--              *
; * Version : 1.0                         *
; * File : Simple Jumps MACROS            *
; * Author : Frederic Cordier             *
; *****************************************
;
; Label labelNAME                                      ; Create a simple label name
; Gosub labelNAME                                      ; Jump (bsr) to a label. Will require a return to come back
; Goto labelNAME                                       ; do a simple jump (bra) to a label (no return possible).
; Return


; *****************************************************
; 3.3 Add a new label
Label         MACRO
lab_\1:
                ENDM


; *****************************************************
; 3.6 add a GOSUB to a Label
Gosub             MACRO
    cmp.w     #0,procedureDepth(a5)             ; Check if we are inside a Procedure or Function
    beq.s    .ok                             ; NO -> Jump .ok
    CastErrorID        GosubNotAllowedFromInsideAProcedure
.ok:
    add.w     #1,gosubDepth(a5)
    cmp.w    #16384,gosubDepth(a5)
    blt.s    .ok2
    CastErrorID        TooMuchGosubCalledWithoutReturn
.ok2:
    bsr.l     lab_\1
                ENDM

; *****************************************************
; 3.7 add a GOTO to a label (must not be used on Procedure nor function)
Goto             MACRO
    cmp.w     #0,procedureDepth(a5)             ; Check if we are inside a Procedure or Function
    beq.s    .ok                             ; NO -> Jump .ok
    CastErrorID        GosubNotAllowedFromInsideAProcedure
.ok:
    bra.l     lab_\1
                ENDM

; *****************************************************
; 3.8 add a RETURN from a label (called with Gosub) or from inside a Procedure
Return             MACRO
    cmp.w     #0,procedureDepth(a5)             ; Check if we are inside a Procedure or Function
    beq.s    .fromGosub
    EndProcedure \1,\2,\3
.fromGosub:
    sub.w     #1,gosubDepth(a5)
    bpl.s    .ok
    CastErrorID        TooMuchReturnReached
.ok:
    rts
                ENDM
