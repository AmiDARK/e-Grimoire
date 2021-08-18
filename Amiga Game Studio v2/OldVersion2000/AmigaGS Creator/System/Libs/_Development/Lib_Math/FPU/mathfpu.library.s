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

	opt p=68040

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

LibName:       dc.b 'mathfpu.library',0
idString:      dc.b 'math.library Ver1.0 '
               dc.b '68881/82 & 68040/60 Version '
			   dc.b '(02 Avril 00) ',13,10,0
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
	Dc.l	mf_flt
	Dc.l	mf_fix
	Dc.l	mf_abs
	Dc.l	mf_int
	Dc.l	mf_add
	Dc.l	mf_sub
	Dc.l	mf_mul
	Dc.l	mf_div
	Dc.l	mf_cmp
	Dc.l	mf_neg
	Dc.l	mf_tst
	Dc.l	mf_cos
	Dc.l	mf_sin
	Dc.l	mf_tan
	Dc.l	mf_sincos
	Dc.l	mf_acos
	Dc.l	mf_asin
	Dc.l	mf_atan
	Dc.l	mf_sqrt
	Dc.l	mf_cosh
	Dc.l	mf_sinh
	Dc.l	mf_tanh
	Dc.l	mf_log10
	Dc.l	mf_log2
	Dc.l	mf_logn
	Dc.l	mf_lognp1
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
            bsr Expunge                    ;supprime Library
s2:         rts                            ;retour
;Routine pour supprimer la librairie de la mémoire.
;>= A6 = Pointeur sur Library
;=> D0 = Pointeur sur liste des segments de la Library chargée
Expunge:
            movem.l d1/a5-a6,-(a7)         ;sauver les registres
            move.l a6,a5                   ;Pointeur sur Library vers A5
            move.l ml_SysLib(a5),a6        ;ExecBase vers  A6
            tst.w LIB_OPENCNT(A5)          ;Library encore utilisée?
            beq s3                         ;Saut si non utilisée
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
mf_flt:
	FMove.l	d0,fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_fix:
	FMove.s	d0,fp0
	FMove.l	fp0,d0
	Rts
; ***********************************************************************
mf_abs:
	FMove.s	d0,fp0
	FAbs	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_int:
	FMove.s	d0,fp0
	FInt	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_add:
	FMove.s	d0,fp0
	Fmove.s	d1,fp1
	FAdd	fp1,fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_sub:
	FMove.s	d0,fp0
	Fmove.s	d1,fp1
	FSub	fp1,fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_mul:
	FMove.s	d0,fp0
	Fmove.s	d1,fp1
	FMul	fp1,fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_div:
	FMove.s	d0,fp0
	Fmove.s	d1,fp1
	Fdiv	fp1,fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_cmp:
	FMove.s	d0,fp0
	FMove.s	d1,fp1
	FCmp	fp1,fp0
	Rts
; ***********************************************************************
mf_neg:
	FMove.s	d0,fp0
	FNeg	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_tst:
	FMove.s	d0,fp0
	FTst	fp0
	Rts
; ***********************************************************************
mf_cos:
	FMove.s	d0,fp0
	FCos	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_sin:
	FMove.s	d0,fp0
	FSin	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_tan:
	FMove.s	d0,fp0
	FTan	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_sincos:
	FMove.s	d0,fp0
	FSinCos	fp0,fp0:fp1
	FMove.s	fp0,d0
	FMove.s	fp1,d1
	Rts
; ***********************************************************************
mf_acos:
	FMove.s	d0,fp0
	FaSin	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_asin:
	FMove.s	d0,fp0
	FaSin	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_atan:
	FMove.s	d0,fp0
	FaTan	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_sqrt:
	FMove.s	d0,fp0
	Fsqrt	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_cosh:
	FMove.s	d0,fp0
	FCosH	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_sinh:
	FMove.s	d0,fp0
	FSinH	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_tanh:
	FMove.s	d0,fp0
	FTanH	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_log10:
	FMove.s	d0,fp0
	FLog10	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_log2:
	FMove.s	d0,fp0
	FLog2	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_logn:
	FMove.s	d0,fp0
	FLogn	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************
mf_lognp1:
	FMove.s	d0,fp0
	FLognp1	fp0
	FMove.s	fp0,d0
	Rts
; ***********************************************************************

