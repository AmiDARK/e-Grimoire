;
; **************************************************************************
; *									   *
; * Name     : Amospro_AgaFlx.Lib / Amos_AgaFlx.lib  ( NUM : 17 )	   *
; *----------<								   *
; *									   *
; * Projet   : Amos1.3 / Amospro library.				   *
; *----------<								   *
; *									   *
; * Author   : Frederic Cordier						   *
; *----------<								   *
; *									   *
; * Version  : 1.0a							   *
; *----------<								   *
; *									   *
; **************************************************************************
; P.S:
;----- Les routines portent des noms commencant par L_ P_ U_ M_ ont chacunes 
;	des utilisations differentes.
; L_ -> Routines amos qui correspondent aux instructions AMOS equivalentes.
; P_ -> Routines utilisees par les routines AMOS pour differents travaux.
; U_ -> Routines qui peuvent etre utilisees par une autre librairie AMOS.
; M_ -> Correspondent aux macros.
; S_ -> Correspondent aux U_ mais appelees par : M_SysC S_... ( = Jsr U_...)
;
; Id: flx-2
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
ExtNb		Equ	17-1
;
; Liste des routines appelables.
;
S_SECTIONOFFSET	Equ	-6
S_COPPERECS	Equ	-12
S_COPPERAGA	Equ	-18
S_SECTION1	Equ	-24
S_SECTION2	Equ	-30
S_SECTION3	Equ	-36
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
RSave		MACRO
		DLea	Registers,a0
		Movem.l	a3-a6,(a0)
		ENDM
