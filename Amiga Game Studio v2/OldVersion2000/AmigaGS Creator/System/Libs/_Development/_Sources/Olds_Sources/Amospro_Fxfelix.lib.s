;
; ***************************************************************
; *							        *
; * FireWorks(c)1995 AmosProfessionnal Gfx-Effects Library V1.0 *
; *							        *
; ***************************************************************
; Slot 20
;

Version		MACRO
		Dc.b	"1.0b"
		ENDM

ExtNb		Equ	20-1

		Incdir	"INCLUDES:AMOS/"
		Include "|amos_includes.s"
		Include	"Fredrick/_Chips.s"
;
DLea		MACRO
;		Move.l	ExtAdr+ExtNb*16(a5),\2
;		Add.w	#\1-FWC,\2
		Lea.l	\1(pc),\2
		ENDM
;
Start		Dc.l	C_TK-C_OFF
		Dc.l	C_LIB-C_TK
		Dc.l	C_TITLE-C_LIB
		Dc.l	C_END-C_TITLE
		Dc.w	0

C_OFF		Dc.w	(L1-L0)/2,(L2-L1)/2,(L3-L2)/2,(L4-L3)/2,(L5-L4)/2
		Dc.w	(L6-L5)/2,(L7-L6)/2,(L8-L7)/2,(L9-L8)/2,(L10-L9)/2
		Dc.w	(L11-L10)/2,(L12-L11)/2,(L13-L12)/2,(L14-L13)/2
		Dc.w	(L15-L14)/2,(L16-L15)/2,(L17-L16)/2,(L18-L17)/2

;		Dc.w	...

C_TK		Dc.w	1,0
		Dc.b	$80,-1
		Dc.w	L_ROTATE,-1
		Dc.b	"fx rot Ecra","n"+$80,"I0,0t0",-1
		Dc.w	L_MOSAICx2,-1
		Dc.b	"fx x2 mosai","c"+$80,"I0",-1
		Dc.w	L_MOSAICx4,-1
		Dc.b	"fx x4 mosai","c"+$80,"I0",-1
		Dc.w	L_MOSAICx8,-1
		Dc.b	"fx x8 mosai","c"+$80,"I0",-1
		Dc.w	L_MOSAICx16,-1
		Dc.b	"fx x16 mosai","c"+$80,"I0",-1
		Dc.w	L_MOSAICx32,-1
		Dc.b	"fx x32 mosai","c"+$80,"I0",-1
		Dc.w	L_ZOOM,-1
		Dc.b	"fx zoo","m"+$80,"I0,0,0t0",-1
		Dc.w	L_CONFORM32,-1
		Dc.b	"fx block to scree","n"+$80,"I0",-1
		Dc.w	L_CONFORM32B,-1
		Dc.b	"fx vertice to scree","n"+$80,"I0",-1
		Dc.w	L_BLITCLEAR,-1
		Dc.b	"fx cl","s"+$80,"I0",-1

		Dc.w	-1,L_XXX
		Dc.b	"fx tes","t"+$80,"0",-1

		Dc.w	0
