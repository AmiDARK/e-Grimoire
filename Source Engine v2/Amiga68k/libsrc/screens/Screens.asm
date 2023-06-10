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

    include "coresrc/grimoire-configuration.asm"
    include "coresrc/grimoire-structure.asm"
    include "coresrc/grimoire-vms.Types.asm"
    include "coresrc/grimoire-errorHandler.asm"
    include "coresrc/grimoire-reporterLog.asm"
    include "coresrc/grimoire-stackSystem.asm"
    include "VampiresIncludes/sagaRegisters.h"      ; Not on AGA

; ******** Special labels to allow stack system to work inside library as it can detect procedures.
inProcedure     SET 0                                  ; Used to define if we are inside a procedure (=8) or not (=0)
inProcName      SET 0                                  ; Used for Procedure Unique ID
procCallName    SET 0                                  ; Used for CallProcedure unique ID
nextProcReturn  SET 0                                  ; Used for unique labels for getProcedureReturn macro.
; ******** Special labels to allow stack system to work inside library as it can detect procedures.

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
    dc.b        "grimoire-screens.library",0
idString:
    dc.b        "grimoire-screens Ver:0.2 ( 23 mai 2023 )",13,10,0
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
    dc.l        OpenScreen
    dc.l        OpenScreenEx
;    dc.l        CloseScreen
;    dc.l        getScreenExists
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
    lea     gCore.Base(pc),a0
    move.l  a5,(a0)
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
;                                                    getBestScreenMode Width,Height,PixelFormat
;                                                   ***************************************************************
getBestScreenMode:
    sePushToStackLib  #0,#TypeInt

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    getBestScreenModeEx Width,Height,PixelFormat,GFXMode
;                                                   ***************************************************************
getBestScreenModeEx:
    LoadSys   a5
    move.l    a2,tempSave(a5)                  ; Save a2
    seGetMultiFromStack d7,d6,d5,d4            ; Extract D4=Width, D5=Height, D6=Depth/PixelFormat, D7=GFXMode
; ****************************************************************************************************
; ******** 1. We check if we are under SAGA Chunky display mode                               ********
    btst      #bSagaC2P,d7                     ; Does the requested mode ask for Saga Chunky mode ?
    bne       Use_SAGA_ChunkyMode              ; Yes -> Jump to Use_SAGA_ChunkyMode
    btst      #bSagaPIP,d7                     ; Does the requested mode ask for Saga PIP mode ?
    bne       Use_SAGA_PIPMode                 ; Yes -> Jump to Use_SAGA_PIPMode
;    btst      #bCybergraphx,d7                 ; Does the requested mode ask for a CyberGraph'X graphic mode ?
;    bne       Use_CyberGraphX                  ; Yes -> Jump to Use_CuberGraphX
;    btst      #bPicasso96,d7                   ; Does the requested mode ask for a Picasso96 graphic mode ?
;    bne       Use_Picasso96                    ; Yes -> Jump to Use_Picasso96
;    btst      #bRTG,d7                         ; Does the requested mode ask for a RTG library graphic mode ?
;    bne       Use_RTGLibrary                   ; Yes -> Jump to Use_RTGLibrary
;                                              ; if none of the above, then request for a native planar screen.
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; ******** 2. We use default Bitplanes modes                                                  ********
Use_DefaultPlanars:
    lea         AGAECSREZ(pc),a2
    clr.l       d2
    clr.l       d3
miniLoopGFX:
    move.w      (a2)+,d2              ; d2 = Existing Resolution Width in pixels
    move.w      (a2)+,d3              ; d3 = Existing Resolution Height in pixels
    cmp.w       d3,d5                 ; d5(Height) = Existing resolution Height ?
    bne.s       miniLoopCheck2        ; No, continue with next test
    cmp.w       d2,d4                 ; d4(Width) = Existing resolution Width(d1) ?
    beq.s       miniLoopGFXFound      ; Yes, go and read the ID
