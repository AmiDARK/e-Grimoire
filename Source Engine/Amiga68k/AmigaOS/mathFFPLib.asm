
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS mmathFFP.library       *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to mmathFFP.library calls.
;
; openMathFFPLib()
; closeMathFFPLib()
; LoadMathFFPLib               (MACRO)
; callMathFFP \Method          (MACRO)
; Stack.Int = ConvertFltToInt( Stack.Float )
; DO.Int = privConvertFltToInt( DO.Float )
; Stack.FFP = ConvertIntToFlt( Stack.Integer )
; D0.FFP = privConvertIntToFlt( D0.Integer )
; Stack.FFP = ConvertStrToFlt( Stack.StringPointer )
; D0.FFP = privConvertStrToFlt( A0.String )
; Stack.Int = ConvertStrToInt( Stack.StringPointer )
; D0.Int = privConvertStrToInt( A0.String )

    include     "LVO/mathffp_lib.i"
    include     "seErrorEquates.asm"                   ; Include the error Handler equates and MACROs

openMathFFPLib:
    lea         mathFFPName(pc),a1     ; Load the "intuition.library" name to a1
    Moveq       #0,d0                ; Open All versions of intuition.library
    exeCall     OpenLibrary
    tst.l       d0
    beq.s       .noLib3
    move.l      d0,MathFFPBase(a5)     ; Save intuition.library BASE to gfxBase
    rts
.noLib3:
    CastErrorID CannotOpenMathFFPLibrary

closeMathFFPLib
    move.l      MathFFPBase(a5),a1
    cmp.l       #0,a1
    beq.s       cMFFPEnd
    exeCall     CloseLibrary
cMFFPEnd:
    rts

loadMathFFPLib          MACRO
    move.l      MathFFPBase(a5),a6
                        ENDM

callMathFFP             MACRO
    jsr     _LVO\1(a6)
                        ENDM

; *************************************************************
; Convert a Floating Point Number to an Integer. [Call using Stack]
; INPUT: Stack Float Value (a4)
; OUTPUT : Stack Integer Number (a4)
ConvertFltToInt:
    move.l  -(a4),d0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Floating Point Number to an Integer. [Call not using Stack]
; INPUT: D0 = Float Value
; OUTPUT : D0 = Integer Number
privConvertFltToInt:
    loadMathFFPLib
    callMathFFP SPFix
    ; Return Value in D0 or STACK depending on the way the method was called.
    cmp.b   #1,convertToSTACK
    bne.s   .finInt
    Move.b  #0,convertToSTACK           ; Clear STACK flag.
    move.l  d0,(a4)+                    ; Push to Stack if entered from Stack
.finInt:
    rts


; *************************************************************
; Convert an Integer to a Floating Point Number. [Call using Stack]
; INPUT: Stack Integer Value (a4)
; OUTPUT : Stack FFP Number (a4)
ConvertIntToFlt:
    move.l  -(a4),d0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Static String into a Floating Point Number. [Call not using Stack]
; INPUT: D0 = Integer Value
; OUTPUT : D0 = FFP Number
privConvertIntToFlt:
    loadMathFFPLib
    callMathFFP SPFlt
    ; Return Value in D0 or STACK depending on the way the method was called.
    cmp.b   #1,convertToSTACK
    bne.s   .finInt
    Move.b  #0,convertToSTACK           ; Clear STACK flag.
    move.l  d0,(a4)+                    ; Push to Stack if entered from Stack
.finInt:
    rts

; *************************************************************
; Convert a Static String into a Floating Point Number. [Call using Stack]
; INPUT: Stack String Pointer (a4)
; OUTPUT : Stack FFP Number (a4)
ConvertStrToFlt:
    move.l  -(a4),a0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Static String into a Floating Point Number. [Call not using Stack]
; INPUT: A0 = String Pointer
; OUTPUT : D0 = FFP Number
privConvertStrToFlt:
    movem.l a0-a3/d1-d7,-(sp)           ; Save volatile registers
    bsr.w   getStrDatas                 ; Call the sub-routine that extract all datas from the String (Integer, mantisse, exponent, signs, etc.)
    loadMathFFPLib                      ; 5.1 load MathBase->A6
    ; Convert the mantisse part of the number to Floating Number
    Move.l  d6,d0                       ; 5.2 Convert MANTISSE Value to FLT
    callMathFFP SPFlt
    move.l  d0,d6                       ;                                  ******** D6 = Mantisse converted to floating number ********

    ; Convert the Mantisse exponent part to Floating Number
    Move.l  d5,d0                       ; 5.3 Convert Mantisse Exponent to Float
    callMathFFP SPFlt
    move.l  d0,d1                       ; D1 = Mantisse default exponent
    Move.l  d6,d0                       ; D0 = Mantisse
    callMathFFP SPDiv                   ; 5.4 Divide mantisse with its exponent divider -> D0 = D0 (Mantisse) / D1 (Mantisse Exponent)
    move.l  d0,d6                       ;                                   ******** D6 / Exponent = Final Mantisse converted to floating number ********

    Move.l  d7,d0                       ; 6.4 Convert the Integer part of the float number
    callMathFFP SPFlt
    Move.l  d6,d1
    callMathFFP SPAdd                   ; 6.5 Add the integer part and the float part.
    Move.l  d0,d7                       ;                                   ******** D7 = Integer + Mantisse part of the number (without sign nor final exponent)

    cmp.b   #1,d4                       ; 6.6 Check if global float number sign is negative or not.
    bne.s   .cv1
    Move.l  #-1,d0
    callMathFFP SPFlt
    Move.l  d7,d1
    callMathFFP SPMul                   ; Makes number being negative.
    Move.l  d0,d7                       ;                                   ******** D7 = Integer + Mantisse part of the number with Sign (without final exponent)
