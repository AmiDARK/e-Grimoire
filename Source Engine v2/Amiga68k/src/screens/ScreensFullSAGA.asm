
XLIB; *********************************************************
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

    include "GRMIncludes/grimoire-configuration.asm"

    include "GRMIncludes/grimoire-errorHandler.asm"

    include "GRMIncludes/grimoire-structure.asm"

    include "GRMIncludes/grimoire-reporterLog.asm"

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
    dc.b        "grimoire-screensFullSAGA.library",0
idString:
    dc.b        "grimoire-screensFullSAGA  Ver:0.1 ( 27 avril 2022 )",13,10,0
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
    dc.l        getBestScreenMode             ; Width, Height, Depth
    dc.l        getBestScreenModeEx           ; Width, Height, Depth, Scanmode
    dc.l        OpenScreenSAGA
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
    rts

Destructor:
    rts

getBestScreenMode:
    sePushToStack     #0,TypeInt

getBestScreenModeEx
    seGetMultiFromStack d7,d6,d5,d4            ; Extract D4=Width, D5=Height, D6=Depth/PixelFormat, D7=GFXMode
; ****************************************************************************************************
; ******** 1. We check if we are under SAGA Chunky display mode                               ********
    btst      #bSagaC2P,d7
    bne       Use_SAGA_ChunkyMode
    btst      #bSagaPIP,d7
    bne       Use_SAGA_PIPMode
    btst      #bCybergraphx,d7
    bne       Use_CyberGraphX
    btst      #bPicasso96,d7
    bne       Use_Picasso96
    btst      #bRTG,d7
    bne       Use_RTGLibrary
; ****************************************************************************************************
; ******** 2. We use default Bitplanes modes                                                  ********
Use_DefaultPlanars:
    or.l      d6,d7
    sePushToStack     d7,#TypeInt     ; Specials display mode info (31-19)
    rts
; ****************************************************************************************************
; ******** 3. We use SAGA Chunky mode. Convert pixel format + Resolution                      ********
;             to Saga GFXMODE register for getBestScreenMode
; 3.1 Read Chunky Depth mode
Use_SAGA_ChunkyMode:
    lea         SAGA_C2P_DEPTHS(pc),a4
.miniLoop:
    move.w      (a4)+,d3
    cmp.w       d3,d6
    beq.s       .miniLoopQuit
    add.l       #2,a4                 ; Jump to next value
    cmp.w       #0,(a4)               ; new value ?
    bne.s       .miniLoop             ; Yes -> Continue Looping
    CustomError SagaDepthModeIsUnknown
.miniLoopQuit:
    move.w      (a4),d6               ; d5 (07-00) = GFXMode Pixel Format
; 3.2 Read Chunky Graphic Mode (Resolution)
    lea         SAGA_C2P_GFXMODES(pc),a4
.miniLoopGFX:
    move.w      (a4)+,d2              ; d0 = Existing Resolution Width in pixels
    move.w      (a4)+,d3              ; d4 = Existing Resolution Height in pixels
    cmp.w       d3,d5                 ; d5(Height) = Existing resolution Height ?
    bne.s       .miniLoopCheck2       ; No, continue with next test
    cmp.w       d2,d4                 ; d4(Width) = Existing resolution Width(d1) ?
    beq.s       .miniLoopGFXQuit
.miniLoopCheck2:
    add.l       #2,a0
    cmp.w       #0,(a0)
    bne.s       .miniLoopGFX
    CustomError SagaDisplayModeIsUnknown
.miniLoopGFXQuit:
    or.w        (a0),d7               ; d7 = (07-00) GFXMode Resolution + Specials display mode info (31-19)
    lsl.w       #8,d6                 ; d4 = (15-08) GFXMode Resolution + Specials display mode info (31-19)
    or.w        d6,d7                 ; d3 = GFXMode Resolution (15-08) + PiwelFormat (07-00) + Specials display mode info (31-19)
    sePushToStack d7,#TypeInt


    rts
; ****************************************************************************************************
Use_SAGA_PIPMode:
    rts
; ****************************************************************************************************
Use_CyberGraphX:
    rts
; ****************************************************************************************************
Use_Picasso96:
    rts
; ****************************************************************************************************
Use_RTGLibrary:

; ***** 2021.12.20 Here is the list of the available depths mode in Vampire V4SA - START
SAGA_C2P_DEPTHS:
;             User value -> GFXMODE/PixelFormat value
    dc.l      8,SAGA_VIDEO_FORMAT_CLUT8
    dc.l      16,SAGA_VIDEO_FORMAT_RGB16
    dc.l      15,SAGA_VIDEO_FORMAT_RGB15
    dc.l      24,SAGA_VIDEO_FORMAT_RGB24
    dc.l      32,SAGA_VIDEO_FORMAT_RGB32
    dc.l      422,SAGA_VIDEO_FORMAT_YUV422
    dc.l      1,SAGA_VIDEO_FORMAT_PLANAR1BIT
    dc.l      2,SAGA_VIDEO_FORMAT_PLANAR2BIT
    dc.l      4,SAGA_VIDEO_FORMAT_PLANAR4BIT
    dc.l      0,0
