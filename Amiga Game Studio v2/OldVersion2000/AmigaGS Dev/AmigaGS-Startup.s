; ***************************************
; *                                     *
; *    AMIGA GAME STUDIO startup 0.2a   *
; *                                     *
; *-------------------------------------*
; *                                     *
; * Initialize : Display.library        *
; *------------- Screens.library        *
; *              Joystick.library       *
; *              MemoryCopy.library     *
; *              MemoryBanks.library    *
; *              Chunky.library         *
; *              Ilbm.library           *
; *              FileIO.library         *
; *              AgaIcons.library       *
; *              FXMosaic.library       *
; *              FastMathFFP.library    *
; *              AgsSystem.library      *
; *              TextFont.library       *
; *                                     *
; *-------------------------------------*
; *                                     *
; ***************************************
; This is the beta test startup opening all libraries
; And let you use them easily.
;
	Include	"Includes:Exec/Exec.s"		;
;
	IncDir	"AmigaGS:Includes/"		;
	Include	"AmigaGSIncludeList.i"
;
; *************************************************************
;
; Initialisation de AmigaGameStudio.
		InitLib		AmigaGSMain
		Lea.l		AmigaGSMain,a0
		Move.l		(a0),a6
		Jsr			-30(a6)			; AmigaGSInit
		Lea.l		AmigaGSMain,a0
		Move.l		(a0),a6
		Jsr			-42(a6)			; AmigaGSList
; Mise en place des librairies AMIGA.
		Lea.l		DosBase,a2
IR1:	Move.l		(a0)+,(a2)+
		Subq.l		#1,d0
		Bpl.b		IR1
; Mise en place des librairies AmigaGS.
		Lea.l		FileIOBase,a2
IR2:	Move.l		(a1)+,(a2)+
		Subq.l		#1,d1
		Bpl.b		IR2
		Bra.w		FinInitialisation
;
; *************************************************************
;
;
;
AmigaGSMain:	Dc.l	0
		Dc.b	"AmigaGS:Libs/amigagsmain.library",0
		EVEN
; Librairies AMIGA mises en place par l'initialisation :
;-------------------------------------------------------
DosBase:		Dc.l	0
GraphicsBase:	Dc.l	0
IntuitionBase:	Dc.l	0
MathFFPBase:	Dc.l	0
MathTransBase:	Dc.l	0

; Librairies AmigaGS mises en place par l'initialisation :
;---------------------------------------------------------
FileIOBase:		Dc.l	0
DisplayBase:	Dc.l	0
ScreensBase:	Dc.l	0
FXMosaicBase:	Dc.l	0
ChunkyBase:		Dc.l	0
IconsBase:		Dc.l	0
FxIlbmBase:		Dc.l	0
JoyportBase:	Dc.l	0
BanksBase:		Dc.l	0
CopyBase:		Dc.l	0
FMathFFPBase:	Dc.l	0
AGSSystemBase:	Dc.l	0
AGSFontBase:	Dc.l	0
CacheCPUBase:	Dc.l	0	; Data & Inst cache for CPUs.
OthersBase:		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
AmigaGSTask:	Dc.l	0
; Fin de l'initialisation de Amiga Game Studio.
FinInitialisation:
; Now for WB Usage : WB Startup by MAX 00
GetMsg=-372
WaitPort=-384
FindTask=-294
CLI_OR_WB:
 	Move.l	$4,a6	;Exebase en A6
 	Move.l	#0,a1		;Clean A1
 	Jsr		FindTask(a6)	;Quelle Tâche ???
	Lea.l	AmigaGSTask,a0
	Move.l	d0,(a0)		; Sauvegarde TACHE
 	Move.l	d0,a2		; sauve resultat en A2
 	Tst.l	$ac(a2)		;verify Adr Message WB (Write)
	Bne.b	FromCLI		; si pas bon alors - OK CLI
	Lea.l	$5c(a2),a0    	;Sinon Il est ouvert du WB
	Jsr		WaitPort(a6)  	;Attendre le Port WB
	Lea.l	$5c(a2),a0	;Charge ADr Message WB (Read)
	Jsr		GetMsg(a6)	;recup le message ...
FromCLI:
