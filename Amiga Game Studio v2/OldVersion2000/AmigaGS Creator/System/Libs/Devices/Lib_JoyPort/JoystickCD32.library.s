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

LibName:       dc.b 'joystick_cd32.library',0
idString:      dc.b 'joystick_cd32.library Ver1.0 '
               dc.b '680x0 Version '
			   dc.b '(04 Avril 00) ',13,10,0
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
	Dc.l	_joy0state
	Dc.l	_joy1state
	Dc.l	_joy0fire1state
	Dc.l	_joy0fire2state
	Dc.l	_joy0fire3state
	Dc.l	_joy1fire1state
	Dc.l	_joy1fire2state
	Dc.l	_joy1fire3state
	Dc.l	_arrowkeysstate
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
            bsr.w Expunge                    ;supprime Library
s2:         rts                            ;retour
;Routine pour supprimer la librairie de la mémoire.
;>= A6 = Pointeur sur Library
;=> D0 = Pointeur sur liste des segments de la Library chargée
Expunge:
            movem.l d1/a5-a6,-(a7)         ;sauver les registres
            move.l a6,a5                   ;Pointeur sur Library vers A5
            move.l ml_SysLib(a5),a6        ;ExecBase vers  A6
            tst.w LIB_OPENCNT(A5)          ;Library encore utilisée?
            beq.w s3                         ;Saut si non utilisée
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
; ***********************************************************************
;Ici commencent les fonctions personnelles de librairie.
;Les fonctions reproduites ici sont destinées uniquement à servir
;d'exemple pour la créations de librairies personnelles et ne jouent
;aucun rôle particulier
; ***********************************************************************
;				A0=LibBaseList		/	D0=Num
;				A1=AmigaGSBaseList	/	D1=Num
InitRESERVED:
Initialisation:
	Include	"AmigaGS Dev:System/Libs/InitLib.s"

	Rts
;
; ***************************************************************


; ***********************************************************************
ASP			= $bfec01
ATAL0		= $bfe401
CIAAPRA		= $bfe001	; Bouton 1 Souris[#06] Et Feu 1 Manette[#07]
JOY0DAT		= $dff00a
JOY1DAT		= $dff00c
POTGOR		= $dff016	; Adresse Boutons De Feux [Bits:#10=Mouse2,#08=Mouse3,#14=Fire2,#12=Fire3]
; ***********************************************************************
_joy0state:
	Sub.l	d1,d1
	Move.w	JOY0DAT,d1
	Move.l	d1,d2
	Lsr.l	#2,d2
	Lsl.l	#2,d2
	Move.l	d1,d3
	Sub.l	d2,d3		; D3 = Bits 0 And 1
	Move.l	d1,d2
	Lsr.l	#5,d2
	Lsr.l	#5,d2
	Lsl.l	#5,d2
	Lsl.l	#5,d2
	Sub.l	d2,d1		; D1 = Bits 8 And 9
	Lsr.l	#4,d1
	Lsr.l	#4,d1		; D1 = Bits 8 and 9 in 0 and 1
	Move.l	#0,d0
	Cmp.b	#1,d3
	Bne.B	rj01
	Move.l	#2,d0
rj01:	Cmp	#2,d3
	Bne.B	rj02
	Move.l	#10,d0
rj02:	Cmp	#3,d3
	Bne.B	rj03
	Move.l	#8,d0
rj03:	Cmp	#1,d1
	Bne.B	rj04
	Add.l	#1,d0
rj04:	Cmp	#2,d1
	Bne.B	rj05
	Add.l	#5,d0
rj05:	Cmp	#3,d1
	Bne.B	rj06
	Add.l	#4,d0
rj06:
	Rts
; ***********************************************************************
_joy1state:
	Move.l	#0,d1
	Move.w	JOY1DAT,d1
	Move.l	d1,d2
	Lsr.l	#2,d2
	Lsl.l	#2,d2
	Move.l	d1,d3
	Sub.l	d2,d3		; D3 = Bits 0 And 1
	Move.l	d1,d2
	Lsr.l	#5,d2
	Lsr.l	#5,d2
	Lsl.l	#5,d2
	Lsl.l	#5,d2
	Sub.l	d2,d1		; D1 = Bits 8 And 9
	Lsr.l	#4,d1
	Lsr.l	#4,d1		; D1 = Bits 8 and 9 in 0 and 1
	Move.l	#0,d0
	Cmp	#1,d3
	Bne.B	rj11
	Move.l	#2,d0
rj11:	Cmp	#2,d3
	Bne.B	rj12
	Move.l	#10,d0
rj12:	Cmp	#3,d3
	Bne.B	rj13
	Move.l	#8,d0
rj13:	Cmp	#1,d1
	Bne.B	rj14
	Add.l	#1,d0
rj14:	Cmp	#2,d1
	Bne.B	rj15
	Add.l	#5,d0
rj15:	Cmp	#3,d1
	Bne.B	rj16
	Add.l	#4,d0
rj16:
	Rts
; ***********************************************************************
_joy0fire1state:
	sub.l	d0,d0
	Btst	#06,CIAAPRA
	Bne.B	Retc1
	Moveq.b	#1,d0
Retc1:	Rts
;------------------------------------------------------------------;
_joy0fire2state:
	sub.l	d0,d0
	Btst	#2,POTGOR-1
	Bne.B	Retc2
	Moveq.b	#1,d0
Retc2:	Rts
;------------------------------------------------------------------;
_joy0fire3state:
	sub.l	d0,d0
	Btst	#00,POTGOR-1
	Bne.B	Retc3
	Moveq.b	#1,d0
Retc3:	Rts

;------------------------------------------------------------------;
_joy1fire1state:
	sub.l	d0,d0
	Btst	#07,CIAAPRA
	Bne.b	Retf1
	Moveq.b	#1,d0
Retf1:	Rts
;------------------------------------------------------------------;
_joy1fire2state:
	sub.l	d0,d0
	Btst	#6,POTGOR-1
	Bne.b	Retf2
	Moveq.b	#1,d0
Retf2:	Rts
;------------------------------------------------------------------;
_joy1fire3state:
	sub.l	d0,d0
	Btst	#02,POTGOR
	Bne.b	Retf3
	Moveq.b	#1,d0
Retf3:	Rts
; ***********************************************************************
_arrowkeysstate:
		Move.b	ASP,d0
		Move.w	d0,d1
		Sub.l	d0,d0
		Cmp.w	#103,d1
		Bne.B	Aku2
		Moveq.b	#1,d0
Aku2:	Cmp.w	#101,d1
		Bne.B	Aku3
		Moveq.b	#2,d0
Aku3:	Cmp.w	#97,d1
		Bne.B	Aku4
		Moveq.b	#4,d0
Aku4:	Cmp.w	#99,d1
		Bne.B	Aku5
		Moveq.b	#8,d0
Aku5:
		Rts	; Value : 0=Null 1=Haut 2=Bas 4=Gauche 8 Droite
; ***********************************************************************
