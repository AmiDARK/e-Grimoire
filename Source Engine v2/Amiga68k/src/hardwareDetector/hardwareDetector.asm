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

; Vampires Hardware modes :

; |----------+----------+----------+----------+----------+----------+----------+-------------+-----------+
; | Board ID |   Name   | ECS/OCS  |   AGA    | SuperAGA |  Chunky  |   PIP    | 16bit Audio | 3D MAGGIE |
; |----------+----------+----------+----------+----------+----------+----------+-------------+-----------+
; |          |          |          |          |          |          |          |             |           |
; |    1     | V600     |    X     |          |          |    X     |          |             |           |
; |          |          |          |          |          |          |          |             |           |
; |    2     | V500     |    X     |          |          |    X     |          |             |           |
; |          |          |          |          |          |          |          |             |           |
; |    3     | V4_500   |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |          |          |          |          |          |          |          |             |           |
; |    4     | V4_1200  |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |          |          |          |          |          |          |          |             |           |
; |    5     | V4SA     |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |          |          |          |          |          |          |          |             |           |
; |    6     | V1200    |    X     |    X     |          |    X     |          |             |           |
; |          |          |          |          |          |          |          |             |           |
; |    7     | KRAKEN   |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |          |          |          |          |          |          |          |             |           |
; |----------+----------+----------+----------+----------+----------+----------+-------------+-----------+



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
    include     "exec/exec.i"
    include     "LVO/exec_lib.i"
; ****** 1.3 dos.library includes
    include     "dos/dos.i"
    include     "LVO/dos_lib.i"

    include     "VampiresIncludes/sagaRegisters.h"

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
    dc.b        "grimoire-hardwareDetector.library",0
idString:
    dc.b        "Grimoire-hardwareDetector  Ver:0.1 ( 04 April 2023 )",13,10,0
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
    dc.l        detectHardware
    dc.l        getHardwareDetails
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


Constructor:
    moveq      #0,d0
    rts
Destructor:
    moveq      #0,d0
    rts

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    11. Routines internes à la librairie [Ne pas modifier]
;                                                   ***************************************************************
pushCPUModel MACRO
    lea        processorModel(pc),\2
    move.b     \1,(\2)
    ENDM

pushFPUModel MACRO
    lea        fpuModel(pc),\2
    move.b     \1,(\2)
    ENDM

detectHardware:
; ************************************************************************
; 1. Use exec.library/AttnFlags to get attnFlags to read micro-processor configuration (and FPU too)
detectCPU:
    move.l     $4.w,a6
    move.w     AttnFlags(a6),d7
    lea.l      gAttnFlags(pc),a4 
    move.w     d7,(a4)          ; Save AttnFlags

; ************************************************************************ TRY TO DETECT VAMPIRE CARDS - START
; 1.1 Try to detect any VAMPIRE CARDS
    btst       #CPU_68080,d7
    beq.w      CheckCPUS

; **************************************************** VAMPIRE CARD CPU DETECTED - START
; 1.1.2 Now we must check if the current Vampire card own SAGA graphic chipset.
cpuIs68080:
    move.w     #80,d6                          ; CPU & FPU = 68080.
    pushCPUModel d7,a4
    pushFPUModel d7,a4
; **************************************************** VAMPIRE CARD CPU DETECTED - END
 ***************************************************** DETECT VAMPIRE CARDS GFX/AUDIO CHIPSETS - START
CheckVampVersion    Equ  ChipsetBase+VAMPIREVERSION    
    
    lea.l      gAttnFlags(pc),a4 
    clr.l      d7
    move.w     (a4),d7          ; Save AttnFlags
    movea.l     #CheckVampVersion,a4
    move.w     (a4),d7
    and.l      #$FF00,d7
    lsr.w      #8,d7                           ; Bits 15-08 -> 07-00
    cmp.b      #1,d7
    blt.s      .vpct0                          ; IF ID < 1 -> ERROR
    cmp.b      #7,d7
    ble.s      .vpct1                          ; IF ID > 7 -> ERROR
.vpct0:
    CastErrorID VampireCardNotRecognized
.vpct1:
    lsl.w      #2,d7                           ; D6=D6*4 (each card datas are .l)
    lea.l      KnownCards(pc),a4
    add.l      d7,a4
    move.l     (a4),d7
    Lea.l      AdditionalVampireChipsetType(pc),a4
    move.l     d7,(a4)
    lea        graphicChipsetType(pc),a4
    move.b     #2,(a4)         ; Push both AGA (=2) & ECS/OCS (=1) = 2 + 1 = 3
; ***************************************************** DETECT VAMPIRE CARDS GFX/AUDIO CHIPSETS - END
    bra        detectGraphicsCardsAndInterfaces ; Jump to next part to detect CGX, RTG, P96, etc...
