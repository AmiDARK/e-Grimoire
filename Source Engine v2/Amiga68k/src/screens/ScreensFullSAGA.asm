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
    dc.b        "grimoire-screensFullSaga.library",0
idString:
    dc.b        "grimoire-screensFullSaga Ver:0.1.2 ( 12 mai 2022 )",13,10,0
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
    dc.l        CloseScreen
    dc.l        getScreenExists
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
    sePushToStackLib  #0,TypeInt

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    getBestScreenModeEx Width,Height,PixelFormat,GFXMode
;                                                   ***************************************************************
getBestScreenModeEx
    move.l    a2,tempSave(a5)                  ; Save a2
    seGetMultiFromStack d7,d6,d5,d4            ; Extract D4=Width, D5=Height, D6=Depth/PixelFormat, D7=GFXMode
; ****************************************************************************************************
; ******** 1. We check if we are under SAGA Chunky display mode                               ********
    btst      #bSagaC2P,d7                     ; Does the requested mode ask for Saga Chunky mode ?
    bne       Use_SAGA_ChunkyMode              ; Yes -> Jump to Use_SAGA_ChunkyMode
    btst      #bSagaPIP,d7                     ; Does the requested mode ask for Saga PIP mode ?
    bne       Use_SAGA_PIPMode                 ; Yes -> Jump to Use_SAGA_PIPMode
    btst      #bCybergraphx,d7                 ; Does the requested mode ask for a CyberGraph'X graphic mode ?
    bne       Use_CyberGraphX                  ; Yes -> Jump to Use_CuberGraphX
    btst      #bPicasso96,d7                   ; Does the requested mode ask for a Picasso96 graphic mode ?
    bne       Use_Picasso96                    ; Yes -> Jump to Use_Picasso96
    btst      #bRTG,d7                         ; Does the requested mode ask for a RTG library graphic mode ?
    bne       Use_RTGLibrary                   ; Yes -> Jump to Use_RTGLibrary
;                                              ; if none of the above, then request for a native planar screen.
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; ******** 2. We use default Bitplanes modes                                                  ********
Use_DefaultPlanars:
    or.l      d6,d7                            ; mix d7 = d6 || d7 to push both PixelFormat & GFXMode inside d7
    sePushToStackLib d7,#TypeInt               ; push d7 to stack to get it back after the commands
    rts
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
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Use_CyberGraphX:
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Use_Picasso96:
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Use_RTGLibrary:

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
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
    move.l     d4,d2                           ; D2 = Width
    and.l      #$FFFFFFF0,d2                   : D2 = Width (multiple of 16)
    cmp.l      d2,d4                           ; Was original Height (D4) a multiple of 16 ?
    beq.s      oSA_CheckDimensions             ; if Width is multiple of 16 pixels -> Jump oSA_CheckDimension
error_ScreenWidthNotMultipleOf16:
;    movem.l    (sp)+,d0-d3/a0-a2
    CastErrorID ScreenWidthMultipleOfSixteen   ; if Width not multiple of 16 pixels -> Cast Error.
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 1.2 Check if screen dimensions meets the requirements
oSA_CheckDimensions:
    logDebugMessage debugM02,<"OpenScreen:CheckScreenSizes">
    cmp.l      #ScreenMinWidth,d4              ; 
    blt.s      error_ScreenDimensionsKO        ; if Width < 320 pixels -> Error
    cmp.l      #ScreenMinHeight,d5             ; 
    blt.s      error_ScreenDimensionsKO        ; if Height < 32 pixels -> Error
    cmp.l      #ScreenMaxWidth,d4              ;
    bgt.s      error_ScreenDimensionsKO        ; if Width > 2048 pixels -> Error
    cmp.l      #ScreenMaxHeight,d5             ;
    ble.s      oSA_CheckScreenID               ; if Height > 2048 pixels -> Error else ->OK (oSA_DimensionsOK)
; Cast "Screen Dimensions are incorrects" error
error_ScreenDimensionsKO:
;    movem.l    (sp)+,d0-d3/a0-a2
    CastErrorID ScreenDimensionsAreKO
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 1.3 Continue by checking if Screen is correct (in range 0-7)
oSA_CheckScreenID:
    logDebugMessage debugM03,<"OpenScreen:CheckScreenID">
    cmp.l      #seMaxScreens,d3
    bge.s      error_ScreenIDIsInvalid
    cmp.l      #0,d3
    bge.s      oSA_CheckScreenAlreadyExists
