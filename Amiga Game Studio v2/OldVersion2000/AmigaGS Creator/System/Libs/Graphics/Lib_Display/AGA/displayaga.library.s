	Incdir	"includes:"
	include "exec/types.i"
	include "exec/initializers.i"
	include "exec/libraries.i"
	include "exec/lists.i"
	include "exec/nodes.i"
	include "exec/resident.i"
	include "libraries/dos.i"
	include "exec/alerts.i"
;	Include "exec/exec_lib.i"
	include	"exec/exec.s"

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
Revision       equ 0                 ;Révision de la Library
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

LibName:       dc.b 'displayaga.library',0
idString:      dc.b 'displayaga.library',13,10,0
               dc.b '680x0 Version '
			   dc.b '(11 Avril 00) ',0
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

	Dc.l	InitRESERVED
	Dc.l	L_AGS_DISPLAY
	Dc.l	L_WB_DISPLAY
	Dc.l	L_AGS_WAITVBL
	Dc.l	L_AGS_SCREEN
	Dc.l	L_AGS_SETCOLOR
	Dc.l	L_AGS_COPPER
	Dc.l	L_REFRESH_COPPER
	Dc.l	L_SCREEN_OFFSET
	Dc.l	DISPLAYYSIZE

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

; ***********************************************************************
;Ici commencent les fonctions personnelles de librairie.
;Les fonctions reproduites ici sont destinées uniquement à servir
;d'exemple pour la créations de librairies personnelles et ne jouent
;aucun rôle particulier
; ***********************************************************************
;AllocMem		= -198	; [Take] (D0=ByteSize,D1=Requirements) (D0=MemoryBlock)
AllocAbs		= -204	; [Take] (D0=ByteSize,A1=Location) (D0=MemoryBlock)
;FreeMem		= -210	; [Free] (D0=ByteSize,A1=MemoryBlock)
OldOpenLibrary	= -408	; [Load] (D0=Version,A1=LibName) (D0=LibraryBase)
CloseLibrary	= -414	; [Close] (A1=LibraryBase) ()

COP1LCH		Equ	$DFF080
COP2LCH		Equ	$DFF084
COP1JMP		Equ	$DFF086
COP2JMP		Equ	$DFF088
;StartList	Equ	36

; Adresses utiles dans la copper list.
; Par rapport à l'adresse de base SCREEN dans la copper list.
C_BPL0PTH	Equ	2
C_BPL1PTH	Equ	10
C_BPL2PTH	Equ	18
C_BPL3PTH	Equ	26
C_BPL4PTH	Equ	34
C_BPL5PTH	Equ	42
C_BPL6PTH	Equ	50
C_BPL7PTH	Equ	58
;
C_DIWSTRT	Equ	66+4
C_DIWSTOP	Equ	70+4
C_DDFSTRT	Equ	74+4
C_DDFSTOP	Equ	78+4
;
C_BPL1MOD	Equ	82+4
C_BPL2MOD	Equ	86+4
;
C_BPLCON0	Equ	90+4
C_BPLCON1	Equ	94+4
C_BPLCON2	Equ	98+4
C_BPLCON3	Equ	102+4
;
; ***************************************************************
;				A0=LibBaseList		/	D0=Num
;				A1=AmigaGSBaseList	/	D1=Num
InitRESERVED:
Initialisation:
	Include	"AmigaGS Dev:System/Libs/InitLib.s"

	Rts
;
; ***************************************************************

;
; ****************************************************************
; *                                                              *
; * CREATION DE COPPER LIST AGA ET MISE EN VISUALISATION         *
; *                                                              *
; ****************************************************************
;
L_AGS_DISPLAY:
; ****************************************************************
	Move.l	$4,a6
;
; 1> On Sauvegarde les adresses copper list du workbench :
;---------------------------------------------------------
;
	Lea.l	GraphicsBase,a0
	Move.l	(a0),a1
	Lea.l	OldCopper,a0
	Move.l	$26(a1),(a0)+		; D0=Old Copper 1
	Move.l	$32(a1),(a0)		; D1=Old Copper 2
;
	Jsr		CloseLibrary(a6)

