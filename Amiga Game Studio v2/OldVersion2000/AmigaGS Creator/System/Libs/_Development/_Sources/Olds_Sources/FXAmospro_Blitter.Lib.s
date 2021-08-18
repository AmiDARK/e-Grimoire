;
; **************************************************************************
; *									   *
; * Name     : Amospro_Blitter.Lib / Amos_Blitter.lib  ( NUM : 21 )	   *
; *----------<								   *
; *									   *
; * Projet   : Amos1.3 / Amospro library.				   *
; *----------<								   *
; *									   *
; * Author   : Frederic Cordier						   *
; *----------<								   *
; *									   *
; * Version  : 0.0a							   *
; *----------<								   *
; *									   *
; **************************************************************************
; SPEEDS :
; -------- Not tested.

; Lasts Changes :
; ---------------
;	id: flx-1

; P.S:
;----- Les routines portent des noms commencant par L_ P_ U_ M_ ont chacunes 
;	des utilisations differentes.
; L_ -> Routines amos qui correspondent aux instructions AMOS equivalentes.
; P_ -> Routines utilisees par les routines AMOS pour differents travaux.
; U_ -> Routines qui peuvent etre utilisees par une autre librairie AMOS.
; M_ -> Correspondent aux macros.
; S_ -> Correspondent aux U_ mais appelees par : M_SysC S_... ( = Jsr U_...)
;
;
; **************************************************************************
; *									   *
; * Quelques definitions utiles a l'AMOS.				   *
; *									   *
; **************************************************************************
;
Version		MACRO
		Dc.b	"1.0a"
		ENDM
ExtNb		Equ	21-1
;
; Liste des routines appelables.
;
; S_...			Equ	-...
;
; **************************************************************************
; *									   *
; * Quelques definitions utiles a l'AMOS.				   *
; *									   *
; **************************************************************************
OpenLibrary	Equ	-552
CloseLibrary	Equ	-414
;
;
; **************************************************************************
; *									   *
; * Fichiers a inclure pour que la librairie soit COMPILABLE/ASSEMBLABLE.  *
; *									   *
; **************************************************************************
;
	IncDir	"Dh4:Sources/AmosProExtensions/"
		Include "|Amos_Includes.s"
;		Include	"Fredrick/_Chips.s"
;		Include	"Fredrick/_Player61.s"
;		Include "Fredrick/_OctaMed.s"
;
; **************************************************************************
; *									   *
; * MACROS crees pour se simplifier la vie.				   *
; *									   *
; **************************************************************************
;
DLea		MACRO
		Move.l	ExtAdr+ExtNb*16(a5),\2
		Add.w	#\1-Data_Base,\2
		ENDM
DLoad		MACRO
		Move.l	ExtAdr+ExtNb*16(a5),\1
		ENDM
ExecC		MACRO			; Executer une instruction Exec.lib
		Move.l	$4,a6
		Jsr	\1(a6)
		ENDM
SysC		MACRO
		Move.l	ExtAdr+ExtNb*16(a5),a2
		Jsr	\1(a2)
		ENDM
;
; **************************************************************************
; *									   *
; * Definition de la librairie FELIX.LIB.				   *
; *									   *
; **************************************************************************
;
Start		Dc.l	C_TK-C_OFF
		Dc.l	C_LIB-C_TK
		Dc.l	C_TITLE-C_LIB
		Dc.l	C_END-C_TITLE
		Dc.w	0