miniLoopCheck2:
    adda.l      #2,a2                 ; Add #4 to a2 to reach next resolution data
    tst.l       (a2)                  ; No more resolution ?
    bne.s       miniLoopGFX           ; Another resolution to check -> miniLoopGFX
    CustomError PlanarDisplayModeIsUnknown ; call the error handler and return an error
miniLoopGFXFound:
    clr.l       d3
    move.w      (a2),d3               ; d3 = (07-00) GFXMode Resolution
    or.l        d3,d7                 ; d7 = (07-00) GFXMode Resolution + Specials display mode info (31-19)
    lsl.l       #8,d6                 ; d6 = (15-08) Specials display mode info
    or.l        d6,d7                 ; d7 = GFXMode Resolution (15-08) + PiwelFormat (07-00) + Specials display mode info (31-19)
    sePushToStackLib d7,#TypeInt      ; push d7 to stack to get it back after the commands
    move.l      tempSave(a5),a2       
    rts

AGAECSREZ:
    dc.w       320,200,$01
    dc.w       320,240,$02
    dc.w       320,256,$03
    dc.w       320,400,$04
    dc.w       320,480,$05
    dc.w       320,512,$06
    dc.w       640,200,$07
    dc.w       640,240,$08
    dc.w       640,256,$09
    dc.w       640,400,$0A
    dc.w       640,480,$0B
    dc.w       640,512,$0C
    dc.w      1280,200,$0D
    dc.w      1280,240,$0E
    dc.w      1280,256,$0F
    dc.w      1280,400,$10
    dc.w      1280,480,$11
    dc.w      1280,512,$12
    dc.w         0,000,$00      ; Last slot is empty to ensure loop quit possible.

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; ******** 3. We use SAGA Chunky mode. Convert pixel format + Resolution                      ********
;             to Saga GFXMODE register for getBestScreenMode
; 3.1 Read Chunky Depth mode
Use_SAGA_ChunkyMode:
    lea         SAGA_C2P_DEPTHS(pc),a2
.miniLoop:
    move.l      (a2)+,d3
    cmp.w       d3,d6
    beq.s       .miniLoopQuit
    add.l       #4,a2                 ; Jump to next value
    cmp.l       #0,(a2)               ; new value ?
    bne.s       .miniLoop             ; Yes -> Continue Looping
    CustomError SagaDepthModeIsUnknown
.miniLoopQuit:
    move.l      (a2),d6               ; d6 (07-00) = GFXMode Pixel Format
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 3.2 Read Chunky Graphic Mode (Resolution)
    lea         SAGA_C2P_GFXMODES(pc),a2
.miniLoopGFX:
    move.w      (a2)+,d2              ; d0 = Existing Resolution Width in pixels
    move.w      (a2)+,d3              ; d4 = Existing Resolution Height in pixels
    cmp.w       d3,d5                 ; d5(Height) = Existing resolution Height ?
    bne.s       .miniLoopCheck2       ; No, continue with next test
    cmp.w       d2,d4                 ; d4(Width) = Existing resolution Width(d1) ?
    beq.s       .miniLoopGFXQuit
.miniLoopCheck2:
    add.l       #4,a2
    cmp.l       #0,(a2)
    bne.s       .miniLoopGFX
    CustomError SagaDisplayModeIsUnknown
.miniLoopGFXQuit:
    move.l      (a2),d3               ; d3 = (07-00) GFXMode Resolution
    or.l        d3,d7                 ; d7 = (07-00) GFXMode Resolution + Specials display mode info (31-19)
    lsl.l       #8,d6                 ; d6 = (15-08) Specials display mode info
    or.l        d6,d7                 ; d7 = GFXMode Resolution (15-08) + PiwelFormat (07-00) + Specials display mode info (31-19)
    sePushToStackLib d7,#TypeInt
    move.l      tempSave(a5),a2
    rts
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
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
    dc.w       320,200,0,$01
    dc.w       320,240,0,$02
    dc.w       320,256,0,$03
    dc.w       640,400,0,$04
    dc.w       640,480,0,$05
    dc.w       640,512,0,$06
    dc.w       960,240,0,$07
    dc.w       480,270,0,$08
    dc.w       304,224,0,$09
    dc.w      1280,720,0,$0A
    dc.w       640,360,0,$0B
    dc.w      1024,768,0,$0D
    dc.w       800,600,0,$0C
    dc.w       720,576,0,$0E
    dc.w       848,480,0,$0F
    dc.w       640,200,0,$10
    dc.w         0,000,0,$00      ; Last slot is empty to ensure loop quit possible.

; **** 2022.01.03 Added pixel size for custom screen buffer creation
SAGA_PIXEL_SIZE:
    dc.w       0,1,2,2,3,4,3,0  ; CLUT_OFF(0),CLUT8(1),RGB16(2),RGB15(3),RGB24(4),RGB32(5),YUV422(6),NOT_DEFINED(7)
    dc.w       1,1,1            ; PLANAR1BIT(8),PLANAR2BIT(9),PLANAR4BIT(10=$A) (unknowns modes formats)

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Use_SAGA_PIPMode:
    sePushToStackLib #0,#TypeInt
    move.l      tempSave(a5),a2
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Use_CyberGraphX:
    sePushToStackLib #0,#TypeInt
    move.l      tempSave(a5),a2
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Use_Picasso96:
    sePushToStackLib #0,#TypeInt
    move.l      tempSave(a5),a2
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Use_RTGLibrary:
    sePushToStackLib #0,#TypeInt
    move.l      tempSave(a5),a2
    rts



***************************************************************
;                                                    OpenScreen d3=ScreenID,d4=Width,d5=Height,d6=BestScreenMode
;                                                   ***************************************************************
; D3=ScreenID, D4=Width, D5=Height, D6=BestScreenMode, D7=Must be Extracted from D6
; Based on Vampire's SAGA GFXMODE for better compatibility between ECS/OCS, AGA & SAGA displayables screens.
OpenScreen:
    grmCall    grmLoadSys                      ; a5 = Load SYS 
    movem.l    d0-d3/a0-a2,-(sp)
    seGetMultiFromStack d6,d5,d4,d3            ; Extract D3=ScreenID, D4=Width, D5=Height, D6=BestScreenMode
    move.l     d6,d7
    and.l      #$FFFF,d6                       ; d6 = Depth/PixelFormat
    and.l      #$FFFF0000,d7                   ; d7 = GFXMode
    bra.w      seOpenScreenP2
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    OpenScreenEx d3=ScreenID,d4=Width,d5=Height,d6=PixelFormat,d7=GfxMode
;                                                   ***************************************************************
; D3=ScreenID, D4=Width, D5=Height, D6=Depth/PixelFormat, D7=GFXMode
; Based on Vampire's SAGA GFXMODE for better compatibility between ECS/OCS, AGA & SAGA displayables screens.
OpenScreenEx:
    grmCall    grmLoadSys                      ; a5 = Load SYS 
    movem.l    d0-d3/a0-a2,-(sp)
    seGetMultiFromStack d7,d6,d5,d4,d3         ; Extract D3=ScreenID, D4=Width, D5=Height, D6=Depth/PixelFormat, D7=GFXMode
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 1.1 Check if Screen width is multiple of 16 pixels.
seOpenScreenP2:
    logDebugMessage debugM01,<"OpenScreen:CheckScreenWidthMultipleOf16">
    move.l     d4,d2                           ; D2 = Height
    and.l      #$FFFFFFF0,d2                   : D2 = Height (multiple of 16)
    cmp.l      d2,d4                           ; Was original Height (D4) a multiple of 16 ?
    beq.s      oSA_CheckDimensions             ; if Width is multiple of 16 pixels -> Jump oSA_CheckDimension
