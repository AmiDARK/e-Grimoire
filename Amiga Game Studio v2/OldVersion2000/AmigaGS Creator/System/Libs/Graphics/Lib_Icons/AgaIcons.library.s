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

	Include	"AmigaGS Crt:System/Libs/Graphics/Lib_Icons/Dos.i"
	Include	"AmigaGS Dev:Includes/AmigaGSIncludeList.i"
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

LibName:       dc.b 'agaicons.library',0
idString:      dc.b 'agaicons.library Ver1.1r2 '
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
			Dc.l	_InitRESERVED
			Dc.l	__ReserveIcons
			Dc.l	__EraseIcons
			Dc.l	__GetIcon
			Dc.l	__PasteIcon
			Dc.l	__LoadIcons
			Dc.l	__SaveIcons
			Dc.l	__IconsBase
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

; Fonctions personnelles :
;
; ***************************************************************
;				A0=LibBaseList		/	D0=Num
;				A1=AmigaGSBaseList	/	D1=Num
_InitRESERVED:
Initialisation:
	Include	"AmigaGS Crt:System/Libs/InitLib.s"
	Rts
; ***************************************************************

;
;; Icons Data List...
ICC:	Dc.l	0,0,0	;X,Y,IC

_Icons	Dc.l	0	; Nombre d'icones au maximum.
_IcBase	Dc.l	0	; adresse de la banque d'icones.
_IcN	Dc.b	"                                                "
	Dc.b	"                                               ",0
	EVEN
_IHnd	Dc.l	0	; Icon File Handle.
_IcLoad	Dc.l	0,0,0,0	; Chargement des 8 octets des fichiers Icons.
_XY		Dc.l	$140,$C0	; X.l,Y.l Screen Sizes(320,192).
_BitsPlanes	Dc.l	0,0,0,0,0,0,0,0,0	; All 8 planes adresses.
_DName	Dc.b	"dos.library",0
	EVEN
_DBase	Dc.l	0	; Dos.Library Base.
;
; ***************************************************************
;
__ReserveIcons:
	Move.l	d0,d7		; D7=nombre d'icones.
	Lea.l	_Icons,a0
	Tst.l	(a0)
	Bne.b	_rie		; Si banque deja reservee.
	Move.l	d7,(a0)		; Save icon max.
	Mulu.l	#260,d7
	Add.l	#8,d7
	Move.l	d7,d0		; D0=Byte Size.
	Move.l	#$10004,d1	; D1=Memory : FAST for speed improvements.
	Move.l	$4,a6
	Jsr		_LVOAllocMem(a6)
	Lea.l	_IcBase,a0
	Move.l	d0,(a0)
	Tst.l	d0
	Beq.b	NOFREE
; Preparation de la banque d'icones.
	Move.l	d0,a0
	Lea.l	_Icons,a1
	Move.l	#"F.C1",(a0)+	; Offset #0 Equ "F.C1"
	Move.l	(a1),(a0)	; Offset #4 Equ IconMax.
	Rts
NOFREE
	Lea.l	_Icons,a0
	Clr.l	(a0)
	Move.l	#$FFFFFFEF,d0
	Rts
_rie
	Move.l	#$FFFFFFEE,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
__EraseIcons:
	Lea.l	_Icons,a2
	Move.l	(a2),d0
	Tst.l	d0
	Beq.b	_eie
	Clr.l	(a2)		; Clear _ICONS Register.
	Mulu.l	#260,d0
	Addq.l	#8,d0
	Lea.l	_IcBase,a2
	Move.l	(a2),a1
	Tst.l	a1
	Beq.b	ei
	Clr.l	(a2)	; Clear _ICBASE Register.
	Move.l	$4,a6
	Jsr		_LVOFreeMem(a6)
_eie:
	Rts
ei:
	Moveq	#$FFFFFFED,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
__GetIcon:
	Lea.l	ICC,a0
	Movem.l	d0-d2,(a0)
;
	LibCall	Screens,CurrentBase
	Cmp.l	#0,a0
	Beq.b	gi
	Move.l	a0,a1				; A1=SCREEN BASE
;
	Lea.l	ICC,a0
	Move.l	(a0)+,d6	; X
	Move.l	(a0)+,d7	; Y
	Move.l	(a0)+,d5	; ICON
; Verifications...
	Cmp.l	#1,d5
	Blt.b	_gie		; Icon<1.
	Lea.l	_Icons,a2
	Cmp.l	(a2),d5
	Bgt.b	_gie		; Icon>IconMax.
	Subq.l	#1,d5