; 2> On crée notre copper list 256 couleurs :
;--------------------------------------------
; Pour le moment , elle sera de 256couleurs en noir.
; Aucun écran n'est représenté mais les registres sont crées.
; ----------------------------------------------------------------
; ----------------------------------------------------------------
; A> ALLOCATION MéMOIRE POUR LA COPPER LIST EN CHIP-RAM.
	Move.l	#16384,d0
	Move.l	#$10002,d1
	Move.l	$4,a6
	Jsr		_LVOAllocMem(a6)
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
;
	Lea.l	SPRITES,a1
	Move.l	a0,(a1)
;
	Move.w	#$0120,d0
cs1:
	Move.w	d0,(a0)+
	Clr.w	(a0)+
	Add.w	#$2,d0
	Cmp.w	#$0140,d0
	Bne.s	cs1
;
; ----------------------------------------------------------------
; ----------------------------------------------------------------
; C> CREATION DE LA COPPER LIST // COLOR PALETTE DEFINITION :
	Move.l	#$1803FFFE,(a0)+
;
	Lea.l	PALETTE1,a1
	Move.l	a0,(a1)
;
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
;
	Lea.l	PALETTE2,a1
	Move.l	a0,(a1)
;
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
; D> CREATION DE LA COPPER LIST // ECRAN à VISUALISER.
	Move.l	#$3103FFFE,(a0)+	; Start at Y=48
;	Move.l	#$00960100,(a0)+	; DMACON Pour l'amos ?!?
;
	Lea.l	SCREEN,a1
	Move.l	a0,(a1)
;
; Install 8 bitsplanes.
	Move.w	#$00E0,d0		; Bpl0PTH
cs6:
	Move.w	d0,(a0)+
	Clr.w	(a0)+
	Add.w	#$0002,d0
	Cmp.w	#$0100,d0
	Bne.s	cs6
	Move.l	#$3203FFFE,(a0)+
; Others registers to define.
	Move.l	#$008E0181,(a0)+	; DIWSTRT	???
	Move.l	#$009037C1,(a0)+	; DIWSTOP	???
	Move.l	#$00920038,(a0)+	; DDFSTRT =38 no scrl,=30 scroll.
	Move.l	#$009400D0,(a0)+	; DDFSTOP
	Move.l	#$01080000,(a0)+	; BPL1MOD
	Move.l	#$010A0000,(a0)+	; BPL2MOD
;
;		BPLCON REGISTERS.
	Move.l	#$01000000,(a0)+	; BPLCON0
	Move.l	#$01020000,(a0)+	; BPLCON1
	Move.l	#$01040000,(a0)+	; BPLCON2 $0224
	Move.l	#$01060000,(a0)+	; BPLCON3=$1000 pour 2nd pf palette.
	Move.l	#$3303FFFE,(a0)+
; Start screen displaying:
;	Move.l	#$00968300,(a0)+
; Fin de la copper list.
;
; Copper END Position.
	Lea.l	COPPEREND,a1
	Move.l	a0,(a1)
;
	Move.l	#$F203FFFE,(a0)+
	Move.l	#$01000000,(a0)+	; DMACON Pour l'amos ?!?
;	Move.l	#$00960100,(a0)+
	Move.l	#$F303FFFE,(a0)+
	Move.l	#$FFFFFFFE,(a0)+
;
; ****************************************************************
;
; 3> On active notre copper list :
;---------------------------------
	Lea.l	CopperBase,a0
	Move.l	(a0),d0
	Move.l	d0,COP1LCH
_NotEnoughMemory1:
	Rts
;
; ****************************************************************
; *                                                              *
; * RETOUR AU DISPLAY DU WORKBENCH OU DE L'AMOS SELON L'ORIGINE  *
; *                                                              *
; ****************************************************************
;
L_WB_DISPLAY
	Lea.l	OldCopper,a0
	Move.l	(a0)+,d0
	Move.l	(a0),d1
	Tst.l	d0
	Beq.b	_NoChanges
	Move.l	d0,COP1LCH
	Move.l	d1,COP2LCH
;	Move.w	#$8300,$DFF096

; 5> On libère la mémoire utilisée par la copper list :
;------------------------------------------------------
	Lea.l		CopperBase,a0
	Move.l	(a0),a1
	Clr.l	(a0)
	Move.l	#16384,d0
	Move.l	$4,a6
	Jsr		_LVOFreeMem(a6)
	Moveq.l	#0,d0
;
_NoChanges:
	Rts
