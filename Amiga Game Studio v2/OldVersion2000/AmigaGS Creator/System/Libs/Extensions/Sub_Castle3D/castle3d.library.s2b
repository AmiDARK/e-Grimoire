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

	opt	p=68882

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

LibName:       dc.b 'castle3d.library',0
idString:      dc.b 'Castle of darkness 3D Engine Ver0.2a '
               dc.b '68881/2 68040 and 68060 Version '
			   dc.b '(05 Mai 00) ',13,10,0
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
			Dc.l	TraceView
			Dc.l	Set3d_MapBase
			Dc.l	Set3d_TextureBase
			Dc.l	Set3d_PlayerPos
			Dc.l	Set3d_ScreenSize
			Dc.l	Set3d_ChunkyBase
			Dc.l	Set3d_ChunkySize
			Dc.l	Set3d_CosTable
			Dc.l	Set3d_SinTable
			Dc.l	CaseSize
			Dc.l	CheckPosition
			Dc.l	LightState
			Dc.l	TexturesState
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
; ***************************************************************
; Data Bank pointers
	IncDir	"CASTLE2000:Sources/"
		Include	"3DPointers.Equ"
SPIX			Equ		0
XSIZE			Equ		2
YSIZE			Equ		4
PLCASE			Equ		6
CASE			Equ		8
BANK_MAP		Equ		10
ADR_CASE		Equ		14
LR				Equ		18
LRFISH			Equ		20
UDADD			Equ		22
UDO				Equ		24
UD				Equ		26
XVIEW			Equ		28
YVIEW			Equ		30
ZVIEW			Equ		32
XTTR			Equ		34
YTTR			Equ		36
BANK_TEXTURE	Equ		38
ADR_CHUNKY		Equ		42
XCHUNKY			Equ		46
XPLOT			Equ		48
YPLOT			Equ		50
TXTR			Equ		52
T_COS			Equ		54
T_SIN			Equ		58
CHUNKY_PLOT		Equ		62
SAVEFP1			Equ		66
SAVEFP2			Equ		70
OldSysStack		Equ		74
LIGHT			Equ		78
TEXTURESSTATE	Equ		79
;				Equ		80
; ***************************************************************
;'
;' *********************************************************  
;' *                                                       *  
;' * PROCEDURE DE TRACE D'UN MONDE VIRTUEL EN 3 DIMENSIONS *  
;' *                                                       *  
;' *********************************************************  
;'    X/YSIZE = dimensions de la vue en 3D  
;'    SPIX = facteur de qualité du tracé 3D   
;'    LR#,UD# = angles de vue 3D LR#=X,Y / UD#=Z  
;'       CASE = case 3D ou le joueur se trouve
;' X/Y/ZVIEW# = point de vue en 3D
;Global LR#,UD#
TraceView:
;
	Move.l	$4,a6
	Lea.l	Data_Base,a1
	Lea.l	Registers,a0
;'
;' *********************************************************  
;' *                                                       *  
;' * PROCEDURE DE TRACE D'UN MONDE VIRTUEL EN 3 DIMENSIONS *  
;' *                                                       *  
;' *********************************************************  
;'    X/YSIZE = dimensions de la vue en 3D  
;'    SPIX = facteur de qualité du tracé 3D   
;'    LR#,UD# = angles de vue 3D LR#=X,Y / UD#=Z  
;'       CASE = case 3D ou le joueur se trouve
;' X/Y/ZVIEW# = point de vue en 3D
;Global LR#,UD#
;'
;' Nombre de pixels à tracer. 
;   XPIXELS=XSIZE/SPIX
;   YPIXELS=YSIZE/SPIX
;'
;' Angles de décalages pour le tracé 3D 
;   LRADD#=(64.0/XPIXELS)*F_DEG2RAD#
;   UDADD#=(40.0/YPIXELS)*F_DEG2RAD#
	Clr.l	d3
	Move.w	SPIX(a1),d2
	Lsl.w	#2,d2
	Cmp.w	#320,XSIZE(a1)
	Beq.b	jj
	Lsl.w	#1,d2
