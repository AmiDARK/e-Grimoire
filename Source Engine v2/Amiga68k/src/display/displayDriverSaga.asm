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

    include     "graphics/gfx.i"
    include     "LVO/graphics_lib.i"

    include     "LVO/mathffp_lib.i"



exeCall         MACRO
    move.l      $4,a6
    Jsr         _LVO\1(a6)
                ENDM

dosCall         MACRO
    move.l      DosBase(a5),a6
    jsr         _LVO\1(a6)
                ENDM

graphicsCall    MACRO
    move.l      graphicsBase(a5),a6
    jsr         _LVO\1(a6)
        ENDM
        

    include "GRMIncludes/grimoire-configuration.asm"
    include "GRMIncludes/grimoire-structure.asm"
    include "GRMIncludes/grimoire-vms.Types.asm"
    include "GRMIncludes/grimoire-errorHandler.asm"
    include "GRMIncludes/grimoire-reporterLog.asm"
    include "GRMIncludes/grimoire-stackSystem.asm"

    include "VampiresIncludes/sagaRegisters.h"

; Adresses utiles dans la copper list.
; Par rapport à l'adresse de base SCREEN dans la copper list.
C_BPL0PTH   Equ 2
C_BPL1PTH   Equ 10
C_BPL2PTH   Equ 18
C_BPL3PTH   Equ 26
C_BPL4PTH   Equ 34
C_BPL5PTH   Equ 42
C_BPL6PTH   Equ 50
C_BPL7PTH   Equ 58
;
C_DIWSTRT   Equ 66+4
C_DIWSTOP   Equ 70+4
C_DDFSTRT   Equ 74+4
C_DDFSTOP   Equ 78+4
;
C_BPL1MOD   Equ 82+4
C_BPL2MOD   Equ 86+4
;
C_BPLCON0   Equ 90+4
C_BPLCON1   Equ 94+4
C_BPLCON2   Equ 98+4
C_BPLCON3   Equ 102+4

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


loadGlobalDatas MACRO
    move.l      globalDatas(a5),\1
                ENDM

loadLocalDatas  MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\1
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
    dc.b        "grimoire-displayDriverSaga.library",0
idString:
    dc.b        "grimoire-DisplayDriverSaga Ver:0.1.2 ( 12 mai 2022 )",13,10,0
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
    dc.l        Constructor
    dc.l        Destructor
    dc.l        setupLogicCopper
    dc.l        WorkBenchToFront
    dc.l        AppToFront
    dc.l        swapCoppersLogicToPhysic
    dc.l        pushCurrentScreen
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

Constructor:
    movem.l     d0-d3/a0-a2,-(sp)
    move.l      GraphicsBase(a5),a2
    move.l      $26(a2),oldCopper(a5)          ; Save Graphic Library Copper List 1
    move.l      $32(a1),oldCopperL(a5)         ; Save Graphic Library Copper List 1

    move.l      #CopperListSize,d0
    grmCall     grmAllocClrChipMem
    tst.l       d0
    bne.s       sCL_Continue
    ; ******** If not enough memory is available to allocate 16Kb, we cast an error.
    movem.l     (sp)+,d0-d3/a0-a2
    CustomError NotEnoughMemoryForCopperList
    rts
sCL_Continue:
    move.l      d0,CopperListBuffer(a5)        ; Save the start of the copper list buffer
    move.l      d0,CopperPhysic(a5)            ; Save the adress to the 1st copper list (in use)
    move.l      d0,a0
    add.l       #CopperListSize/2,d0           ; Point to the half of the memory block for the 2nd copper list
    move.l      d0,CopperLogic(a5)             ; Save the adress to the 2nd copper list (buffer)
    movem.l     (sp)+,d0-d3/a0-a2
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    
;                                                   ***************************************************************
Destructor:
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    
;                                                   ***************************************************************
setupLogicCopper:
    movem.l     d0-d3/a0-a2,-(sp)
    move.l      CopperLogic(a5),a0             ; Save the adress to the 1st copper list (in use)

    ; ******** Start to populate basic copper list system
    Move.l      #$1003FFFE,(a0)+
    Move.l      #$01fc0000,(a0)+               ; Anti Double scanning !!!.
    move.l      a0,CopperSprites(a5)           ; 
    move.w      $0120,d0
    ; ******** Copy Sprites registers into copper list.
