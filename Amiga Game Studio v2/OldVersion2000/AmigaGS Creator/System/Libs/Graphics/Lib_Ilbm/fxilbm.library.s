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

LibName:       dc.b 'fxilbm.library',0
idString:      dc.b 'felix iff/ilbm library Ver1.0 '
               dc.b '680x0 Version '
			   dc.b '(13 Avril 00) ',13,10,0
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
			Dc.l	IlbmConvert
			Dc.l	IlbmXSize
			Dc.l	IlbmYSize
			Dc.l	IlbmDepth
			Dc.l	IlbmPalette

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
InitRESERVED:
Initialisation:
	Include	"AmigaGS Dev:System/Libs/InitLib.s"

	Rts
;
; ***************************************************************


; Iff CONVERT.
_BitsPlanes	Dc.l	0,0,0,0,0,0,0,0,0	; All 8 planes adresses.
_IffBase	Dc.l	0	; Ilbm Base.
_Bmhd		Dc.l	0	; Ilbm 'BMHD' Base.
_Cmap		Dc.l	0	; Ilbm 'CMAP' Base.
_Body		Dc.l	0	; Ilbm 'BODY' Base.
_LbmXs		Dc.l	0	; Ilbm X Size.
_LbmYs		Dc.l	0	; Ilbm Y Size.
_LbmDp		Dc.l	0	; Ilbm Depth.
_BitsPlanes3	Dc.l	0,0,0,0,0,0,0,0,0	; during IFF Convertion.
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;					IN	:	A1=IFF/ILBM IMAGE ADRESS IN MEMORY.
;							A0=Screen Base
IlbmConvert:
	Lea.l	_IffBase,a2
	Move.l	a1,(a2)
; **********************
; COPY BITSPLANES.
	Lea.l	_BitsPlanes,a1
	Moveq.b	#7,d0
cbpp:
	Move.l	(a0)+,(a1)+
	Subq.b	#1,d0
	Bpl.b	cbpp
; **********************
; Find BMHD Header
	Lea.l	_IffBase,a0
	Move.l	(a0),a2
;	Bclr	#0,a2
	Move.l	#16384,d0
	Move.l	a2,a0
_bm	Move.l	(a0),d1
	Cmp.l	#"BMHD",d1
	Beq.b	_bm2
	Sub.l	#1,d0
	Add.l	#2,a0
	Cmp.l	#0,d0
	Bne.b	_bm
	Bra.w	_its		; BMHD Non trouve !!!
_bm2
	Add.l	#4,a0
	Lea.l	_Bmhd,a1
	Move.l	a0,(a1)
; Find CMAP Header
	Move.l	#16384,d0
	Move.l	a2,a0
_cm	Move.l	(a0),d1
	Cmp.l	#"CMAP",d1
	Beq.b	_cm2
	Sub.l	#1,d0
	Add.l	#2,a0
	Cmp.l	#0,d0
	Bne.b	_cm
	Bra.w	_its		; CMAP Non trouve !!!
_cm2
	Add.l	#4,a0
	Lea.l	_Cmap,a1
	Move.l	a0,(a1)
; Find BODY Header
	Move.l	#16384,d0
	Move.l	a2,a0
_bo
	Move.l	(a0),d1
	Cmp.l	#"BODY",d1
	Beq.b	_bo2
	Sub.l	#1,d0
	Add.l	#2,a0
	Cmp.l	#0,d0
	Bne.b	_bo
	Bra.w	_its		; CMAP Non trouve !!!
_bo2
	Add.l	#4,a0
	Lea.l	_Body,a1
	Move.l	a0,(a1)
	Lea.l	_Bmhd,a2
	Move.l	(a2),a0
	Add.l	#4,a0
	Clr.l	d0
	Move.w	(a0)+,d0
	Clr.l	d1
	Move.w	(a0),d1
	Lea.l	_Bmhd,a2
	Move.l	(a2),a0
	Add.l	#12,a0
	Clr.l	d7
	Move.b	(a0),d7
	Lea.l	_LbmXs,a0
	Move.l	d0,(a0)
	Lea.l	_LbmYs,a0
	Move.l	d1,(a0)
	Lea.l	_LbmDp,a0
	Move.l	d7,(a0)
	Lea.l	_BitsPlanes,a0
	Sub.l	#1,d7
	Lsl.l	#2,d7
	Add.l	d7,a0
	Move.l	(a0),d0
	Cmp.l	#0,d0
	Beq.w	_its
; Copier les _bitsPlanes: dans _BitsPlanes3:
	Lea.l	_BitsPlanes,a0
	Lea.l	_BitsPlanes3,a1
	Move.l	#7,d0
_bp
	Move.l	(a0)+,(a1)+
	Sub.l	#1,d0
	Bpl.s	_bp
;
; CONVERTION ILBM TO AMOS COPPER DEFINED SCREEN V1.0
;
_TRACE
; A3 Replaced by A2. Two lines.
	Lea.l	_Body,a2
	Move.l	(a2),a0
	Add.l	#4,a0
;   For D0=1 To _YSIZE
	Move.l	#1,d0
_01
;      For d1=0 To _NBPL-1
	Move.l	#0,d1
_02
;         For d2=1 To(_XSIZE/8)
	Move.l	#1,d2
_03
;            D3=Peek(A0)
	Clr.l	d3
	Move.b	(a0),d3
;            Add a0,1
	Add.l	#1,a0
;            D4=Peek(A0)
	Move.b	(a0),d4
;            Add A0,1
	Add.l	#1,a0
