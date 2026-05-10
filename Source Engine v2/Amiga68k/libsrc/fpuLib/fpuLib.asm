; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.25                                     *
; * Last Update : 2022.03.25                              *
; * Version : 0.1                                         *
; * File : Grimoire CORE Engine Ver 0.1-2022.03.25        *
; * Author : Frederic Cordier                             *
; *********************************************************
; Rebuilded using native Amiga OS library style
;

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     1. Inclusion des fichiers du SDK AmigaOS
;                                                   ***************************************************************
; ****** 1.1 Tell compiler where to find the SDK includes
    incdir      "includes/"
; ****** 1.2 exec.library includes
    include     "exec/types.i"
    include     "exec/initializers.i"
    include     "exec/lists.i"
    include     "exec/nodes.i"
    include     "exec/resident.i"
    include     "exec/alerts.i"
    include     "exec/memory.i"
    include     "LVO/exec_lib.i"
; ****** 1.3 dos.library includes
    include     "dos/dos.i"
    include     "LVO/dos_lib.i"

    include "libraries/dosextens.i"

    include     "LVO/mathffp_lib.i"

exeCall         MACRO
    move.l      $4,a6
    Jsr         _LVO\1(a6)
                ENDM

dosCall         MACRO
    move.l      DosBase(a5),a6
    jsr         _LVO\1(a6)
                ENDM

    include "coresrc/grimoire-configuration.asm"

    include "coresrc/grimoire-structure.asm"

    include "coresrc/grimoire-errorHandler.asm"

    include "coresrc/grimoire-reporterLog.asm"

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     2. Macro système
;                                                   ***************************************************************
CALLSYS MACRO
            jsr _LVO\1(a6)
            ENDM

XLIB        MACRO
            XREF _LVO\1
            ENDM

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     3. Structure interne
;                                                   ***************************************************************
  STRUCTURE     MyLib,LIB_SIZE
    ULONG       ml_SysLib
    ULONG       ml_DosLib
    ULONG       ml_SegList
    UBYTE       ml_Flags
    UBYTE       ml_pad
    LABEL       MyLib_Sizeof
    XLIB        OpenLibrary
    XLIB        CloseLibrary
    XLIB        FreeMem
    XLIB        Remove
    XLIB        Alert

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     4. Version de la librairie
;                                                   ***************************************************************
Version         equ 0                 ; Version de la Library
Revision:       equ 1                 ; Révision de la Library
Pri             equ 0                 ; Pri. de la Library (sans importance)


; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     5. Start point
;                                                   ***************************************************************
Start:
               move.l #0,d0
               rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     6. Interne à la librairie [Ne pas modifier]
;                                                   ***************************************************************
Resident:
    dc.w        RTC_MATCHWORD     ; Code pour Resident
    dc.l        Resident          ; Pointeur sur le début de la structure
    dc.l        FinCode           ; Pointeur sur la fin de la structure
    dc.b        RTF_AUTOINIT      ; Flag pour l'appel automatique
    dc.b        Version           ; Version de la Library
    dc.b        NT_LIBRARY        ; Type de la structure Resident=Library
    dc.b        Pri               ; Priorité de la str.Resident
    dc.l        LibName           ; Pointeur sur le nom de la Library
    dc.l        idString          ; Chaîne d'id. pour la Library
    dc.l        Init              ; Pointeur sur le tableau d'initialisation
LibName:
    dc.b        "grimoire-fpconvert.library",0
idString:
    dc.b        "grimoire-fpu  Ver:0.1.1 ( 28 mars 2023 )",13,10,0
    ds.w        0

FinCode:

Init:
    dc.l        MyLib_Sizeof      ; Taille de la structure de librairie
    dc.l        FuncTable         ; Pointeur sur le tableau des fonctions Lib
    dc.l        DataTable         ; Pointeur sur tableau pour InitFonction
    dc.l        InitRoutine       ; Pointeur sur routine propre de création  (appel de MakeLibrary())

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     7. Table des fonctions initiales de la librairies (obligatoires)
;                                                   ***************************************************************
FuncTable:
;----------- Routines système
    dc.l        Open
    dc.l        Close
    dc.l        Expunge
    dc.l        Zero

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     8. Table des routines ajoutées à la librairies [Personnelles]
;                                                   ***************************************************************
    dc.l        startGrimoireFPU
    dc.l        closeGrimoireFPU
    dc.l        ConvertFltToInt              ; D0->D0
    dc.l        ConvertIntToFlt              ; D0->D0
    dc.l        ConvertStrToFlt              ; A0->D0
    dc.l        ConvertStrToInt              ; A0->D0
    dc.l        StackA4ConvertFltToInt       ; -(a4)->(a4)+
    dc.l        StackA4ConvertIntToFlt       ; -(a4)->(a4)+
    dc.l        StackA4ConvertStrToFlt       ; -(a4)->(a4)+
    dc.l        StackA4ConvertStrToInt       ; -(a4)->(a4)+
    dc.l        -1

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                     9. Interne à la librairie [Ne pas modifier]
;                                                   ***************************************************************
DataTable:     INITBYTE  LH_TYPE,NT_LIBRARY
               INITLONG  LN_NAME,LibName
               INITBYTE  LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
               INITWORD  LIB_VERSION,Version
               INITWORD  LIB_REVISION,Revision
               INITLONG  LIB_IDSTRING,idString
               dc.l 0

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    10. Routines internes à la librairie [Ne pas modifier]
;                                                   ***************************************************************
InitRoutine:
            move.l a5,-(a7)                     ;sauver A5
            move.l d0,a5                        ;Pointeur sur MyLib
            move.l a6,ml_SysLib(a5)             ;Pointeur sur ExecLib
            move.l a0,ml_SegList(a5)            ;introduit liste des segments
            lea dosName(pc),a1                  ;Pointeur sur le nom DOS
            move.l #Version,d0                  ;numéro de version= 0
            CALLSYS OpenLibrary
            move.l d0,ml_DosLib(a5)             ;Entrée de l'adresse
            bne.s s1                            ;Ok, Lib trouvé