sCl1:
    move.w      d0,(a0)+
    clr.w       (a0)+
    add.w       #2,d0
    cmp.w       #$140,d0
    blt.s       sCl1
    ; ******** Copy 256 colors Color Palette high bits
    move.l      #$1803FFFE,(a0)+
    move.l      a0,CopperPaletteH(a5)
    move.l      #$01060000,d0                  ; d0 = 1st color palette (Index 00-31)
sCl2:
    move.l      d0,(a0)+                       ; Push the 32 color palette bloc ton insert
    move.w      #$180,d1
sCl3:
    move.w      d1,(a0)+                       ; Push Color D1 (From ID 00 to 31 inside current block)
    clr.w       (a0)+                          ; Push D1 color to black
    add.w       #$0002,d1                      ; D1 = Next Color ID (00-31)
    cmp.w       #$01C0,d1                      ; Does D1 reache ID=32 ?
    bne.b       sCl3                           ; Not Yet, continue loop -> sCl3
    Add.l       #$00002000,d0                  ; D0 = Next 32 colors color palette block?
    cmp.l       #$01070000,d0                  ; Does D0 reach block ID=8 ?
    bne.b       sCl2

    ; ******** Copy 256 colors Color Palette Low bits
    move.l      a0,CopperPaletteL(a5)
    move.l      #$01060200,d0                  ; d0 = 1st color palette (Index 00-31)
sCl4:
    move.l      d0,(a0)+                       ; Push the 32 color palette bloc ton insert
    move.w      #$180,d1
sCl5:
    move.w      d1,(a0)+                       ; Push Color D1 (From ID 00 to 31 inside current block)
    clr.w       (a0)+                          ; Push D1 color to black
    add.w       #$0002,d1                      ; D1 = Next Color ID (00-31)
    cmp.w       #$01C0,d1                      ; Does D1 reache ID=32 ?
    bne.b       sCl5                           ; Not Yet, continue loop -> sCl3
    Add.l       #$00002000,d0                  ; D0 = Next 32 colors color palette block?
    cmp.l       #$01070200,d0                  ; Does D0 reach block ID=8 ?
    bne.b       sCl4

    ; ******** Now we insert the screen details themselves
    move.l      #$3103FFFE,(a0)+
    move.l      a0,CopperScreen(a5)
    ; ******** Now we insert the screen details : Bitplanes
    move.w      #$00E0,d0                      ; Bpl0PTH
sCl6:
    move.w      d0,(a0)+
    clr.w       (a0)+
    add.w       #$0002,d0
    cmp.w       #$0100,d0                      ; Does D0 is above Bpl7Ptl ?
    blt.s       sCl6                           ; Not Yet, continue to push bitplanes -> Jump sCl6
    move.l      #$3203FFFE,(a0)+
    move.l      a0,CopperScreenProp(a5)        ; Save Screen properties
    ; ******** Now we insert the screen details : Properties (Part 1)
    Move.l      #$008E0181,(a0)+               ; DIWSTRT   ???
    Move.l      #$009037C1,(a0)+               ; DIWSTOP   ???
    Move.l      #$00920038,(a0)+               ; DDFSTRT =38 no scrl,=30 scroll.
    Move.l      #$009400D0,(a0)+               ; DDFSTOP
    Move.l      #$01080000,(a0)+               ; BPL1MOD
    Move.l      #$010A0000,(a0)+               ; BPL2MOD
    ; ******** Now we insert the screen details : Properties (Part 2 BplCon(s))
    move.l      a0,CopperScreenBplCon(a5)      ; Save Screen properties
    Move.l      #$01000000,(a0)+               ; BPLCON0
    Move.l      #$01020000,(a0)+               ; BPLCON1
    Move.l      #$01040000,(a0)+               ; BPLCON2 $0224
    Move.l      #$01060000,(a0)+               ; BPLCON3=$1000 pour 2nd pf palette.
    Move.l      #$3303FFFE,(a0)+
    ; ******** Start screen displaying:
;    Move.l      #$00968300,(a0)+
    ; ******** Fin de la copper list.
    move.l      a0,CopperEnding(a5)
    Move.l      #$F203FFFE,(a0)+
    Move.l      #$01000000,(a0)+    ; DMACON Pour l'amos ?!?
