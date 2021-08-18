; **************************
; *                        *
; * AMIGA GAME STUDIO BETA *
; *                        *
; *------------------------*
; *                        *
; * Example de programme : *
; * demonstration 3D       *
; * 68881/2 ou 68040 ou    *
; * 68060 OBLIGATOIRES !!! *
; *                        *
; **************************
; ATTENTION :
; CE PROGRAMME NECESSITE LA PRéSENCE D'UN DES PROCESSEURS SUIVANTS:
; MC68881,MC68882,MC68040 ou MC68060 car les mathématiques 3D
; Utilisent les fonctions FPU de ces procésseurs.
; Cette démonstration ne doit pas être utilisée sur d'autres
; processeurs car cela provoquerait le plantage de votre système!!!

;	opt p=68040

XVIEW		Equ		320		; Dimension du tracé selon X
YVIEW		Equ		200		; Dimension du tracé selon Y
PIXELSIZE	Equ		2		; Taille d'un pixel. ( 1 , 2 ou 4 )
SPEED		Equ		16		; Vitesse de déplacement et d'angles.
SPEEDR		Equ		8
LUMIERE		Equ		1
;
; Fichier startup de AGS.
	Include	"AmigaGS:AmigaGS-Startup.s"
;
;
; VOTRE PROGRAMME COMMENCERA ICI !!!!!!!!
;	Bra.b	DEBUT

;	SECTION code,CODE

DEBUT:
; PROPERTIES 68060 FPU ROUNDING MODE SELECTION:
;	Fmove.l	FPCR,d0
;	Or.b	#$20,d0
;	And.b	#$10,d0
;	FMove.l	d0,FPCR

; Initialisation des librairies de l'utilisateur.
	Include	"AmigaGS:Includes/Extensions/Castle3dSubLib.i"
	InitLib	Felix3DBase

; En tout premier lieu,on charge les fichiers externes.
	ReserveFast		#2,#300000	: Textures.
	Moveq.l			#2,d0
	LibCall			Banks,BankBase
	Move.l			a0,a1				; File Adress
	Lea.l			_Textures,a0		; File Name
	Move.l			#196644,d0			; File Size
	LibCall			FileIO,LoadFile

	ReserveFast		#3,#16384	; (BANK 3)+1000:Map for the game.
	Moveq.l			#3,d0
	LibCall			Banks,BankBase
	Move.l			a0,a1				; File Adress
	Add.l			#1000,a1	; MAP Start at ADRESS+1000
	Lea.l			_Map,a0				; File Name
	Move.l			#15384,d0			; File Size
	LibCall			FileIO,LoadFile

	Moveq.l			#3,d0		; BANK 3:PALETTE
	LibCall			Banks,BankBase
	Move.l			a0,a1				; File Adress
	Lea.l			_Palette,a0			; File Name
	Move.l			#900,d0				; File Size
	LibCall			FileIO,LoadFile

	ReserveFast		#4,#32768	; BANK 4 : Cosinus,Sinus
; On charge les cosinus et sinus.
	Moveq.l			#4,d0		
	LibCall			Banks,BankBase
	Move.l			a0,a1				; File Adress
	Lea.l			_Cosinus,a0			; File Name
	Move.l			#7200,d0			; File Size
	LibCall			FileIO,-36
	Moveq.l			#4,d0		
	LibCall			Banks,BankBase
	Move.l			a0,a1				; File Adress
	Add.l			#7200,a1
	Lea.l			_Cosinus,a0			; File Name
	Move.l			#7200,d0			; File Size
	LibCall			FileIO,-36
	Moveq.l			#4,d0		
	LibCall			Banks,BankBase
	Move.l			a0,a1				; File Adress
	Add.l			#14400,a1
	Lea.l			_Sinus,a0			; File Name
	Move.l			#7200,d0			; File Size
	LibCall			FileIO,-36
	Moveq.l			#4,d0		
	LibCall			Banks,BankBase
	Move.l			a0,a1				; File Adress
	Add.l			#21600,a1
	Lea.l			_Sinus,a0			; File Name
	Move.l			#7200,d0			; File Size
	LibCall			FileIO,-36

	Wait	1,$7fffff





