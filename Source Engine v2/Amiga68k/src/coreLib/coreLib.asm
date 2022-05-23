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
;    include     "dos/dos.i"
;    include     "LVO/dos_lib.i"
    include "libraries/dosextens.i"


exeCall         MACRO
    move.l      $4,a6
    Jsr         _LVO\1(a6)
                ENDM

dosCall         MACRO
    move.l      DosBase(a5),a6
    jsr         _LVO\1(a6)
                ENDM


    include "GRMIncludes/grimoire-configuration.asm"

    include "GRMIncludes/grimoire-structure.asm"

    include "GRMIncludes/grimoire-errorHandler.asm"

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

; This Macro load the System Structure pointer -> A5
LoadSys         MACRO
    ; Load the Source Engine internal Data Structure pointer to A5 register
    lea.l       SysStructBackup(pc),\1
    Move.l      (\1),\1                                ; \1 = Pointer to Internal System Structure
                ENDM

loadGlobalDatas MACRO
    move.l      globalDatas(a5),\1
                ENDM

loadLocalDatas  MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\1
                ENDM

; This macro will save Stack pointer
SaveSP          MACRO
    lea.l       savedSP(pc),a5
    move.l      a7,(a5)
                ENDM

AllocateSPBuffer MACRO
    move.l      $4,a6
    move.l      #StackBufferSize,d0
    move.l      #Public|Clear,d1
    exeCall     AllocMem
    lea         newSP(pc),a5
    move.l      d0,(a5)
    add.l       #2044,d0
    move.l      d0,a7
                ENDM
     
ReleaseSPBuffer MACRO
    move.l      newSP(pc),a1
    move.l      #StackBufferSize,d0
    exeCall     FreeMem
    lea.l       newSP(pc),a1
    clr.l       (a1)
                ENDM   

LoadSP          MACRO
    lea.l       savedSP(pc),a5
    move.l      (a5),a7
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
    dc.b        "grimoire-core.library",0
idString:
    dc.b        "grimoire-core  Ver:0.1.1 ( 26 mars 2023 )",13,10,0
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
    dc.l        Constructor                       ; -30
    dc.l        Destructor                        ; -36
    dc.l        startGrimoire                     ; -42
    dc.l        hotEndGrimoire                    ; -48
    dc.l        CastErrorIDInt                    ; -54
    dc.l        LoadSysInternal                   ; -60
    dc.l        AllocClrChipMem                   ; -66
    dc.l        AllocChipMem                      ; -72
    dc.l        AllocClrFastMem                   ; -78
    dc.l        AllocFastMem                      ; -84
    dc.l        FreeMm                            ; -90
    dc.l        clearSmallMemory                  ; -96
    dc.l        buildGlobalVariables              ; -102
    dc.l        deleteGlobal                      ; -108
    dc.l        buildLocalVariables               ; -114
    dc.l        deleteLocalVariables              ; -120
    dc.l        buildAllLoopsBuffer               ; -126
    dc.l        deleteAllLoopsBuffer              ; -132
    dc.l        CastCustomErrorMessage            ; -138
    dc.l        seLoadStackA3                     ; -144
    dc.l        seSaveA3Stack                     ; -150
    dc.l        seResetStack                      ; -156
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
            exeCall OpenLibrary
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
            exeCall Remove                 ;supprimer Library
                                           ;de la liste Exec-Lib
            move.l ml_DosLib(a5),a1        ;Pointeur sur DOS-Library
            exeCall CloseLibrary           ;Fermer Library
            clr.l d0                       ;effacer D0
            move.l a5,a1                   ;Pointeur sur Library
            move.w LIB_NEGSIZE(a5),d0
            sub.l d0,a1                    ;cherche pointeur sur
                                           ;début de la mémoire
                                           ;occupée par la librairie
            add.w LIB_POSSIZE(a5),d0       ;obtenir longueur de la
                                           ;mémoire occupée
            exeCall FreeMem                ;libère la mémoire
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

; -------------------------------------------------------------------------------------------------------
; ********************* 1. Here is the start "setup" point of the e-grimoire core engine.
; This point is reached with the pointer to the developer function that will be the start point of his/her source code development
; project in A0.
startGrimoire:
; ****************** 1.1 Here we will save the initial StackPointer to be sure we will makes it being correct at ending
;    SaveSP                                            ; Now directly saved from startup.
;    AllocateSPBuffer
; ****************** 1.2 Here we will get information from CLI if available of from WB if available
    bsr         cliOrWbStartup                         ; Cli & WorkBench Startup
; ****************** 1.3 Here we will allocate memory for internal structures
    bsr         AllocSys                               ; (seInternalStructures.s) Allocate memory for the internal Structure and save it into SysStructBackup
; ****************** 1.4 Load internal structure memory pointer into A5 [RESERVED FOR THIS USE ONLY]
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
; ****************** 1.5 Build the full variables buffer. It will contains firstly global, then locals to procedure set on the fly.
    bsr         vmsbuildFullVariablesBuffer            ; Allocate memory for the whole variables (global+local+ local recursive calls)
; ****************** 1.6 Create the stack memory block to contains parameters for Game Engine calls.
    bsr         seCreateStack                          ; Create the stack used to send/receive variables
; ****************** 1.7 Open all the required AmigaOS libraries/devices/etc.
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    bsr         openDosLib                             ; Open dos.library and save its base in the SysStructDatas
    bsr         openGraphicsLib                        ; Open graphics.library and save its base in the SysStructDatas
    bsr         openIntuitionLib                       ; Open intuition.library and save its base in the SysStructDatas
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    bsr         openHardwareDetectorLib_v1             ; Open hardwareDetector.library and save its base in the SysStructDatas
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    bsr         openMathFFPLib_v2                      ; Open mathffp.library and save its base in the SysStructDatas
    LoadSys     a5
    bsr         openScreensSupportLib

    rts

