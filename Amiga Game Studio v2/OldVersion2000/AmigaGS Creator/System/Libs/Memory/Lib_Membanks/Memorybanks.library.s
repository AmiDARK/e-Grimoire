;
;
;
;
; Comments : I have removed a bug in bank memorization.
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

LibName:       dc.b 'memorybanks.library',0
idString:      dc.b 'memorybanks.library Ver1.0 '
               dc.b '680x0 Version 1.0a'
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
	Dc.l	_ReserveAsChipData
	Dc.l	_ReserveAsFastData
	Dc.l	_ReserveAsPublicData
	Dc.l	_ReserveAs24BitDMAData
	Dc.l	_BankBase
	Dc.l	_EraseBank
	Dc.l	_EraseAll
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

;
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


AllocMem	=	-198
FreeMem		=	-210
;
MEMPUBLIC	=	0
MEMCHIP		=	1
MEMFAST		=	2
MEM24BITDMA	=	9
MEMCLEAR	=	$10000
; ***********************************************************************
;											D0=BANK / D1=SIZE
_ReserveAsChipData:
;
; Banques de 1 à 128 seulement !!!
	And.l	#$FF,d0
	Subq.w	#1,d0
	Bmi.w	_Invalid	;	<1
	Cmp.w	#127,d0
	Bgt.w	_Invalid	;	>128
;
; Sauvegarde BankAsked/BankSized
	Lea.l	BankAsked,a0
	Move.w	d0,(a0)
	Lea.l	BankSized,a1
	Move.l	d1,(a1)
;
; If bank exist then skip.
	Lsl.w	#2,d0
	Lea.l	BankBase,a0
	Tst.l	(a0,d0.w)
	Bne.w	_BankExist
;
; Now,we will initialize for memory type
	Move.l	d1,d0
	Move.l	#MEMCLEAR,d1		; Clear memory bank.
	Bset	#MEMCHIP,d1			; CHIP MEMORY SELECTED.
;
; Allocate memory.
	Move.l	$4,a6
	Jsr		AllocMem(a6)
	Tst.l	d0					; D0=BankBase
	Beq.w	_NotEnoughChipMemory
	Move.l	d0,a0				; A0=RETURN=BankBase
; Take old saved values
	Lea.l	BankAsked,a1
	Move.w	(a1),d0
	Lea.l	BankSized,a1
	Move.l	(a1),d1
	Lsl.w	#2,d0
; Sauvegarde des données.
	Lea.l	BankSize,a1
	Move.l	d1,(a1,d0.w)
	Lea.l	BankBase,a1
	Move.l	a0,(a1,d0.w)
;
	Sub.l	d0,d0
	Rts
; ***********************************************************************
_ReserveAsFastData:
;
; Banques de 1 à 128 seulement !!!
	And.l	#$FF,d0
	Subq.w	#1,d0
	Bmi.w	_Invalid	;	<1
	Cmp.w	#127,d0
	Bgt.w	_Invalid	;	>128
;
; Sauvegarde BankAsked/BankSized
	Lea.l	BankAsked,a0
	Move.w	d0,(a0)
	Lea.l	BankSized,a1
	Move.l	d1,(a1)
;
; If bank exist then skip.
	Lsl.w	#2,d0
	Lea.l	BankBase,a0
	Tst.l	(a0,d0.w)
	Bne.w	_BankExist
;
; Now,we will initialize for memory type
	Move.l	d1,d0
	Move.l	#MEMCLEAR,d1		; Clear memory bank.
	Bset	#MEMFAST,d1			; FAST MEMORY SELECTED.
;
; Allocate memory.
	Move.l	$4,a6
	Jsr		AllocMem(a6)
	Tst.l	d0					; D0=BankBase
	Beq.w	_NotEnoughFastMemory
	Move.l	d0,a0				; A0=RETURN=BankBase
; Take old saved values
	Lea.l	BankAsked,a1
	Move.w	(a1),d0
	Lea.l	BankSized,a1
	Move.l	(a1),d1
	Lsl.w	#2,d0
; Sauvegarde des données.
	Lea.l	BankSize,a1
	Move.l	d1,(a1,d0.w)
	Lea.l	BankBase,a1
	Move.l	a0,(a1,d0.w)
;
	Sub.l	d0,d0
	Rts
; ***********************************************************************
_ReserveAsPublicData:
;
; Banques de 1 à 128 seulement !!!
	And.l	#$FF,d0
	Subq.w	#1,d0
	Bmi.w	_Invalid	;	<1
	Cmp.w	#127,d0
	Bgt.w	_Invalid	;	>128
;
; Sauvegarde BankAsked/BankSized
	Lea.l	BankAsked,a0
	Move.w	d0,(a0)
	Lea.l	BankSized,a1
	Move.l	d1,(a1)
;
; If bank exist then skip.
	Lsl.w	#2,d0
	Lea.l	BankBase,a0
	Tst.l	(a0,d0.w)
	Bne.w	_BankExist
;
; Now,we will initialize for memory type
	Move.l	d1,d0
	Move.l	#MEMCLEAR,d1		; Clear memory bank.
	Bset	#MEMPUBLIC,d1		; PUBLIC MEMORY SELECTED.
;
; Allocate memory.
	Move.l	$4,a6
	Jsr		AllocMem(a6)
	Tst.l	d0					; D0=BankBase
	Beq.w	_NotEnoughPublicMemory
	Move.l	d0,a0				; A0=RETURN=BankBase
; Take old saved values
	Lea.l	BankAsked,a1
	Move.w	(a1),d0
	Lea.l	BankSized,a1
	Move.l	(a1),d1
	Lsl.w	#2,d0
; Sauvegarde des données.
	Lea.l	BankSize,a1
	Move.l	d1,(a1,d0.w)
	Lea.l	BankBase,a1
	Move.l	a0,(a1,d0.w)
;
	Sub.l	d0,d0
	Rts
; ***********************************************************************
_ReserveAs24BitDMAData:
;
; Banques de 1 à 128 seulement !!!
	And.l	#$FF,d0
	Subq.w	#1,d0
	Bmi.w	_Invalid	;	<1
	Cmp.w	#127,d0
	Bgt.w	_Invalid	;	>128
;
; Sauvegarde BankAsked/BankSized
	Lea.l	BankAsked,a0
	Move.w	d0,(a0)
	Lea.l	BankSized,a1
	Move.l	d1,(a1)
;
; If bank exist then skip.
	Lsl.w	#2,d0
	Lea.l	BankBase,a0
	Tst.l	(a0,d0.w)
	Bne.w	_BankExist
;
; Now,we will initialize for memory type
	Move.l	d1,d0
	Move.l	#MEMCLEAR,d1		; Clear memory bank.
	Bset	#MEM24BITDMA,d1		; 24BITDMAable MEMORY SELECTED.
;
; Allocate memory.
	Move.l	$4,a6
	Jsr		AllocMem(a6)
	Tst.l	d0					; D0=BankBase
	Beq.w	_NotEnough24BitDMAMemory
	Move.l	d0,a0				; A0=RETURN=BankBase
; Take old saved values
	Lea.l	BankAsked,a1
	Move.w	(a1),d0
	Lsl.w	#2,d0
	Lea.l	BankSized,a1
	Move.l	(a1),d1
; Sauvegarde des données.
	Lea.l	BankSize,a1
	Move.l	d1,(a1,d0.w)
	Lea.l	BankBase,a1
	Move.l	a0,(a1,d0.w)
;
	Sub.l	d0,d0
	Rts
; ***********************************************************************
_BankBase:
;
; Banques de 1 à 128 seulement !!!
	And.l	#$FF,d0
	Subq.w	#1,d0
	Bmi.w	_Invalid	;	<1
	Cmp.w	#127,d0
	Bgt.w	_Invalid	;	>128