;
; ****************************************************************
; *                                                              *
; * SIMPLE ROUTINE D'ATTENTE GRAPHIQUE POUR LE BALAYAGE HORIZ.   *
; *                                                              *
; ****************************************************************
;
L_AGS_WAITVBL
;	Move.l	$DFF004,d0
	Cmp.l	#300,($DFF004)
	Blt.b	L_AGS_WAITVBL

	Rts
;
; ****************************************************************
; *                                                              *
; * MISE EN PLACE D'UN ECRAN AGA DANS LA COPPER LIST.            *
; *                                                              *
; ****************************************************************
;	In	:	A0=ScreenBase
L_AGS_SCREEN:
;	Tst.l	a0
;	Beq.b	_NoScreen
	Move.l	a0,a2
;
	Lea.l	ScreenBase,a1
	Move.l	a0,(a1)
;
	Lea.l	SCREEN,a0
	Move.l	(a0),a1			; A1=Screen In Copper !!!
;
	move.w	#$0038,C_DDFSTRT(a1)	; Scroll value initial.
;
	Movem.w	(a2,76),d0/d1/d2	; D0=XSize/D1=YSize/D2=Depth
; Calcul des modulos.
	Sub.w	#320,d0			; x-320
	Lsr.w	#3,d0			; x/8
	Move.w	d0,C_BPL1MOD(a1)
	Move.w	d0,C_BPL2MOD(a1)
; Calcul du nombre de bits plans.
	Lea.l	BPLCONF,a0		; A0=BPLCONF filter list for bplanes.
	Lsl.w	#1,d2
	Add.w	d2,a0
	Move.w	(a0),C_BPLCON0(a1)
;	Move.w	#$0010,C_BPLCON0(a1)
; Mise en place des bits plans.
	Moveq.w	#C_BPL0PTH,d0
	Subq.b	#1,d2
as_bcl:
	Move.w	(a2)+,(a1,d0.w)
	Addq.b	#4,d0
	Subq.b	#1,d2
	Bpl.b	as_bcl
_NoScreen:
	Rts
;
; ****************************************************************
; *                                                              *
; * DEFINITION D'UNE COULEUR AGA 24 BITS.                        *
; *                                                              *
; ****************************************************************
;	In	:	D0=Register / D1=Rouge / D2=Vert / D3=Bleu
L_AGS_SETCOLOR
	Move.w	d1,d4
	Move.w	d2,d5
	Move.w	d3,d6		; D4=Rouge / D5=Vert / D6=Bleu
	And.w	#$F0,d1
	And.w	#$F0,d2
	And.w	#$F0,d3
	Lsl.w	#4,d1
	Lsr.w	#4,d3
	Or.w	d2,d1
	Or.w	d3,d1		; D1.W=Couleur RVB bits de poids forts.
	And.w	#$F,d4
	And.w	#$F,d5
	And.w	#$F,d6
	Lsl.w	#8,d4
	Lsl.w	#4,d5
	Or.w	d6,d4
	Or.w	d5,d4		; D2.W=Couleur RVB bits de poids faible.
	Move.w	d4,d2
;
	Move.w	d0,d7
	Lsr.w	#5,d7		; D3=COULEUR/32 ( blocs de 32 couleurs.)
	Mulu.w	#132,d7		; *132 Car 132bytes définissent 32 couleurs.
;
	And.w	#$1F,d0
	Mulu.w	#4,d0		; Car 4bytes définissent 1 couleur.
	Add.w	#6,d0
	Add.w	d7,d0
;
	Lea.l	PALETTE1,a0
	Move.l	(a0),a1
	Adda.l	d0,a1
	Lea.l	PALETTE2,a0
	Move.l	(a0),a2
	Adda.l	d0,a2
	Move.w	d1,(a1)
	Move.w	d2,(a2)
	Rts
;
;
; ****************************************************************
; *                                                              *
; * ADRESSE DE COPPER LIST.                                      *
; *                                                              *
; ****************************************************************
;	Out	:	D0=CopperBase
L_AGS_COPPER
	Lea.l	CopperBase,a0
	Move.l	(a0),d0
	Rts
;
; ****************************************************************
; *                                                              *
; * MISE à JOUR DE LA COPPER LIST SI MODIFIé.                    *
; *                                                              *
; ****************************************************************
L_REFRESH_COPPER
	Lea.l	CopperBase,a0
	Move.l	(a0),COP1LCH
	Rts