;
	Lea.l	_IcBase,a2
	Move.l	(a2),a0
	Tst.l	a0
	Beq.b	gi
	Add.l	#8,a0
	Mulu.l	#260,d5
	Add.l	d5,a0		; A0=Adresse cible pout TAKE ICON.	
;
	Lea.l	_XY,a2
	Move.l	(a2),d4		; D4=X Scren Size.
	Lsr.l	#3,d4		; D4=RAJOUT PAR LIGNES.
	Mulu.l	d4,d7
	Lsr.l	#3,d6
	Add.l	d6,d7		; D7=RAJOUT AUX BITS PLANS.
;
	Move.l	a1,a2
	Move.l	#8,d6		; D6=8 bits plans.
_gi0:
	Move.l	(a2)+,a1	; A1=Adresse cible
	Tst.l	a1
	Beq.b	_gie		; Plus de bits plans a saisir ???
	Add.l	d7,a1
	Moveq.l	#16,d5		; D5=16 lignes par bobs.
;
_gi1:
	Move.w	(a1),(a0)+	; A0 -> Next Data.
	Add.l	d4,a1		; A1 -> Next Line.
	Subq.l	#1,d5
	Tst.l	d5
	Bne.b	_gi1
	Subq.l	#1,d6
	Tst.l	d6
	Bne.b	_gi0
;
_gie:
	Rts
gi:
	Moveq	#$FFFFFFEC,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
__PasteIcon:
	Lea.l	ICC,a0
	Movem.l	d0-d2,(a0)
;
	LibCall	Screens,CurrentBase
	Tst.l	a0
	Beq.b	gi
	Move.l	a0,a1				; A1=SCREEN BASE
;
	Lea.l	ICC,a0
	Movem.l	(a0)+,d6/d7	; X,Y
	Move.l	(a0)+,d5	; ICON
; Verifications...
	Cmp.l	#1,d5
	Blt.b	_pie		; Icon<1.
	Lea.l	_Icons,a2
	Cmp.l	(a2),d5
	Bgt.b	_pie		; Icon>IconMax.
	Subq.l	#1,d5
;
;
	Lea.l	_IcBase,a2
	Move.l	(a2),a0
	Tst.l	a0
	Beq.b	pii
	Addq.l	#8,a0
	Mulu.l	#260,d5
	Add.l	d5,a0		; A0=Adresse icone a PASTER.
;
	Sub.l	d4,d4
	Move.w	(a1,76),d4		; D4=X Screen Size.
;
	Lsr.l	#3,d4
	Lsr.l	#3,d6
	Mulu.l	d4,d7
	Add.l	d6,d7		; D7=RAJOUT AUX BITS PLANS.
;
	Move.l	a1,a2
	Move.w	(a1,80),d6		; D6=how many bits plans.
_pi0:
	Move.l	(a2)+,a1	; A1=Adresse cible
	Tst.l	a1
	Beq.b	_pie		; Plus de bits plans a saisir ???
	Add.l	d7,a1
	Moveq.l	#15,d5		; D5=16 lignes par bobs.
;
_pi1
	Move.w	(a0)+,(a1)	; A0 -> Next Data.
	Add.l	d4,a1		; A1 -> Next Line.
	Subq.b	#1,d5
;	Tst.l	d5
;	Bne.b	_pi1
	Bpl.b	_pi1
	Subq.b	#1,d6
	Tst.b	d6
	Bne.b	_pi0
;
_pie:
	Rts
pii:
	Moveq	#$FFFFFFEB,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
__IconsBase:
	Lea.l	_IcBase,a1
	Move.l	(a1),a0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
__SaveIcons:
;								A0=IconName
	Lea.l	_IcBase,a2
	Tst.l	(a2)
	Beq.b	NOTRESERVED
	Lea.l	_IcN,a1
; Mise en place du nom du fichier termine par '0' dans la zone reservee.
_si1:
	Move.b	(a0)+,(a1)+
	Tst.b	(a0)
	Bne.b	_si1
	Move.b	#$0,(a1)
;
	Move.l	$4,a6
	Lea.l	_DName,a1
	Clr.l	d0
	Jsr		_LVOOpenLibrary(a6)
	Lea.l	_DBase,a1
	Move.l	d0,(a1)
	Move.l	d0,a1
	Jsr		_LVOCloseLibrary(a6)