; Mise en place du copper AGA.
	LibCall		Display,Ags_Display

; Creation d'un ecran 256 couleurs et mise en place de ce dernier.
	ScreenOpen	#0,#320,#200,#8
	Moveq.l		#0,d0
	LibCall		Screens,Screen_Base
	Lea.l		Screen0,a1
	Move.l		a0,(a1)
	LibCall		Display,Ags_Screen

	ScreenOpen	#1,#320,#200,#8
	Moveq.l		#1,d0
	LibCall		Screens,Screen_Base
	Lea.l		Screen1,a1
	Move.l		a0,(a1)
	
;
;
;---------------------------------------------------------
; Initialisation des données principales pour le rendu 3D.
;---------------------------------------------------------
;
; Creation de pi#
	FMove.l	#100000,fp0
	FMove.l	#314159,fp1		;	314159
	FDiv	fp0,fp1
; Creation de Deg2Rad#
	FMove.w	#180,fp0
	FDiv	fp0,fp1
	Lea.l	DEG2RAD,a1
	FMove.s	fp1,(a1)


; 1A > On a besoin d'un ecran en chunky. (320*256=81920)
;---------------------------------------
	ReserveFast	#1,#81920	; BANQUE 1 = CHUNKYSCREEN (chip-memory)
	Moveq.l		#1,d0
	LibCall		Banks,BankBase
	LibCall		Chunky,Set_ChunkyBase
	Move.l		#320,d0
	Move.l		#200,d1
	LibCall		Chunky,Set_ChunkySize

; 1B > Convertion chunky dans l'ecran 0.
;---------------------------------------
	Moveq.l		#0,d0
	LibCall		Screens,Screen_Base
	LibCall		Chunky,Set_ScreenBase
	LibCall		Chunky,Chunky_Convert
	Moveq.l		#0,d0
	LibCall		Screens,Screen_Base
	LibCall		Chunky,Set_ScreenBase

; 1C > On definit les couleurs à afficher.
;-----------------------------------------
	Moveq.l		#3,d0
	LibCall		Banks,BankBase
	Move.l		a0,a3
	Lea.l		_Color,a4
	Clr.l		(a4)
	Move.l		(a4),d0
defcolor:
	Sub.l		d1,d1
	Sub.l		d2,d2
	Sub.l		d3,d3
	Move.b		(a3)+,d1		; Lecture ROUGE 8bits.
	Move.b		(a3)+,d2		; Lecture VERT ...   .
	Move.b		(a3)+,d3		; Lecture BLEU ...   .
	LibCall		Display,Ags_SetColor
	Addq.l		#1,(a4)
	Move.l		(a4),d0
	Cmp.w		#256,d0
	Blt.b		defcolor
;

; 2A > le moteur 3D utilise une carte et des textures.
;-----------------------------------------------------
	Moveq.l		#3,d0
	LibCall		Banks,BankBase
	Move.l		a0,d1		; D1=Adresse CARTE
	Add.l		#1016,d1		; D1=ADRESSE 1ere CASE 3D.
	Lea.l		_CaseList,a0	; On pointe la précalculation.
	Moveq.l		#63,d0		; D0=63 cases à définir.
mbcl1:
	Move.l		d1,(a0)+
	Add.l		#256,d1
	Subq.l		#1,d0
	Bpl.b		mbcl1
;
	Lea.l		_CaseList,a0
	LibCall		Felix3D,Set3d_MapBase
;
;
	Moveq.l		#2,d0
	LibCall		Banks,BankBase
	Move.l		a0,d1		; D1=Adresse 1ère TEXTURE
	Moveq.l		#63,d0		; D0=63 Textures à définir.
	Add.l		#36,d1		; AMOS File HEADER
	Lea.l		_TextureList,a0	; On pointe la précalculation.