error_ScreenIDIsInvalid:
    CastErrorID ScreenIDIsInvalid
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 1.4 Continue by checking if Screen already exists or not
oSA_CheckScreenAlreadyExists:
    logDebugMessage debugM04,<"OpenScreen:CheckIfScreenAlreadyExists">
    move.l     d3,d1
    lsl.l      #2,d1                           ; d0 = ScreenID * 4 = Index in the list
    move.l     Screens(a5,d1.w),d0             ; d0 = ScreenPointer(ScreenID/Index)
    tst.l      d0                              ; is d0=NULL ?
    beq.s      oSA_Continue                    ; d0=NULL (Screen does not exists) -> Jump oSA_Continue
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 1.5 If requested screen already exists, we close it before opening a new one.
oSA_CallCloseScreen:
    logDebugMessage debugM04B,<"OpenScreen:ClosePreviousExistingScreen">
    movem.l    d3-d7,-(sp)
    sePushToStack d3
    bsr        CloseScreen
    movem.l    (sp)+,d3-d7
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 1.6 Now we check the type of screen requested to be sure it's an ECS/OCS/AGA one.
oSA_Continue:
    logDebugMessage debugM05,<"OpenScreen:CheckScreenType">
    btst      #bSagaC2P,d7
    bne       Open_SAGA_ChunkyMode
    btst      #bSagaPIP,d7
    bne       Open_SAGA_PIPMode
    btst      #bCybergraphx,d7
    bne       Open_CyberGraphX
    btst      #bPicasso96,d7
    bne       Open_Picasso96
    btst      #bRTG,d7
    bne       Open_RTGLibrary
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
; 1.6.1 Open a native planar screen with D3=ScreenID, D4=Width, D5=Height, D6=Depth/PixelFormat, D7=GFXMode
Open_NativePlanars:
    ; 1.6.1.0 ******** Check if Depth/PixelFormat is compatible with 1-8 bitplanes 
    logDebugMessage debugM06,<"OpenScreen:CheckNativePlanarScreenDepthValidity">
    cmp.l     #8,d6
    bgt.w     FailOpenPlanarScreenDepthKO
    cmp.l     #0,d6
    ble.w     FailOpenPlanarScreenDepthKO

    ; 1.6.1.1 ******** Allocate screen structure buffer
    logDebugMessage debugM07,<"OpenScreen:AllocateInternalScreenStructure">
    movem.l   d3-d7/a3-a5,-(sp)
    bsr       internal_AllocateScreenStructure
    movem.l   (sp)+,d3-d7/a3-a5
    tst.l     d0
    beq       FailOpenScreenNotEnoughMemory
    ; 1.6.1.2 ******** Save screen structure inside screens list.
    logDebugMessage debugM08,<"OpenScreen:LoadScreenStructureIntoA2">
    lea.l     Screens(a5),a2
    lsl.w     #2,d3
    add.l     d3,a2
    lsr.w     #2,d3
    move.l    d0,(a2)
    ; 1.6.1.3 ******** Save screen informations inside the Screen Structure
    logDebugMessage debugM09,<"OpenScreen:SaveScreenInformations">
    move.l    d0,a2                            ; A2 = Currsnt Screen Structure
    move.l    d3,ScScreenID(a2)
    move.l    d4,ScWidth(a2)
    move.l    d5,ScHeight(a2)
    move.l    d6,ScDepth(a2)
    move.w    d6,ScPixelFormat(a2)
    move.l    d7,ScGfxMode(a2)
    move.w    d3,CurrentScreen(a5)             ; Save this screen as "Current Screen"
    ; 1.6.1.4 ******** Define default values (like position, view, etc.) that will be used for copper list.
    logDebugMessage debugM10,<"OpenScreen:PushAGAPModeToColorPalette">
    move.l    #"AGAP",AGAPMode(a2)
    move.l    d4,d0                            ; d0 = Screen Width in pixels
    lsr.l     #3,d0                            ; d0 = Screen Width in bytes
    mulu      d5,d0                            ; d0 = 1 Bit plane size in bytes
    move.l    d0,ScAllocSize(a2)               ; Save 1 bitplane memory allocation size
    ; 1.6.1.5 ******** Create BitMap Structure for screen
    logDebugMessage debugM11,<"OpenScreen:AllocateBitMapStructure">