error_ScreenWidthNotMultipleOf16:
;    movem.l    (sp)+,d0-d3/a0-a2
    CastErrorID ScreenWidthMultipleOfSixteen   ; if Width not multiple of 16 pixels -> Cast Error.
oSA_CheckDimensions:


                                                   





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


;                      .HBBBD..US.B.L..
;                      .rpppP..HH.P.A..
;                      .e210F..RR.3.C..
;                       s
AGA_DEPTHS:
    dc.l           2,1,%000100000000000                         ; Nbre colors, nbre bitplanes, BplCon0
    dc.l           4,2,%001000000000000
    dc.l           8,3,%001100000000000
    dc.l          16,4,%010000000000000
    dc.l          32,5,%010100000000000
    dc.l          64,6,%011000000000000
    dc.l         128,7,%011100000000000
    dc.l         256,8,%000000000010000
    dc.l        4096,6,%011000000000000
    dc.l    16777216,8,%011000000000000
    dc.l           0,0,%000000000000000

;                       HBBBD..US.B.L..
;                       rpppP..HH.P.A..
;                       e210F..RR.3.C..
;                       s
AGA_GFXMODES:
    dc.w     320,200,0,%000000000000000
    dc.w     320,240,0,%000000000000000
    dc.w     320,256,0,%000000000000000
    dc.w     320,400,0,%000000000000100
    dc.w     320,480,0,%000000000000100
    dc.w     320,512,0,%000000000000100
    dc.w     640,200,0,%100000000000000
    dc.w     640,240,0,%100000000000000
    dc.w     640,256,0,%100000000000000
    dc.w     640,400,0,%100000000000100
    dc.w     640,480,0,%100000000000100
    dc.w     640,512,0,%100000000000100
    dc.w    1280,200,0,%000000001000000
    dc.w    1280,240,0,%000000001000000
    dc.w    1280,256,0,%000000001000000
    dc.w    1280,400,0,%000000001000100
    dc.w    1280,480,0,%000000001000100
    dc.w    1280,512,0,%000000001000100
    dc.w    0,0,0,0


; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    99. Inutile mais nécessaire
;                                                   ***************************************************************
dosName:
    dc.b    "dos.library",0
    EVEN
gCore.Base:
    dc.l    0

addCustomError  MACRO
err\1:
    dc.b    \2,10,0
    ENDM

  addCustomError IncompatibleVideoMode,<"Error #AGA01 : SAGA Chipset modes are not available on this computer.">
  addCustomError UnknownDisplayMode,<"Error #AGA02 : Unknown display resolution.">
  addCustomError NotEnoughMemoryToOpenScreen,<"Error #AGA03 : Not enough memory to open screen.">
  addCustomError PlanarScreenDepthIsInvalid,<"Error #AGA04 : Screen depth can only be in range 1-8 for planar screens.">
  addCustomError ScreenNotOpened,<"Error #AGA05 : Cannot close a non existing screen.">
  addCustomError ScreenWidthMultipleOfSixteen,<"Error #AGA06 : Screen width must be multiple of 16.">
  addCustomError AgaDepthModeIsUnknown,<"Error #AGA07 : Aga depth is unknown.">
  addCustomError AgaDisplayModeIsUnknown,<"Error #AGA08 : Aga display mode is unknown.">
  addCustomError PlanarDisplayModeIsUnknown,<"Error #AGA09 : Aga planar display mode is unknown.">
  addCustomError SagaDepthModeIsUnknown,<"Error #SAGA01 : Unknown SAGA C2P depth mode.">
  addCustomError SagaDisplayModeIsUnknown,<"Error #SAGA02 : Unknown SAGA C2P screen resolution.">

    Dc.l    0,0,0,0
    Dc.b    "<<Grimoire Screens AGA - The Amiga Book of Magic>> All rights reserved © Frederic Cordier 2023 : cordierfr@wanadoo.fr"