; -------------------------------------------------------------------------------------------------------
; ********************* 3. Here is the Ending "setup" point of the e-grimoire core engine.
; This point is reached when the developer source code run is over and the engine return to this library after a "RTS" from the gosub call
; to the default "grimoireSTART" label inside the developer source code.
; This function is ordered in the opposite way than the coldStart function to be sure to closes things in the correct order
hotEndGrimoire:
; ****************** 3.1 Load internal structure memory pointer into A5 [RESERVED FOR THIS USE ONLY].
    LoadSys     a5
    move.l      SpPanic(a5),d0
    lea         savedSP(pc),a0
    move.l      d0,(a0)
; ****************** 3.2 Close all the required AmigaOS libraries/devices/etc.
    bsr        closeScreensSupportLib
    LoadSys     a5
    bsr        closeMathFFPLib_v2                      ; Close mathffp.library and remove it's pointer from the SysStructDatas
    LoadSys     a5
    bsr        closeHardwareDetectorLib_v1             ; Close hardwareDetector.library and remove it's pointer from the SysStructDatas
    bsr        closeIntuitionLib                       ; Close intuition.library and remove it's pointer from the SysStructDatas
    bsr        closeGraphicsLib                        ; Close graphics.library and remove it's pointer from the SysStructDatas
    bsr        closeDosLib                             ; Close dos.library and remove it's pointer from the SysStructDatas
; ****************** 3.3 release the stack memory block.
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    bsr        seReleaseStack                          ; Release the stack used to send/receive variables
; ****************** 3.4 Release the full variables buffer.
    bsr        vmsDeleteFullVariablesBuffer            ; Release the memory buffer allocated for all datas.
; ****************** 3.5 Here we will release memory previously allocated for internal structures.
    bsr        FreeSys                                 ; (seSetup.s) Release memory of the Internal Structure
; ****************** 3.6 Here we will quit properly, depending on the launch mode CLI or Workbench
    bsr        cliOrWbFinish                           ; Cli & Workbench proper ends
; ****************** 3.7 Here, we will restore initial stack pointer to be sure that Amiga system will not crash after leaving.
;    LoadSP
;    move.l      savedSP(pc),a7
;    ReleaseSPBuffer
; ****************** 3.8 All is over. Go back to CLI or Workbench.
    rts
; -------------------------------------------------------------------------------------------------------
; ********************* 4. Here we will includes additional internal functions/methods required by the grimoire source engine..
LoadSysInternal:
    LoadSys    a5
    rts

; ****************** 4.1 Include memory alloc AllocSys/FreeSys
    include     "src/coreLib/coreLib_memoryHandler.asm"

; ****************** 4.2 Include stack memory alloc AllocSys/FreeSys
    include     "src/coreLib/coreLib_stack.asm"

; ****************** 4.3 Include Error Handler System
    include     "src/coreLib/coreLib_errorHandler.asm"

; ****************** 4.4 Include 'Variables Managment System' internal functions vmsbuildFullVariablesBuffer/vmsDeleteFullVariablesBuffer
    include     "src/coreLib/coreLib_vms.asm"

; ****************** 4.4 Include startup & quit for CLI & Workbench modes cliOrWbStartup/cliOrWbFinish
    include     "src/coreLib/coreLib_cliOrWorkbench.asm"

; ****************** 4.5 Include file for Maths FFP conversion functions openMathFFPLib_v2/closeMathFFPLib_v2
    include     "src/coreLib/coreLib_grm_fpu_lib.asm"

; ****************** 4.6 Include file for hardwareDetector conversion functions openMathFFPLib_v2/closeMathFFPLib_v2
    include     "src/coreLib/coreLib_hardwareDetector.asm"

    include     "src/coreLib/coreLib_doslibrary.asm"
    include     "src/coreLib/coreLib_graphicslibrary.asm"
    include     "src/coreLib/coreLib_intuitionlibrary.asm"

    include     "src/coreLib/coreLib_displayDriverSupport.asm"
    include     "src/coreLib/coreLib_screensSupport.asm"

;                                                       ****
;                                                   ***************************************************************
;                                                    99. Inutile mais nécessaire
;                                                   ***************************************************************
; Pointer to where the developer source code compiled start.
DeveloperPoint:
    dc.l        0,0
; System structure pointer backup
SysStructBackup:
    dc.l    0
; Stack pointer backup
savedSP:
    dc.l    0
newSP:
    dc.l    0

grm_fpconvert.library:
    dc.b    "System/grimoire-fpconvert.library",0
    EVEN

grm_hardwareDetector.library:
    dc.b    "System/grimoire-hardwareDetector.library",0
    EVEN

screensName:
    dc.b    "System/grimoire-screensFullSaga.library",0
    EVEN

displayDriverName:
    dc.b    "System/grimoire-displayDriverSaga.library",0
    EVEN

dosName:
    dc.b    "dos.library",0
    even

graphicsName:
   dc.b    "graphics.library",0
   EVEN

intuitionName:
    dc.b    "intuition.library",0
    EVEN

    Dc.l    0,0,0,0
    Dc.b    "<<Grimoire Core - The Amiga Book of Magic>> All rights reserved © Frederic Cordier 2023 : cordierfr@wanadoo.fr"