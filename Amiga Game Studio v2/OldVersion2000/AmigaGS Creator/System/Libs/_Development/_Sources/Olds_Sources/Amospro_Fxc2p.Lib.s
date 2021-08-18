;
; **************************************************************************
; *									   *
; * Name     : Amospro_3DFlx.Lib / Amos_3DFlx.lib  ( NUM : 10 )		   *
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
ExtNb		Equ	10-1
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
;
;
; **************************************************************************
; *									   *
; * Fichiers a inclure pour que la librairie soit COMPILABLE/ASSEMBLABLE.  *
; *									   *
; **************************************************************************
;
	IncDir	"INCLUDES:Amos/"
		Include "|Amos_Includes.s"
		Include	"Fredrick/_Chips.s"
		Include	"Fredrick/_Player61.s"
		Include "Fredrick/_OctaMed.s"
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
		Dc.w	L_CHUNKYBASE,-1
		Dc.b	"c2p chunky bas","e"+$80,"I0",-1
		Dc.w	L_SCREENBASE,-1
		Dc.b	"c2p screen bas","e"+$80,"I0",-1
		Dc.w	L_CHUNKYSIZES,-1
		Dc.b	"c2p chunky siz","e"+$80,"I0,0",-1
		Dc.w	L_CHUNKYCONVERTION,-1
		Dc.b	"c2p conver","t"+$80,"I",-1
		Dc.w	L_CHUNKYPLOT,-1
		Dc.b	"c2p plo","t"+$80,"I0,0,0",-1

;
; **************************************************************************
; *									   *
; * Description (inutile) de l'utilisation des differentes routines AMOS.  *
; *									   *
; **************************************************************************
;
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
; **************************************************************************
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
Data_Base:
C2pID:		Dc.b	"flx-1",1,0,"a"
CHUNKY_BASE:	Dc.l	0
SCREEN_BASE:	Dc.l	0
XSIZE:		Dc.l	0
YSIZE:		Dc.l	0

EMPTY		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; ZONE DE SAUVEGARDES DE REGISTRES Ax/Ax+n Dx/Dx+n
Registers	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
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
L_CHUNKYBASE		Equ	3
L3	DLea	CHUNKY_BASE,a0
	Move.l	(a3)+,(a0)
	Rts
;-----------------------------------------------------------------------------
; Definir l'adresse du 1er bit plan de l'ecran AMIGA.
L_SCREENBASE		Equ	4
L4	DLea	SCREEN_BASE,a0
	Move.l	(a3)+,(a0)
	Rts
;-----------------------------------------------------------------------------
; Definir les dimensions de l'ecran CHUNKY a convertir en PLANAR.
; Seulement 320/200 et 160/100 sont permises
L_CHUNKYSIZES		Equ	5
L5	DLea	YSIZE,a0
	Move.l	(a3)+,(a0)
	DLea	XSIZE,a0
	Move.l	(a3)+,(a0)
	Rts
;-----------------------------------------------------------------------------
; Convertir un ecran chunky en ecran planar.
L_CHUNKYCONVERTION	Equ	6
L6	DLea	CHUNKY_BASE,a2
	Move.l	(a2),a0
	Beq.l	L6NoChunky
	DLea	SCREEN_BASE,a2
	Move.l	(a2),a1
	Beq.l	L6NoScreen
	Movem.l	a3-a6,-(sp)
	DLea	XSIZE,a2
	Move.l	(a2),d0
	Beq.l	L6NoSize
	Cmp.w	#160,d0
	Beq.l	_chunky2planar160_100
;-----------------------------------------------------------------------------
; chunky2planar:	(new Motorola syntax)
;  a0 -> chunky pixels
;  a1 -> plane0 (assume other 7 planes are allocated contiguously)
; d0-d1/a0-a1 are trashed
plsiz		equ	(320/8)*200
_chunky2planar320_200:
		move.l	#$0f0f0f0f,d5	; d5 = constant $0f0f0f0f
		move.l	#$55555555,d6	; d6 = constant $55555555
		move.l	#$3333cccc,d7	; d7 = constant $3333cccc
		lea	(plsiz,a1),a2	; a2 -> plane1 (end of plane0)
		movea.l	a2,a3		; a3 -> plane1
		lea	(2*plsiz,a1),a4	; a4 -> plane2
		lea	(2*plsiz,a4),a5	; a5 -> plane4
		lea	(2*plsiz,a5),a6	; a6 -> plane6