; ***** 2021.12.20 Here is the list of the available depths mode in Vampire V4SA - END

; **** 2021.12.21 Updated Saga GFXMODE register screen resolutions
SAGA_C2P_GFXMODES:
    dc.w       320,200,$01
    dc.w       320,240,$02
    dc.w       320,256,$03
    dc.w       640,400,$04
    dc.w       640,480,$05
    dc.w       640,512,$06
    dc.w       960,240,$07
    dc.w       480,270,$08
    dc.w       304,224,$09
    dc.w      1280,720,$0A
    dc.w       640,360,$0B
    dc.w      1024,768,$0D
    dc.w       800,600,$0C
    dc.w       720,576,$0E
    dc.w       848,480,$0F
    dc.w       640,200,$10
    dc.w         0,000,$00      ; Last slot is empty to ensure loop quit possible.

; **** 2022.01.03 Added pixel size for custom screen buffer creation
SAGA_PIXEL_SIZE:
    dc.w       0,1,2,2,3,4,3,0  ; CLUT_OFF(0),CLUT8(1),RGB16(2),RGB15(3),RGB24(4),RGB32(5),YUV422(6),NOT_DEFINED(7)
    dc.w       1,1,1            ; PLANAR1BIT(8),PLANAR2BIT(9),PLANAR4BIT(10=$A) (unknown mode format)













; *****************************************************************************
; D7=ScreenID, D6=Width(pixels), D5=Height(pixels), D4=PixelFormat, D3=Resolution
; Based on Vampire's SAGA GFXMODE for better compatibility between ECS/OCS, AGA & SAGA displayables screens.
OpenScreenSAGA:
    grmCall    grmLoadSys                      ; a5 = Load SYS 
    movem.l    d0-d3/a0-a2,-(sp)
; *****************************************************************************
; 1.1 Check if Screen width is multiple of 16 pixels.
    move.l     d6,d2
    and.l      #$FFFFFFF0,d2
    beq.s      oSA_CheckDimensions             ; if Width < 320 pixels -> Error
    movem.l    (sp)+,d0-d3/a0-a2
    CastErrorID ScreenWidthMultipleOfSixteen
; *****************************************************************************
; 1.2 Check if screen dimensions meets the requirements
oSA_CheckDimensions:
    cmp.l      #320,d6                         ; 
    blt.s      oSA_ScreenDimensionsKO          ; if Width < 320 pixels -> Error
    cmp.l      #2048,d6                        ;
    bgt.s      oSA_ScreenDimensionsKO          ; if Width > 2048 pixels -> Error
    cmp.l      #32,d5                          ; 
    blt.s      oSA_ScreenDimensionsKO          ; if Height < 32 pixels -> Error
    cmp.l      #2048,d5                        ;
    ble.s      oSA_DimensionsOK                ; if Height > 2048 pixels -> Error else ->OK (oSA_DimensionsOK)
; Cast "Screen Dimensions are incorrects" error
oSA_ScreenDimensionsKO:
    movem.l    (sp)+,d0-d3/a0-a2
    CastErrorID ScreenDimensionsAreKO
; *****************************************************************************
; 1.3 Continue by checking if Screen already exists or not
oSA_DimensionsOK:
    bsr        getScreenExists_noLS            ; Check if requested screen already exists.
    tst.l      d0
    beq.s      oSA_Continue
oSA_CallCloseScreen
; 1.4 If requested screen already exists, we close it before opening a new one.
    bsr        CloseScreenAGA
oSA_Continue:
; 1.5 Now we check the type of screen requested to be sure it's an ECS/OCS/AGA one.

    rts


; D7=ScreenID
CloseScreenAGA:

    rts

; D7=ScreenID
getScreenExists:
    grmCall    grmLoadSys                      ; a5 = Load SYS 
getScreenExists_noLS:
    cmp.l      #seMaxScreens,d7
    bge.s      gSE_ScreenIDIsInvalid
    bpl.s      gSE_Ok
gSE_ScreenIDIsInvalid:
    CastErrorID ScreenIDIsInvalid
gSE_Ok:
    move.l     a2,tempSave(a5)
    lea.l      Screens(a5),a2                  ; A2 = Screen #0
    lsl.w      #2,d7                           ; D7 = Screen ID * 4 (convert ID to .l shift value)
    add.l      d7,a2                           ; a2 = Pointer to the screen if exists, otherwise pointer contains 0/NULL
    lsr.w      #2,d7                           ; Restaure D7 = ScreenID
    move.l     (a2),d0                         ; D0 = Screen Exists (=/= 0 = Screen Structure Pointer)
    move.l     tempSave(a5),a2
    rts


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

addCustomError SagaDepthModeIsUnknown, <"Error #SAGA01 : Unknown SAGA C2P Depth mode.">
addCustomError SagaDisplayModeIsUnknown, <"Error #SAGA02 : Unknown SAGA C2P Screen Resolution.">



    Dc.l    0,0,0,0
    Dc.b    "<<Grimoire Screens SuperAGA - The Amiga Book of Magic>> All rights reserved © Frederic Cordier 2023 : cordierfr@wanadoo.fr"