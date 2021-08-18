; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : seString                       *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the Source Engine String methods and MACROS
;
; (D0=Size)=getStringSize(A0=String Pointer)
;
; (A0=String Pointer) = CreateDeleteString( A0=String Pointer, D0=String Length or -1 To Delete A0 String)


; ****************************************************************** getStringSize
; This method evaluate the length of the string in the current stack position.
; Input : A0 = Pointer to the string (terminated with 0) to read length
; Output : D0 = Length of the string.
getStringSize:
    move.l         a1,-(sp)
    clr.l         d0             ; Clear the counter
    cmp.l         #0,a0         ; Security for null pointer
    beq.s         .gtsFin     ; Pointer = null -> Jump to end .gtsFin
    move.l         a0,a1
.gts1:
    cmp.b         #0,(a1)+     ; is (a0.b)+ content =0 ?
    beq.s         .gtsFin     ; YES -> Stop counting -> Jump to end .gtsFin
    addq         #1,d0         ; NO -> Increment D0+
    cmp.w         #16382,d0
    beq.s        .gtsFin     ; Does not allow string longer than 16382 bytes
    bra.s         .gts1         ; Continue Loop -> Jump .gts1
.gtsFin:
    move.l         (sp)+,a1
    rts                        ; Return to caller.

; ********************************************
; This method can create or delete a string depending on entered parameters.
; The String length must contain the null terminated (0) character.
; INPUT : A1 = String Pointer, D0 = String Length (or <0 (neg) to delete an existing String)
; OUTPUT : A1 = String Pointer
CreateDeleteString:
    movem.l a1,-(sp)
    tst.l     d0
    bgt.s   createStr                   ; Len > 0 -> Create New String
    bmi.s   deleteStr                   ; Len < 0 -> Delete String
    bra.s   cdsEnd                      ; Len = 0 -> Do nothing.
createStr:
    bsr     AllocClrFastMem            ; Allocate memory for String
    movem.l (sp)+,a1
    rts
deleteStr:
    bsr.b        getStringSize             ; Call seString.s to evaluate the size of the String to delete
    addq    #1,d0                     ; To contain the null terminated character (0)
    move.l     a0,a1                     ; FreeMem requires buffer pointer to be located into a1 (not a0)
    bsr        FreeMm
cdsEnd:
    Move.L     #0,a1                     ; A0 = Null String Pointer
    clr.l     d0                         ; D0 = empty, no character at all. Nothing in.
    movem.l (sp)+,a1
    rts