;    Move.l      #$00960100,(a0)+
    Move.l      #$F303FFFE,(a0)+
    Move.l      #$FFFFFFFE,(a0)+

    movem.l     (sp)+,d0-d3/a0-a2
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    
;                                                   ***************************************************************
WorkBenchToFront:
    tst.w       fullScreenMode(a5)                 ; Are we under FullScreenMode ?
    beq.s       WBTF2                              ; No, Workbench is at front -> Jump to WBTF2
    movem.l     d0/d1,-(sp)
    move.w      #0,fullScreenMode(a5)              ; Push FullScreenMode OFF
    move.l      oldCopper,d0                       ; D0 = Old WorkBench Copper List 1
    move.l      oldCopperL,d1                      ; D1 = Old WorkBench Copper List 2
    move.l      d0,COP1LCH                         ; Restore WorkBench Copper List 1
    move.l      d1,COP2LCH                         ; Restore WorkBench Copper List 2
    movem.l     (sp)+,d0/d1
WBTF2:
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    
;                                                   ***************************************************************
AppToFront:
    tst.w       fullScreenMode(a5)                 ; Are we under FullScreenMode ?
    bne.s       ATF2                               ; Yes -> Jump to ATF2
    movem.l     d0/d1,-(sp)
    move.w      #1,fullScreenMode(a5)              ; Push FullScreenMode ON
    movem.l     (sp)+,d0/d1
ATF2:
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    
;                                                   ***************************************************************
swapCoppersLogicToPhysic:
    tst.w       fullScreenMode(a5)
    beq.s       sCLTP2
    movem.l     d0/d1,-(sp)
    move.l      CopperLogic(a5),d0                 ; A0 = Copper Physic
    move.l      CopperPhysic(a5),d1                ; A1 = Copper Physic
    move.l      d1,CopperLogic(a5)                 ; CopperLogic = A1
    move.l      d0,CopperPhysic(a5)                ; CopperPhysic = A0
    Move.l      d0,COP1LCH
;    move.l      #0,COP2LCH
    movem.l     (sp)+,d0/d1
sCLTP2:
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    pushCurrentScreen push current screen datas inside simple copper system
;                                                   ***************************************************************
pushCurrentScreen:
    Move.w      CurrentScreen(a5),d7               ; D0 = CurrentScreen
    Tst.w       D7
    bpl.s       rCS1
    CustomError NoScreenAvailable
    rts
rCS1:
    and.l       #$0007,d7                          ; Ensure 0 >= D0 >= 7
    Lea         Screens(a5),a2                     ; A2 = Pointer to Screen index #0 in screen list
    lsl.w       #2,d7                              ; D0 = D0 * 4 = Current Screen * 4 bytes = Index in integer size
    move.l      (a2,d7),a2                         ; A2 = Current Screen Structure pointer
    move.l      CopperScreenProp(a5),a1            ; A1 = Pointer to Screen start in copper list
    ; ******** Start to push screen datas inside copper list
    move.w      #$0038,C_DDFSTRT(a1)               ; Scroll value initial.
    ; ********
    movem.l     ScWidth(a2),d0/d1/d2               ; D0=Width/D1=Height/D2=Depth
    sub.l       #320,d0                            ; D0=Screen Width - 320 Pixels (display size)
    lsr.w       #3,d0                              ; D0=Screen Modulo in bytes
    move.w      d0,C_BPL1MOD(a1)
    move.w      d0,C_BPL2MOD(a1)
    ; ********
    lea.l       BPLCONF(pc),a0
    lsl.w       #1,d2
    add.w       d2,a0
    move.w      (a0),C_BPLCON0(a1)
    ; ********
    moveq.w     #C_BPL0PTH,d0
    subq.b      #1,d2
rCS2:
    move.w      (a2)+,(a1,d5.w)
    addq.b      #4,d0
    dbra        d2,rCS2
    rts



BPLCONF:
    Dc.w    $0000,$1000,$2000,$3000
    Dc.w    $4000,$5000,$6000,$7000
    Dc.w    $0010                       ; De 0 à 8 bits plans.

;
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    pushColor D0=ColorID, D1=Red(0-255), D2=Green(0-255), D3=Blue(0-255)
;                                                   ***************************************************************
pushColor:

;
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    
;                                                   ***************************************************************


; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    99. Inutile mais nécessaire
;                                                   ***************************************************************
dosName:
    dc.b    "dos.library",0
    EVEN

addCustomError  MACRO
err\1:
    dc.b \2,10,0
    ENDM

  addCustomError NotEnoughMemoryForCopperList,<"Error #SAGADRV01 : Not Enough Memory - Cannot allocate copper list memory block.">
  addCustomError NoScreenAvailable,<"Error #SAGADRV02 : No Screen Opened to be set as current one.">

    Dc.l    0,0,0,0
    Dc.b    "<<Grimoire Display Driver SuperAGA - The Amiga Book of Magic>> All rights reserved © Frederic Cordier 2022-2023 : cordierfr@wanadoo.fr"

