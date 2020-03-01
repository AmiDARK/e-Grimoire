

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
    beq.s        .errorTooLarge   ; Does not allow string longer than 16382 bytes
    bra.s         .gts1         ; Continue Loop -> Jump .gts1
.gtsFin:
    move.l         (sp)+,a1
    rts                        ; Return to caller.
.errorTooLarge:
    CastErrorID StringSizeTooBig
    