mainloop:
		move.l	(a0)+,d0	; 12 get next 4 chunky pixels in d0
		move.l	(a0)+,d1	; 12 get next 4 chunky pixels in d1
		move.l	d0,d2		;  4
		and.l	d5,d2		;  8 d5=$0f0f0f0f
		eor.l	d2,d0		;  8
		move.l	d1,d3		;  4
		and.l	d5,d3		;  8 d5=$0f0f0f0f
		eor.l	d3,d1		;  8
		lsl.l	#4,d2		; 16
		or.l	d3,d2		;  8
		lsr.l	#4,d1		; 16
		or.l	d1,d0		;  8
		move.l	d2,d3		;  4
		and.l	d7,d3		;  8 d7=$3333cccc
		move.w	d3,d1		;  4
		clr.w	d3		;  4
		lsl.l	#2,d3		; 12
		lsr.w	#2,d1		; 10
		or.w	d1,d3		;  4
		swap	d2		;  4
		and.l	d7,d2		;  8 d7=$3333cccc
		or.l	d2,d3		;  8
		move.l	d0,d1		;  4
		and.l	d7,d1		;  8 d7=$3333cccc
		move.w	d1,d2		;  4
		clr.w	d1		;  4
		lsl.l	#2,d1		; 12
		lsr.w	#2,d2		; 10
		or.w	d2,d1		;  4
		swap	d0		;  4
		and.l	d7,d0		;  8 d7=$3333cccc
		or.l	d0,d1		;  8
		move.l	d1,d2		;  4
		lsr.l	#7,d2		; 22
		move.l	d1,d0		;  4
		and.l	d6,d0		;  8 d6=$55555555
		eor.l	d0,d1		;  8
		move.l	d2,d4		;  4
		and.l	d6,d4		;  8 d6=$55555555
		eor.l	d4,d2		;  8
		or.l	d4,d1		;  8
		lsr.l	#1,d1		; 10
		move.b	d1,(plsiz,a6)	; 12 plane 7
		swap	d1		;  4
		move.b	d1,(plsiz,a5)	; 12 plane 5
		or.l	d0,d2		;  8
		move.b	d2,(a6)+	;  8 plane 6
		swap	d2		;  4
		move.b	d2,(a5)+	;  8 plane 4
		move.l	d3,d2		;  4
		lsr.l	#7,d2		; 22
		move.l	d3,d0		;  4
		and.l	d6,d0		;  8 d6=$55555555
		eor.l	d0,d3		;  8
		move.l	d2,d4		;  4
		and.l	d6,d4		;  8 d6=$55555555
		eor.l	d4,d2		;  8
		or.l	d4,d3		;  8
		lsr.l	#1,d3		; 10
		move.b	d3,(plsiz,a4)	; 12 plane 3
		swap	d3		;  4
		move.b	d3,(a3)+	;  8 plane 1
		or.l	d0,d2		;  8
		move.b	d2,(a4)+	;  8 plane 2
		swap	d2		;  4
		move.b	d2,(a1)+	;  8 plane 0
		cmpa.l	a1,a2		;  6
		bne.w	mainloop	; 10	total=536 (67.0 cycles/pixel)
	Movem.l	(sp)+,a3-a6
	Rts
;-----------------------------------------------------------------------------
plsi2		equ	(160/8)*100
_chunky2planar160_100:
		move.l	#$0f0f0f0f,d5	; d5 = constant $0f0f0f0f
		move.l	#$55555555,d6	; d6 = constant $55555555
		move.l	#$3333cccc,d7	; d7 = constant $3333cccc
		lea	(plsi2,a1),a2	; a2 -> plane1 (end of plane0)
		movea.l	a2,a3		; a3 -> plane1
		lea	(2*plsi2,a1),a4	; a4 -> plane2
		lea	(2*plsi2,a4),a5	; a5 -> plane4
		lea	(2*plsi2,a5),a6	; a6 -> plane6