;            If D3>$80 Then Goto _COMPRESSED
	Cmp.l	#$80,d3
	Bgt.b	_COMPRESSED
_NOCOMPRESSION
;            Dec A0
	Sub.l	#1,a0
;            For D5=0 To D3
	Move.l	#0,d5
_04
;               Poke _BPL(d1),Peek(A0)
	Move.l	d1,d7
	Lsl.l	#2,d7
	Lea.l	_BitsPlanes3,a1
	Add.l	d7,a1
	Move.l	(a1),a2
	Move.b	(a0),(a2)
;               Inc _BPL(d1)
	Add.l	#1,a2
	Move.l	a2,(a1)
;               Inc A0
	Add.l	#1,a0
;              Next D5
	Add.l	#1,d5
	Move.l	d3,d7
	Add.l	#1,d7
	Cmp.l	d7,d5
	Bne.b	_04
;            D2=D2+D3
	Add.l	d3,d2
;            Goto _CONTINUE
	Bra.b	_CONTINUE

_COMPRESSED:
;               D5=(257-D3)
	Move.l	#257,d5
	Sub.l	d3,d5
;               If D5>(_XSIZE/8) Then Bell : Goto _END
; A3 Replaced by A1. Two lines.
	Lea.l	_LbmXs,a1
	Move.l	(a1),d7
	Lsr.l	#3,d7
	Cmp.l	d7,d5
	Bgt.b	_END
;               For D6=1 To D5
	Move.l	#1,d6
_05
;                  Poke _BPL(d1),D4
	Lea.l	_BitsPlanes3,a1
	Move.l	d1,d7
	Lsl.l	#2,d7
	Add.l	d7,a1
	Move.l	(a1),a2
	Move.b	d4,(a2)
;                  Inc _BPL(d1)
	Add.l	#1,a2
	Move.l	a2,(a1)
;                 Next D6
	Add.l	#1,d6
	Move.l	d5,d7
	Add.l	#1,d7
	Cmp.l	d7,d6
	Bne	_05
;               D2=D2+(D5-1)
	Add.l	d5,d2
	Sub.l	#1,d2
_CONTINUE
;           Next D2
	Add.l	#1,d2
; A3 Replaced by A1. Two lines.
	Lea.l	_LbmXs,a1
	Move.l	(a1),d7
	Lsr.l	#3,d7
	Add.l	#1,d7
	Cmp.l	d7,d2
	Bne	_03
;        Next D1
	Add.l	#1,d1
; A3 Replaced by A1. Two lines.
	Lea.l	_LbmDp,a1
	Move.l	(a1),d7
	Cmp.l	d7,d1
	Bne	_02
;     Next D0
	Add.l	#1,d0
; A3 Replaced by A1. Two lines.
	Lea.l	_LbmYs,a1
	Move.l	(a1),d7
	Add.l	#1,d7
	Cmp.l	d7,d0
	Bne	_01
_END
; FIN DE LA CONVERTION.
_its
	RTS
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;					IN	:	A0=ILBM ADRESS
IlbmXSize:
	Moveq.l	#0,d2
	Move.l	#$FFFFFFFF,d3
	Move.l	#32768,d7
; Find BMHD
_xs0
	Move.l	(a0),d6
	Cmp.l	#"BMHD",d6
	Beq.b	_xs1
	Add.l	#2,a0
	Sub.l	#1,d7
	Tst.l	d7
	Beq.b	_Xsend
	Bra.b	_xs0
_xs1
	Add.l	#4,a0
	Add.l	#4,a0
	Clr.l	d0
	Move.w	(a0),d0
	RTS
_Xsend
	Moveq.l	#$FFFFFFFF,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
IlbmYSize:
	Moveq.l	#0,d2
	Move.l	#$FFFFFFFF,d3
	Move.l	#32768,d7
; Find BMHD
_ys0	Move.l	(a0),d6
	Cmp.l	#"BMHD",d6
	Beq.b	_ys1
	Add.l	#2,a0
	Sub.l	#1,d7
	Tst.l	d7
	Beq.b	_Ysend
	Bra.b	_ys0
_ys1
	Add.l	#4,a0
	Add.l	#6,a0
	Clr.l	d0
	Move.w	(a0),d0
	Rts
_Ysend
	Moveq	#$FFFFFFFF,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
IlbmDepth:
	Moveq.l	#0,d2
	Move.l	#$FFFFFFFF,d3
	Move.l	#32768,d7
; Find BMHD
_ds0
	Move.l	(a0),d6
	Cmp.l	#"BMHD",d6
	Beq.b	_ds1
	Add.l	#2,a0
	Sub.l	#1,d7
	Tst.l	d7
	Beq.b	_Dsend
	Bra.b	_ds0
_ds1
	Add.l	#4,a0
	Add.l	#12,a0
	Clr.l	d0
	Move.b	(a0),d0
	RTS
_Dsend
	Moveq	#$FFFFFFFF,d0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
IlbmPalette:
	Moveq.l	#0,d2
	Move.l	#$FFFFFFFF,d3
	Move.l	#32768,d7
; Find BMHD
_ds0b
	Move.l	(a0),d6
	Cmp.l	#"CMAP",d6
	Beq.b	_ds1b
	Add.l	#2,a0
	Sub.l	#1,d7
	Tst.l	d7
	Beq.b	_Dsendb
	Bra.b	_ds0b
_ds1b
	Add.l	#4,a0
	Rts
_Dsendb
	Move.l	#$FFFFFFFF,a0
	Rts
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