mbcl2:
	Move.l		d1,(a0)+
	Add.l		#128*128,d1
	Subq.l		#1,d0
	Bpl.b		mbcl2
;
	Lea.l		_TextureList,a0
	LibCall		Felix3D,Set3d_TextureBase

; 2B > Le moteur 3D dessine dans l'ecran chunky.
;-----------------------------------------------
	Moveq.l		#1,d0
	LibCall		Banks,BankBase
	LibCall		Felix3D,Set3d_ChunkyBase
	Move.l		#320,d0
	Move.l		#200,d1
	LibCall		Felix3D,Set3d_ChunkySize

; 2C > Il utilise des cosinus et sinus précalculés.
;--------------------------------------------------
	Moveq.l		#4,d0
	LibCall		Banks,BankBase
	LibCall		Felix3D,Set3d_CosTable
	Moveq.l		#4,d0
	LibCall		Banks,BankBase
	Add.l		#14400,a0
	LibCall		Felix3D,Set3d_SinTable

; 2D > Le trace se fera en 320*200 pixels mode 1*1pixels.
;--------------------------------------------------------
	Move.l		#XVIEW,d0
	Move.l		#YVIEW,d1
	Moveq.l		#PIXELSIZE,d2
	LibCall		Felix3D,Set3d_ScreenSize

; #0=Inactive lightning / #1=Active
	Moveq.w		#LUMIERE,d0
	LibCall		Felix3D,LightState

; Wait for left mouse button
; Avec en plus une boucle de tracé 3D.

	LibCall		AGSSystem,TasksOff

wlc:
; 4A > On définit aussi les position d'origine du joueur.
;--------------------------------------------------------
;
	LibCall		Joyport,Joy1State
;	Tst.b		d0
;	Beq.w		w1cb

	Lea.l		Angles,a0
;
	Lea.l		DEG2RAD,a0
	FMove.s		(a0),fp7
;
	Lea.l		Angles,a0
	Move.l		(a0),d5	;	 Angle LR=0°
	Lea.l		PlXPos,a1
	Movem.l		(a1),d2/d3/d4	; Player positions
	Btst		#2,d0
	Beq.b		_s1		; Pas vers le gauche.
	Add.l		#SPEEDR,d5
_s1:
	Btst		#3,d0
	Beq.b		_s2		; Pas vers la droite.
	Sub.l		#SPEEDR,d5
_s2:
	Move.l		d5,(a0)

	Btst		#0,d0
	Beq.b		_s3
	FMove.l		d5,fp0		; FP0=Degrés.
	FMul		fp7,fp0		; FP0=Radians.
	FSin		fp0,fp1
	FCos		fp0
	FMul.b		#SPEED,fp0
	FMul.b		#SPEED,fp1
	FMove.l		fp0,d0
	Add.l		d0,d2
	FMove.l		fp1,d1
	Sub.l		d1,d3
	Bra.b		_s4
_s3
	Btst		#1,d0
	Beq.b		_s4
	FMove.l		d5,fp0		; FP0=Degrés.
	FMul		fp7,fp0		; FP0=Radians.
	FSin		fp0,fp1
	FCos		fp0
	FMul.b		#SPEED,fp0
	FMul.b		#SPEED,fp1
	FMove.l		fp0,d0
	Sub.l		d0,d2
	FMove.l		fp1,d1
	Add.l		d1,d3
_s4
	Movem.l	d2/d3/d3,(a1)
;
	Lea.l	PLCase,a0
	Movem.l	(a0),d0/d1/d2/d3
	LibCall	Felix3D,CheckPosition
	Lea.l	PLCase,a0
	Movem.l	d0/d1/d2/d3,(a0)

	Lea.l		Angles,a0
	Movem.l		(a0),d0/d1	;	 Angle LR=0°
	Cmp.w		#180,d0
	Blt.b		w0c
	Sub.l		#360,d0
w0c:
	Cmp.l		#-180,d0
	Bge.b		w1c
	add.l		#360,d0