mainloop2:
		move.l	(a0)+,d0	; 12 get next 4 chunky pixels in d0
		move.l	(a0)+,d1	; 12 get next 4 chunky pixels in d1
		move.l	d0,d2		;  4
		and.l	d5,d2		;  8 d5=$0f0f0f0f
		eor.l	d2,d0		;  8
		move.l	d1,d3		;  4
		and.l	d5,d3		;  8 d5=$0f0f0f0f
		eor.l	d3,d1		;  8
		lsl.l	#4,d2		; 16
		or.l	d3,d2		;  8
		lsr.l	#4,d1		; 16
		or.l	d1,d0		;  8
		move.l	d2,d3		;  4
		and.l	d7,d3		;  8 d7=$3333cccc
		move.w	d3,d1		;  4
		clr.w	d3		;  4
		lsl.l	#2,d3		; 12
		lsr.w	#2,d1		; 10
		or.w	d1,d3		;  4
		swap	d2		;  4
		and.l	d7,d2		;  8 d7=$3333cccc
		or.l	d2,d3		;  8
		move.l	d0,d1		;  4
		and.l	d7,d1		;  8 d7=$3333cccc
		move.w	d1,d2		;  4
		clr.w	d1		;  4
		lsl.l	#2,d1		; 12
		lsr.w	#2,d2		; 10
		or.w	d2,d1		;  4
		swap	d0		;  4
		and.l	d7,d0		;  8 d7=$3333cccc
		or.l	d0,d1		;  8
		move.l	d1,d2		;  4
		lsr.l	#7,d2		; 22
		move.l	d1,d0		;  4
		and.l	d6,d0		;  8 d6=$55555555
		eor.l	d0,d1		;  8
		move.l	d2,d4		;  4
		and.l	d6,d4		;  8 d6=$55555555
		eor.l	d4,d2		;  8
		or.l	d4,d1		;  8
		lsr.l	#1,d1		; 10
		move.b	d1,(plsi2,a6)	; 12 plane 7
		swap	d1		;  4
		move.b	d1,(plsi2,a5)	; 12 plane 5
		or.l	d0,d2		;  8
		move.b	d2,(a6)+	;  8 plane 6
		swap	d2		;  4
		move.b	d2,(a5)+	;  8 plane 4
		move.l	d3,d2		;  4
		lsr.l	#7,d2		; 22
		move.l	d3,d0		;  4
		and.l	d6,d0		;  8 d6=$55555555
		eor.l	d0,d3		;  8
		move.l	d2,d4		;  4
		and.l	d6,d4		;  8 d6=$55555555
		eor.l	d4,d2		;  8
		or.l	d4,d3		;  8
		lsr.l	#1,d3		; 10
		move.b	d3,(plsi2,a4)	; 12 plane 3
		swap	d3		;  4
		move.b	d3,(a3)+	;  8 plane 1
		or.l	d0,d2		;  8
		move.b	d2,(a4)+	;  8 plane 2
		swap	d2		;  4
		move.b	d2,(a1)+	;  8 plane 0
		cmpa.l	a1,a2		;  6
		bne.w	mainloop2	; 10	total=536 (67.0 cycles/pixel)
	Movem.l	(sp)+,a3-a6
	Rts
L6NoChunky:
	Moveq	#0,d0
	Rbra	L_CUSTOM
L6NoScreen
	Moveq	#1,d0
	Rbra	L_CUSTOM
L6NoSize
	Moveq	#2,d0
	Rbra	L_CUSTOM
;-----------------------------------------------------------------------------L_CHUNKYPLOT		Equ	7
; Tracer un point dans l'ecran CHUNKY defini.
L_CHUNKYPLOT		Equ	7
L7	Movem.l	(a3)+,d0-d2
	DLea	XSIZE,a0
	Mulu.w	(a0),d1
	Add.l	d1,d2
	DLea	CHUNKY_BASE,a0
	Move.l	(a0),a1
	Beq.b	L7_NoChunky
	Add.l	d2,a1
	Move.b	d0,(a1)
	Rts
L7_NoChunky
	Moveq	#0,d0
	Rbra	L_CUSTOM
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
	Dc.b	"Chunky screen adress not defined.",0			; 0
	Dc.b	"Planar screen adress not defined.",0			; 1
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L11	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#-1,d3
	Rjmp	L_ErrorExt
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L12
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_TITLE
		Dc.b	"c2p Convert V1.0a / Felix 1997"
		Dc.b	0
		Dc.b	"10/06/97."
		Even
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_END		Dc.w	0
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