.cv1:
    Tst.l   d3                          ; 6.7 Verify if there was a Exxx value at the end of the float number String definition
    beq.s   .endOfConv
    move.l  d3,d0
    callMathFFP SPFlt                   ; Exponent converted to float number
    move.l  d0,d1                       ; D1 = Final Exponent E-04 or e56, etc..
    move.l  d7,d0                       ; D0 = Floating Number
    cmp.b   #1,d2
    beq.s   .expIsNeg
.expIsPos:
    callMathFFP SPMul                   ; Mulu float number by its exponent to get the final number
    bra.s   .endOfConv
.expIsNeg:
    callMathFFP SPDiv                   ; D0 = D0 (Float Number) / D1 (Exponent)
.endOfConv:
    ; Return Value in D0 or STACK depending on the way the method was called.
    movem.l (sp)+,a0-a3/d1-d7           ; Load original registers values as when entered the method
    cmp.b   #0,convertToSTACK
    beq.s   .fin
    Move.b  #0,convertToSTACK           ; Clear STACK flag.
    move.l  d0,(a4)+                    ; Push to Stack if entered from Stack
.fin:
    rts

; *************************************************************
; Convert a Static String into an Integer Number. [Call using Stack]
; INPUT: Stack String Pointer (a4)
; OUTPUT : Stack Integer Number (a4)
ConvertStrToInt:
    move.l  -(a4),a0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Static String into an Integer Number. [Call not using Stack]
; INPUT: A0 = String Pointer
; OUTPUT : D0 = Integer Number
privConvertStrToInt:
    movem.l a0-a3/d1-d7,-(sp)           ; Save volatile registers
    bsr.b   getStrDatas                 ; Call the sub-routine that extract all datas from the String (Integer, mantisse, exponent, signs, etc.)
    move.l  d7,d0                       ; D0 = The Integer part of the number
    cmp.b   #1,d4
    bne.s   .ct1
    Neg.l   d0                          ; Negativise D0.
.ct1:
    ; Return Value in D0 or STACK depending on the way the method was called.
    movem.l (sp)+,a0-a3/d1-d7          ; Load original registers values as when entered the method
    cmp.b   #0,convertToSTACK
    beq.s   .fin
    Move.b  #0,convertToSTACK           ; Clear STACK flag.
    move.l  d0,(a4)+                    ; Push to Stack if entered from Stack
.fin:
    rts
errorNotAnINTValue:
    Move.b  #0,convertToSTACK           ; Clear STACK flag.
    movem.l (sp)+,a0-a3/d1-d7           ; Load original registers values as when entered the method
    CastErrorID StringIsNotAnINTValue


getStrDatas:
    ; 1. We check if a floating number is explicitely set as negative or positive
    Clr.l   d4                          ; D4 = Clear the ffp number sign to consider it as positive if no + or - is at beginning
    cmp.b   #"-",(a0)                   ; 1. Check for the sign (if exist)
    beq.s   .isNegative
    cmp.b   #"+",(a0)
    beq.s   .shiftA0
    bra.s   .strtRead
.isNegative:
    Moveq   #1,d4
.shiftA0:
    add.l   #1,a0
.strtRead:
    clr.l   d7                          ; D7 = Integer part of the number
    clr.l   d6                          ; D6 = Mantisse part of the number (part after the comma/dot)
    moveq   #1,d5                       ; D5 = Floating part Exponent part of the number = Divide by 1 at start.
    clr.l   d3                          ; D3 = Global number exponent at the end of definition (ex. E10, E-14, e+5 )
    clr.l   d2                          ; D2 = Clear the global number Exponent sign to consider it as positive if no + or - is at beginning