C_OFF		Dc.w	(L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2
		Dc.w	(L5-L4)/2,(L6-L5)/2,(L7-L6)/2,(L8-L7)/2
		Dc.w	(L9-L8)/2,(L10-L9)/2,(L11-L10)/2,(L12-L11)/2
;		Dc.w	...
C_TK		Dc.w	1,0
		Dc.b	$80,-1
;
; **************************************************************************
; *									   *
; * Nom des differentes nouvelles instruction AMOS.			   *
; *									   *
; **************************************************************************
;
		Dc.w	L_SCREENBASE,-1
		Dc.b	"screen bas","e"+$80,"I0",-1

;
; **************************************************************************
; *									   *
; * Description (inutile) de l'utilisation des differentes routines AMOS.  *
; *									   *
; **************************************************************************
;
; Screen Base ADRESS	( Definit l'ecran pour les BOBS )
;
;
; **************************************************************************
; *									   *
; * ?.									   *
; *									   *
; **************************************************************************
;
		Dc.w	0
C_LIB
;
; **************************************************************************
; *									   *
; * Initialisation de la librairie sous AMOS lors du lancement initial.	   *
; *									   *
; *************************************************************************
;
L0	movem.l	a3-a6,-(sp)
	Lea	Data_Base(pc),a2
	Move.l	a2,ExtAdr+ExtNb*16(a5)
	Lea	RouDef(pc),a0
	Move.l	a0,ExtAdr+ExtNb*16+4(a5)
	Lea	RouEnd(pc),a0
	Move.l	a0,ExtAdr+ExtNb*16+8(a5)
	Movem.l	(sp)+,a3-a6
	Moveq	#ExtNb,D0				; OK
	Rts
;
; **************************************************************************
; *									   *
; * ROUTINE D'INITIALISATION DE LA LIBRAIRIE.				   *
; *									   *
; **************************************************************************
;
RouDef
	movem.l	a3-a6,-(sp)
;
	Movem.l	(sp)+,a3-a6
	Rts
;
; **************************************************************************
; *									   *
; * ROUTINE D'EXECUTION LORS QUE L'ON QUITTE L'AMOS OU L'EXECUTION AMOS.   *
; *									   *
; **************************************************************************
;
RouEnd
	Rts
;
; **************************************************************************
; *									   *
; * Liste des routines appelables a partir d'une autre librairie.	   *
; *									   *
; **************************************************************************
;
;	Bra.l	P_...
;
; **************************************************************************
; *									   *
; * Zone des donnees recuperables par l'utilisateur.(autre librairie/amos) *
; *									   *
; **************************************************************************
;
ABL_Ver:	Dc.b	"Amiga_Blitter_Library Ver 0.0a "
ABL_Author:	Dc.b	"/ Par Frederic Cordier 01.14.99"

Data_Base:
EMPTY		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; ZONE DE SAUVEGARDES DE REGISTRES Ax/Ax+n Dx/Dx+n
Registers	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;
; VALEURS POUR L'ECRAN A UTILISER.
ScreenBase	Dc.l	0
XSize		Dc.l	0
YSize		Dc.l	0
Depth		Dc.w	0
;
; **************************************************************************
; *									   *
; * PETITES ROUTINES INTERNES APPELEES PAR LES ROUTINES D'INITIALISATION.  *
; *									   *
; **************************************************************************
;
;

;
;
; **************************************************************************
; *									   *
; *									   *
; *									   *
; **************************************************************************
;
;
;
L1
L2
;-----------------------------------------------------------------------------
; Definir l'adresse de base de l'ecran CHUNKY.
L_SCREENBASE		Equ	3
L3	DLea	ScreenBase,a0
	Move.l	(a3),(a0)
;
	Move.l	(a3)+,a0	; Copy to register
;	DLea	XSize,a1
;	Move.w	(a0,



	Rts
L4
L5
L6
L7
L8
L9
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CUSTOM		Equ	10
L10
ENGLISH	Lea	ErrMessE(pc),a0
LxSuit	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#0,d3
	Rjmp	L_ErrorExt
ErrMessE
	Dc.b	"....",0
ErrMessF
	Dc.b	"....",0
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L11	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#-1,d3
	Rjmp	L_ErrorExt
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L12
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_TITLE
		Dc.b	"Blitter Objects Library / frederic Cordier"
		Dc.b	0
		Dc.b	"14.01.99 / Version 0.0a"
		Even
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_END		Dc.w	0
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