w1c:		
	Move.l		d0,(a0)

	Movem.l		PlXPos,d2/d3/d4	; Player positions
	Lea.l		PLCase,a0
	Move.l		(a0),d5			;	 Player Case = PLCASE
	LibCall		Felix3D,Set3d_PlayerPos

; On selectionne l'ecran pour le trace.
	Lea.l		Screen0,a2
	Lea.l		Screen1,a3
	Move.l		(a3),d0
	Move.l		(a2),(a3)
	Move.l		d0,(a2)
; On le redéfinit pour le chunky
	Lea.l		Screen0,a1
	Move.l		(a1),a0
	LibCall		Chunky,Set_ScreenBase

; 4B > On fait tracer l'ecran de jeu 3D.
;---------------------------------------
	LibCall		Felix3D,TraceView

; 4C > On convertit en planar pour voir le résultat.
;---------------------------------------------------
	LibCall		Chunky,Chunky_Convert

; On affiche le resultat.
	Lea.l		Screen0,a1
	Move.l		(a1),a0
	LibCall		Display,Ags_Screen
	Moveq.l		#0,d0
	Moveq.l		#0,d1
	LibCall		Display,Screen_Offset

w1cc:
	LibCall		Joyport,Joy1Fire1State
	Tst.b		d0
	Beq.b		w1c2
	Lea.l		NumFormat,a0
	Move.w		(a0),d3
	Addq.w		#1,d3
	Cmp.w		#6,d3
	Blt.b		w1c3
	Moveq.w		#0,d3
w1c3:
	Move.w		d3,(a0)
	Lea.l		Formats,a0
	Mulu.w		#12,d3
	Movem.l		(a0,d3.w),d0/d1/d2
	LibCall		Felix3D,Set3d_ScreenSize
w1c4:
	LibCall		Joyport,Joy1Fire1State
	Tst.b		d0
	Bne.b		w1c4
;
w1c2:
	LibCall		Joyport,Joy0Fire1State
	Tst.b		d0
	Beq.w		wlc

_Fin1:
	EraseBank	#1
	EraseBank	#2
	EraseBank	#3
	EraseBank	#4
	LibCall		Display,WB_Display
	ScreenClose	#0
	ScreenClose	#1

	LibCall		AGSSystem,TasksOn

	Moveq.l	#0,d0

; Fichier FERMETURE de AGS.
	Include	"AmigaGS:AmigaGS-EndStartup.s"

	Rts
;
; Autres librairies définissables par l'utilisateur
;
Felix3DBase:
	Dc.l	0
	Dc.b	"AmigaGS:Libs/Extensions/castle3d.library",0
	EVEN
;
; Données du moteur 3D.
;
	SECTION	dat,DATA

PLCase:		Dc.l	1
PlXPos:		Dc.l	(64*3)+32	; X
			Dc.l	64*3		; Y
			Dc.l	80			; Z
DEG2RAD:
		Dc.l	0
Screen0:
		Dc.l	0
Screen1:
		Dc.l	0
_Color:
	Dc.l	0		; Couleur courante à definir.
_Textures:
	Dc.b	"AmigaGS:Examples/Castle3D FPU Demo/Data/Default.ttr",0,0
	EVEN
_Map:
	Dc.b	"AmigaGS:Examples/Castle3D FPU Demo/Data/Default.map",0,0
	EVEN
_Palette:
	Dc.b	"AmigaGS:Examples/Castle3D FPU Demo/Data/Default.pal",0,0
	EVEN
_Cosinus:
	Dc.b	"AmigaGS:Examples/Castle3D FPU Demo/Data/Cosinus.raw",0
	EVEN
_Sinus:
	Dc.b	"AmigaGS:Examples/Castle3D FPU Demo/Data/Sinus.Raw",0
	EVEN
;
_CaseList:
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
_TextureList:
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Angles:
	Dc.l	10,1
NumFormat:
	Dc.w	1
Formats:
	Dc.l	320,200,1
	Dc.l	320,200,2
	Dc.l	320,200,4
	Dc.l	160,100,1
	Dc.l	160,100,2
	Dc.l	160,100,4