KnownCards:
; |----------+----------+----------+----------+----------+----------+----------+-------------+-----------+
; | Board ID |   Name   | ECS/OCS  |   AGA    | SuperAGA |  Chunky  |   PIP    | 16bit Audio | 3D MAGGIE |
; |----------+----------+----------+----------+----------+----------+----------+-------------+-----------+
; |    0     |          |    X     |          |          |          |          |             |           |
; |    1     | V600     |    X     |          |          |    X     |          |             |           |
; |    2     | V500     |    X     |          |          |    X     |          |             |           |
; |    3     | V4_500   |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |    4     | V4_1200  |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |    5     | V4SA     |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |    6     | V1200    |    X     |    X     |          |    X     |          |             |           |
; |    7     | KRAKEN   |    X     |    X     |    X     |    X     |    X     |      X      |     X     |
; |----------+----------+----------+----------+----------+----------+----------+-------------+-----------+
NULL:
    dc.b       1,0,0,1                         ; ECS/OCS / NO ADDITIONAL / NO ADDITIONAL / NATIVE AUDIO 
V600:
    dc.b       1,1,0,1                         ; ECS/OCS / CHUNKY / NO ADDITIONAL / NATIVE AUDIO
V500:
    dc.b       1,1,0,1                         ; ECS/OCS / CHUNKY / NO ADDITIONAL / NATIVE AUDIO
V4_500:
    dc.b       3,3,0,3                         ; ECS/OCS/AGA / CHUNKY+SUPERAGA+PIP / NO ADDITIONAL/ NATIVE AUDIO + SAGA AUDIO
V4_1200:
    dc.b       3,3,0,3                         ; ECS/OCS/AGA / CHUNKY+SUPERAGA+PIP / NO ADDITIONAL/ NATIVE AUDIO + SAGA AUDIO
V4SA:
    dc.b       3,3,0,3                         ; ECS/OCS/AGA / CHUNKY+SUPERAGA+PIP / NO ADDITIONAL/ NATIVE AUDIO + SAGA AUDIO
V1200:
    dc.b       1,1,0,1                         ; ECS/OCS / CHUNKY / NO ADDITIONAL / NATIVE AUDIO
KRAKEN:
    dc.b       3,3,0,3                         ; ECS/OCS/AGA / CHUNKY+SUPERAGA+PIP / NO ADDITIONAL/ NATIVE AUDIO + SAGA AUDIO
;
; ************************************************************************ TRY TO DETECT VAMPIRE CARDS - END

; ************************************************************************ TRY TO DETECT OTHERS CPUS (Classics 680x0) - START
CheckCPUS:
; As AttbFlags store cumulative values (ex. 68010, 68020 and 68030 for 68040), we must check bit value separately
    lea.l      gAttnFlags(pc),a4               ; (remove cumulatives flags sets)
    move.w     (a4),d7
nextCPU60:                                ; 1.1.3 Now we setup CPU/FPU depending on the higher model detected
    btst       #CPU_68060,d7
    beq.s      nextCPU40
cpuIs60:                                    ; 1.1.4 Cpu MODEL is Motorola 68060
    move.w     #60,d7                          ; CPU = 68060
    bra        pushCPU
nextCPU40:                                ; 1.1.5 Is CPU 68040 ?
    btst       #CPU_68040,d7
    beq.s      nextCPU30
cpuIs40:                                    ; 1.1.6 Cpu MODEL is Motorola 68040
    move.w     #40,d7                          ; CPU = 68060
    bra        pushCPU
nextCPU30:                                ; 1.1.7 Is CPU 68040 ?
    btst       #CPU_68030,d7
    beq.s      nextCPU20
cpuIs30:                                    ; 1.1.8 Cpu MODEL is Motorola 68040
    move.w     #30,d7                          ; CPU = 68060
    bra        pushCPU
nextCPU20:                                ; 1.1.9 Is CPU 68040 ?
    btst       #CPU_68020,d7
    beq.s      nextCPU10
cpuIs20:                                    ; 1.1.10 Cpu MODEL is Motorola 68040
    move.w     #20,d7                          ; CPU = 68060
    bra        pushCPU
nextCPU10:                                ; 1.1.11 Is CPU 68040 ?
    btst       #CPU_68010,d7
    beq.s      cpuIs00
cpuIs10:                                    ; 1.1.12 Cpu MODEL is Motorola 68040
    move.w     #10,d7  
    bra        pushCPU
cpuIs00:
    move.w     #0,d7                          ; CPU = 68060
pushCPU:
    pushCPUModel d7,a4
; ************************************************************************ TRY TO DETECT OTHERS CPUS (Classics 680x0) - END

; ************************************************************************ TRY TO DETECT OTHERS FPUS (Classics 68081/2 & 68040) - START
CheckForFPUs:
    lea.l      gAttnFlags(pc),a4               ; (remove cumulatives flags sets)
    move.w     (a4),d7