;
; Rotate Screen SCRN1,ANGLE To SCRN2
; =R Cos(ANGLE') -> Cos()*1024
; =R Sin(ANGLE') -> Sin()*1024
; Fx X?? Mosaic SCRN
; Fx Zoom SCRN1,XZOOM*100,YZOOM*100 To SCRN2
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_LIB
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L0	movem.l	a3-a6,-(sp)
	Lea	FWC(pc),a2
	Move.l	a2,ExtAdr+ExtNb*16(a5)
	Lea	RouDef(pc),a0
	Move.l	a0,ExtAdr+ExtNb*16+4(a5)
	Lea	RouEnd(pc),a0
	Move.l	a0,ExtAdr+ExtNb*16+8(a5)
	Movem.l	(sp)+,a3-a6
	Moveq	#ExtNb,D0				; OK
	Rts
******** Initialise.
; Remise a zero de tous les compteurs.
RouDef	Move.w	#$0,$dff1fc		; Disable DOUBLE SCANNING.
	Move.w	#$c00,$dff106		; GRAPHICS PALETTE=0 to 31
	Rts
******** Quit.
RouEnd
	Rts
;
;
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DATA ZONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
FWC
FxId:	Dc.b	"flx-4",1,0,"a"
_MosaicBase	Dc.l	0
_MosaicPlanes	Dc.l	0,0,0,0,0,0,0,0,0
;
XSC	Dc.l	0
YSC	Dc.l	0
XCENTRE	Dc.l	0
YCENTRE	Dc.l	0
CO21	Dc.l	0
CO22	Dc.l	0
ANGLE	Dc.l	0
BPL	Dc.l	0
BPL2	Dc.l	0
BIT	Dc.l	0
PLANE	Dc.l	0
SCRN1	Dc.l	0
SCRN2	Dc.l	0
SPX	Dc.l	0,0,0,0
_c1	Dc.l	0
;CosT	IncBin	"Fredrick/cosinus.raw"
;SinT	IncBin	"Fredrick/sinus.raw"
	Rdata
; BANQUE DE DONNEES ACCESSIBLES A L'UTILISATEUR.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L1
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L2
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ROTATE		Equ	3				; OK
L3
	Movem.l	(a3)+,d1/d2/d3
	DLea	YSC,a1
	Move.l	d2,(a1)
	DLea	XCENTRE,a1
	Move.l	d3,(a1)
	Rjsr	L_GetEc
	DLea	XSC,a1
	Move.l	a0,(a1)
	Cmp.l	#0,a0
	Beq	_L3ScreenNotOpened
	DLea	XCENTRE,a1
	Move.l	(a1),d1
	Rjsr	L_GetEc
	Cmp.l	#0,a0
	Beq	_L3ScreenNotOpened
	Sub.l	#12,a3
	DLea	SPX,a1
	Movem.l	a3-a6,(a1)
	Move.l	a0,a4	; A4=Ecran Source.
	DLea	XSC,a1
	Move.l	(a1),a5	; A5=Ecran Cible.
	DLea	YSC,a1
	Move.l	(a1),d0	; D0=Angle de rotation.
; Clear all 9 registers for ROTATION
	DLea	XSC,a0
	Move.b	#8,d1
L3Clr	Move.l	#0,(a0)+
	Sub.b	#1,d1
	Bpl	L3Clr
; A5=Base cible A4=Base Source D0=Angle de rotation.
	DLea	2+ANGLE,a0
	Move.w	d0,(a0)
	Cmp.l	#0,d0
	Blt	_L3AngleTooLittle
	Cmp.l	#359,d0
	Bgt	_L3AngleTooLarge
;
	Move.l	a4,a3
	Add.l	#76,a3
	Clr.l	d1
	Move.w	(a3)+,d1
	DLea	2+XSC,a6
	Move.w	d1,(a6)
	Lsr.l	#1,d1
	DLea	2+XCENTRE,a6
	Move.w	d1,(a6)
	Move.w	(a3),d1
	DLea	2+YSC,a6
	Move.w	d1,(a6)
	Lsr.l	#1,d1
	DLea	2+YCENTRE,a6
	Move.w	d1,(a6)
L3DEBUT:
	Clr.l	d0
	DLea	2+ANGLE,a6
	Move.w	(a6),d0
;   A0=Leek(Screen Base) Of screen cible.
	Move.l	(a5)+,a0	; A0=1er bit plan ecran Cible.
;   D5=7
	Moveq	#7,d5
;   D1=Cos(D0)*1024
	Lsl.w	#2,d0
;	DLea	CosT,a3
	Add.l	d0,a3
	Move.l	(a3),d1
;   D2=Sin(D0)*1024
;	DLea	SinT,a3
	Add.l	d0,a3
	Move.l	(a3),d2
;   For D3=0 To YSC-1 Step 1
	Moveq	#0,d3
L3e
;' CO21,CO22 a sauver dans les adresses CO21,CO22  temporaires par d7. 
;      CO21=(((D3-YCENTRE)*D2)/1024)
	Move.l	d3,d7
	DLea	YCENTRE,a6
	Sub.l	(a6),d7
	Muls.l	d2,d7
	Divs.l	#1024,d7
	DLea	CO21,a6
	Move.l	d7,(a6)
;      CO22=(((D3-YCENTRE)*D1)/1024)
	Move.l	d3,d7
	DLea	YCENTRE,a6
	Sub.l	(a6),d7
	Muls.l	d1,d7
	Divs.l	#1024,d7
	DLea	CO22,a6
	Move.l	d7,(a6)
;      For D4=0 To XSC-1 Step 1
	Moveq	#0,d4
L3d
;         D6=(((D4-XCENTRE)*D1)/1024)-CO21+XCENTRE
	Move.l	d4,d6
	DLea	XCENTRE,a6
	Sub.l	(a6),d6
	Muls.l	d1,d6
	Divs.l	#1024,d6
	DLea	CO21,a6
	Sub.l	(a6),d6
	DLea	XCENTRE,a6
	Add.l	(a6),d6
;         D7=(((D4-XCENTRE)*D2)/1024)+CO22+YCENTRE
	Move.l	d4,d7
	DLea	XCENTRE,a6
	Sub.l	(a6),d7
	Muls.l	d2,d7
	Divs.l	#1024,d7
	DLea	CO22,a6
	Add.l	(a6),d7
	DLea	YCENTRE,a6
	Add.l	(a6),d7
;         If 0<D6<XSC and 0<D7<YSC
	Cmp.l	#0,d6
	Blt	L3a
	DLea	2+XSC,a6
	Cmp.w	(a6),d6
	Bgt	L3a
	Beq	L3a
	Cmp.l	#0,d7
	Blt	L3a
	DLea	2+YSC,a6
	Cmp.w	(a6),d7
	Bgt	L3a
	Beq	L3a
;            CO=F Point(D6,D7) of Screen Source
	Clr.l	d0
	DLea	2+XSC,a6
	Move.w	(a6),d0
	Lsr.w	#3,d0		; D0=X Screen/8
	Mulu.w	d7,d0		; D0=Horizontal source ligne.
	Move.l	d6,d7
	Lsr.l	#3,d7
	Add.l	d7,d0		; D0=OCTET TO BE READ.
	Lsl.l	#3,d7
	Sub.l	d7,d6	;	D6=7-Bit to read.
	Move.b	#7,d7
	Sub.b	d6,d7		; D7=BIT FROM D0 TO BE READ.
	Move.l	(a4),a1
	Add.l	d0,a1
;         If CO>0 Then Bset D5,(A0)
	Btst.b	d7,(a1)
	Beq	L3a
	Bset.b	d5,(a0)
	Bra	L3f
L3a
	Bclr.b	d5,(a0)
L3f
;         D5=D5-1
	Sub.b	#1,d5
;         If D5=-1
	Bpl	L3c
;            D5=7
	Moveq	#7,d5
;            A0=A0+1
	Add.l	#1,a0
;           End If 
L3c
;        Next D4
	Add.w	#1,d4
	DLea	2+XSC,a6
	Cmp.w	(a6),d4
	Blt	L3d
;     Next D3
	Add.w	#1,d3
	DLea	2+YSC,a6
	cmp.w	(a6),d3
	Blt	L3e
	Add.l	#4,a4
	Cmp.l	#0,(a4)
	Beq	L3FIN
	DLea	BPL,a6
	Add.b	#1,(a6)
	Cmp.b	#6,d0
	Blt	L3DEBUT
L3FIN
	DLea	SPX,a0
	Movem.l	(a0),a3-a6
	Add.l	#12,a3
	Rts
_L3AngleTooLittle
	DLea	SPX,a0
	Movem.l	(a0),a3-a6
	Add.l	#12,a3
	Moveq	#0,d0
	Rbra	L_CUSTOM
_L3AngleTooLarge
	DLea	SPX,a0
	Movem.l	(a0),a3-a6
	Add.l	#12,a3
	Moveq	#1,d0
	Rbra	L_CUSTOM
_L3ScreenNotOpened
	DLea	SPX,a0
	Movem.l	(a0),a3-a6
	Add.l	#12,a3
	Moveq	#2,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx2		Equ	4
L4
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d1		; D0=Screen Base.
	Rjsr	L_GetEc
	Move.l	a0,d0
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
	Movem.l	a3-a6,-(sp)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_m1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_m1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#1,d7
	Lsl.l	#1,d7	; D7 Paire
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_m2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_m3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$AAAAAAAA,d2		; D2=Masque 
	And.l	d0,d2
	Move.l	d2,d0
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Move.l	d0,(a1)+
	Move.l	d0,(a2)+
	Cmp.l	a1,a3
	Bne	_m3
; UNE LIGNE TERMINEE.
	Add.l	d3,a1		; A1 = A1 + 1 Ligne.
	Add.l	d3,a2		; A2 = A2 + 1 Ligne.
	Add.l	d3,a3
	Add.l	d3,a3		; A3 = A3 + 2 Lignes. !!!
	Add.l	#2,d1
	Cmp.l	d1,d7
	Bne	_m3
	Bra	_m2
_mend	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx4		Equ	5
L5
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d1		; D0=Screen Base.
	Rjsr	L_GetEc
	Move.l	a0,d0
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
	Movem.l	a3-a6,-(sp)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_mb1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_mb1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#2,d7
	Lsl.l	#2,d7	; D7 Multiple de 4
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_mb2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mbend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_mb3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$88888888,d2		; D2=Masque 
	And.l	d0,d2
	Move.l	d2,d0
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Move.l	d0,(a1)+
	Move.l	d0,(a2)
	Add.l	d3,a2
	Move.l	d0,(a2)
	Add.l	d3,a2
	Move.l	d0,(a2)+
	Sub.l	d3,a2
	Sub.l	d3,a2
	Cmp.l	a1,a3
	Bne	_mb3
; UNE LIGNE TERMINEE.
	add.l	d3,a1
	Add.l	d3,a2
	Lsl.l	#1,d3
	Add.l	d3,a1		; A1 = A1 + 3 Ligne.
	Add.l	d3,a2		; A2 = A2 + 3 Ligne.
	Add.l	d3,a3
	Add.l	d3,a3		; A3 = A3 + 4 Lignes. !!!
	Lsr.l	#1,d3
	Add.l	#4,d1
	Cmp.l	d1,d7
	Bne	_mb3
	Bra	_mb2
_mbend	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx8		Equ	6
L6
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d1		; D0=Screen Base.
	Rjsr	L_GetEc
	Move.l	a0,d0
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
	Movem.l	a3-a6,-(sp)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_mc1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_mc1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#3,d7
	Lsl.l	#3,d7	; D7 Multiple de 4
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_mc2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mcend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_mc3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$80808080,d2		; D2=Masque.
	And.l	d0,d2
	Move.l	d2,d0
	Move.l	#7,d4
_mcw	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mcw
	Move.l	d0,(a1)+
	Move.l	#6,d4
_mcx	Move.l	d0,(a2)
	Add.l	d3,a2
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mcx
	Move.l	d0,(a2)+
	Mulu	#6,d3
	Sub.l	d3,a2
	Divu	#6,d3
	Cmp.l	a1,a3
	Bne	_mc3
; UNE LIGNE TERMINEE.
	Mulu	#7,d3
	Add.l	d3,a1
	Add.l	d3,a2
	Add.l	d3,a3
	Divu	#7,d3
	Add.l	d3,a3	; A3=1 ligne de plus que les autres (a1,a2)
	Add.l	#8,d1
	Cmp.l	d1,d7
	Bne	_mc3
	Bra	_mc2
_mcend	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx16		Equ	7
L7
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d1		; D0=Screen Base.
	Rjsr	L_GetEc
	Move.l	a0,d0
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
	Movem.l	a3-a6,-(sp)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_md1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_md1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#4,d7
	Lsl.l	#4,d7	; D7 Multiple de 4
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_md2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_mdend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_md3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$80008000,d2		; D2=Masque.
	And.l	d0,d2
	Move.l	d2,d0
	Move.l	#15,d4
_mdw	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mdw
	Move.l	d0,(a1)+
	Move.l	#14,d4
_mdx	Move.l	d0,(a2)
	Add.l	d3,a2
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mdx
	Move.l	d0,(a2)+
	Mulu	#14,d3
	Sub.l	d3,a2
	Divu	#14,d3
	Cmp.l	a1,a3
	Bne	_md3
; UNE LIGNE TERMINEE.
	Mulu	#15,d3
	Add.l	d3,a1
	Add.l	d3,a2
	Add.l	d3,a3
	Divu	#15,d3
	Add.l	d3,a3	; A3=1 ligne de plus que les autres (a1,a2)
	Add.l	#16,d1
	Cmp.l	d1,d7
	Bne	_md3
	Bra	_md2
_mdend	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_MOSAICx32		Equ	8
L8
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	(a3),d1		; D0=Screen Base.
	Rjsr	L_GetEc
	Move.l	a0,d0
	DLea	_MosaicBase,a0
	Move.l	d0,(a0)
	Movem.l	a3-a6,-(sp)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	DLea	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#5,d1
_me1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_me1
; POSITIONNEMENT DES DONNEES.
	DLea	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#5,d7
	Lsl.l	#5,d7	; D7 Multiple de 32
	DLea	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_me2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq	_meend
	Move.l	#0,d1			; D1=CURRENT SCREEN LINE POS.
	Move.l	a1,a2
	Add.l	d3,a2			; A2=CURRENT SCREEN LINE +1.
	Move.l	a2,a3			; A3= '' '' '' '' '' '' '' .
_me3	Move.l	(a1),d0			; D0=Donnee Lue.
	Move.l	#$80000000,d2		; D2=Masque.
	And.l	d0,d2
	Move.l	d2,d0
	Move.l	#31,d4
_mew	Lsr.l	#1,d2
	Or.l	d2,d0			; D0=Nouvelle Donnee.
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mew
	Move.l	d0,(a1)+
	Move.l	#30,d4
_mex	Move.l	d0,(a2)
	Add.l	d3,a2
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_mex
	Move.l	d0,(a2)+
	Mulu	#30,d3
	Sub.l	d3,a2
	Divu	#30,d3
	Cmp.l	a1,a3
	Bne	_me3
; UNE LIGNE TERMINEE.
	Mulu	#31,d3
	Add.l	d3,a1
	Add.l	d3,a2
	Add.l	d3,a3
	Divu	#31,d3
	Add.l	d3,a3	; A3=1 ligne de plus que les autres (a1,a2)
	Add.l	#32,d1
	Cmp.l	d1,d7
	Bne	_me3
	Bra	_me2
_meend	Movem.l	(sp)+,a3-a6
	Add.l	#4,a3		; 2 donnees lues.
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_ZOOM			Equ	9
L9
	Movem.l	a3-a6,-(sp)
	Move.l	(a3)+,d1
	Rjsr	L_GetEc
	Cmp.l	#0,a0
	Beq	L11ScreenNotOpened
	DLea	SCRN2,a1		; Sauvegarde screen CIBLE.
	Move.l	a0,(a1)
	Add.l	#8,a3
	Move.l	(a3),d1
	Sub.l	#8,a3
	Rjsr	L_GetEc
	Cmp.l	#0,a0
	Beq	L11ScreenNotOpened
	DLea	SCRN1,a1		; Sauvegarde screen SOURCE.
	Move.l	a0,(a1)
	DLea	4+SPX,a0
	Move.l	(a3)+,d1
	Move.l	(a3)+,d0
	Add.l	#3,a3
	Movem.l	(sp)+,a3-a6
	Add.l	#16,a3
	DLea	SPX,a0
	Movem.l	a3-a6,(a0)
;XSC=Screen X Size.
;YSC=Screen Y Size.
; XCENTRE=XSC/2
; YCENTRE=YSC/2
	DLea	SCRN1,a0
	Move.l	(a0),a1
	add.l	#76,a1
	Clr.l	d2
	Move.w	(a1)+,d2	; Lecture de la taille de l'ecran.
	DLea	2+XSC,a0
	Move.w	d2,(a0)
	Lsr.l	#1,d2
	DLea	2+XCENTRE,a0
	Move.w	d2,(a0)
	Move.w	(a1)+,d2
	DLea	2+YSC,a0
	move.w	d2,(a0)
	Lsr.l	#1,d2
	DLea	2+YCENTRE,a0
	Move.w	d2,(a0)
	DLea	BPL2,a0		; Sauvegarde du nombre de bits plans utiles.
	Move.w	(a1)+,d2
	Move.b	d2,(a0)
	DLea	BPL,a6		; BPL a 0.
	Move.b	#0,(a6)
	DLea	SCRN1,a2
	Move.l	(a2),a0
	DLea	SCRN2,a3
	Move.l	(a3),a1
;' D0=X Zoom Factor D1=Y Zoom Factor. 
L11DEBUT:
;   A2=Leek(A0) : A0=A0+4
	Move.l	(a0),a2
	Add.l	#4,a0
;   A3=Leek(A1) : A1=A1+4
	Move.l	(a1),a3
	Add.l	#4,a1
;   If A2=0 Then Goto AAY
	Cmp.l	#0,a2
	Beq	L11AAY
;   If A3=0 Then Goto AAY
	Cmp.l	#0,a3
	Beq	L11AAY
;D6=7
	Moveq	#7,d6
;For D3=0 To YSC-1
	Moveq	#0,d3
L11D3
;   For D2=0 To XSC-1
	Moveq	#0,d2
L11D2
;      D4=XCENTRE+((D2-XCENTRE)*100)/D0
	Moveq	#0,d4
	DLea	2+XCENTRE,a6
	Move.w	d2,d4
	Sub.w	(a6),d4
	Muls.w	#100,d4
	Divs.w	d0,d4
	Add.w	(a6),d4
;      D5=YCENTRE+((D3-YCENTRE)*100)/D1
	Moveq	#0,d5
	DLea	2+YCENTRE,a6
	Move.w	d3,d5
	Sub.w	(a6),d5
	Muls.w	#100,d5
	Divs.w	d1,d5
	Add.w	(a6),d5
;         If D4<0 Then Goto AAX
	Cmp.w	#0,d4
	Blt	L11AAX
; 	  If D5<0 Then Goto AAX
	Cmp.w	#0,d5
	Blt	L11AAX
;         If D4>(XSC-1) Then Goto AAX
	DLea	2+XSC,a6
	Cmp.w	(a6),d4
	Bgt	L11AAX
	Beq	L11AAX
;         If D5>(YSC-1) Then Goto AAX
	DLea	2+YSC,a6
	Cmp.w	(a6),d5
	Bgt	L11AAX
	Beq	L11AAX
;         D7=((XSC/8)*D5)+(D4/8)
	Moveq	#0,d7
	DLea	2+XSC,a6
	Move.w	(a6),d7		; XSC
	Lsr.w	#3,d7		; /8
	Muls.w	D5,d7		; *d5
	Move.w	d4,d5
	Lsr.w	#3,d5
	Add.w	d5,d7		; +(d4/8)
;' D7=Octet de decalage a l'adresse source a tester.
;         D5=D4/8 : D5=D5*8
	Move.w	d4,d5
	And.w	#$FFF8,d5	; Mise des bits 0,1 et 2 a zero.
;         D4=D4-D5
	Sub.w	d5,d4
;         D5=7-D4
	Moveq	#7,d5
	Sub.w	d4,d5
;' D5 bit de l'octet a tester.
;         A4=A2+D7
	Move.l	a2,a4
	Add.l	d7,a4
;         D7=Peek(A4)
	Move.b	(a4),d7
;         If Btst(D5,D7)
	Btst	d5,d7
	Beq	L11AAX
;            Bset D6,(A3)
	Bset.b	d6,(a3)
;           End If 
L11AAX:
;         D6=D6-1
	Sub.b	#1,d6
;         If D6=-1
	Cmp.w	#$ff,d6
	Bne	L11Nope
;            D6=7 : A3=A3+1
	Moveq	#7,d6
	Add.l	#1,a3
;           End If 
L11Nope
;     Next D2
	Add.l	#1,d2
	DLea	2+XSC,a6
	Cmp.w	(a6),d2
	Blt	L11D2
;  Next D3
	Add.l	#1,d3
	DLea	2+YSC,a6
	Cmp.w	(a6),d3
	Blt	L11D3
;   BPL=BPL+1
	DLea	BPL,a6
	Add.b	#1,(a6)
;   If BPL<6 Then Goto DEBUT
	Cmp.b	#6,(a6)
	Blt	L11DEBUT
L11AAY:
	DLea	SPX,a0
	Movem.l	(a0)+,a3-a6
	Rts
L11ScreenNotOpened
	DLea	SPX,a0
	Movem.l	(a0)+,a3-a6
	Moveq	#2,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CONFORM32		Equ	10
L10
	Move.l	(a3)+,d1
	Rjsr	L_GetEc
	DLea	_c1,a1
	Move.l	a0,(a1)
	Cmp.l	#0,a0
	Beq	L12ScreenNotOpened
	Move.l	a0,d7		; D7=Bit Plane Adress
	Add.l	#76,a0
	Clr.l	d0
	Clr.l	d1
	Move.w	(a0)+,d0	; D0=X Screen Size.
	Move.w	(a0)+,d1	; D1=Y Screen Size.
	Lsr.l	#5,d0		; D0=.l X Screen length.
	Lsr.l	#5,d1		; D1=Block 32 Y Size Length.
	Move.l	#7,d5	; D5=6 Bits plans maximum.
; Copier sur une ligne de 1 bit plan.
_z3	Move.l	d7,a0
	Sub.l	#1,d5
	Cmp.l	#0,d5
	Beq	_fini	; Ecran Termine.
	Move.l	(a0),a2		; A2=Adresse cible.
	Cmp.l	#0,a2
	Beq	_fini	; Ecran Termine.
	Add.l	#4,d7		; D7=Adresse prochain bit plan a cibler.
;
; Faire la routine sur 1 bit plan.
	Move.l	d1,d4		; D4=Nbre de blocks a copier en Y.
_z2	Move.l	(a0),a1	; A1=Adresse source.
	Move.l	#32,d3		; D3=32 lignes a modifier.
_z0	Move.l	d0,d2	; D0 Blocks a copier en X.
_z1	Move.l	(a1),(a2)+	; Copie source / destination .
	Sub.l	#1,d2
	Cmp.l	#0,d2
	Bne	_z1
	Move.l	d0,d6
	Lsl.l	#2,d6
	Add.l	d6,a1
	Sub.l	#1,d3
	Cmp.l	#0,d3
	Bne	_z0
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_z2
	Bra	_z3
_fini	Rts
L12ScreenNotOpened
	Moveq	#2,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CONFORM32B		Equ	11
L11
	Move.l	(a3)+,d1
	Rjsr	L_GetEc
	DLea	_c1,a1
	Move.l	a0,(a1)
	Cmp.l	#0,a0
	Beq	L13ScreenNotOpened
	Move.l	a0,d7		; D7=Bit Plane Adress
	Add.l	#76,a0
	Clr.l	d0
	Clr.l	d1
	Move.w	(a0)+,d0	; D0=X Screen Size.
	Move.w	(a0)+,d1	; D1=Y Screen Size.
	Lsr.l	#5,d0		; D0=.l X Screen length.
	Lsr.l	#5,d1		; D1=Block 32 Y Size Length.
	Move.l	#7,d5	; D5=6 Bits plans maximum.
; Copier sur une ligne de 1 bit plan.
_z3b	Move.l	d7,a0
	Sub.l	#1,d5
	Cmp.l	#0,d5
	Beq	_finib	; Ecran Termine.
	Move.l	(a0),a2		; A2=Adresse cible.
	Cmp.l	#0,a2
	Beq	_finib	; Ecran Termine.
	Add.l	#4,d7		; D7=Adresse prochain bit plan a cibler.
	Move.l	(a0),a1
;
; Faire la routine sur 1 bit plan.
	Move.l	d1,d4		; D4=Nbre de blocks a copier en Y.
_z2b	Move.l	#32,d3		; D3=32 lignes a modifier.
_z0b	Move.l	d0,d2	; D0 Blocks a copier en X.
_z1b	Move.l	(a1),(a2)+	; Copie source / destination .
	Sub.l	#1,d2
	Cmp.l	#0,d2
	Bne	_z1b
	Move.l	d0,d6
	Lsl.l	#2,d6
	Add.l	d6,a1
	Sub.l	#1,d3
	Cmp.l	#0,d3
	Bne	_z0b
	Sub.l	#1,d4
	Cmp.l	#0,d4
	Bne	_z2b
	Bra	_z3b
_finib	Rts
L13ScreenNotOpened
	Moveq	#2,d0
	Rbra	L_CUSTOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_BLITCLEAR		Equ	12
L12	Move.l	(a3)+,d1
	Rjsr	L_GetEc
	Move.l	#5,d7		; D7=6 bits plans au maximum.
	Move.l	a0,a1
	Add.l	#76,a1
	Clr.l	d1
	Clr.l	d2
	Move.w	(a1)+,d1	; D1=X Screen Size.
	Move.w	(a1),d2		; D2=Y Screen Size.
	Divu	#16,d1		; D1=X Screen .W Size.
	Mulu	#64,d2		; D2=Y Size*64
	Add.l	d1,d2		; D2=Y Size*64 + X Size.
;bcx	Move.l	(a0),d0
bcx	Cmp.l	#$0,(a0)
	Beq	bcz		; Plus de bits plans a utiliser.
; Blitter Occupe ???
_bcp	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne	_bcp
; Mise de BLITTER en mode FILL CARRY IN.
_bc2	Move.w	#$0,BLTCON1		; Origin=#$4
; Mise en place de la source a lire.
;	Move.l	(a0),BLTCPTH		; A0=ADRESSE SOURCE !!!
; Modulo de la source=0.
;	Move.w	#$0,BLTCMOD
; Selection de la zone cible.
	Move.l	(a0)+,BLTDPTH		; A0=ADRESSE CIBLE !!!
; Selection du modulo de la cible
	Move.w	#$0,BLTDMOD
; Mise a 0 des masques de debut et fin du blitter.
;	Move.w	#$ffff,BLTAFWM
;	Move.w	#$ffff,BLTALWM
; Selection du type d'operation logique pour obtenir le resultat graphique.
; Et positionnement par rapport au decalage D6 de la source B.
;	Move.w	#%0000000100000000,BLTCON0	; Calcul mathematique.
	Move.w	#%0000000100000000,BLTCON0+$1A	; Equ BltCon0L
; Mise en place de la zone a copier.
	Move.w	D2,BLTSIZE
; Blitter occupe ?
;_bcq	Move.w	$Dff002,d5
;	Btst	#14,d5
;	Bne	_bcq
	Sub.l	#1,d7
	Bpl	bcx		; Si les 6 bits plans ont ete scannes.
bcz	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_XXX			Equ	13
L13	Rjsr	L_Bnk.GetBobs
	Move.l	a0,d3
	Moveq	#0,d2
	Rts
L14
L15
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L_CUSTOM		Equ	16
L16	DLea	ErrMess,a0
	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#0,d3
	Rjmp	L_ErrorExt
; Error Selection Messages
ErrMess	Dc.b	"Angle Trop Petit.",0				;    0
	Dc.b	"Angle Trop Grand.",0				;    1
	Dc.b	"Ecran non ouvert.",0				;    2
	EVEN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L17	Moveq	#0,d1
	Moveq	#ExtNb,d2
	Moveq	#-1,d3
	Rjmp	L_ErrorExt
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
L18
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_TITLE
		Dc.b	"Amos1.3/AmosPro felix-Effects Extension V1.0b"
		Dc.b	0
		Dc.b	"Released : 31/12/96"
;		Dc.b	0
		Even
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C_END		Dc.w	0
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Ne Jamais Oublier :
;
;	A > Lire Des Donnees De L'Amos
;		1 > A3(.l)=Adresse des valeurs
;		 ( Toujours remettre A3 a sa valeur initiale avant un RTS )
;		    A0(.w)=Longueur des textes (Strings)
;		2 > A4,A5,A6 ne doivent aucunement etre modifies
;		3 > D0,D1,D2,D3,D4,D5,D6,
;	B > Si l'utilisation des registres a3,a4,a5,a6 est obligatoire,
;		1 > Au debut de la routine faire : MOVEM.L A3-A6,-(SP)
;		2 > Utiliser a3,a4,a5,a6 a sa guise,
;		3 > A la fin de la routine : MOVEM.L (SP)+,A3-A6
;		4 > Ne pas oublier de remettre A3 a sa valeur initiale !!!
;