;    movem.l   d3-d7/a3-a5,-(sp)
    bsr       internal_AllocateBitMapStructure
    beq       FailOpenScreenNotEnoughMemoryEx
    move.l    d0,ScBitMap(a2)
    move.l    d4,d1
    move.l    d5,d2
    movem.l   d3-d7/a3-a5,-(sp)
    exeCall   InitBitMap
    movem.l   (sp)+,d3-d7/a3-a5
    ; 1.6.1.6 ******** Allocate all the screen BitPlanes
    logDebugMessage debugM12,<"OpenScreen:AllocateTrueBitplanes">
;;    movem.l   d3-d7/a3-a5,-(sp)
;    subq.w    #1,d6                            ; d6= Screen Depth -1 ( for dbra loop)
;    lea       ScAllocPhysic(a2),a0
;    lea       ScPhysic(a2),a1
;    moveq     #0,d2
;oSA_BplLoop:
;    move.l    ScAllocSize(a2),d0               ; Directly get bitplane size
;    add.l     #8,d0                            ; Add 8 bytes in total bitmap memory size allow manual 64 bits alignment
;    movem.l   d2-d7/a1-a5,-(sp)
;    grmCall   grmAllocClrChipMem
;    movem.l   (sp)+,d2-d7/a1-a5
    move.l     ScAllocSize(a2),d0               ; d0 = 1 Bitplane bytes size
    mulu       d6,d0                            ; d0 = Full screen size (all bitplanes at once)
    add.l      #8,d0
    movem.l   d2-d7/a1-a5,-(sp)
    grmCall   grmAllocClrChipMem
    movem.l   (sp)+,d2-d7/a1-a5
    tst.l     d0
    beq       FailOpenScreenNotEnoughMemoryEx
    logDebugMessage debugM12B,<"OpenScreen:AllBitPlanesMemoryBlockAllocatedAtOnce">
    move.l    d0,ScAllocPhysic(a2)              ; Save full screen block.
    add.l     #8,d0                             ; Prepare for 64 bits alignment
    and.l     #$FFFFFFC0,d0                     ; d0 = 64 Bit aligned bitplane starting.
    logDebugMessage debugM12C,<"OpenScreen:DefineallBitplanesAdresses">
    move.l    ScAllocSize(a2),d7                ; D7 = 1 Bitplane size
    lea.l     ScPhysic(a2),a2 
    subq.w    #1,d6                             ; d6 = Depth -1 (for dbra loop purposes)
cpLoop:
    logDebugMessage debugM12D,<"OpenScreen:Push1BitPlane">
    move.l    d0,(a2)+                          ; Save Bitplane Adress
    add.l     d7,d0                             ; d0 = Next Bitplane
    dbra      d6,cpLoop
;    move.l    d0,(a2,d2.w)                     ; Save current created bitplane in ScAllocPhysic(0-7)
;;    and.l     #$FFFFFFF8,d0
;;    add.l     #8,d0
;    move.l    d0,(a1,d2.w)                     ; Save final Bitplane 64 bits aligned start adress in ScPhysic(0-7)
;    dbra      d6,oSA_BplLoop

    logDebugMessage debugM13,<"OpenScreen:ScreenOpenedSuccessfully">
    movem.l    (sp)+,d0-d3/a0-a2               ; Restores registers d0 to d3 and a0 to a2.
    rts
;    bra       EndOfOpeningScreen

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Open_SAGA_ChunkyMode:
    bra       EndOfOpeningScreen

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Open_SAGA_PIPMode:
    bra       EndOfOpeningScreen

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Open_CyberGraphX:
    bra       EndOfOpeningScreen

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Open_Picasso96:
    bra       EndOfOpeningScreen
    dc.b      "void"
; **************************************************************
;                                                       ****
;                                                   ***************************************************************
Open_RTGLibrary:


EndOfOpeningScreen:
    movem.l    (sp)+,d0-d3/a0-a2               ; Restores registers d0 to d3 and a0 to a2.
    rts


; **************************************************************
;                                                       ****
;                                                   ***************************************************************
FailOpenScreenNotEnoughMemoryEx:
    move.l     a2,tempSave(a5)                 ; Save Screen Structure pointer into TempSave(a5)
    bsr        internal_ReleaseBitMapStructureA2
    move.l     tempSave(a5),a2                 ; A2 = Screen Structure
    bsr        internal_ReleaseBitplanesA2
    move.l     tempSave(a5),a2                 ; A2 = Screen Structure
    bsr        internal_ReleaseScreenStructureA2
