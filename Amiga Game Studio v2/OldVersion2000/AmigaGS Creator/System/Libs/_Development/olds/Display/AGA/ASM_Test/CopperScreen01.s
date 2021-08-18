; *********************
; *                   *
; * Copper screen use *
; *                   *
; *********************
;
; That example use personal copper for user choice.
; It can allow AGA features for colors and resolutions.

AllocMem		= -198	; [Take] (D0=ByteSize,D1=Requirements) (D0=MemoryBlock)
AllocAbs		= -204	; [Take] (D0=ByteSize,A1=Location) (D0=MemoryBlock)
FreeMem			= -210	; [Free] (D0=ByteSize,A1=MemoryBlock)
OldOpenLibrary	= -408	; [Load] (D0=Version,A1=LibName) (D0=LibraryBase)
CloseLibrary	= -414	; [Close] (A1=LibraryBase) ()

COP1LCH		Equ	$DFF080
COP2LCH		Equ	$DFF084
COP1JMP		Equ	$DFF086
COP2JMP		Equ	$DFF088
StartList	Equ	36
;
; ****************************************************************
;
	Move.l	$4.w,a6
;
; 1> On Sauvegarde les adresses copper list du workbench :
;---------------------------------------------------------
	Lea.l	GraphicsName,a1
	Moveq.l	#0,d0
	Jsr		OldOpenLibrary(a6)
	Lea.l	GraphicsBase,a1
	Move.l	d0,(a1)
;
	Move.l	d0,a1
	Move.l	$26(a1),d0		; D0=Old Copper 1
	Move.l	$32(a1),d1		; D1=Old Copper 2
	Lea.l	OldCopper,a0
	Movem.l	d0/d1,(a0)
;
	Jsr		CloseLibrary(a6)

;
; ****************************************************************
;

; 2> On crée notre copper list 256 couleurs :
;--------------------------------------------
; Pour le moment , elle sera de 256couleurs en noir.
; Aucun écran n'est représenté mais les registres sont crées.
; ----------------------------------------------------------------
; ----------------------------------------------------------------
; A> ALLOCATION MéMOIRE POUR LA COPPER LIST EN CHIP-RAM.
	Move.l	#16384,d0
	Move.l	#$10002,d1
	Jsr		AllocMem(a6)
	Tst.l	d0
	Beq.w	_NotEnoughMemory1
;
	Lea.l	CopperBase,a0
	Move.l	d0,(a0)
	Move.l	d0,a0			; A0=CURRENT COPPER POSITION.

;
; ----------------------------------------------------------------
; ----------------------------------------------------------------
; B> CREATION DE LA COPPER LIST // SPRITES DEFINITION :
	Move.l	#$1003FFFE,(a0)+
	Move.l	#$01fc0000,(a0)+	; Anti Double scanning !!!.
	Move.l	#$01200000,d0
cs1:
	Move.l	d0,(a0)+
	Add.l	#$20000,d0
	Cmp.l	#$01400000,d0
	Bgt.s	cs1
;
; ----------------------------------------------------------------
; ----------------------------------------------------------------
; C> CREATION DE LA COPPER LIST // COLOR PALETTE DEFINITION :
	Move.l	#$1803FFFE,(a0)+
; ***********************
	Lea.l	PALETTE1,a1
	Move.l	a0,(a1)
; ***********************
	Move.l	#$01060000,d0		; D0=1ère palette (color0-31)
cs2:
	Move.l	d0,(a0)+		; bloc de couleurs à choisir.
	Move.w	#$0180,d1
cs3:
	Move.w	d1,(a0)+
	Clr.w	(a0)+
	Add.w	#$0002,d1
	Cmp.w	#$01C0,d1
	bne.b	cs3
	Add.l	#$00002000,d0
	Cmp.l	#$01070000,d0
	Bne.b	cs2

; ***********************
	Lea.l	PALETTE2,a1
	Move.l	a0,(a1)
; ***********************
	Move.l	#$01060200,d0		; D0=1ère palette (color0-31)
cs4:
	Move.l	d0,(a0)+		; bloc de couleurs à choisir.
	Move.w	#$0180,d1
cs5:
	Move.w	d1,(a0)+
	Clr.w	(a0)+
	Add.w	#$0002,d1
	Cmp.w	#$01C0,d1
	bne.b	cs5
	Add.l	#$00002000,d0
	Cmp.l	#$01070200,d0
	Bne.b	cs4
;
; ----------------------------------------------------------------
; ----------------------------------------------------------------
; ***********************
	Lea.l	PROPERTIES,a1
	Move.l	a0,(a1)
; ***********************
; D> CREATION DE LA COPPER LIST // ECRAN à VISUALISER.
	Move.l	#$3003FFFE,(a0)+	; Start at Y=48
;	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
; Install 8 bitsplanes.
	Move.w	#$00E0,d0		; Bpl0PTH
cs6:
	Move.w	d0,(a0)+
	Clr.w	(a0)+
	Add.w	#$0002,d0
	Cmp.w	#$0100,d0
	Bne.s	cs6
;
; Others registers to define.
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
	Move.l	#$3103FFFE,(a0)		; First screen line Y=50
; Start screen displaying:
	Move.l	#$00968300,(a0)+
	Move.l	#$3203FFFE,(a0)+
; Fin de la copper list.
	Move.l	#$F203FFFE,(a0)+
	Move.l	#$01000000,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$F303FFFE,(a0)+
	Move.l	#$FFFFFFFE,(a0)+
;

;
; ****************************************************************
;


; 3> On active notre copper list :
;---------------------------------
	Jsr		WaitVbl
	Lea		CopperBase,a0
	Move.l	(a0),d0
	Move.l	d0,COP1LCH

; 4> Après un click sur le bouton gauche , on quitte :
;-----------------------------------------------------
	Jsr		WaitLeftClick
	Jsr		WaitVbl
;
	Lea.l	OldCopper,a0
	Movem.l	(a0),d0/d1
	Movem.l	d0/d1,COP1LCH
	Jsr		WaitVbl

; 5> On libère la mémoire utilisée par la copper list :
;------------------------------------------------------
	Lea		CopperBase,a0
	Move.l	(a0),a1
	Move.l	#16384,d0
	Jsr		FreeMem(a6)
;
	Moveq	#0,d0
	Rts

;
; ****************************************************************
;

; x> PAS ASSEZ DE MéMOIRE :
;--------------------------
_NotEnoughMemory1:
	Moveq	#0,d0
	Rts
;
; ****************************************************************
;

; x> La zone des données :
;-------------------------
GraphicsName:
	Dc.b	"graphics.library",0,0
GraphicsBase:
	Dc.l	0
;
CopperBase:
	Dc.l	0		; New copper list 1 base offset.
OldCopper:
	Dc.l	0,0
; COPPER LIST USEFUL ADRESS :
PALETTE1:
	Dc.l	0		; Adresse de la palette de 256 couleurs.
PALETTE2:
	Dc.l	0		; Adresse de l'atenuation de palette 256c.
PROPERTIES:
	Dc.l	0		; Adresse de la définition de l'écran.
;
; ****************************************************************
;

; x>SOUS-PROGRAMMES :
;--------------------
WaitVbl:
	Btst.b	#0,$DFF005
	Beq.s	WaitVbl
.loop
	Btst.b	#0,$DFF005
	Bne.s	.loop
	Rts
WaitLeftClick:
	Btst.b	#6,$BFE001
	Bne.s	WaitLeftClick
	Rts



; END OF PROGRAM