;ALERT est une macro qui se trouve dans "exec/alerts.i"
            ALERT AG_OpenLib!AO_DOSLib          ;Sort Alert
s1:
;Vous placerez ici votre propre routine d'initialisation
            move.l a5,d0                        ;Pointeur sur Mylib
            move.l (a7)+,a5                     ;Recherche les registres
            rts                                 ;Retour
;La routine suivante est appelée par la fonction OpenLibrary()
;>= A6 = Pointeur sur la structure personelle de librairie
;>= D0 = Pointeur sur la structure personnelle de librairie
Open:
            addq.w #1,LIB_OPENCNT(a6)      ;Incrémente le compteur pour
                                           ;le nombre des accès à la Library
            bclr #LIBB_DELEXP,ml_Flags(a6) ;Flag pour supprimer
                                           ;la Library
            move.l a6,d0                   ;définir les paramètres de retour
            rts                            ;Retour
Close:
            clr.l d0                       ;Supprime le pointeur
                                           ;sur liste de  segments (important)
            subq.w #1,LIB_OPENCNT(a6)      ;compteur pour ouverture de la
                                           ;Library -1
            bne.s s2                       ;saut si Library
                                           ;encore utilisée
            btst #LIBB_DELEXP,ml_Flags(a5) ;est-ce que le flag
                                           ; LIBB_DELEXP est posé?
            beq.s s2                       ;Fin, s'il ne l'est pas
            bsr.b Expunge                    ;supprime Library
s2:         rts                            ;retour
;Routine pour supprimer la librairie de la mémoire.
;>= A6 = Pointeur sur Library
;=> D0 = Pointeur sur liste des segments de la Library chargée
Expunge:
            movem.l d1/a5-a6,-(a7)         ;sauver les registres
            move.l a6,a5                   ;Pointeur sur Library vers A5
            move.l ml_SysLib(a5),a6        ;ExecBase vers  A6
            tst.w LIB_OPENCNT(A5)          ;Library encore utilisée?
            beq.b s3                         ;Saut si non utilisée
            bset #LIBB_DELEXP,ml_Flags(a5) ;on souhaite supprimer
                                           ;la Library
            clr.l d0                       ;supprime le pointeur sur
                                           ;liste des segments
            bra.s Expunge_end              ;saut inconditionnel
s3:         move.l ml_SegList(a5),d2       ;Pointeur sur liste des segments
                                           ;vers D2
            move.l a5,a1                   ;Pointeur sur Library vers A1
            CALLSYS Remove                 ;supprimer Library
                                           ;de la liste Exec-Lib
            move.l ml_DosLib(a5),a1        ;Pointeur sur DOS-Library
            CALLSYS CloseLibrary           ;Fermer Library
            clr.l d0                       ;effacer D0
            move.l a5,a1                   ;Pointeur sur Library
            move.w LIB_NEGSIZE(a5),d0
            sub.l d0,a1                    ;cherche pointeur sur
                                           ;début de la mémoire
                                           ;occupée par la librairie
            add.w LIB_POSSIZE(a5),d0       ;obtenir longueur de la
                                           ;mémoire occupée
            CALLSYS FreeMem                ;libère la mémoire
            move.l d2,d0                   ;Pointeur sur liste des segments
                                           ;vers D0
Expunge_end:
            movem.l (a7)+,d2/a5-a6         ;restaurer les registres
            rts                            ;retour
;la fonction suivante peut être atteinte avec offset -24.
;Elle n'est pas utilisée dans la version Kickstart actuelle.
Zero:
            moveq #0,d0                    ;efface D0
            rts                            ;retour

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    11. Routines internes à la librairie [Ne pas modifier]
;                                                   ***************************************************************

loadMathFFPLib          MACRO
    move.l      MathFFPBase(a5),a6
                        ENDM

callMathFFP             MACRO
    jsr     _LVO\1(a6)
                        ENDM