RLoad		MACRO
		DLea	Registers,a0
		Movem.l	(a0),a3-a6
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
C_OFF		Dc.w	(L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2,(L5-L4)/2
		Dc.w	(L6-L5)/2,(L7-L6)/2,(L8-L7)/2
		Dc.w	(L9-L8)/2,(L10-L9)/2,(L11-L10)/2,(L12-L11)/2
		Dc.w	(L13-L12)/2,(L14-L13)/2,(L15-L14)/2,(L16-L15)/2
		Dc.w	(L17-L16)/2,(L18-L17)/2,(L19-L18)/2

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
; GESTION DE LA COPPER LIST.
		Dc.w	L_FXCOPPERON,-1
		Dc.b	"fx copper o","n"+$80,"I",-1
		Dc.w	-1,L_FXCOPPERBASE
		Dc.b	"fx copper bas","e"+$80,"00",-1
		Dc.w	L_FXCOPPERSHOW,-1
		Dc.b	"fx copper sho","w"+$80,"I0",-1
		Dc.w	L_FXCOPPERHIDE,-1
		Dc.b	"fx copper hid","e"+$80,"I0",-1
		Dc.w	L_FXCOPPERDISPLAY,-1
		Dc.b	"fx section displa","y"+$80,"I0,0t0",-1
		Dc.w	L_FXSCREENTOSECTION,-1
		Dc.b	"fx screen sectio","n"+$80,"I0",-1
		Dc.w	L_FXCOPPERVIEW,-1
		Dc.b	"fx copper vie","w"+$80,"I0,0",-1
		Dc.w	L_FXSCREENOFFSET,-1
		Dc.b	"fx section offse","t"+$80,"I0,0,0",-1
		Dc.w	L_FXCOPPERCOLOR,-1
		Dc.b	"fx copper colou","r"+$80,"I0,0,0,0",-1
		Dc.w	L_FXCOPPERAGA,-1
		Dc.b	"fx copper ag","a"+$80,"I",-1
		Dc.w	L_FXCOPPERECS,-1
		Dc.b	"fx copper ec","s"+$80,"I",-1
		Dc.w	L_FXSECTION,-1
		Dc.b	"fx sectio","n"+$80,"I0",-1
;
; **************************************************************************
; *									   *
; * Description (inutile) de l'utilisation des differentes routines AMOS.  *
; *									   *
; **************************************************************************
;
; Fx Copper On
; =Fx Copper Base(cop) , (Cop=1 to 2)
; Fx Copper Show COPPERSECTION
; Fx Copper Hide COPPERSECTION
; Fx Copper Display COPPERSECTION,YSTART To YEND
; Fx Screen Section COPPERSECTION (Current Screen to section 1-3).
; Fx Copper View COPPERSECTION,NUMBER OF PLANES
; Fx Copper Offset COPPERPART,XOFFSET,YOFFSET
; Fx Copper Colour REGISTER,RED,GREEN,BLUE
; Fx Copper Aga
; Fx Copper Ecs
; Fx Section SECTION
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
	Bra.l	P_COPPER2PART3		; Equ	 -36
	Bra.l	P_COPPER2PART2		; Equ	 -30
	Bra.l	P_COPPER2PART1		; Equ	 -24
	Bra.l	P_COPPER1AGA		; Equ	 -18
	Bra.l	P_COPPER1ECS		; Equ	 -12
 	Bra.l	P_SECTIONOFFSET		; Equ	  -6
;
; **************************************************************************
; *									   *
; * Zone des donnees recuperables par l'utilisateur.(autre librairie/amos) *
; *									   *
; **************************************************************************
;
Data_Base:
FlxAgaId:	Dc.b	"flx-2",1,0,"a"
COP1LEN		Dc.l	0	; Memoire reservee pour le copper 1e (SPR/RN)
COP2LEN		Dc.l	0	; '' '' ''' '' '' '' '' '' '' ''  2e (SCREEN)
COP1BASE	Dc.l	0	; Adresse de base du 1er copper list.
COP2BASE	Dc.l	0	; Adresse de base du 2eme copper list.
COP1ADR		Dc.l	0	; Adresse copper 1 pour creer les rainbows.
COP2ADR		Dc.l	0	; '' '' '' '' '' 2 pour modifier les ecrans.
COPNUM		Dc.l	0	; Nombre de parties copper. ( 1 -> 3 )
COPSPR		Dc.l	0	; Adresse de base pour les sprites copper.
COPPAL1		Dc.l	0	; Adresse de la base des palette COPPER MSB.
COPPAL2		Dc.l	0	; '' '' '' '' '' '' '' '' '' '' '' '' ' LSB.
COP1PART	Dc.l	0	; Adresse du 1er ecran du copper.
COP2PART	Dc.l	0	; Adresse du 2eme ecran copper.
COP3PART	Dc.l	0	; '' '' '' ' 3eme ecran copper.
; 3 sections copper list.
COPSECTION1	Dc.l	0,0,0,0	;\ Bits plans de 1 a 8 (bits plans possibles)
		Dc.l	0,0,0,0	;/ 
		Dc.l	0,0,0,0	; Screen offset X,Y. Screen Size X,Y.
COPSECTION2	Dc.l	0,0,0,0
		Dc.l	0,0,0,0
		Dc.l	0,0,0,0
COPSECTION3	Dc.l	0,0,0,0
		Dc.l	0,0,0,0
		Dc.l	0,0,0,0
COPPALVAL	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; ZONE DE SAUVEGARDES DE REGISTRES Ax/Ax+n Dx/Dx+n
Registers	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
EMPTY		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;
; **************************************************************************
; *									   *
; * Zone d'AUTO-CONFIG de la librairie FELIX.Lib.			   *
; *									   *
; **************************************************************************
;
CONFIG		Dc.b	"CFG1"
FREQ		Dc.b	0	; 0=Pal 1=Ntsc.
VIDEO		Dc.b	1	; 0=ECS 1=AGA.
COP1DEF		Dc.l	16384	; Memoire initiale pour le copper list
COPPART		Dc.b	1	; Nombre d'ecrans visible simultanes (1-3)
LANGUAGE	Dc.b	1	; 1=Francais/0=Anglais.(Messages d'erreur)
COP1POS		Dc.w	50	; Position du 1er ecran (en Y). (Default)
COP2POS		Dc.w	67	; '' '' '' '' 2eme '' '' '' ''. (Default)
COP3POS		Dc.w	252	; '' '' '' '' 3eme '' '' '' ''. (Default)
;
; **************************************************************************
; *									   *
; * PETITES ROUTINES INTERNES APPELEES PAR LES ROUTINES D'INITIALISATION.  *
; *									   *
; **************************************************************************
; P_RESERVECOPPER 	-> Reserve de la memoire pour les 2 copper list.
; P_ERASECOPPER		-> Libere la memoire des 2 copper list.
; P_COPPER1END		-> Rajoute la fin du copper 1 / Si ce dernier a ete
; P_COPPER2END		-> Rajoute la fin du copper 2 / modifie.(COPxADR)
; P_COPPER1ECS		-> Cree le copper 1 SPRITES/PALETTE/RAINBOWS ECS!!!
; P_COPPER1AGA		-> '' '' '' '' '' '' '' '' '' '' '' '' '' '' AGA!!!
; P_COPPER2PART1	-> Cree le copper 2 Version 1 ecran.
; P_COPPER2PART2	-> Cree le copper 2 Version 2 ecrans.
; P_COPPER2PART3	-> Cree le copper 2 Version 3 ecrans.
; P_SECTIONOFFSET	-> Screen offset d'une section D0=Section D1=X D2=Y.
; P_...			-> ...
; **************************************************************************
; Reservation d'une copper list selon la memoire demandee pour.
P_RESERVECOPPER
	RSave
; Copper 1 : SPRITES/PALETTE/RAINBOWS.
	Lea	COP1DEF(pc),a0
	Move.l	(a0),d0
	DLea	COP1LEN,a0
	Move.l	d0,(a0)		; Save Cop1length
	Move.l	#$10002,d1
	ExecC	AllocMem
	DLea	COP1BASE,a0
	Move.l	d0,(a0)		; Save Cop1Base.	Lea	COP1DEF(pc),a0
	RLoad
	Rts
;
; **************************************************************************
; liberation de la memoire copper.
P_ERASECOPPER
	RSave
; Copper 1
	DLea	COP1LEN,a0
	Move.l	(a0),d0		; d0=Longueur.
	DLea	COP1BASE,a0
	Move.l	(a0),d1		; A1=Base.
	Cmp.l	#0,d1
	Beq	P_E1
	Move.l	d1,a1
	ExecC	FreeMem
P_E1	RLoad				; P_E2
	Rts
;
; **************************************************************************
; Creation du copper SPRITES/PALETTE/RAINBOWS ECS.
P_COPPER1ECS
	DLea	COP1BASE,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq.w	P_NOCOP
; COP WAIT ...
	Move.l	#$1003FFFE,(a0)+
	Move.l	#$01fc0000,(a0)+	; Anti Double scanning !!!.
; CREATION DES SPRITES POUR LE COPPER-LIST.
	Move.l	#$01200000,d0
P_E3	Move.l	d0,(a0)+
	Add.l	#$20000,d0
	Cmp.l	#$01400000,d0
	Bne	P_E3
; CREATION DE LA PALETTE DE 32 
	Move.l	#$1403FFFE,(a0)+
	DLea	COPPAL1,a1
	Move.l	a0,(a1)
; SELECTION DU BLOC MEMOIRE.
	Move.l	#$01060000,(a0)+	; si machine aga,copper ecs.
	Move.l	#$01800000,d1
; BLOCS DE 32 COULEURS A CODER SEPAREMENT.
P_E5	Move.l	d1,(a0)+
	Add.l	#$00020000,d1
	Cmp.l	#$01C00000,d1
	Bne	P_E5
	Move.l	#$2803FFFE,(a0)+	
	DLea	COP1ADR,a1
	Move.l	a0,(a1)
;	SysC	S_COPPER1END
	DLea	COPPAL2,a1
	Move.l	#0,(a1)
	Rts
;
; **************************************************************************
; Creation du copper SPRITES/PALETTE/RAINBOWS AGA.
P_COPPER1AGA
	DLea	COP1BASE,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq.w	P_NOCOP
; COP WAIT ...
	Move.l	#$1003FFFE,(a0)+
	Move.l	#$01fc0000,(a0)+	; Anti Double scanning !!!.
; CREATION DES SPRITES POUR LE COPPER-LIST.
	Move.l	#$01200000,d0
P_E7	Move.l	d0,(a0)+
	Add.l	#$20000,d0
	Cmp.l	#$01400000,d0
	Bne	P_E7
; CREATION DE LA PALETTE DE 256 COULEURS AGA SEULEMENT !!!
	Move.l	#$1803FFFE,(a0)+
	Move.l	#$01060000,d0
	DLea	COPPAL1,a1
	Move.l	a0,(a1)
; SELECTION DU BLOC MEMOIRE.
P_E8	Move.l	d0,(a0)+
	Move.l	#$01800000,d1
; BLOCS DE 32 COULEURS A CODER SEPAREMENT. (MSB)
P_E9	Move.l	d1,(a0)+
	Add.l	#$00020000,d1
	Cmp.l	#$01C00000,d1
	Bne	P_E9
	Add.l	#$00002000,d0
	Cmp.l	#$01070000,d0
	Bne	P_E8
; Couleurs complementaires. (LSB)
	Move.l	#$01060200,d0
	DLea	COPPAL2,a1
	Move.l	a0,(a1)
; SELECTION DU BLOC MEMOIRE.
P_E10	Move.l	d0,(a0)+
	Move.l	#$01800000,d1
; BLOCS DE 32 COULEURS A CODER SEPAREMENT.
P_E11	Move.l	d1,(a0)+
	Add.l	#$00020000,d1
	Cmp.l	#$01C00000,d1
	Bne	P_E11
	Add.l	#$00002000,d0
	Cmp.l	#$01070200,d0
	Bne	P_E10
	Move.l	#$2803FFFE,(a0)+
	DLea	COP1ADR,a1
	Move.l	a0,(a1)
;	SysC	S_COPPER1END
P_NOCOP	Rts
;
; **************************************************************************
; Creation du copper 2 version 1 ecran.
P_COPPER2PART1
	DLea	COP2BASE,a2
	DLea	COP1ADR,a1
	Move.l	(a1),a0
	move.l	a0,(a2)
	Cmp.l	#0,a0
	Beq	P_NOCOP
	DLea	COPNUM,a1
	Move.l	#1,(a1)
	DLea	COP1POS,a1
	Move.w	(a1),d7
	Sub.l	#1,d7
	DLea	COP1PART,a1
	Move.l	a0,(a1)
; CREATION DE L'ECRAN.
	Move.l	#$0003FFFE,(a0)
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
P_E12	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	P_E12
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
;		BPLCON REGISTERS.
	Move.l	#$01000000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040000,(a0)+	; BPLCON2
	Move.l	#$01061000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00968300,(a0)+
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
;	Move.l	#$F203FFFE,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$F303FFFE,(a0)+
	DLea	COP2ADR,a1
	Move.l	a0,(a1)
	Move.l	#$FFFFFFFE,(a0)+
	DLea	COP2PART,a0
	Move.l	#$0,(a0)
	DLea	COP3PART,a0
	Move.l	#$0,(a0)
	Rts
; **************************************************************************
; Creation du copper 2 version 2 ecran.
P_COPPER2PART2
	DLea	COP2BASE,a2
	DLea	COP1ADR,a1
	Move.l	(a1),a0
	Move.l	a0,(a2)
	Cmp.l	#0,a0
	Beq.w	P_NOCOP
	DLea	COPNUM,a1
	Move.l	#2,(a1)
	DLea	COP1POS,a1
	Move.w	(a1),d7
	Sub.l	#1,d7
	DLea	COP1PART,a1
	Move.l	a0,(a1)
; CREATION DE L'ECRAN.
	Move.l	#$0003FFFE,(a0)
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
P_E13	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	P_E13
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
;		BPLCON REGISTERS.
	Move.l	#$01000000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040224,(a0)+	; BPLCON2
	Move.l	#$01061000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00968300,(a0)+
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
	DLea	COP2PART,a1
	Move.l	a0,(a1)
	DLea	COP2POS,a1
	Move.w	(a1),d7
	Sub.l	#1,d7
; CREATION DE L'ECRAN.
	Move.l	#$0003FFFE,(a0)
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
P_E14	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	P_E14
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
;		BPLCON REGISTERS.
	Move.l	#$01000000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040224,(a0)+	; BPLCON2
	Move.l	#$01061000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00968300,(a0)+
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
;	Move.l	#$FE03FFFE,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$FF03FFFE,(a0)+
	DLea	COP2ADR,a1
	Move.l	a0,(a1)
	Move.l	#$FFFFFFFE,(a0)+
;	SysC	S_COPPER2END
	DLea	COP3PART,a0
	Move.l	#$0,(a0)
	Rts
; **************************************************************************
; Creation du copper 2 version 3 ecran.
P_COPPER2PART3
	DLea	COP2BASE,a2
	DLea	COP1ADR,a1
	Move.l	(a1),a0
	Move.l	a0,(a2)
	Cmp.l	#0,a0
	Beq.w	P_NOCOP
	DLea	COPNUM,a1
	Move.l	#3,(a1)
	DLea	COP1POS,a1
	Move.w	(a1),d7
	Sub.l	#1,d7
	DLea	COP1PART,a1
	Move.l	a0,(a1)
; CREATION DE L'ECRAN.
	Move.l	#$0003FFFE,(a0)
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
P_E15	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	P_E15
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
;		BPLCON REGISTERS.
	Move.l	#$01000000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040224,(a0)+	; BPLCON2
	Move.l	#$01061000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00968300,(a0)+
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
;
	Move.l	#$00960100,(a0)+
;
	DLea	COP2PART,a1
	Move.l	a0,(a1)
	DLea	COP2POS,a1
	Move.w	(a1),d7
	Sub.l	#1,d7
; CREATION DE L'ECRAN.
	Move.l	#$0003FFFE,(a0)
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
P_E16	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	P_E16
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
;		BPLCON REGISTERS.
	Move.l	#$01000000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040224,(a0)+	; BPLCON2
	Move.l	#$01061000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00968300,(a0)+
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
;
	Move.l	#$00960100,(a0)+
;
	DLea	COP3PART,a1
	Move.l	a0,(a1)
	DLea	COP3POS,a1
	Move.w	(a1),d7
	Sub.l	#1,d7
; CREATION DE L'ECRAN.
	Move.l	#$0003FFFE,(a0)
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$00E00000,d0		; Bpl0PTH
; BPLPTH\L INSTALLATION POUR LES 8 BIT-PLANS.
P_E17	Move.l	d0,(a0)+
	Add.l	#$00020000,d0
	Cmp.l	#$01000000,d0
	Bne	P_E17
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
	Move.l	#$0098FFC0,(a0)+	; CLXCON Enable/Disable Planes.
;		BPLCON REGISTERS.
	Move.l	#$01000000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040224,(a0)+	; BPLCON2
	Move.l	#$01061000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
	Move.l	#$00968300,(a0)+
	Move.l	#$0003FFFE,(a0)
	Add.l	#1,d7
	Move.b	d7,(a0)
	Add.l	#4,a0
;	Move.l	#$FE03FFFE,(a0)+
	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$FF03FFFE,(a0)+
	DLea	COP2ADR,a1
	Move.l	a0,(a1)
	Move.l	#$FFFFFFFE,(a0)+
;	SysC	S_COPPER2END
	Rts
;
;
; **************************************************************************
; *									   *
; * Screen offset d'une section copper					   *
; *									   *
; **************************************************************************
;
; Screen offset d'une section copper.
P_SECTIONOFFSET
	RSave
	DLea	COPSECTION1-4,a2	; A2=Copper section defines.
	DLea	COP1BASE-4,a1		; A1=Copper base.
	Lsl.l	#2,d0
	Add.l	d0,a1			; A1=Copper SELECTED base.
	Move.l	(a1),a0			; A0=ADRESSE COPPER.
	Cmp.l	#0,a0
	Beq	U_SONC
	Lsr.l	#2,d0
	Mulu.l	#48,d0
	Add.l	d0,a2			; A2=SECTION DEFINITIONS.
	Move.l	a2,a1			; A1=SECTION DEFINITIONS.
	Add.l	#32,a2
	Move.l	d1,(a2)+
	Move.l	d2,(a2)+
	Move.l	(a2)+,d6		; D6=X Screen Size.
	Move.l	d1,d0
	Lsr.l	#3,d6
	Mulu.l	d2,d6			; D6=Rajout aux bits plans pour Yof.
	Lsr.l	#4,d1
	Lsl.l	#4,d1
	Sub.l	d1,d0
	Lsr.l	#3,d1
	Add.l	d1,d6			; D6=Rajout total.
	Moveq	#15,d7
	Sub.l	d0,d7			; D7=Offset.	
	DLea	U_SOTP,a2
	Moveq	#7,d0
U_SO1	Move.l	(a1)+,d1
	Add.l	d6,d1
	Move.l	d1,(a2)+
	Sub.l	#1,d0
	Bpl	U_SO1
	DLea	U_SOTP,a1
	Add.l	#10,a0			; A0=Adresse Bpl1Pth data.
	Moveq	#15,d0
U_SO2	Move.w	(a1)+,(a0)
	Add.l	#4,a0
	Sub.l	#1,d0
	Bpl	U_SO2
; Il ne reste plus qu'a mettre le bit de decalage D7
	Move.l	d7,d6
	Lsl.l	#4,d6
	Add.l	d6,d7
	Add.l	#32+4,a0
	Move.w	d7,(a0)	; Mise en place du decalage de bits.
	RLoad
	Moveq	#$0,d0
	Rts
U_SONC	RLoad
	Move.l	#$ffffffff,d0
	Rts
U_SOTP	Dc.l	0,0,0,0,0,0,0,0		; bitsplans + screen offset.
;
;
;
;
; **************************************************************************
; *									   *
; *									   *
; *									   *
; *									   *
; * DEBUT DE LA LIBRAIRIE ' AGA CHIPSET FELIX EXTENSION '		   *
; *									   *
; *									   *
; *									   *
; *									   *
; **************************************************************************
;
;
;
L1
L2
;
; **************************************************************************
; *									   *
; * Activation du copper list de la librairie a la place de celui d'Amos   *
; *									   *
; **************************************************************************
;
L_FXCOPPERON		Equ	3
L3	DLea	COP1BASE,a0
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Beq	L3_ERR
	Cmp.l	#0,d1
	Beq	L3_ERR
	Move.l	d0,$dff080
	Rts
L3_ERR	Moveq	#1,d0
	Rbra	L_CUSTOM
;
; **************************************************************************
; *									   *
; * Renvoie l'adresse de base des copper list SPR/PAL/RAIN ou SCREEN	   *
; *									   *
; **************************************************************************
;
L_FXCOPPERBASE		Equ	4
L4 	Move.l	(a3)+,d0
	Cmp.l	#1,d0
	Beq	L4_1
	DLea	COP1BASE,a0
	Bra	L4_2
L4_1;	DLea	COP2BASE,a0
	DLea	COP1ADR,a0
L4_2	Move.l	(a0),d3
	Moveq	#0,d2
	Rts
;
; **************************************************************************
; *									   *
; * Activation d'une partie du copper SCREEN.				   *
; *									   *
; **************************************************************************
;
L_FXCOPPERSHOW		Equ	5
L5	Move.l	(a3)+,d0
	DLea  COP1PART-4,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),a1
	Cmp.l	#0,a1
	Beq	L5NCOP
	Add.l	#118+4,a1
	Move.w	#$8300,(a1)
	Rts
L5NCOP	Moveq	#2,d0
	Rbra	L_CUSTOM
;
; **************************************************************************
; *									   *
; * Desactivation d'une partie du copper SCREEN				   *
; *									   *
; **************************************************************************
;
L_FXCOPPERHIDE		Equ	6
L6	Move.l	(a3)+,d0
	DLea	COP1PART-4,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),a1
	Cmp.l	#0,a1
	Beq	L6NCOP
	Add.l	#118+4,a1
	Move.w	#$0100,(a1)
	Rts
L6NCOP	Moveq	#2,d0
	Rbra	L_CUSTOM
;
; **************************************************************************
; *									   *
; * Definir la hauteur graphique et la position d'une section copper	   *
; *									   *
; **************************************************************************
;
L_FXCOPPERDISPLAY	Equ	7
L7 	Move.l	(a3)+,d7	; D7=Y end position.
	Move.l	(a3)+,d6	; D6=Y Start position.
	Move.l	(a3)+,d0	; D0=Copper Section.
	DLea	COP1PART,a1
	Sub.l	#1,d0
	Lsl.l	#2,d0
	Add.l	d0,a1
	Move.l	(a1),a0
	Cmp.l	#0,a0
	Beq	L7NCOP
	Sub.l	#1,d6
	Move.b	d6,(a0)
	Add.l	#116,a0
	Add.l	#1,d6
	Move.b	d6,(a0)
	Add.l	#8,a0
	Move.b	d7,(a0)
	Rts
L7NCOP	Moveq	#2,d0
	Rbra	L_CUSTOM
;
; **************************************************************************
; *									   *
; * Mettre un ecran ECS/AGA (0 a 7) dans une section COPPER (1-3)	   *
; *									   *
; **************************************************************************
;
L_FXSCREENTOSECTION	Equ	8
L8	Move.l	(a3)+,d7
;	RSave
;	Sub.l	#1,d7
;	Cmp.l	#3,d7
;	Bgt	L8_ERR
;	Cmp.l	#0,d7
;	Blt	L8_ERR
;	Move.l	d7,d6
;	Move.l	d7,d5
;	Lsl.l	#2,d6
;	DLea	COP1PART,a0
;	Add.l	d6,a0
;	Move.l	(a0),d6		; D6=Adresse copper COPxPART.
;	Cmp.l	#0,d6
;	Beq	L8NCOP
;	Move.l	d6,a4			; A4=Zone cible copie BIT PLANES.
;	Add.l	#10,a4			; Bpl0Pth position in COPPERLIST.
;	Mulu.l	#48,d7		; 1 section de donnees use 48 octets.
;	DLea	COPSECTION1,a1
;	Add.l	d7,a1		; A1=Zone Cible.
;	Move.l	a1,a3			; A3=Zone source adresse BPLANES.
;	DLea	SCRNCURRENT,a2
;	Move.l	(a2),a0		; A0=Zone source.
;	Cmp.l	#0,a0
;	Beq	L8NSCN
;	Move.l	#7,d0
;L8_A	Move.l	(a0)+,(a1)+	; Copie bits plans screen dans bits plans
;	Sub.l	#1,d0		; COPSECTIONx
;	Bpl	L8_A
;	Move.l	#0,(a1)+	; X Screen offset=0
;	Move.l	#0,(a1)+	; Y Screen offset=0
;	Add.l	#44,a0		; A0=Screen base+76
;	Add.l	#2,a1
;	Move.w	(a0),(a1)	; Copy X screen size.
;	Move.w	(a0)+,d7
;	Add.l	#4,a1
;	Move.w	(a0),(a1)	; Copy Y screen size.
;; Copie dans le copper list 2.
;	Move.l	#15,d0
;L8_B	Move.w	(a3)+,(a4)
;	Add.l	#4,a4
;	Sub.l	#1,d0
;	Bpl	L8_B
;; Mise en place des modulos d'ecran.
;	Add.l	#16,a4		; A4=Bpl1Mod
;	Sub.l	#320,d7
;	Lsr.l	#4,d7
;	Move.w	d7,(a4)
;	Add.l	$4,a4
;	Move.w	d7,(a4)
;	RLoad
	Rts
;L8NCOP	RLoad
;	Moveq	#2,d0
;	Rbra	L_CUSTOM
;L8NSCN	RLoad
;	Moveq	#6,d0
;	Rbra	L_CUSTOM
;L8_ERR	RLoad
;	Moveq	#3,d0
;	Rbra	L_CUSTOM
;;
; **************************************************************************
; *									   *
; * Definir le nombre de bits plans visibles dans une section copper.	   *
; *									   *
; **************************************************************************
;
L_FXCOPPERVIEW		Equ	9
L9	Move.l	(a3)+,d1	; D1=Number of planes.
	Move.l	(a3)+,d0	; D0=Copper Section.
	Cmp.l	#8,d1
	Bgt	L9BPL
	Cmp.l	#0,d1
	Blt	L9BPL
	Cmp.l	#1,d0
	Blt	L9CS
	Cmp.l	#3,d0
	Bgt	L9CS
	Lea	COPVIEW(pc),a0
	Lsl.l	#1,d1
	Add.l	d1,a0
	Move.w	(a0),d1		; D1=Bit plane mask to allow bits planes.
	DLea	COP1PART,a0
	Sub.l	#1,d0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Beq	L9CS2
	Add.l	#102,d0
	Move.l	d0,a0
	Move.w	d1,(a0)
	Rts
COPVIEW	Dc.w	$0000,$1000,$2000,$3000,$4000,$5000,$6000,$7000,$0010
L9CS	Moveq	#3,d0
	Rbra	L_CUSTOM
L9BPL	Moveq	#5,d0
	Rbra	L_CUSTOM
L9CS2	Moveq	#2,d0
	Rbra	L_CUSTOM
;
; **************************************************************************
; *									   *
; * Screen offset d'une section copper					   *
; *									   *
; **************************************************************************
;
L_FXSCREENOFFSET	Equ	10
L10	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,d2
	Move.l	(a3)+,d1
	Move.l	(a3),d0
	Cmp.l	#1,d0
	Blt	L10ERR2
	Cmp.l	#3,d0
	Bgt	L10ERR2
	SysC	S_SECTIONOFFSET
	Movem.l	(sp)+,a3-a6
	Add.l	#12,a3
	Cmp.l	#$ffffffff,d0
	Beq	L10ERR
	Rts
L10ERR	Moveq	#4,d0
	Rbra	L_CUSTOM
L10ERR2	Movem.l	(sp)+,a3-a6
	Add.l	#12,a3
	Moveq	#3,d0
	Rbra	L_CUSTOM
;
; **************************************************************************
; *									   *
; * Redefinir une des couleurs du copper list				   *
; *									   *
; **************************************************************************
;
L_FXCOPPERCOLOR		Equ	11
L11	Move.l	(a3)+,d3	; D3=Blue
	Move.l	(a3)+,d2	; D2=Green
	Move.l	(a3)+,d1	; D1=Red
	Move.l	(a3)+,d0	; D0=Register
	DLea	COPPALVAL,a0
	Move.l	d0,d4
	Mulu.l	#3,d4
	Add.l	d4,a0
	Movem.l	d1/d2/d3,(a0)
; 13 lignes pour les LSB de la couleur.
	Move.l	d1,d4
	Move.l	d2,d5
	Move.l	d3,d6
	And.b	#$F0,d1
	And.b	#$F0,d2
	And.b	#$F0,d3
	Sub.l	d1,d4
	Sub.l	d2,d5
	Sub.l	d3,d6
	Lsl.l	#4,d4
	Or.l	d5,d4
	Lsl.l	#4,d4
	Or.l	d6,d4	; D4=Color complement ( 0 up to 15 )
; ...
	Lsr.l	#4,d1
	Lsr.l	#4,d2
	Lsr.l	#4,d3
	Lsl.l	#4,d1
	Or.l	d2,d1
	Lsl.l	#4,d1
	Or.l	d3,d1	; D1=Color Component. ( 0 up to 15 )
	Move.l	#6,d7	; D7=Decalage de l'adresse pour les couleurs.
L11_B0	Cmp.l	#31,d0
	Blt	L11_B1
	Beq	L11_B1
	Sub.l	#32,d0
	Add.l	#132,d7 ; D7+(32*4 couleurs +4(BplCon3) = 132)
	Bra	L11_B0
L11_B1	Lsl.l	#2,d0
	Add.l	d0,d7	; D7+(d0*4 couleurs = ???)
	DLea	COPPAL1,a2
	Move.l	(a2),a0
	Add.l	d7,a0
	Move.w	d1,(a0)
; la suite pour installer les LSB.
	DLea	VIDEO,a2
	Move.b	(a2),d0
	Cmp.b	#1,d0
	Bne	L11_B2
	DLea	COPPAL2,a2
	Move.l	(a2),d0
	Cmp.l	#0,d0
	Beq	L11_B2
	Move.l	d0,a0
	Add.l	d7,a0
	Move.w	d4,(a0)
L11_B2	Rts
;
; **************************************************************************
; *									   *
; * Recreer le copper palette/sprites/rainbows pour AGA machines	   *
; *									   *
; **************************************************************************
;
L_FXCOPPERAGA		Equ	12
L12	DLea	VIDEO,a0
	Move.b	#$1,(a0)
	SysC	S_COPPERAGA
R12_2	DLea	COPPART,a0
	Move.b	(a0),d0
	Cmp.b	#2,d0
	Beq	R12_2P
	Cmp.b	#3,d0
	Beq	R12_3P
R12_1P	SysC	S_SECTION1
	Rts
R12_2P	SysC	S_SECTION2
	Rts
R12_3P	SysC	S_SECTION3
	Rts
;
; **************************************************************************
; *									   *
; * Recreer le copper palette/sprites/rainbows pour ECS machines	   *
; *									   *
; **************************************************************************
;
L_FXCOPPERECS		Equ	13
L13	DLea	VIDEO,a0
	Move.b	#$0,(a0)
	SysC	S_COPPERECS
R13_2	DLea	COPPART,a0
	Move.b	(a0),d0
	Cmp.b	#2,d0
	Beq	R13_2P
	Cmp.b	#3,d0
	Beq	R13_3P
R13_1P	SysC	S_SECTION1
	Rts
R13_2P	SysC	S_SECTION2
	Rts
R13_3P	SysC	S_SECTION3
	Rts
;
; **************************************************************************
; *									   *
; * Recreer le copper ecran en 1,2,3 section ECRANS.			   *
; *									   *
; **************************************************************************
;
L_FXSECTION		Equ	14
L14	Move.l	(a3)+,d0
	DLea	COPPART,a0
	Move.b	d0,(a0)
	Cmp.l	#1,d0
	Beq.b	L14_S1
	Cmp.l	#2,d0
	Beq.b	L14_S2
	Cmp.l	#3,d0
	Beq.b	L14_S3
	Moveq	#9,d0
	Rbra	L_CUSTOM
L14_S1	SysC	S_SECTION1
	Rts
L14_S2	SysC	S_SECTION2
	Rts
L14_S3	SysC	S_SECTION3
	Rts
;
L15
L16
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CUSTOM		Equ	17
L17	DLea	LANGUAGE,a0
	Move.b	(a0),d3
	Cmp.b	#1,d3
	Beq	FRENCH
ENGLISH	Lea	ErrMessE(pc),a0
	Bra	LxSuit
FRENCH	Lea	ErrMessF(pc),a0
LxSuit	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#0,d3
	Rjmp	L_ErrorExt
ErrMessE
	Dc.b	"Not enough free memory.",0			;  0
	Dc.b	"Internal error COPPER not created !",0		;  1
	Dc.b	"Invalid Copper number or not created !",0	;  2
	Dc.b	"Copper section must be 1-3.",0			;  3
	Dc.b	"Invalid copper section.",0			;  4
	Dc.b	"Only 1 up to 8 Bits planes alloweds.",0	;  5
	Dc.b	"Screen not opened.",0				;  6
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
ErrMessF
	Dc.b	"Pas assez de memoire libre.",0			;  0
	Dc.b	"Erreur Interne COPPER LIST non cree !",0	;  1
	Dc.b	"Copper demande invalide ou non cree !",0	;  2
	Dc.b	"Seules les sections 1 a 3 sont possibles.",0	;  3
	Dc.b	"Section Copper invalide.",0			;  4
	Dc.b	"De 1 a 8 bits plans sont permis.",0		;  5		;  1
	Dc.b	"Ecran non ouvert.",0				;  6
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L18	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#-1,d3
	Rjmp	L_ErrorExt
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L19
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_TITLE
		Dc.b	"Aga/Ecs Copper V1.0a / Felix 1997"
		Dc.b	0
		Dc.b	"10/06/97."
		Even
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_END		Dc.w	0
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