jj:
;'
;' Angles d'origine pour le tracé 3D
;   LR#=(LR#+32.0)*F_DEG2RAD#
;   LRFISH#=32.0*F_DEG2RAD#
;   UDO#=(UD#+20.0)*F_DEG2RAD#
	Move.w	LR(a1),d0
	Move.w	#392,d1
	Move.w	UD(a1),d3
	Addi.w	#32,d0
	Mulu.w	#5,d1
	Addi.w	#20,d3
	Mulu.w	#5,d0
	Lsl.w	#2,d1
	Mulu.w	#5,d3
	Lsl.w	#2,d0
	Lsl.w	#2,d3
	Movem.w	d0-d3,LR(a1)
;'
	Move.l	ADR_CHUNKY(a1),CHUNKY_PLOT(a1)

;' Début de la boucle sur X.
;   For XPLOT=0 To XSIZE Step SPIX
	Clr.w	XPLOT(a1)
FOR_XPLOT:

;      UD#=UDO#
	Move.w	UDO(a1),UD(a1)
;'
;      XADD#=Cos(LR#)
;      YADD#=-Sin(LR#)
	Move.w	LR(a1),d0
	Move.l	T_COS(a1),a3
	FMove.s	(a3,d0.w),fp2			; FP2=XADD#
	FMove.s	(a3,14400,d0.w),fp3	; FP3=YADD#
;'
;      For YPLOT=0 To YSIZE Step SPIX
	clr.w	YPLOT(a1)
FOR_YPLOT:
;'
;      If CASE<>PLCASE
;         CASE=PLCASE
;         ADR_CASE=BANK_MAP+16+((CASE-1)*256)
;         CASEXSIZE=Leek(ADR_CASE+_CASEXSIZE)
;         CASEYSIZE=Leek(ADR_CASE+_CASEYSIZE)
;         CASEZSIZE=Leek(ADR_CASE+_CASEZSIZE)
;        End If 
	Movem.w	PLCASE(a1),d0/d1
	Cmp.w	d1,d0
	Beq.b	JP1
	Move.w	d0,CASE(a1)
	Move.l	BANK_MAP(a1),a2
	Subq.w	#1,d0
	Move.l	(a2,d0.w*4),a2

	Movem.w	_CASEXSIZE(a2),d5-d7
JP1:
;
;      XCASE=XVIEW
;      YCASE=YVIEW
;      ZCASE=ZVIEW
	Movem.w	XVIEW(a1),d2-d4

;      ZADD#=Sin(UD#)*Cos(LRFISH#)
	Move.w	UD(a1),d0
	Move.l	T_COS(a1),a3
	FMove.s	(a3,d0.w,14400),fp4
	Move.w	LRFISH(a1),d0
	FNeg	fp4
	FMove.s	(a3,d0.w),fp0
	FMul	fp0,fp4					; FP4=ZADD#
;'
;   If ZADD#>0 Then ZAD=True Else ZAD=False
;   If YADD#>0 Then YAD=True Else YAD=False
;   If XADD#>0 Then XAD=True Else XAD=False
;' boucle de rappel ( en case de changement de case 3D. 
MOVE_TO_BORDER:
;'
;         If XAD=True
;            XDIST#=(CASEXSIZE-XCASE)/XADD#
;            WALLX=_WALLEAST
;           Else 
;            XDIST#=-XCASE/XADD#
;            WALLX=_WALLWEST
;          End If 
	Suba.l	a3,a3

	Ftst	fp2
	Fblt	JP2inf
JP2sup:
	Move.w	d5,d0
	Move.w	#_WALLEAST,a3
	Bra.b	JP2
JP2inf:
	clr.w	d0
	Move.w	#_WALLWEST,a3
JP2:
	Sub.w	d2,d0
	FMove.w	d0,fp5
	FDiv	fp2,fp5	
;
;         If YAD=True
;            YDIST#=(CASEYSIZE-YCASE)/YADD#
;            WALLY=_WALLSOUTH
;           Else 
;            YDIST#=-YCASE/YADD#
;            WALLY=_WALLNORTH
;          End If 
	Ftst	fp3
	Fblt	JP3inf
JP3sup:
	Move.w	d6,d0
	Move.w	#_WALLSOUTH,a4
	Bra.b	JP3
JP3inf:
	Clr.w	d0
	Move.w	#_WALLNORTH,a4
JP3:
	Sub.w	d3,d0
	FMove.w	d0,fp6
	FDiv	fp3,fp6	
;         If ZAD=True
;            ZDIST#=(CASEZSIZE-ZCASE)/ZADD#
;            WALLZ=_WALLCEIL
;           Else 
;            ZDIST#=-ZCASE/ZADD#
;            WALLZ=_WALLFLOOR
;          End If 
	Ftst	fp4
	Fblt	JP4inf
