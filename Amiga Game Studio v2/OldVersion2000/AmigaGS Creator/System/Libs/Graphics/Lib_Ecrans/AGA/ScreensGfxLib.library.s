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
;	include	"exec/exec.s"

;	include	"graphics/graphics_lib.i"
;	include	"graphics/graphics.h"
	Include	"LVOs.i"

	Include	"Includes:_Chips.s"
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
GfxCall	MACRO
		Lea.l	GraphicsBase,a6
		Move.l	(a6),a6
		Jsr		\1(a6)
	EndM

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
Revision       equ 1                 ;Révision de la Library
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

LibName:       dc.b 'screensgfxlib.library',0
idString:      dc.b 'screens.library 1.0 Graphics.Library Version '
			   dc.b '(31 Aout 2000)',13,10,0
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
			Dc.l	ScreenOpen
			Dc.l	ScreenClose
			Dc.l	ScreenBase
			Dc.l	Screen
			Dc.l	CurrentBase
			Dc.l	ScreenClear
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
            lea DosName,a1                  ;Pointeur sur le nom DOS
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

;
;
; ***************************************************************
;				A0=LibBaseList		/	D0=Num
;				A1=AmigaGSBaseList	/	D1=Num
InitRESERVED:
Initialisation:
	Include	"AmigaGS Crt:System/Libs/InitLib.s"
	Rts
;
;
; ***************************************************************
; *									   							*
; * CREATION D'UN ECRAN ECS/AGA						   			*
; *									 						  ok*
; ***************************************************************
ScreenOpen:
;	D0=Screen number
;	D1=Screen X Size
;	D2=Screen Y Size
;	D3=Screen Depth ( how namy bits-planes are used 1-8 for AGA )
;	D4=Screen Type ( contain:DPF/EHB/HAM/Lowres/Hires/SHires/etc.. )
;							D4 is unused for the moment !!!
;
;
; Sauvegarde données.
	Lea.l	DatSave,a0
	Movem.l	d0/d1/d2/d3/d4,(a0)
;
; Corrupted entries ?
	Tst.b	d0
	Blt.b	BadEntries
	Cmpi.l	#7,d0
	Bgt.b	BadEntries
	Lea.l	SCRNOPEN,a0
	Tst.b	(a0,d0)
	Bne.b	ScreenEvenOpened
;
; On crée l'écran bitmap demandé.
	Lea.l	DatSave+4,a0
	Movem.l	(a0),d0/d1/d2	; X,Y,Depth
;	Move.l	#BMF_CLEAR+BMGM_INTERLEAVED,d3	; FLAGS *
	Move.l	#0,a0		; No Friend_Bitmap.
	GfxCall	_LVOAllocBitMap



	Rts
DatSave:	Dc.l	0,0,0,0,0
BadEntries:
ScreenEvenOpened:
	Rts
; **************************************************************************
; *									   *
; * FERMER UN ECRAN CREE AVEC L_FXSCREENOPEN				   *
; *									 ok*
; **************************************************************************
ScreenClose:
;	D0=Screen number
;
	Tst.l	d0
	Blt.b	L5IC
	Cmpi.l	#7,d0
	Bgt.b	L5IC
	Lea		SCRNOPEN,a0
	Add.l	d0,a0
	Move.b	(a0),d1
	Clr.b	(a0)
	Cmp.b	#$ff,d1
	Bne.b	L5SC
	Lea		SCRNBASE,a0
	Lsl.l	#2,d0
	Add.l	d0,a0
	Move.l	(a0),a1		; A1=Screen base
	Lea		SCRNCURRENT,a2
	Move.l	(a2),a3
	Cmpa.l	a1,a3
	Bne.b	L5B1
	Clr.l	(a2)
L5B1
	Clr.l	(a0)
	Move.l	a1,a0
	Add.l	#68,a0
	Move.b	(a0),d0
	Cmp.b	#0,d0
	Bne.b	L5DBuf
	Sub.l	#4,a0		; Base+64 (Screen memory length).
	Move.l	(a0),d0		; D0=Length.
	ExecC	FreeMem
	Rts
L5IC
	Moveq	#3,d0
	Rts
L5SC
	Moveq	#4,d0
	Rts
L5DBuf	
; Mode DOUBLE BUFFER non géré pour le moment .
	Rts
;
;
; ***************************************************************
; *									   							*
; * RENVOIE LA BASE DE L'ECRAN EN COURS SI CE DERNIER EXISTE	*
; *									   							*
; ***************************************************************
ScreenBase:
;
	Cmpi.l	#7,d0
	Bgt.b	L6SN0
	Tst.l	d0
	Blt.b	L6SN0
;
	Lea		SCRNBASE,a1
	Lsl.l	#2,d0
	Add.l	d0,a1
	Move.l	(a1),a0
	Rts
L6SN0
	Moveq	#4,d0
	Rts
;
; ***************************************************************
; *									   							*
; * CHANGE D'ECRAN COURANT										*
; *									   							*
; ***************************************************************
Screen:
	Cmpi.l	#7,d0
	Bgt.b	L6SN0
	Tst.l	d0
	Blt.b	L6SN0
;
	Lea.l	SCRNBASE,a1
	Lsl.l	#2,d0
	Add.l	d0,a1
	Move.l	(a1),d0
	Tst.l	d0
	Beq.b	L6SN0
	Lea.l	SCRNCURRENT,a0
	Move.l	d0,(a0)
	Rts
CurrentBase:
	Lea.l	SCRNCURRENT,a1
	Move.l	(a1),a0
	Rts
;
;
; Screen Clear Using Blitter.
ScreenClear:
	Lea.l	SCRNCURRENT,a1
	Move.l	(a1),a0
	Tst.l	a0
	Beq.b	NOSCREEN
	Move.l	#5,d7		; D7=6 bits plans au maximum.
	Clr.l	d1
	Clr.l	d2
	Move.w	(a0,76),d1	; D1=X Screen Size.
	Move.w	(a0,78),d2		; D2=Y Screen Size.
	Divu.l	#16,d1		; D1=X Screen .W Size.
	Mulu.l	#64,d2		; D2=Y Size*64
	Add.l	d1,d2		; D2=Y Size*64 + X Size.
;bcx	Move.l	(a0),d0
bcx
	Tst.l	(a0)
	Beq.b	bcz		; Plus de bits plans a utiliser.
; Blitter Occupe ???
_bcp
	Move.w	$Dff002,d5
	Btst	#14,d5
	Bne.b	_bcp
; Mise de BLITTER en mode FILL CARRY IN.
_bc2
	Move.w	#$0,BLTCON1		; Origin=#$4
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
NOSCREEN:
	Rts


;
; ***************************************************************
; *									   							*
; * Base de données.								   			*
; *									 						  ok*
; ***************************************************************
;
; GESTION DES ECRANS ECS/AGA.
SCRNOPEN	Dc.b	0,0,0,0,0,0,0,0	; Ecrans crees (0=non)
SCRNBASE	Dc.l	0,0,0,0,0,0,0,0	; Adresse de base des ecrans.
SCRNCURRENT	Dc.l	0		; '' '' '' '' '' 'de l'ecran en cours
CAS			Dc.l	0