; Concerning 68060 & 68080, they always own a FPU, so the values are updated when the CPU is detected.
; Then, we will only have to check for 68881, 68882 and 68040 FPUs
nextFPU60:
    btst       #FPU_68060,d7
    beq.s      nextFPU40
fpuIs60:
    move.w     #60,d7                          ; CPU = 68060
    bra        pushFPU
nextFPU40:                                ; 1.2.1 Now we setup CPU/FPU depending on the higher model detected
    btst       #FPU_68040,d7
    beq.s      nextFPU82
fpuIs40:
    move.w     #40,d7                          ; CPU = 68060
    bra        pushFPU
nextFPU82:
    btst       #FPU_68882,d7
    beq.s      nextFPU81
fpuIs82:
    move.w     #82,d7                          ; CPU = 68060
    bra        pushFPU
nextFPU81:
    btst       #FPU_68881,d7
    beq.s      nextNOFPU
fpuIs81:
    move.w     #81,d7                          ; CPU = 68060
    bra        pushFPU
nextNOFPU:
    move.w     #0,d7
pushFPU:
    pushFPUModel d7,a4
noMoreFPUs:
; ************************************************************************ TRY TO DETECT OTHERS FPUS (Classics 68081/2 & 68040) - END

; ************************************************************************ TRY TO DETECT AGA Chipset - START
detect_ECS_OCS_AGA_Chipset:
; 2.1 Force ECS/OCS to be always available
    lea        graphicChipsetType(pc),a4
    move.b     #1,(a4)
; 2.2 Start to detect AGA graphics chipset
    moveq      #30,d7          ; Loop amount()
    lea        $dff07c,a4      ; lea the register to check content
    move.w     (a4),d6         ; 61 = read register
    and.w      #$FF,d6         ; D6 = filtered
dcLoop:
    move.w     (a4),d5         ; D5 = Read Register
    and.w      #$FF,d5         ; D5 = filtered
    cmp.b      d6,d5           ; Compare D6 read & D5 Read
    bne.s      cdEOAc            ; Not equal -> Bus Garbage -> ECS
    dbra       d7,dcLoop       ; Loop until d7 = -1
    or.b       #$F0,d6         ; D6 & $F0
    cmp.b      #$F8,d6         ; if D6 =$F8 -> AGA
    bne.s      cdEOAc          ; Else -> ECS
cIsAGA:
    lea        graphicChipsetType(pc),a4
    move.b     #2,(a4)         ; Push both AGA (=2) & ECS/OCS (=1) = 2 + 1 = 3
cdEOAc:
; ************************************************************************ TRY TO DETECT AGA Chipset - END

; ************************************************************************ TRY TO DETECT Secondaries displays drivers - START
detectGraphicsCardsAndInterfaces:
; ******************************************************************
; 3.1 Try to detect RTG.library system

; ******************************************************************
; 3.2 Try to detect cybergraphics system

; ******************************************************************
; 3.3 Try to detect picasso96.library system



    lea.l      audioChipset(pc),a4
    move.b     #1,(a4)
; ************************************************************************ TRY TO DETECT Secondaries displays drivers - END
    lea.l      hardwareDetails(pc),a4
    rts

getHardwareDetails:
    lea        hardwareDetails(pc),a4
    rts

hardwareDetails:
    dc.b       "GRIMR-HD"
gAttnFlags:
    dc.l       0
processorModel:
    dc.b       0               ; 0=68000, 1=68010, 2=68020, 3=68030, 4=68040, 6=68060 or 8=68080
fpuModel:
    dc.b       0               ; 0=none, 3=68030, 6=68060, 81=68881, 82=68882 or 80=68080
graphicChipsetType:
    dc.b       1               ; 1=ECS/OCS, 2=AGA
AdditionalVampireChipsetType:
    dc.b       0               ; 1=C2P, 2=Super AGA.
isAdditionalGraphics:
    dc.b       0               ; 1=RTG available, 2=CyberGraphics available, 4=Picasso96 available
audioChipset:
    dc.b       1               ; 1=Native amiga classics one, 2=SAGA Audio, 4=AHI driver
cpuModels:
    dc.b       0, 10, 20, 30, 40,  0,  0, 40, 60, -1
fpuModels:
    dc.b       0,  0,  0,  0,  0, 81, 82, 40, 60, -1


dosName:
    dc.b    "dos.library",0
    even

; **************************************************************
;                                                       ****
;                                                   ***************************************************************
;                                                    99. Inutile mais nécessaire
;                                                   ***************************************************************


    Dc.l    0,0,0,0
    Dc.b    "<<Grimoire Amiga Hardware detection - The Amiga Book of Magic>> All rights reserved © Frederic Cordier 2023 : cordierfr@wanadoo.fr"