FailOpenScreenNotEnoughMemory:
    movem.l    (sp)+,d0-d3/a0-a2               ; Restores registers d0 to d3 and a0 to a2.
    CustomError NotEnoughMemoryToOpenScreen
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
FailOpenPlanarScreenDepthKO:
    movem.l    (sp)+,d0-d3/a0-a2               ; Restores registers d0 to d3 and a0 to a2.
    CustomError PlanarScreenDepthIsInvalid
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
internal_AllocateScreenStructure:
    move.l     #ScreensStructureLen,d0         ; D0 = Screen Structure size in bytes
    grmCall    grmAllocClrFastMem              ; Allocate memory to handle screen structure -> D0=Buffer
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
internal_AllocateBitMapStructure:
    move.l     #bm_SIZEOF,d0                   ; D0 = BitMap structure size
    grmCall    grmAllocClrFastMem              ; Allocate memory to handle screen structure -> D0=Buffer
    rts


; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    CloseScreenSAGA d7=ScreenID
;                                                   ***************************************************************
CloseScreen:
    grmCall    grmLoadSys                      ; a5 = Load SYS 
    movem.l    d0-d3/a0-a2,-(sp)
    logDebugMessage debugCS01,<"CloseScreen:CheckIfScreenExistsOrNot">
    bsr        getScreenExists
    ; Clear Screen informations inside the screens list.
    lea.l      Screens(a5),a2                  ; A2 = Screen #0
    lsl.w      #2,d7                           ; D7 = Screen ID * 4 (convert ID to .l shift value)
    move.l     #0,(a2,d7.w)                    ; D0 = Screen Exists (=/= 0 = Screen Structure Pointer)

    seGetFromStack d7                          ; D7=Screen Pointer
    move.l     d7,tempSave(a5)                 ; Save Screen Structure pointer into TempSave(a5)
    tst.l      d7
;    beq.s      csNotOpened
    bne.s      CloseScreenB
csNotOpened:
    CustomError ScreenNotOpened
CloseScreenB:
    logDebugMessage debugCS02,<"CloseScreen:CheckScreenTypeForSpecificCloseMethod">
    move.l     d7,a2                            ; a2 = Screen Pointer
    move.l     ScGfxMode(a2),d7
    btst       #bSagaC2P,d7
    bne        Close_SAGA_ChunkyMode
    btst       #bSagaPIP,d7
    bne        Close_SAGA_PIPMode
    btst       #bCybergraphx,d7
    bne        Close_CyberGraphX
    btst       #bPicasso96,d7
    bne        Close_Picasso96
    btst       #bRTG,d7
    bne        Close_RTGLibrary
Close_Planars:
    logDebugMessage debugCS03,<"CloseScreen:CloseNativePlanarsScreen">
    ; ******** Release the screen bitplanes
    move.l     a2,tempSave(a5)                 ; Save Screen Structure pointer into TempSave(a5)
    bsr        internal_ReleaseBitplanesA2
    ; ******** Release the BitMap Structure memory block
    move.l     tempSave(a5),a2                 ; A2 = Screen Structure
    bsr        internal_ReleaseBitMapStructureA2
scClosureCommon:
    ; ******** Finish the screen closure
    move.l     tempSave(a5),a2                 ; A2 = Screen Structure
    bsr        releaseScreenStructure
    ; ******** Release the screen structure memory block
    move.l     tempSave(a5),a2                 ; A2 = Screen Structure
    bsr        internal_ReleaseScreenStructureA2
csEnd:
    logDebugMessage debugCS08,<"CloseScreen:ScreenSuccessfullyClosed">
    movem.l    (sp)+,d0-d3/a0-a2
    rts

Close_SAGA_ChunkyMode:
    ; ******** Finish the screen closure
    bra        scClosureCommon

Close_SAGA_PIPMode:
    ; ******** Finish the screen closure
    bra        scClosureCommon

Close_CyberGraphX:
    ; ******** Finish the screen closure
    bra        scClosureCommon

Close_Picasso96:
    ; ******** Finish the screen closure
    bra        scClosureCommon

Close_RTGLibrary:
    ; ******** Finish the screen closure
    bra        scClosureCommon