; *****************************
.readInt:                               ; 2. Start The read the Integer part of the number
    Move.b  (a0)+,d0
    cmp.b   #0,d0                       ; 2.1 Check for the end of the String
    bra.w   .endOfRead                  ;     String is finished -> Jump to .endOfRead
    cmp.b   #",",d0                     ; 2.2 Check for the start of mantisse part.
    beq.s   .readMantisse               ;     Comma is found -> Jump to .readMantisse
    cmp.b   #".",d0                     ;     Same for dot
    beq.s   .readMantisse               ;     Dot is found -> Jump to .readMantisse
    sub.l   #"0",d0                     ; 2.3 Check for integrity (Is it a number between 0-9 range ?)
    bpl.s   .isOk1                      ;     result >=0 -> .isOk1 We continue conversion
    bra   errorNotAFFPValue             ;     Value is out of range 0-9 -> Jump to errorNotAFFPValue
.isOk1:
    cmp.b   #9,d0                       ;     result <= 9 ?
    ble.s   .isOk2                      ;     Yes -> .isOk2 We continue conversion
    bra   errorNotAFFPValue             ;     Value is out of range 0-9 -> Jump to errorNotAFFPValue
.isOk2:
    mulu    #10,d7                      ; 2.4 We multiply the integer par of the number by 10, and add the new number in.
;    and.l   #$F,d0                      ; Be sure that d0 is only in 0-9 range
    Add.l   d0,d7                       ; Update integer part of the number
    bra.s   .readInt                    ; -> Go back to .readInt to continue the integration of the integer part
; *****************************
.readMantisse:                          ; 3. Start the read of the Floating part of the whole number
    Move.b  (a0)+,d0
    cmp.b   #0,d0                       ; 3.1 Check for the end of the String
    bra.w  .endOfRead                   ;     String is finished -> Jump to .endOfRead
    cmp.b   #"e",d0                     ; 3.2 Check for the exponent at end
    bra.s   .readExponent               ;     Exponent E02, E-4, etc. is fount -> Jump to .readExponent
    cmp.b   #"E",d0
    bra.s   .readExponent               ;     Exponent E02, E-4, etc. is fount -> Jump to .readExponent
    cmp.b   #"f",d0                     ; 3.3 Check for number formatting ending with "f" (or "F" ) like "15.06f"
    bra.s   .endOfRead                  ;     floating number identification found -> Jump to .endOfRead
    cmp.b   #"F",d0
    bra.s   .endOfRead                  ;     floating number identification found -> Jump to .endOfRead
    sub.l   #"0",d0                     ; 3.4 Check for integrity (Is it a number between 0-9 range ?)
    bpl.s   .isOk3                      ;     result >=0 -> .isOk3 We continue conversion
    bra   errorNotAFFPValue             ;     Value is out of range 0-9 -> Jump to errorNotAFFPValue
.isOk3:
    cmp.b   #9,d0                       ;     result <= 9 ?
    ble.s   .isOk4                      ;     Yes -> .isOk24We continue conversion
    bra   errorNotAFFPValue             ;     Value is out of range 0-9 -> Jump to errorNotAFFPValue
.isOk4:
    mulu    #10,d6                      ; 3.4 We multiply the number by 10, and add the new number in.
;    and.l   #$F,d0                      ; Be sure that d0 is only in 0-9 range
    Add.l   d0,d6                       ; Update floating part of the number
    Mulu    #10,d5                      ; Mulu Divider by 10 to ensure we will shift the floating part correctly.
    bra   .readMantisse               ; -> Go back to .readMantisse to continue the integration of the float part
; *****************************
.readExponent:                          ; 4. Start the read of the Exponent part of the number if exists.
    cmp.b   #"-",(a0)                   ; 4.1 Check for the sign (if exist)
    beq.s   .isExpNegative
    cmp.b   #"+",(a0)
    beq.s   .shiftExpA0
    bra.s   .strtReadExp
.isExpNegative:
    Moveq   #1,d2                       ; Exponent sign is negative
.shiftExpA0:
    add.l   #1,a0
.strtReadExp:
    Move.b  (a0)+,d0
    cmp.b   #0,d0                       ; 4.2 Check for the end of the String
    beq.s   .endOfRead                  ;     String is finished -> Jump to .endOfRead
    sub.l   #"0",d0                     ; 4.3 Check for integrity (Is it a number between 0-9 range ?)
    bpl.s   .isOk5
    bra   errorNotAFFPValue
.isOk5:
    cmp.b   #9,d0
    ble.s   .isOk6
    bra   errorNotAFFPValue
.isOk6:
    mulu    #10,d3                      ; Mulu the current exponent value by 10
;    And.l   #$F,d0                      ; Be sure that d0 is only in 0-9 range
    Add.l   d0,d3                       ; Update the Exponant part of the FP number
    bra   .strtReadExp                  ; -> Go back to .readExponent to continue the integration of the exponent part
; *****************************
.endOfRead:
    rts

errorNotAFFPValue:
    Move.b  #0,convertToSTACK           ; Clear STACK flag.
    movem.l (sp)+,a0-a3/d1-d7           ; Load original registers values as when entered the method
    CastErrorID StringIsNotAFFPValue

mathFFPName:    dc.b    "mathffp.library",0
convertToSTACK: dc.b    0,0
                even