;
;
; ****************************************************************
; *                                                              *
; * SCREEN OFFSET DE L'éCRAN VISIBLE.                            *
; *                                                              *
; ****************************************************************
;	In	:	D0=XOffset / D1=YOffset
L_SCREEN_OFFSET
	Move.l	d1,d2
	Lea.l	ScreenBase,a0
	Move.l	(a0),a1			; A1=Screen base.
	Clr.l	d3
	Move.w	76(a1),d3		; D3=X-PIXELS SCREEN SIZE.
	Move.l	d3,d5
	Lsr.l	#3,d3			; D3=X-BYTES  SCREEN SIZE.
	Bclr	#0,d3
	Mulu.l	d2,d3			; D3=Ajout pur la bonne ligne.
	Move.l	d0,d1
	And.l	#$F,d0
	And.l	#$FFFFFFF0,d1
	Lsr.l	#3,d1			; D0=Scrolling OFFSET. 0<=D0<=15
	Add.l	d1,d3			; D3=AJOUT FINAL PUR SCROLLING.
;
	Lea.l	SCREEN,a0
	Move.l	(a0),a2			; A2=SCREEN IN COPPER.
;
	Sub.w	#320,d5
	Lsr.w	#3,d5			; Calcul des modulos

	Tst.w	d0
	beq.s	so2
	Moveq.w	#16,d1
	Sub.w	d0,d1
	Move.w	d1,d0
	Lsl.w	#4,d0
	Or.w	d1,d0
	move.w	#$0030,C_DDFSTRT(a2)	; Scroll value SCROLLING ON.
	Subq	#1,d5
	Bra.b	so3
so2:
	move.w	#$0038,C_DDFSTRT(a2)	; Scroll value initial.
;	Addq.l	#2,d3
so3:
; Use D0,D3,A1
	Move.w	d5,C_BPL1MOD(a2)
	Move.w	d5,C_BPL2MOD(a2)
	Move.w	d0,C_BPLCON1(a2)
;
	Moveq	#7,d1			; D1=MAX 8 BITS PLANES.
so1:
	Move.l	(a1)+,d2
	Add.l	d3,d2
	Move.w	d2,6(a2)
	Swap	d2
	Move.w	d2,2(a2)
	Add.l	#8,a2
	Subq	#1,d1
	bpl.s	so1
	Rts

;
; ****************************************************************
; *                                                              *
; * SCREEN Y SIZE DE L'éCRAN VISIBLE.                            *
; *                                                              *
; ****************************************************************
;
DISPLAYYSIZE:
	Add.l	#$32,d0			; D0=YSTART SCREEN+YSIZE.
	Lea.l	COPPEREND,a1
	Move.l	(a1),a0
	Cmp.l	#$FF,d0
	Bgt.b	SUPERIOR
INFERIOR:
	Move.l	#$0003FFFE,(a0)
	Move.b	d0,(a0)
	Add.l	#4,a0
	Move.l	#$01000000,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$FF03FFFE,(a0)+
	Move.l	#$FFFFFFFE,(a0)+
	Rts
SUPERIOR:
	Move.l	#$FFD9FFFE,(a0)+
	Sub.l	#$FF,d0
	Move.l	#$0103FFFE,(a0)+
	Move.l	#$0003FFFE,(a0)+
	Move.b	d0,(a0)
	Add.l	#4,a0
	Move.l	#$01000000,(a0)+	; DMACON Pour l'amos ?!?
	Move.l	#$FFFFFFFE,(a0)+
	Rts

;
; ****************************************************************
; *                                                              *
; * LISTE DES VARIABLES EN MéMOIRE.                              *
; *                                                              *
; ****************************************************************
;-------------------------
;
CopperBase:
	Dc.l	0		; New copper list 1 base offset.
OldCopper:
	Dc.l	0,0
SPRITES:
	Dc.l	0
PALETTE1:
	Dc.l	0
PALETTE2:
	Dc.l	0
SCREEN:
	Dc.l	0
COPPEREND:
	Dc.l	0
ScreenBase:
	Dc.l	0
BPLCONF:
	Dc.w	$0000,$1000,$2000,$3000
	Dc.w	$4000,$5000,$6000,$7000
	Dc.w	$0010						; De 0 à 8 bits plans.
EndCode:
	Dc.b	"Amiga Game Studio Development : DisplayAGA library / "
	Dc.b	"Version 1.0 by Frederic Cordier / "
	Dc.b	"On 11.04.00"
   END

