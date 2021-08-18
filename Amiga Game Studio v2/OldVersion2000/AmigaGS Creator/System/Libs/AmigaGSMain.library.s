	Incdir	"includes:"
	include "exec/types.i"
	include "exec/initializers.i"
	include "exec/librariesDVP.i"
	include "exec/lists.i"
	include "exec/nodes.i"
	include "exec/resident.i"
	include "libraries/dosDVP.i"
	include "exec/alerts.i"
;	Include "exec/exec_lib.i"
	include	"exec/exec.s"

	Include	"AmigaGS Crt:System/Libs/AmigaGSMain.Macro.s"

	opt	p=68020

CALLSYS MACRO
		jsr _LVO\1(a6)
	ENDM

XLIB        MACRO
		XREF _LVO\1
	ENDM

ExecC	MACRO
		Move.l	$4,A6
		Jsr	_LVO\1(a6)
	ENDM
;Structure d'une librairie personnelle
 STRUCTURE  MyLib,LIB_SIZE
            ULONG ml_SysLib
            ULONG ml_DosLib
            ULONG ml_SegList
            UBYTE ml_Flags
            UBYTE ml_pad
            LABEL MyLib_Sizeof
 XLIB       OpenLibrary
 XLIB       CloseLibrary
 XLIB       FreeMem
 XLIB       Remove
 XLIB       Alert

Version        equ 1                 ;Version de la Library
Revision       equ 2                 ;Révision de la Library
Pri            equ 0                 ;Pri. de la Library (sans importance)

Start:
               moveq #0,d0
               rts
Resident:
               dc.w RTC_MATCHWORD    ;Code pour Resident
               dc.l Resident         ;Pointeur sur le début de la structure
               dc.l FinCode          ;Pointeur sur la fin de la structure
               dc.b RTF_AUTOINIT     ;Flag pour l'appel automatique
               dc.b Version          ;Version de la Library
               dc.b NT_LIBRARY       ;Type de la structure Resident=Library
               dc.b Pri              ;Priorité de la str.Resident
               dc.l LibName          ;Pointeur sur le nom de la Library
               dc.l idString         ;Chaîne d'id. pour la Library
               dc.l Init             ;Pointeur sur le tableau d'initialisation

LibName:       dc.b 'amigagsmain.library',0
idString:      dc.b 'amigagsmain.library Ver1.0r3 '
               dc.b '68020+ Version '
			   dc.b '(19 Septembre 00) ',13,10,0
DosName:       dc.b 'dos.library',0
               ds.w 0

FinCode:

Init:
			dc.l	MyLib_Sizeof     ;Taille de la structure de librairie
			dc.l	FuncTable        ;Pointeur sur le tableau
                                     ;des fonctions Lib
			dc.l	DataTable        ;Pointeur sur tableau pour InitFonction
			dc.l	InitRoutine      ;Pointeur sur routine propre

FuncTable:
;----------- Routines système
			dc.l	Open
			dc.l	Close
			dc.l	Expunge
			dc.l	Zero
;----------- Routines personnelles
			Dc.l	AmigaGSInit
			Dc.l	AmigaGSQuit
			Dc.l	AmigaGSList

;----------- Marque de fin
               dc.l -1

;tableau transmis à la fonction InitStruct
DataTable:     INITBYTE  LH_TYPE,NT_LIBRARY
               INITLONG  LN_NAME,LibName
               INITBYTE  LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
               INITWORD  LIB_VERSION,Version
               INITWORD  LIB_REVISION,Revision
               INITLONG  LIB_IDSTRING,idString
               dc.l 0
;>= D0 = Pointeur sur la structure de librairie
;>= A0 = Pointeur sur la liste des segments de la Library chargée
;>= A6 = Pointeur sur Execbase
;=> D0 = Pointeur sur la structure de librairie
InitRoutine:
            move.l a5,-(a7)                     ;sauver A5
            move.l d0,a5                        ;Pointeur sur MyLib
            move.l a6,ml_SysLib(a5)             ;Pointeur sur ExecLib
            move.l a0,ml_SegList(a5)            ;introduit liste des segments
            lea DosName(pc),a1                  ;Pointeur sur le nom DOS
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