startGrimoireFPU:
    lea         gCore.Base(pc),a0
    move.l      a5,(a0)
    lea         mathFFPName(pc),a1     ; Load the "intuition.library" name to a1
    Moveq       #0,d0                ; Open All versions of intuition.library
    exeCall     OpenLibrary
    tst.l       d0
    beq.s       .noLib3
    move.l      d0,MathFFPBase(a5)     ; Save intuition.library BASE to gfxBase
    rts
.noLib3:
    CastErrorID CannotOpenMathFFPLibrary

closeGrimoireFPU
    move.l      MathFFPBase(a5),a1
    cmp.l       #0,a1
    beq.s       cMFFPEnd
    exeCall     CloseLibrary
cMFFPEnd:
    rts

; *************************************************************
; Convert a Floating Point Number to an Integer. [Call using Stack]
; INPUT: Stack Float Value (a4)
; OUTPUT : Stack Integer Number (a4)
StackA4ConvertFltToInt:
    move.l  -(a4),d0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Floating Point Number to an Integer. [Call not using Stack]
; INPUT: D0 = Float Value
; OUTPUT : D0 = Integer Number
ConvertFltToInt:
    loadMathFFPLib
    callMathFFP SPFix
    ; Return Value in D0 or STACK depending on the way the method was called.
    cmp.b   #1,convertToSTACK
    bne.s   .finInt
    clr.b   convertToSTACK           ; Clear STACK flag.
    move.l  d0,(a4)+                    ; Push to Stack if entered from Stack
.finInt:
    rts


; *************************************************************
; Convert an Integer to a Floating Point Number. [Call using Stack]
; INPUT: Stack Integer Value (a4)
; OUTPUT : Stack FFP Number (a4)
StackA4ConvertIntToFlt:
    move.l  -(a4),d0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Static String into a Floating Point Number. [Call not using Stack]
; INPUT: D0 = Integer Value
; OUTPUT : D0 = FFP Number
ConvertIntToFlt:
    loadMathFFPLib
    callMathFFP SPFlt
    ; Return Value in D0 or STACK depending on the way the method was called.
    cmp.b   #1,convertToSTACK
    bne.s   .finInt
    clr.b   convertToSTACK           ; Clear STACK flag.
    move.l  d0,(a4)+                    ; Push to Stack if entered from Stack
.finInt:
    rts

; *************************************************************
; Convert a Static String into a Floating Point Number. [Call using Stack]
; INPUT: Stack String Pointer (a4)
; OUTPUT : Stack FFP Number (a4)
StackA4ConvertStrToFlt:
    move.l  -(a4),a0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Static String into a Floating Point Number. [Call not using Stack]
; INPUT: A0 = String Pointer
; OUTPUT : D0 = FFP Number
ConvertStrToFlt:
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
    clr.b   convertToSTACK           ; Clear STACK flag.
    move.l  d0,(a4)+                    ; Push to Stack if entered from Stack
.fin:
    rts

; *************************************************************
; Convert a Static String into an Integer Number. [Call using Stack]
; INPUT: Stack String Pointer (a4)
; OUTPUT : Stack Integer Number (a4)
StackA4ConvertStrToInt:
    move.l  -(a4),a0                     ; A0 = pointer to the string containing the Floating Number
    Move.b  #1,convertToSTACK
; *************************************************************
; Convert a Static String into an Integer Number. [Call not using Stack]
; INPUT: A0 = String Pointer
; OUTPUT : D0 = Integer Number
ConvertStrToInt:
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
    clr.b   convertToSTACK           ; Clear STACK flag.
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
    beq.w   .endOfRead                  ;     String is finished -> Jump to .endOfRead
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
    beq.w  .endOfRead                   ;     String is finished -> Jump to .endOfRead
    cmp.b   #"e",d0                     ; 3.2 Check for the exponent at end
    beq.s   .readExponent               ;     Exponent E02, E-4, etc. is fount -> Jump to .readExponent
    cmp.b   #"E",d0
    beq.s   .readExponent               ;     Exponent E02, E-4, etc. is fount -> Jump to .readExponent
    cmp.b   #"f",d0                     ; 3.3 Check for number formatting ending with "f" (or "F" ) like "15.06f"
    beq.s   .endOfRead                  ;     floating number identification found -> Jump to .endOfRead
    cmp.b   #"F",d0
    beq.s   .endOfRead                  ;     floating number identification found -> Jump to .endOfRead
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
    clr.b   convertToSTACK           ; Clear STACK flag.
    movem.l (sp)+,a0-a3/d1-d7           ; Load original registers values as when entered the method
    CastErrorID StringIsNotAFFPValue

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    99. Inutile mais nécessaire
;                                                   ***************************************************************
mathFFPName:
    dc.b    "mathffp.library",0
    EVEN
convertToSTACK:
    dc.b    0,0
    EVEN
dosName:
    dc.b    "dos.library",0
    EVEN
gCore.Base:
    dc.l    0


    Dc.l    0,0,0,0
    Dc.b    "<<Grimoire Floating Point Unit - The Amiga Book of Magic>> All rights reserved © Frederic Cordier 2023 : cordierfr@wanadoo.fr"