; Creation du fichier.
	Lea.l	_DBase,a0
	Move.l	(a0),a6		; A6=Dos Base.
	Lea.l	_IcN,a1		; D1=File Name.
	Move.l	a1,d1
	Move.l	#1006,d2	; D2=Write File.
	Jsr		DosOpen(a6)
	Lea.l	_IHnd,a0
	Move.l	d0,(a0)		; D0=Icon File Handle.
	Move.l	d0,d1		; D1=Handle.
	Lea.l	_Icons,a0
	Move.l	(a0),d3
	Mulu.l	#260,d3
	Addq.l	#8,d3		; D3=File Length to be written.
	Lea.l	_IcBase,a0
	Move.l	(a0),d2		; D2=Icon Bank Base.
	Jsr	DosWrite(a6)
	Lea.l	_IHnd,a0
	Move.l	(a0),d1
	Jsr		DosClose(a6)
_sie:
	Rts
NOTRESERVED
	Moveq	#$FFFFFFEA,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
__LoadIcons:
; Verifications.
	Lea.l	_IcN,a1
; Mise en place du nom du fichier termine par '0' dans la zone reservee.
_sii1::
	Move.b	(a0)+,(a1)+
	Tst.b	(a0)
	Bne.b	_sii1
	Move.b	#$0,(a1)
; Ouverture de la Dos.Library .
	Move.l	$4,a6
	Lea.l	_DName,a1
	Clr.l	d0
	Jsr		_LVOOpenLibrary(a6)
	Lea.l	_DBase,a1
	Move.l	d0,(a1)
	Move.l	d0,a1
	Jsr		_LVOCloseLibrary(a6)
; Lecture des 8 premier octets du fichier.
	Lea.l	_DBase,a0
	Move.l	(a0),a6		; A6=Dos Base.
	Lea.l	_IcN,a1		; D1=File Name.
	Move.l	a1,d1
	Move.l	#1005,d2	; D2=Read File.
	Jsr	DosOpen(a6)
	Lea.l	_IHnd,a0
	Move.l	d0,(a0)		; Sauvegarde du File Handle.
	Move.l	#8,d3		; D3=Length = 8 octets .
	Move.l	d0,d1		; D1=File Handle.
	Lea.l	_IcLoad,a0
	Move.l	a0,d2		; d2=Adress
	Jsr		DosRead(a6)
	Lea.l	_IcLoad,a0
	Cmp.l	#"F.C1",(a0)
	Bne.b	_NotIconFile	; Mauvais format.
; Fichier au format Icones.
	Add.l	#4,a0
	Move.l	(a0),d0
	Lea.l	_Icons,a0
	Move.l	d0,(a0)		; Sauvegarde du nombre d'icones du fichier.
	Mulu.l	#260,d0
	Add.l	#8,d0		; D0=Byte size needed.
	Move.l	#$10004,d1	; D1=Requirements.
	Move.l	$4,a6
	Jsr		_LVOAllocMem(a6)
	Tst.l	d0				; Not enough memory available ???
	Beq.b	_NotIconFile	; Pas assez de memoire pour le fichier.
	Lea.l	_IcBase,a0
	Move.l	d0,(a0)		; Save ICON BASE Adress.
	Move.l	d0,d7
	Lea.l	_DBase,a0
	Move.l	(a0),a6		; A6=DosBase.
	Lea.l	_IHnd,a0
	Move.l	(a0),d1		; D1=File Handle.
	Lea.l	_Icons,a0
	Move.l	(a0),d3
	Mulu.l	#260,d3		; D3=Longueur de chargement du reste.
	Move.l	d7,a1		; A1=Icon Adress.
	Move.l	#"F.C1",(a1)+	; Remise en place du header.
	Move.l	(a0),(a1)+	; Remise en place du nombre d'icones.
	Move.l	a1,d2		; D2=Adresse de chargement.
	Jsr		DosRead(a6)
	Lea.l	_IHnd,a0
	Move.l	(a0),d1
	Jsr		DosClose(a6)
	Rts
;
_NotIconFile
; Fermeture du fichier.
	Lea.l	_IHnd,a0
	Move.l	(a0),d1
	Lea.l	_DBase,a0
	Move.l	(a0),a6
	Jsr		DosClose(a6)
;
	Lea.l	_Icons,a0
	Move.l	#$0,(a0)
	Lea.l	_IcBase,a0
	Move.l	#$0,(a0)
	Moveq	#$FFFFFFE9,d0
	Rts
;