AmigaLib		Equ		5
AmigaGSLib		Equ		15
;
; ***************************************************************
; *                                                             *
; * DEBUT DE LA LIBRAIRIE D'INITIALISATION DE AMIGA GAME STUDIO *
; *                                                             *
; *=============================================================*
; *                                                             *
; * 1 / Verification du système                                 *
; * 2 / Ouverture des librairies Amiga (5) :                    *
; *                                       Dos.library        OK *
; *                                       Graphics.library   OK *
; *                                       Intuition.library  OK *
; *                                       MathFFP.library    OK *
; *                                       MathTrans.library  OK *
; * 3 / Ouverture des librairies AmigGS (15) :                  *
; *                                      AGSSystem.library   OK *
; *                                      FileIO.library      OK *
; *                                      DisplayAga.library  OK *
; *                                      ScreensAga.library  OK *
; *                                      FxMosaic.library    OK *
; *                                      MemoryBanks.library OK *
; *                                      MemoryCopy.library  OK *
; *                                      JoyPort.library     OK *
; *                                      Ilbm.library        OK *
; *                                      Icons.libray        OK *
; *                                      AgsFont.library     NA *
; *                                      Chunky.library      OK *
; *                                      FMath.library       OK *
; *                                      MemoryCache.library NA *
; *                                                             *
; ***************************************************************

; Fonctions personnelles :
AmigaGSInit:
; 1st , Check for present CPU in system :
	Sub.l	d0,d0
	Move.l	$4,a6
	Move.w	296(a6),d0
	Lea.l	CPU,a0
	Move.w	d0,(a0)
; **************************************************************
	InitLib	Dos
	InitLib	Graphics
	InitLib	Intuition
	InitLib	MathFFP
	InitLib	MathTrans
; **************************************************************
	InitLib	AGSSystem
	InitLib	FileIO
	InitLib	Display
	InitLib	Screens
	InitLib	FXMosaic
	InitLib	Banks
	InitLib	Copy
	InitLib	Joyport
	InitLib	Ilbm
	InitLib	Icons
;	InitLib	AGSFont
; **************************************************************
CHUNKYINIT:
	CheckCPUBra	Cpu68040+Cpu68060,CI_Set68040
CI_No68040:
	InitLib	Chunky
	Bra.b	END_CHUNKYINIT
CI_Set68040:
	InitLib	Chu040
END_CHUNKYINIT:
; **************************************************************
MATHFFPINIT:
	CheckCPUBra	FpuOnly,FpuOk
CI_NoFPU:
	InitLib	FMathCPU
	Bra.b	END_MATHFFPINIT
FpuOk:
	InitLib	FMathFPU
END_MATHFFPINIT:
; **************************************************************
;CACHEINIT:
;	CheckCPUBra	Cpu68040+Cpu68060,_Cache68040
;	CheckCPUBra	Cpu68030,_Cache68030
;	CheckCPUBra	Cpu68020,_Cache68020
;_NoCACHE:
;	InitLib	Cache000
;	Bra.b	END_CACHEINIT
;_Cache68020:
;	InitLib	Cache020		; For INST CACHE
;	Bra.b	END_CACHEINIT
;_Cache68030:
;	InitLib	Cache030		; For INST & DATA CACHES
;	Bra.b	END_CACHEINIT
;_Cache68040
;	InitLib	Cache040		; For ALL EXISTENT CACHES.
;END_CACHEINIT:
; **************************************************************
	InitLibRESERVED	AGSSystem
	InitLibRESERVED	FileIO
	InitLibRESERVED	Display
	InitLibRESERVED	Screens
	InitLibRESERVED	FXMosaic
	InitLibRESERVED	Banks
	InitLibRESERVED	Copy
	InitLibRESERVED	Joyport
	InitLibRESERVED	Ilbm
	InitLibRESERVED	Icons
	InitLibRESERVED	Chunky
	InitLibRESERVED	FMathCPU
;	InitLibRESERVED AGSFont
;	InitLibRESERVED	CacheCPU
; **************************************************************
	Moveq.l	#0,d7
	Rts

AmigaGSQuit:
	Move.l		$4,a6
	CloseLib	AGSSystem
	CloseLib	FileIO
	CloseLib	Display
	CloseLib	Screens
	CloseLib	Banks
	CloseLib	Copy
	CloseLib	Joyport
	CloseLib	Ilbm
	CloseLib	Chunky
	CloseLib	Icons
	CloseLib	FMathCPU
	CloseLib	FXMosaic