; **************************************************************
;                                                       ****
;                                                   ***************************************************************
internal_ReleaseBitplanesA2:
    logDebugMessage debugCS05,<"CloseScreen:ReleaseBitPlanes">
    move.l    ScDepth(a2),d6
    move.l    ScAllocSize(a2),d0               ; d0 = 1 Bitplane bytes size
    mulu      d6,d0                            ; d0 = All Bitplanes bytes size
    add.l     #8,d0                            ; d0 = + 64 Bits alignment = Full allocated size
    move.l    ScAllocPhysic(a2),d1             ; d1 = Memory block to release
    tst.l     d1
    bne.s     iRBA2
    CustomError BitPlanesNotAllocated
iRBA2:
    move.l    d1,a1
    grmCall   grmFreeMem                       ; Release buffer a1,d0
    ; ****************************************************************** TO DO : Release ScAllocLogic for double buffer mode.
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
releaseScreenStructure:
    logDebugMessage debugCS06,<"CloseScreen:ReleaseScreenStructure">
    ; ******** Remove Screen Structure from screens list.
    move.l     ScScreenID(a2),d0
    lsl.l      #2,d0
    Lea        Screens(a5),a2
    add.l      d0,a2
    clr.l      (a2)
   rts

internal_ReleaseScreenStructureA2:
    logDebugMessage debugCS07,<"CloseScreen:ReleaseScreenStructure[Internal]">
    movea.l   a2,a1
    move.l    #ScreensStructureLen,d0
    grmCall   grmFreeMem                       ; Release buffer a1,d0
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
internal_ReleaseBitMapStructureA2:
    logDebugMessage debugCS04,<"CloseScreen:ReleaseBitMapStructure">
    move.l    ScBitMap(a2),a1
    clr.l     ScBitMap(a2)
    move.l    #bm_SIZEOF,d0
    grmCall   grmFreeMem                       ; Release buffer a1,d0
    rts



; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    getScreenExists( d7=ScreenID )
;                                                   ***************************************************************
getScreenExists:
    logDebugMessage debugGSE01,<"GetScreenExists:CallMethod">
    grmCall    grmLoadSys                      ; a5 = Load SYS 
    movem.l    d0/a2,-(sp)
    seGetFromStack d7                       ; D0=ScreenID
    logDebugMessage debugGSE02,<"GetScreenExists:CheckScreenIDNumberValidity">
    cmp.l      #seMaxScreens,d7
    bge.s      gSE_ScreenIDIsInvalid
    cmp.l      #0,d7
    bge.s      gSE_Ok
gSE_ScreenIDIsInvalid:
;    movem.l    (sp)+,d0/a2
    CastErrorID ScreenIDIsInvalid
    rts
gSE_Ok:
    logDebugMessage debugGSE03,<"GetScreenExists:GetScreenStructureOrNullPointer">
    lea.l      Screens(a5),a2                  ; A2 = Screen #0
    lsl.w      #2,d7                           ; D7 = Screen ID * 4 (convert ID to .l shift value)
    move.l     (a2,d7.w),d0                    ; D0 = Screen Exists (=/= 0 = Screen Structure Pointer)
    lsr.w      #2,d7
    sePushToStack d0
    logDebugMessage debugGSE04,<"GetScreenExists:Finished">
    movem.l    (sp)+,d0/a2
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

  addCustomError SagaDepthModeIsUnknown,<"Error #SAGA01 : Unknown SAGA C2P Depth mode.">
  addCustomError SagaDisplayModeIsUnknown,<"Error #SAGA02 : Unknown SAGA C2P Screen Resolution.">
  addCustomError NotEnoughMemoryToOpenScreen,<"Error #SAGA03 : Not enough memory to open screen.">
  addCustomError PlanarScreenDepthIsInvalid,<"Error #SAGA04 : Screen depth can only be in range 1-8 for planar screens.">
  addCustomError ScreenNotOpened,<"Error #SAGA05 : Cannot close a non existing screen.">
  addCustomError BitPlanesNotAllocated,<"Error #SAGA06 : Error Bitplane buffer not allocated">

    Dc.l    0,0,0,0
    Dc.b    "<<Grimoire Screens SuperAGA - The Amiga Book of Magic>> All rights reserved © Frederic Cordier 2023 : cordierfr@wanadoo.fr"

