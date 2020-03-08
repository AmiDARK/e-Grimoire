

; ****************************************************************** getStringSize
; This method evaluate the length of the string in the current stack position.
; Input : A0 = Pointer to the string (terminated with 0) to read length
; Output : D0 = Length of the string.
getStringSize:
    movem.l     a1,-(sp)
    cmp.l       #0,a0                                  ; Security for null pointer
    beq.s       .errNoStringAtAll
    move.l      a0,a1
    clr.l       d0                                     ; Clear the counter
.gts1:
    cmp.b       #0,(a1)+                               ; is (a0.b)+ content =0 ?
    beq.s       .gtsFin                                ; YES -> Stop counting -> Jump to end .gtsFin
    add.l       #1,d0                                  ; NO -> Increment D0+
    cmp.w       #16382,d0
    ble.s       .gts1
    bra.s       .errStringTooBig                       ; Does not allow string longer than 16382 bytes
.gtsFin:
    movem.l     (sp)+,a1
    rts                        ; Return to caller.
.errNoStringAtAll:
    CastErrorID CannotEValuateStringUsingNullPointer
.errStringTooBig:
    CastErrorID StringSizeTooBig

; ****************************************************************** getStringSize
; This method evaluate the length of the string in the current stack position.
; Input : A0 = Pointer to the string (terminated with 0) to read length
; Output : A0 = Cloned String
cloneString:
    cmp.l       #0,a0
    beq.s       .errNoStringAtAll
    movem.l     a1/d0/d7,-(sp)
    move.l      a0,d7                                  ; Save a0 to d7 register
    bsr.b       getStringSize                          ; Evaluate the String length
    add.l       #1,d0                                  ; Count 0 at the end for the new String
    bsr         AllocClrFastMem
    tst.l       d0
    beq.s       .errCannotAllocateString
    move.l      d7,a0                                  ; a0 = Source
    move.l      d0,a1                                  ; a1 = Target
.loop:
    move.b      (a0)+,(a1)+
    cmp.b       #0,(a0)
    bne.s       .loop
    move.l      d0,a0
    movem.l     (sp)+,a1/d0/d7
    rts
.errNoStringAtAll:
    CastErrorID CannotEValuateStringUsingNullPointer
.errCannotAllocateString:
    CastErrorID NotEnoughFreeMemory
