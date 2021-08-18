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

LibName:       dc.b 'cachectrl68030.library',0
idString:      dc.b 'cachectrl68030.library Ver1.0 '
               dc.b '68030 Version '
			   dc.b '(07 Mai 00) ',13,10,0
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
			Dc.l	DataCacheMode	; Enable/Disable (d0)
			Dc.l	InstCacheMode	; Enable/Disable (d0)
			Dc.l	ClearDataCache	;
			Dc.l	ClearInstCache
			Dc.l	DataBurstMode	; Enable/Disable (d0)
			Dc.l	InstBurstMode	; Enable/Disable (d0)
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

; **************************************************************
OldSysStack:	Dc.l	0


; ***************************************************************
;				A0=LibBaseList		/	D0=Num
;				A1=AmigaGSBaseList	/	D1=Num
Initialisation:
	Include	"AmigaGS Dev:System/Libs/InitLib.s"

	Rts

; Fonctions personnelles :
JpSupervisor	MACRO
		Move.l	$4,a6
		Jsr		_LVOSuperState(a6)
		Lea.l	OldSysStack,a0
		Move.l	d0,(a0)
		ENDM
JpUser		MACRO
		Move.l	$4,a6
		Lea.l	OldSysStack,a0
		Move.l	(a0),d0
		Jsr		_LVOUserState(a6)
		ENDM
; *******************************************************
DataCacheMode:
	Tst.l	d0
	Beq.b	DCM_Disable
DCM_Enable:
	JpSupervisor
	MoveC	CACR,d0
	Bset	#8,d0
	MoveC	d0,CACR
	JpUser
	Rts
DCM_Disable:
	JpSupervisor
	MoveC	CACR,d0
	BClr	#8,d0
	MoveC	d0,CACR
	JpUser
	Rts
; *******************************************************
InstCacheMode:
	Tst.l	d0
	Beq.b	ICM_Disable
ICM_Enable:
	JpSupervisor
	MoveC	CACR,d0
	Bset	#0,d0
	MoveC	d0,CACR
	JpUser
	Rts
ICM_Disable:
	JpSupervisor
	MoveC	CACR,d0
	BClr	#0,d0
	MoveC	d0,CACR
	JpUser
	Rts
; *******************************************************
ClearDataCache:
	JpSupervisor
	MoveC	CACR,d0
	Bset	#11,d0
	MoveC	d0,CACR
	JpUser
; *******************************************************
ClearInstCache:
	JpSupervisor
	MoveC	CACR,d0
	Bset	#3,d0
	MoveC	d0,CACR
	JpUser
	Rts
; *******************************************************
InstBurstMode:
	Tst.l	d0
	Beq.b	IBM_Disable
IBM_Enable:
	JpSupervisor
	MoveC	CACR,d0
	Bset	#4,d0
	MoveC	d0,CACR
	JpUser
	Rts
IBM_Disable:
	JpSupervisor
	MoveC	CACR,d0
	BClr	#4,d0
	MoveC	d0,CACR
	JpUser
	Rts
; *******************************************************
DataBurstMode:
	Tst.l	d0
	Beq.b	DBM_Disable
DBM_Enable:
	JpSupervisor
	MoveC	CACR,d0
	Bset	#12,d0
	MoveC	d0,CACR
	JpUser
	Rts
DBM_Disable:
	JpSupervisor
	MoveC	CACR,d0
	BClr	#12,d0
	MoveC	d0,CACR
	JpUser
	Rts
; *******************************************************
; *******************************************************
; *******************************************************
; *******************************************************
;