;	CloseLib	AGSFont
;	CloseLib	CacheCPU
		Moveq.l	#0,d0
		Rts

AmigaGSList:
		Lea.l	DosBase,a0
		Move.l	#AmigaLib,d0
		Lea.l	FileIOBase,a1
		Move.l	#AmigaGSLib,d1
		Rts

; ***************************************************************
;
; Librairies AMIGA mises en place par l'initialisation :
;-------------------------------------------------------

				Dc.b	"Amiga_Main_List:"
DosBase:		Dc.l	0
GraphicsBase:	Dc.l	0
IntuitionBase:	Dc.l	0
MathFFPBase:	Dc.l	0
MathTransBase:	Dc.l	0

; Librairies AmigaGS mises en place par l'initialisation :
;---------------------------------------------------------
				Dc.b	"AGS_Main_List:"
FileIOBase:		Dc.l	0					; #01
DisplayBase:	Dc.l	0					; #02
ScreensBase:	Dc.l	0					; #03
FXMosaicBase:	Dc.l	0					; #04
Chu040Base:
ChunkyBase:		Dc.l	0					; #05
IconsBase:		Dc.l	0					; #06
IlbmBase:		Dc.l	0					; #07
JoyportBase:	Dc.l	0					; #08
BanksBase:		Dc.l	0					; #09
CopyBase:		Dc.l	0					; #10
FMathCPUBase:
FMathFPUBase:	Dc.l	0					; #11
AGSSystemBase:	Dc.l	0					; #12
AGSFontBase:	Dc.l	0					; #13
Cache000Base:
Cache020Base:
Cache030Base:
Cache040Base:
CacheCPUBase:	Dc.l	0
FinishLib:		Dc.l	$FFFFFFFF
Futures_Others:	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
CPU:			Dc.w	0	; What cpu is ?
;
; ***************************************************************

;				Dc.b	"12121212121212121212121212121212121212121212"
GraphicsName:	Dc.b	"graphics.library",0,0
IntuitionName:	Dc.b	"intuition.library",0
MathFFPName:	Dc.b	"mathffp.library",0
MathTransName:	Dc.b	"mathtrans.library",0
;
;				Dc.b	"12121212121212121212121212121212121212121212"
AGSSystemName:	Dc.b	"AmigaGS:Libs/System/amigagssystem.library",0
FileIOName:		Dc.b	"AmigaGS:Libs/Devices/fileio.library",0
JoyportName:	Dc.b	"AmigaGS:Libs/Devices/joystick.library",0
DisplayName:	Dc.b	"AmigaGS:Libs/Graphics/displayaga.library",0,0
ScreensName:	Dc.b	"AmigaGS:Libs/Graphics/screensaga.library",0,0
IconsName:		Dc.b	"AmigaGS:Libs/Graphics/agaicons.library",0,0
IlbmName:		Dc.b	"AmigaGS:Libs/Graphics/fxilbm.library",0,0
FXMosaicName:	Dc.b	"AmigaGS:Libs/Graphics/fxmosaic.library",0,0
AGSFontName:	Dc.b	"AmigaGS:Libs/Graphics/textfont.library",0,0
ChunkyName:		Dc.b	"AmigaGS:Libs/Graphics/chunkycpu.library",0
Chu040Name:		Dc.b	"AmigaGS:Libs/Graphics/chunky040.library",0
FMathFPUName:	Dc.b	"AmigaGS:Libs/Math/fastmathffpfpu.library",0,0
FMathCPUName:	Dc.b	"AmigaGS:Libs/Math/fastmathffpcpu.library",0,0
BanksName:		Dc.b	"AmigaGS:Libs/Memory/memorybanks.library",0
CopyName:		Dc.b	"AmigaGS:Libs/Memory/memory680x0.library",0
Cache000Name:	Dc.b	"AmigaGS:Libs/System/cachectrl68000.library",0,0
Cache020Name:	Dc.b	"AmigaGS:Libs/System/cachectrl68020.library",0,0
Cache030Name:	Dc.b	"AmigaGS:Libs/System/cachectrl68030.library",0,0
Cache040Name:	Dc.b	"AmigaGS:Libs/System/cachectrl68040.library",0,0
	Dc.b	"            "
	Dc.b	"Frederic Cordier 2000 : cordierfr@wanadoo.fr"