;
	Lsl.w	#2,d0
	Lea.l	BankBase,a1
	Move.l	(a1,d0.w),a0	; A0=RETURN=BANKBASE
	Rts
; ***********************************************************************
_EraseBank:
;
; Banques de 1 à 128 seulement !!!
	And.l	#$FF,d0
	Subq.w	#1,d0
	Bmi.b	_Invalid	;	<1
	Cmp.w	#127,d0
	Bgt.b	_Invalid	;	>128
;
	Lsl.w	#2,d0
	Lea.l	BankBase,a0
	Move.l	(a0),a1					; A1=BASE ( freemem )
	Tst.l	a1
	Beq.w	_CannotEraseMemoryBank
	Clr.l	(a0)
	Lea.l	BankSize,a0
	Move.l	(a0),d0					; D0=SIZE ( freemem )
	Tst.l	d0
	Beq.w	_CannotEraseMemoryBank
	Clr.l	(a0)
;
	Move.l	$4,a6
	Jsr		FreeMem(a6)
;
	Clr.l	d0
	Rts
;
; ***********************************************************************
_EraseAll:
	Move.l	#127,d7
Bcl:
	Move.l	d7,d0
	Bsr.b	_EraseBank2
	Subq.b	#1,d7
	Bpl.b	Bcl
	Clr.l	d0
	Rts
_EraseBank2:
;
; Banques de 1 à 128 seulement !!!
	Lsl.w	#2,d0
	Lea.l	BankBase,a0
	Move.l	(a0),a1					; A1=BASE ( freemem )
	Tst.l	a1
	Beq.b	_suite
	Clr.l	(a0)
	Lea.l	BankSize,a0
	Move.l	(a0),d0					; D0=SIZE ( freemem )
	Tst.l	d0
	Beq.b	_suite
	Clr.l	(a0)
;
	Move.l	$4,a6
	Jsr		FreeMem(a6)
;
_suite:
	Clr.l	d0
	Rts
; ***********************************************************************
_Invalid:
	Moveq.l	#$FFFFFFFF,d0
	Move.l	#0,a0
	Lea		_Message1,a1
	Rts
_BankExist:
	Moveq.l	#$FFFFFFFE,d0
	Move.l	#0,a0
	Lea		_Message2,a1
	Rts
_NotEnoughChipMemory:
	Moveq.l	#$FFFFFFFD,d0
	Move.l	#0,a0
	Lea		_Message3,a1
	Rts
_NotEnoughFastMemory:
	Moveq.l	#$FFFFFFFC,d0
	Move.l	#0,a0
	Lea		_Message4,a1
	Rts
_NotEnoughPublicMemory:
	Moveq.l	#$FFFFFFFB,d0
	Move.l	#0,a0
	Lea		_Message5,a1
	Rts
_NotEnough24BitDMAMemory:
	Moveq.l	#$FFFFFFFA,d0
	Move.l	#0,a0
	Lea		_Message6,a1
	Rts
_CannotEraseMemoryBank:
	Moveq.l	#$FFFFFFF9,d0
	Move.l	#0,a0
	Lea		_Message7,a1
	Rts
; ***********************************************************************
_Message1:	Dc.b	"Bank asked is not valid.",0
	EVEN
_Message2:	Dc.b	"Bank already exist.",0
	EVEN
_Message3:	Dc.b	"Not enough CHIP memory to create bank.",0
	EVEN
_Message4:	Dc.b	"Not enough FAST memory to create bank.",0
	EVEN
_Message5:	Dc.b	"Not enough PUBLIC memory to create bank.",0
	EVEN
_Message6:	Dc.b	"Not enough 24BitDMAable memory to create bank.",0
	EVEN
_Message7:	Dc.b	"Cannot erase bank that does not exist.",0
	EVEN
BankAsked:
	Dc.w	0	; Temp #Memory bank asked * 4
BankSized:
	Dc.l	0	; Temp size asked for memory bank
BankBase:
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
BankSize:
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