JP4sup:
	Move.w	d7,d0
	Move.w	#_WALLCEIL,a5
	Bra.b	JP4
JP4inf:
	Clr.w	d0
	Move.w	#_WALLFLOOR,a5
JP4:
	Sub.w	d4,d0
	FMove.w	d0,fp7
	FDiv	fp4,fp7	
;'
;         WALL=1
	Moveq.b	#1,d1
;
;         If YDIST#<XDIST#
;            XDIST#=YDIST#
;            WALL=2
;           End If 
	FCmp	fp5,fp6
	FBge	JP5sup
	Moveq.b	#2,d1
	FMove	fp6,fp5
JP5sup:
;
;         If ZDIST#<XDIST#
;            XDIST#=ZDIST#
;            WALL=3
;           End If 
	FCmp	fp5,fp7
	FBge	JP6sup
	Moveq.b	#3,d1
	FMove	fp7,fp5
JP6sup:
;'
;         XCASE=XCASE+(XDIST#*XADD#)
;         YCASE=YCASE+(XDIST#*YADD#)
;         ZCASE=ZCASE+(XDIST#*ZADD#)
	FMove	fp5,fp6
	FMove	fp5,fp7
	FSMul	fp2,fp5
	FMove.w	fp5,d0
	FSMul	fp3,fp6
	Add.w	d0,d2
	FSMul	fp4,fp7
	FMove.w	fp6,d0
	Add.w	d0,d3
	FMove.w	fp7,d0
	Add.w	d0,d4
;         If WALL=1
;            WALLS=WALLX
;            XTTR=YCASE
;            YTTR=ZCASE
;            Goto _SUITE
;           End If 
	Cmpi.b	#2,d1
	Beq.b	WALL2
	Bgt.b	WALL3
WALL1:
	Move.w	d3,d0			; D0=XTTR=YCASE
	Move.w	d4,d1			; D1=YTTR=ZCASE
	Bra.b	SUITE
;
;         If WALL=2
;            WALLS=WALLY
;            XTTR=XCASE
;            YTTR=ZCASE
;            Goto _SUITE
;           End If 
WALL2:
	Move.w	a4,a3
	Move.w	d2,d0			; D0=XTTR=XCASE
	Move.w	d4,d1			; D1=YTTR=ZCASE
	Bra.b	SUITE
;
;         WALLS=WALLZ
;         XTTR=XCASE
;         YTTR=YCASE
WALL3:
	Move.w	a5,a3
	Move.w	d2,d0			; D0=XTTR=XCASE
	Move.w	d3,d1			; D1=YTTR=YCASE
;
SUITE:
	Movem.w	d0/d1,XTTR(a1)
;   TXTR=Deek(ADR_CASE+WALLS+_TEXTURE)
	Add.l	a2,a3					; A3=ADR_CASE+WALLS
	Move.w	(a3),d0					;
	Move.w	d0,TXTR(a1)
;
;' On regarde si on ne se trouve pas dans une porte vers une autre case.
;   NEWCASE=Deek(ADR_CASE+WALLS+_NEXTCASE)
;   If NEWCASE=0 Then Goto _END_FOR_CHECK
	Move.w	_NEXTCASE(a3),d1
	Tst.w	d0
	Beq.b	_ENTER
	Tst.w	d1
	Beq.b	END_FOR_CHECK
;
;_CHECK_FOR_X:
;      XDOOR=Leek(ADR_CASE+WALLS+_DOORXPOS)
;      XDSIZE=Leek(ADR_CASE+WALLS+_DOORXSIZE)
;      _TESTX=XTTR-XDOOR
;      If _TESTX<=0 Then Goto _END_FOR_CHECK
;      If _TESTX>=XDSIZE Then Goto _END_FOR_CHECK
	Move.w	XTTR(a1),d0			; Deja en mémoire.
	Cmp.w	_DOORXPOS(a3),d0
	Blt.b	END_FOR_CHECK
	Cmp.w	_DOORXSIZE(a3),d0
	Bgt.b	END_FOR_CHECK
;
;_CHECK_FOR_Y:
;      YDOOR=Leek(ADR_CASE+WALLS+_DOORYPOS)
;      YDSIZE=Leek(ADR_CASE+WALLS+_DOORYSIZE)
;      _TESTY=YTTR-YDOOR
;      If _TESTY<=0 Then Goto _END_FOR_CHECK
;      If _TESTY>=YDSIZE Then Goto _END_FOR_CHECK
	Move.w	YTTR(a1),d0
	Cmp.w	_DOORYPOS(a3),d0
	Blt.b	END_FOR_CHECK
	Cmp.w	_DOORYSIZE(a3),d0
	Bgt.b	END_FOR_CHECK
;
;' Il y a une porte , donc on entre dans la nouvelle case . 
_ENTER:
;      CXP=Leek(ADR_CASE+0)
;      CYP=Leek(ADR_CASE+4)
;      CZP=Leek(ADR_CASE+8)
;      CASE=NEWCASE
;      ADR_CASE=BANK_MAP+16+((CASE-1)*256)
;      CXP=CXP-Leek(ADR_CASE+0)
;      CYP=CYP-Leek(ADR_CASE+4)
;      CZP=CZP-Leek(ADR_CASE+8)
;      CASEXSIZE=Leek(ADR_CASE+_CASEXSIZE)
;      CASEYSIZE=Leek(ADR_CASE+_CASEYSIZE)
;      CASEZSIZE=Leek(ADR_CASE+_CASEZSIZE)
;      XCASE=XCASE+CXP
;      YCASE=YCASE+CYP
;      ZCASE=ZCASE+CZP
	Move.w	d1,CASE(a1)
	Add.w	_CASEXMAP(a2),D2
	Add.w	_CASEYMAP(a2),D3
	Subq.w	#1,d1
	Add.w	_CASEZMAP(a2),D4
	Move.l	BANK_MAP(a1),a2
	Move.l	(a2,d1.w*4),a2
	Movem.w	_CASEYMAP(a2),d0/d1
	Sub.w	d0,D3
	Sub.w	_CASEXMAP(a2),D2
	Sub.w	d1,D4
	Movem.w	_CASEXSIZE(a2),d5-d7
;
;      Goto _MOVE_TO_BORDER
	Bra.w	MOVE_TO_BORDER
;' ?
;' ?
END_FOR_CHECK:
;
;' Lecture de la texture puis trace du point .
;         _READTEXTURE[XTTR,YTTR,TXTR,_MODE]
;         _WRITE_PIXEL[XPLOT,YPLOT,PIXELCOLOR,SPIX]
;' **********************************************************  
;' *                                                        *  
;' * PROCEDURE DE LECTURE D'UN PIXEL D'UNE TEXTURE          *  
;' *                                                        *  
;' **********************************************************  
;_SINGLEPASS[XTTR#,YTTR#,TXTR]
READTEXTURE:
;   '
;   ' On se pointe sur l'adresse de la texture concernée 
;   TTR=TTR-1
;	Sub.l	d0,d0
	Move.w	TXTR(a1),d0
	Subq.w	#1,d0

;   '   _ADRESS=Leek(BANK_TEXTURE+(_TTR*4))
;   _ADRESS=BANK_TEXTURE+(16384*TTR)
	Move.l	BANK_TEXTURE(a1),a3
;	Lsl.w	#2,d0
	Move.l	(a3,d0.w*4),a6					; a6=_ADRESS
;   '
	Tst.b	TEXTURESSTATE(a1)
	Bne.b	rt1
	Move.b	(a6),d0
	Or.b	#%1110,d0
	Bra.b	WRITE_PIXEL
;
rt1:
;   ' On lit les données concernant la texture pointée.
;   '      XSIZE=Deek(_ADRESS) 
;   XSIZE=128
;   '      YSIZE=Deek(_ADRESS+2) 
;   YSIZE=128
;   XFILTER=XSIZE-1
;   YFILTER=YSIZE-1
;   ' On trouve le bon pixel . 
;   '   _ADRESS=_ADRESS+16 
;   _ADRESS=_ADRESS+0
;   '
;   ADR_CASE2=ADR_CASE+WALLS			; A3=ADR_CASE2
;   XPOS=XPOS+Leek(ADR_CASE2+_XPAN)
	Movem.w	XTTR(a1),d0/d1				; D0=XPOS / D1=YPOS
;	Add.w	_XPAN(a3),d0
;	Add.w	_YPAN(a3),d1
;
;   XPOS=XPOS and XFILTER
;
;   YPOS=YPOS+Leek(ADR_CASE2+_YPAN)
;
;   YPOS=YPOS and YFILTER
	Andi.w	#127,d0
	Andi.w	#127,d1
;   '
;   _ADRESS=_ADRESS+XPOS+(YPOS*XSIZE)
;	Mulu.l	#128,d1
	Lsl.w	#7,d1
	Add.w	d0,d1

;   PIXELCOLOR=Peek(_ADRESS)
	Move.b	(a6,d1.w),d0
;End Proc


;'
;' *********************************************  
;' *                                           *  
;' * PROCEDURE DE TRACE D'UN POINT SUR L'éCRAN *  
;' *                                           *  
;' *********************************************  
WRITE_PIXEL:
;Procedure _WRITE_PIXEL[XPLOT,YPLOT,PIXEL,SIZE] PIXEL=D0
	Tst.b	LIGHT(a1)
	Beq.b	NoGouraudShading
;
	Movem.l	d5-d7,P_Empty
;
;   COMP=PIXEL and %11100000
	Move.b	d0,d1
	Andi.b	#%11100000,d1					; D1=COMP
;
;   PIXEL=PIXEL and %11111
	Andi.b	#%11111,d0						; D0=PIXEL

;   LIGHTXPOS=Leek(ADR_CASE+_LIGHTXPOS)
;   LIGHTYPOS=Leek(ADR_CASE+_LIGHTYPOS)
;   LIGHTZPOS=Leek(ADR_CASE+_LIGHTZPOS)
;   DISTX=Abs(LIGHTXPOS-XCASE)
;   DISTY=Abs(LIGHTYPOS-YCASE)
;   DISTZ=Abs(LIGHTZPOS-ZCASE)
;   DISTANCE=(DISTX+DISTY+DISTZ)
	Movem.w	_LIGHTXPOS(a2),d5-d7
	Sub.w	d2,d5
	Bpl.b	JPx1
	Neg.w	d5
JPx1:
	Sub.w	d3,d6
	Bpl.b	JPx2
	Neg.w	d6
JPx2:
	Sub.w	d4,d7
	Bpl.b	JPx3
	Neg.w	d7
JPx3:
	Add.w	d6,d5
	Add.w	d7,d5				; D5=Distance
;
;   LIGHT=Deek(ADR_CASE+_LIGHT)
	Move.w	_LIGHT(a2),d6

;   PIXEL=PIXEL+(DISTANCE/LIGHT)
	Divu.w	d6,d5
	Add.b	d5,d0
;
;   If PIXEL>31 Then PIXEL=31
	Cmpi.b	#31,d0
	Ble.b	JPx
	Moveq.b	#31,d0
JPx:
;   PIXEL=PIXEL+COMP
	Or.b	d1,d0
;
;   If SIZE=1
;      Plot XPOS,YPOS,PIXEL
;     Else 
;      Plot XPOS,YPOS,PIXEL
;      Plot XPOS+1,YPOS,PIXEL
;      Plot XPOS,YPOS+1,PIXEL
;      Plot XPOS+1,YPOS+1,PIXEL
;    End If 
WPx:
	Movem.l	P_Empty,d5-d7
NoGouraudShading:
;
	Move.l	CHUNKY_PLOT(a1),a3
	Cmpi.b	#2,SPIX+1(a1)
	Bgt.b	Plotx4
	Blt.b	Plotx1
Plotx2:
	Move.b	d0,d1
	Lsl.l	#8,d1
	Move.b	d0,d1
	Move.w	d1,(a3)
	Move.w	d1,(a3,320)
	Bra.b	SUITE2
Plotx4:
	Move.b	d0,d1
	Lsl.l	#8,d1
	Move.b	d0,d1
	Move.w	d1,d0
	Swap	d1
	Move.w	d0,d1
	Move.l	d1,(a3)
	Move.l	d1,(a3,320)
	Move.l	d1,(a3,640)
	Move.l	d1,(a3,960)
	Bra.b	SUITE2


Plotx1:
	Move.b	d0,(a3)

SUITE2:
;
;         UD#=UD#-UDADD#
;
	Clr.l	d0
	Move.w	UDADD(a1),d1
	Move.w	SPIX(a1),d0
	Sub.w	d1,UD(a1)
	Mulu.w	#320,d0
	Add.l	CHUNKY_PLOT(a1),d0
	Move.l	d0,CHUNKY_PLOT(a1)
;
;        Next YPLOT
	Move.w	YPLOT(a1),d0
	Add.w	SPIX(a1),d0
	Move.w	d0,YPLOT(a1)
	Cmp.w	YSIZE(a1),d0
	Blt.w	FOR_YPLOT
;
;      LR#=LR#-LRADD#
	Sub.w	d1,LR(a1)
;
;      LRFISH#=LRFISH#-LRADD#
	Sub.w	d1,LRFISH(a1)
;
;     Next XPLOT
	Move.w	XPLOT(a1),d0
	Add.w	SPIX(a1),d0
	Move.w	d0,XPLOT(a1)
;
	Move.l	ADR_CHUNKY(a1),d1
	Add.w	d0,d1
	Move.l	d1,CHUNKY_PLOT(a1)
;
	Cmp.w	XSIZE(a1),d0
	Blt.w	FOR_XPLOT
;

;  End Proc

;
	Rts

;  End Proc
; *********************************************************
Set3d_MapBase:
	Lea.l	Data_Base,a1
	Move.l	a0,BANK_MAP(a1)
	Rts
; *********************************************************
Set3d_TextureBase:
	Lea.l	Data_Base,a1
	Move.l	a0,BANK_TEXTURE(a1)
	Rts
; *********************************************************
Set3d_PlayerPos:	; D0=Lr / D1=Ud / D2-3-4=PLX-Y-ZPOS / D5=Case
	Lea.l	Data_Base,a1
	Add.w	#360,d0
	Add.w	#360,d1
	Move.w	d0,LR(a1)
	Move.w	d1,UD(a1)
	Movem.w	d2/d3/d4,XVIEW(a1)
	Move.w	d5,PLCASE(a1)	; Player CASE in map .
	Move.w	#$FFFF,CASE(a1)	; Reinitialisation de la case 3D map.
	Rts
; *********************************************************
Set3d_ScreenSize:
	Lea.l	Data_Base,a1
	Move.w	d0,XSIZE(a1)
	Move.w	d1,YSIZE(a1)
	Move.w	d2,SPIX(a1)
	Rts
; *********************************************************
Set3d_ChunkyBase:
	Lea.l	Data_Base,a1
	Move.l	a0,ADR_CHUNKY(a1)
	Rts
; *********************************************************
Set3d_ChunkySize:
	Lea.l	Data_Base,a1
	Move.w	d0,XCHUNKY(a1)
;	Move.w	d1,YCHUNKY(a1)
	Rts
; *********************************************************
Set3d_CosTable:
	Lea.l	Data_Base,a1
	Move.l	a0,T_COS(a1)
	Rts
; *********************************************************
Set3d_SinTable:
	Lea.l	Data_Base,a1
	Move.l	a0,T_SIN(a1)
	Rts
; *********************************************************
CaseSize:
	Lea.l	Data_Base,a1
	Subq.w	#1,d0
	Move.l	BANK_MAP(a1),a0
	Sub.l	d1,d1
	Move.l	(a0,d0.w*4),a0
	Sub.l	d0,d0
	Sub.l	d2,d2
	Movem.w	_CASEXSIZE(a0),d0-d2
	Rts
	
; *********************************************************
; IN : D0=CASE D1=XPOS D2=YPOS D3=ZPOS
CheckPosition:
	Lea.l	Data_Base,a1
	Subq.w	#1,d0
	Sub.l	d4,d4
	Move.l	BANK_MAP(a1),a0
	Move.l	(a0,d0.w*4),a0
	Addq.w	#1,d0
	Movem.w	_CASEXSIZE(a0),d5-d7	; D5/D6/D7=CASEX/Y/ZSIZE
	Tst.w	d1					; XPOS<0 -> Mur OUEST.
	Bgt.b	_cp1
	Move.w	#_WALLWEST,d4
	Bra.b	WALLSX
_cp1:
	Cmp.w	d5,d1				; XPOS>CASEXSIZE -> Mur EST
	Blt.b	_cp2
	Move.w	#_WALLEAST,d4
	Bra.b	WALLSX
_cp2:
	Tst.w	d2					; YPOS<0 -> Mur NORD
	Bgt.b	_cp3
	Move.w	#_WALLNORTH,d4
	Bra.b	WALLSY
_cp3:
	Cmp.w	d6,d2				; YPOS>CASEYSIZE -> Mur SUD
	Blt.b	_cp4
	Move.w	#_WALLSOUTH,d4
	Bra.b	WALLSY
_cp4:
	RTS							; Not in a new case.
WALLSX:
	Move.l	a0,a3
	Add.l	d4,a3
;
	Cmp.w	_DOORXPOS(a3),d2
	Blt.b	END_FOR_CHECK2
	Cmp.w	_DOORXSIZE(a3),d2
	Bgt.b	END_FOR_CHECK2
	Cmp.w	_DOORYPOS(a3),d3
	Blt.b	END_FOR_CHECK2
	Cmp.w	_DOORYSIZE(a3),d3
	Bgt.b	END_FOR_CHECK2
	Bra.b	NextCheck
;
WALLSY:
	Move.l	a0,a3
	Add.l	d4,a3
;
	Cmp.w	_DOORXPOS(a3),d1
	Blt.b	END_FOR_CHECK2
	Cmp.w	_DOORXSIZE(a3),d1
	Bgt.b	END_FOR_CHECK2
	Cmp.w	_DOORYPOS(a3),d3
	Blt.b	END_FOR_CHECK2
	Cmp.w	_DOORYSIZE(a3),d3
	Bgt.b	END_FOR_CHECK2
;
NextCheck:
	Add.w	_CASEXMAP(a0),D1
	Add.w	_CASEYMAP(a0),D2
;	Add.w	_CASEZMAP(a0),d3
;
	Move.w	_NEXTCASE(a3),d0		; D0=NEW CASE !!!!
;	
	Subq.w	#1,d0
	Move.l	BANK_MAP(a1),a0
	Move.l	(a0,d0.w*4),a0			; A0=Adresse nouvelle case3D.
	Addq.w	#1,d0
;
	Sub.w	_CASEXMAP(a0),D1
	Sub.w	_CASEYMAP(a0),D2
;	Sub.w	_CASEZMAP(a0),d3
;
	Rts
END_FOR_CHECK2:
	Subq.w	#4,d5
	Subq.w	#4,d6
; On n'est pas rentré dans une nouvelle case alors:
	Cmpi.w	#4,d1					; XPOS<0 -> Mur OUEST.
	Bgt.b	_cp1b
	Moveq.w	#4,d1
_cp1b:
	Cmp.w	d5,d1				; XPOS>CASEXSIZE -> Mur EST
	Blt.b	_cp2b
	Move.w	d5,d1
_cp2b:
	Cmpi.w	#4,d2					; YPOS<0 -> Mur NORD
	Bgt.b	_cp3b
	Moveq.w	#4,d2
_cp3b:
	Cmp.w	d6,d2				; YPOS>CASEYSIZE -> Mur SUD
	Blt.b	_cp4b
	Move.w	d6,d2
_cp4b:
	Rts

; *********************************************************
LightState:
	Lea.l	P_LIGHT,a0
	Move.b	d0,(a0)
	Rts
; *********************************************************
TexturesState:
	Lea.l	P_TEXTURES,a0
	Move.b	d0,(a0)
	Rts
; *********************************************************
	section	dat,DATA
Data_Base:
P_SPIX			Dc.w	1
P_XSIZE			Dc.w	320
P_YSIZE			Dc.w	200
P_PLCASE		Dc.w	$0001
P_CASE			Dc.w	$0000
P_BANK_MAP		Dc.l	0
P_ADR_CASE		Dc.l	0
F_LR			Dc.w	0
F_LRFISH		Dc.w	0
P_UDADD			Dc.w	0
P_UDO			Dc.w	0
P_UD			Dc.w	0
P_XVIEW			Dc.w	0
P_YVIEW			Dc.w	0
P_ZVIEW			Dc.w	0
P_XTTR			Dc.w	0
P_YTTR			Dc.w	0
P_BANK_TTR		Dc.l	0
P_ADRCHUNKY		Dc.l	0
P_XCHUNKY		Dc.w	320
P_XPLOT			Dc.w	0
P_YPLOT			Dc.w	0
P_TXTR			Dc.w	0
P_T_COS			Dc.l	0
P_T_SIN			Dc.l	0
P_CHUNKY_PLOT	Dc.l	0
P_SAVEFP1		Dc.l	0
P_SAVEFP2		Dc.l	0
P_OldSysStack	Dc.l	0
P_LIGHT			Dc.b	0
P_TEXTURES		Dc.b	0
;VAR			Dc.x	0	; Definition des variables .
P_Empty			Dc.l	0,0,0,0
Registers:		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;
;
