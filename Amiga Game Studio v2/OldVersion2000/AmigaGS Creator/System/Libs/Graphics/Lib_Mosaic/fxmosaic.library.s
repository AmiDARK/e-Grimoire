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

	Include	"AmigaGS:Includes/AmigaGSIncludeList.i"

	opt p=68020

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

LibName:       dc.b 'fxmosaic.library',0
idString:      dc.b 'fxmosaic.library Ver1.0 '
               dc.b '680x0 Version '
			   dc.b '(03 Mai 00) ',13,10,0
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
			Dc.l	Initialisation
			Dc.l	CallMosaiques
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
; ***************************************************************
;				A0=LibBaseList		/	D0=Num
;				A1=AmigaGSBaseList	/	D1=Num
Initialisation:
	Include	"AmigaGS Dev:System/Libs/InitLib.s"

	Rts
;
_MosaicBase		Dc.l	0,0
_MosaicPlanes	Dc.l	0,0,0,0,0,0,0,0,0

; ***************************************************************
CallMosaiques:
	LibCall	Screens,CurrentBase
	Tst.l	a0
	Bne.b	_Continue
	Rts
_Continue:
	Cmp.b	#4,d0
	Blt.b	MOSAICx2
	Beq.w	MOSAICx4
	Cmp.b	#16,d0
	Blt.w	MOSAICx8
	Beq.w	MOSAICx16
	Bgt.w	MOSAICx32
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOSAICx2:
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	a0,d0		; D0=Screen Base.
	Lea.l	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	Lea.l	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#7,d1
_m1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_m1
; POSITIONNEMENT DES DONNEES.
	Lea.l	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#1,d7
	Lsl.l	#1,d7	; D7 Paire
	Lea.l	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_m2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq.b	_mend
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
_mend
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOSAICx4:
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	a0,d0		; D0=Screen Base.
	Lea.l	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	Lea.l	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#7,d1
_mb1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_mb1
; POSITIONNEMENT DES DONNEES.
	Lea.l	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#2,d7
	Lsl.l	#2,d7	; D7 Multiple de 4
	Lea.l	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_mb2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq.b	_mbend
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
_mbend
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOSAICx8:
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	a0,d0		; D0=Screen Base.
	Lea.l	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	Lea.l	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#7,d1
_mc1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_mc1
; POSITIONNEMENT DES DONNEES.
	Lea.l	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#3,d7
	Lsl.l	#3,d7	; D7 Multiple de 4
	Lea.l	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_mc2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq.b	_mcend
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
_mcend
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOSAICx16:
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	a0,d0		; D0=Screen Base.
	Lea.l	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	Lea.l	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#7,d1
_md1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_md1
; POSITIONNEMENT DES DONNEES.
	Lea.l	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#4,d7
	Lsl.l	#4,d7	; D7 Multiple de 4
	Lea.l	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_md2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq.b	_mdend
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
_mdend
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOSAICx32:
; SAVE SCREEN BASE IN DATA BANK.
	Move.l	a0,d0		; D0=Screen Base.
	Lea.l	_MosaicBase,a0
	Move.l	d0,(a0)
; TRANSFERT DES 6 BITS PLANES IN DATA BANK.
	Lea.l	_MosaicPlanes,a0
	Move.l	d0,a1
	Move.l	#7,d1
_me1	Move.l	(a1)+,(a0)+
	Sub.l	#1,d1
	Bpl	_me1
; POSITIONNEMENT DES DONNEES.
	Lea.l	_MosaicBase,a0
	Move.l	(a0),a1
	Add.l	#76,a1
	Clr.l	d6
	Move.w	(a1)+,d6		; D6=X SCREEN SIZE.
	Clr.l	d7
	Move.w	(a1)+,d7		; D7=Y SCREEN SIZE.
	Lsr.l	#5,d7
	Lsl.l	#5,d7	; D7 Multiple de 32
	Lea.l	_MosaicPlanes,a0	; A0=BASE DES BITS PLANS.
	Move.l	d6,d3
	Lsr.l	#3,d3			; D3=X OCTETS SCREEN SIZE.
; TESTE SI IL EXISTE UN AUTRE BIT PLAN.
_me2	Move.l	(a0)+,a1
	Cmp.l	#0,a1			; A1=CURRENT SCREEN LINE.
	Beq.b	_meend
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
_meend
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
