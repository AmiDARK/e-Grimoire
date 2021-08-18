*******************************************************************************************
*   DisplayAGA.library.asm -- Example run-time library source code
*
*   Assemble and link, without startup code, to create DisplayAGA.library,
*     a LIBS: drawer run-time shared library
*
*  Linkage Info:
*  FROM     DisplayAGA.library.o
*  LIBRARY  LIB:Amiga.lib
*  TO       DisplayAGA.library
*
*BLink from DisplayAGA.library.o  LIB LIB:amiga.lib TO DisplayAGA.library
* Copyright (c) 1992 Commodore-Amiga, Inc.
*
* This example is provided in electronic form by Commodore-Amiga, Inc. for
* use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
* published by Addison-Wesley (ISBN 0-201-56774-1).
*
* The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
* information on the correct usage of the techniques and operating system
* functions presented in these examples.  The source and executable code
* of these examples may only be distributed in free electronic form, via
* bulletin board or as part of a fully non-commercial and freely
* redistributable diskette.  Both the source and executable code (including
* comments) must be included, without modification, in any copy.  This
* example may not be published in printed form or distributed with any
* commercial product.  However, the programming techniques and support
* routines set forth in these examples may be used in the development
* of original executable software products for Commodore Amiga computers.
*
* All other rights reserved.
*
* This example is provided "as-is" and is subject to change; no
* warranties are made.  All use is at your own risk. No liability or
* responsibility is assumed.
*******************************************************************************************

   SECTION   code

   NOLIST
	Incdir	"Includes:"
	INCLUDE "exec/types.i"
	INCLUDE "exec/initializers.i"
	INCLUDE "exec/librariesDVP.i"
	INCLUDE "exec/lists.i"
	INCLUDE "exec/alerts.i"
	INCLUDE "exec/resident.i"
	INCLUDE "libraries/dosDVP.i"

	Incdir	"AmigaGS Dev:System/Libs/AGADisplay/"
	INCLUDE	"Include/Exec.s"
	INCLUDE "include/asmsupp.i"
	INCLUDE "include/DisplayAGAbase.i"
	INCLUDE "include/DisplayAGA_rev.i"

;   LIST

;_LVOOpenLibrary		Equ	-552
;_LVOAlert			Equ	-108
;_LVORemove			Equ	-252
;_LVOCloseLibrary	Equ	-414
;_LVOFreeMem			Equ	-$0d2

   XDEF   InitTable                    ;------ These don't have to be external but it helps
   XDEF   Open                         ;------ some debuggers to have them globally visible
   XDEF   Close
   XDEF   Expunge
   XDEF   Null
   XDEF   LibName
;   XDEF   Double
;   XDEF   AddThese

   XREF   _AbsExecBase

   XLIB   OpenLibrary
   XLIB   CloseLibrary
   XLIB   Alert
   XLIB   FreeMem
   XLIB   Remove

   ; The first executable location.  This should return an error in case someone tried to
   ; run you as a program (instead of loading you as a library).
Start:
   MOVEQ   #-1,d0
   rts

;------------------------------------------------------------------------------------------
; A romtag structure.  Both "exec" and "ramlib" look for this structure to discover magic
; constants about you (such as where to start running you from...).  The include file
; DisplayAGA_rev.i (created by hand or preferable with the developer tool ``bumprev''
; resolves the VERSION, REVISION, and VSTRING.
;------------------------------------------------------------------------------------------
   ; Few people will need a priority and should leave it at zero.  The RT_PRI field is used
   ; in configuring the ROMs.  Use "mods" from wack to look at other romtags in the system.
MYPRI   EQU   -0

RomTag:
               ;STRUCTURE RT,0
     DC.W    RTC_MATCHWORD      ; UWORD RT_MATCHWORD
     DC.L    RomTag             ; APTR  RT_MATCHTAG
     DC.L    EndCode            ; APTR  RT_ENDSKIP
     DC.B    RTF_AUTOINIT       ; UBYTE RT_FLAGS
     DC.B    VERSION            ; UBYTE RT_VERSION  (defined in DisplayAGA_rev.i)
     DC.B    NT_LIBRARY         ; UBYTE RT_TYPE
     DC.B    MYPRI              ; BYTE  RT_PRI
     DC.L    LibName            ; APTR  RT_NAME
     DC.L    IDString           ; APTR  RT_ADSTRING
     DC.L    InitTable          ; APTR  RT_INIT  table for InitResident()

   ; this is the name that the library will have
LibName:   DisplayAGANAME
   ; standard name/version/date ID string from bumprev-created DisplayAGA_rev.i
IDString:  VSTRING

dosName:   Dc.b	"dos.library",0

   ; force word alignment
   ds.w   0

   ; The romtag specified that we were "RTF_AUTOINIT".  This means that the RT_INIT
   ; structure member points to one of these tables below.  If the AUTOINIT bit was not
   ; set then RT_INIT would point to a routine to run.

InitTable:
   DC.L   DisplayAGABase_SIZEOF ; size of library base data space
   DC.L   funcTable         ; pointer to function initializers
   DC.L   dataTable         ; pointer to data initializers
   DC.L   initRoutine       ; routine to run


funcTable:

   ;------ standard system routines
	dc.l	Open
	dc.l	Close
	dc.l	Expunge
	dc.l	Null

   ;------ my libraries definitions
;	Dc.l	...
	Dc.l	_ActiveDisplayAGA
	Dc.l	_BackToWorkBench
	Dc.l	_WaitVbl



   ;------ function table end marker
   dc.l   -1


   ; The data table initializes static data structures.  The format is specified in
   ; exec/InitStruct routine's manual pages.  The INITBYTE/INITWORD/INITLONG routines are
   ; in the file "exec/initializers.i".  The first argument is the offset from the library
   ; base for this byte/word/long.  The second argument is the value to put in that cell.
   ; The table is null terminated.
   ; NOTE - LN_TYPE belog is a correction - old example had LH_TYPE.

dataTable:
        INITBYTE        LN_TYPE,NT_LIBRARY
        INITLONG        LN_NAME,LibName
        INITBYTE        LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
        INITWORD        LIB_VERSION,VERSION
        INITWORD        LIB_REVISION,REVISION
        INITLONG        LIB_IDSTRING,IDString
        DC.L   0

   ; This routine gets called after the library has been allocated.  The library pointer is
   ; in D0.  The segment list is in A0.  If it returns non-zero then the library will be
   ; linked into the library list.

initRoutine:

   ;------ get the library pointer into a convenient A register
   move.l   a5,-(sp)
   move.l   d0,a5

   ;------ save a pointer to exec
   move.l   a6,sb_SysLib(a5)

   ;------ save a pointer to our loaded code
   move.l   a0,sb_SegList(a5)

   ;------ open the dos library
   lea   dosName(pc),a1
   CLEAR   d0
   CALLSYS   OpenLibrary

   move.l   d0,sb_DosLib(a5)
   bne.s   1$

   ;------ can't open the dos!  what gives
   ALERT   AG_OpenLib!AO_DOSLib

1$:
   ;------ now build the static data that we need
   ;
   ; put your initialization here...
   ;

   move.l   a5,d0
   move.l   (sp)+,a5
   rts

;------------------------------------------------------------------------------------------
; here begins the system interface commands.  When the user calls OpenLibrary/CloseLibrary/
; RemoveLibrary, this eventually gets translated into a call to the following routines
; (Open/Close/Expunge).  Exec has already put our library pointer in A6 for us.  Exec has
; turned off task switching while in these routines (via Forbid/Permit), so we should not
; take too long in them.
;------------------------------------------------------------------------------------------

   ; Open returns the library pointer in d0 if the open was successful.  If the open failed
   ; then null is returned.  It might fail if we allocated memory on each open, or if only
   ; open application could have the library open at a time...

Open:      ; ( libptr:a6, version:d0 )

   ;------ mark us as having another opener
   addq.w   #1,LIB_OPENCNT(a6)

   ;------ prevent delayed expunges
   bclr   #LIBB_DELEXP,sb_Flags(a6)

   move.l   a6,d0
   rts

   ; There are two different things that might be returned from the Close routine.  If the
   ; library is no longer open and there is a delayed expunge then Close should return the
   ; segment list (as given to Init).  Otherwise close should return NULL.

Close:      ; ( libptr:a6 )

   ;------ set the return value
   CLEAR   d0

   ;------ mark us as having one fewer openers
   subq.w   #1,LIB_OPENCNT(a6)

   ;------ see if there is anyone left with us open
   bne.s   1$

   ;------ see if we have a delayed expunge pending
   btst   #LIBB_DELEXP,sb_Flags(a6)
   beq.s   1$

   ;------ do the expunge
   bsr   Expunge
1$:
   rts

   ; There are two different things that might be returned from the Expunge routine.  If
   ; the library is no longer open then Expunge should return the segment list (as given
   ; to Init).  Otherwise Expunge should set the delayed expunge flag and return NULL.
   ;
   ; One other important note: because Expunge is called from the memory allocator, it may
   ; NEVER Wait() or otherwise take long time to complete.

Expunge:   ; ( libptr: a6 )

   movem.l   d2/a5/a6,-(sp)
   move.l   a6,a5
   move.l   sb_SysLib(a5),a6

   ;------ see if anyone has us open
   tst.w   LIB_OPENCNT(a5)
   beq   1$

   ;------ it is still open.  set the delayed expunge flag
   bset   #LIBB_DELEXP,sb_Flags(a5)
   CLEAR   d0
   bra.s   Expunge_End

1$:
   ;------ go ahead and get rid of us.  Store our seglist in d2
   move.l   sb_SegList(a5),d2

   ;------ unlink from library list
   move.l   a5,a1
   CALLSYS   Remove

   ;
   ; device specific closings here...
   ;

   ;------ close the dos library
   move.l   sb_DosLib(a5),a1
   CALLSYS   CloseLibrary

   ;------ free our memory
   CLEAR   d0
   move.l   a5,a1
   move.w   LIB_NEGSIZE(a5),d0

   sub.l   d0,a1
   add.w   LIB_POSSIZE(a5),d0

   CALLSYS   FreeMem

   ;------ set up our return value
   move.l   d2,d0

Expunge_End:
   movem.l   (sp)+,d2/a5/a6
   rts

Null:
   CLEAR   d0
   rts
; ***********************************************************************
;Ici commencent les fonctions personnelles de librairie.
;Les fonctions reproduites ici sont destinées uniquement à servir
;d'exemple pour la créations de librairies personnelles et ne jouent
;aucun rôle particulier
; ***********************************************************************
COP1LEN		Dc.l	0	; Memoire reservee pour le copper 1e (SPR/RN)
COP2LEN		Dc.l	0	; '' '' ''' '' '' '' '' '' '' ''  2e (SCREEN)
COP1BASE	Dc.l	0	; Adresse de base du 1er copper list.
COP2BASE	Dc.l	0	; Adresse de base du 2eme copper list.
COP1ADR		Dc.l	0	; Adresse copper 1 pour creer les rainbows.
COP2ADR		Dc.l	0	; '' '' '' '' '' 2 pour modifier les ecrans.
COPNUM		Dc.l	0	; Nombre de parties copper. ( 1 -> 3 )
COPSPR		Dc.l	0	; Adresse de base pour les sprites copper.
COPPAL1		Dc.l	0	; Adresse de la base des palette COPPER MSB.
COPPAL2		Dc.l	0	; '' '' '' '' '' '' '' '' '' '' '' '' ' LSB.
COP1PART	Dc.l	0	; Adresse du 1er ecran du copper.
COP2PART	Dc.l	0	; Adresse du 2eme ecran copper.
COP3PART	Dc.l	0	; '' '' '' ' 3eme ecran copper.
; 3 sections copper list.
COPSECTION1	Dc.l	0,0,0,0	;\ Bits plans de 1 a 8 (bits plans possibles)
		Dc.l	0,0,0,0	;/ 
		Dc.l	0,0,0,0	; Screen offset X,Y. Screen Size X,Y.
COPSECTION2	Dc.l	0,0,0,0
		Dc.l	0,0,0,0
		Dc.l	0,0,0,0
COPSECTION3	Dc.l	0,0,0,0
		Dc.l	0,0,0,0
		Dc.l	0,0,0,0
COPPALVAL	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
; ZONE DE SAUVEGARDES DE REGISTRES Ax/Ax+n Dx/Dx+n
Registers	Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
EMPTY		Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;
; ***********************************************************************
OldCoppers:
	Dc.l	0,0		; Copper list Workbench 1 et 2 .
; ***********************************************************************
GraphicsName:
	Dc.b	"graphics.library",0
	EVEN
GraphicsBase:
	Dc.l	0
; ***********************************************************************
_ActiveDisplayAGA:
	Lea.l	COP1BASE,a0
	Move.l	(a0),d7
	Tst.l	d7
	Beq.b	_ERROR1

; On sauvegarde les dernièrs valeurs de la copper list du WB.
	Move.l	$4.w,a6
	Lea.l	GraphicsName,a1
	Moveq	#0,d0
	Jsr		_LVOOldOpenLibrary(a6)
	Lea.l	GraphicsBase,a1
	Move.l	d0,(a1)
;
	Move.l	d0,a1
	Move.l	$26(a1),d0		; D0=Old Copper 1
	Move.l	$32(a1),d1		; D1=Old Copper 2
;
	Jsr		_LVOCloseLibrary(a6)
	Lea.l	OldCoppers,a0
	Movem.l	d0-d1,(a0)
;
	Bsr		_WaitVbl
;
	Move.l	d7,$dff080
	Rts
_ERROR1:
	Moveq	#$FFFFFFFF,d0
	Lea.l	Message1,a0
	Rts
; ***********************************************************************
_BackToWorkBench:
	Lea.l	GraphicsBase,a0
	Move.l	(a0),a1
	Tst.l	a1
	Beq.b	_ERROR2
	Lea.l	OldCoppers,a0
	Movem.l	(a0),d0-d1
	Clr.l	(a0)+
	Clr.l	(a0)
	Tst.l	d0
	Beq.b	_ERROR2
;
	Bsr		_WaitVbl
;
	Movem.l	d0-d1,$DFF080
;
	Rts	
;
_ERROR2:
	Moveq	#$fFFFFFFF,d0
	Lea.l	Message2,a0
	Rts
; ***********************************************************************
_WaitVbl:
	Btst.b	#0,$DFF005
	Beq.s	_WaitVbl
.loop
	Btst.b	#0,$DFF005
	Bne.s	.loop
	Rts
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
; ***********************************************************************
Message1:
	Dc.b	"Cannot initialize display",0
	EVEN
Message2:
	Dc.b	"Display not initialized",0
	EVEN
Message3:
	Dc.b	" ",0
	EVEN


EndCode:
	Dc.b	"DisplayAGA library"
	Dc.b	"Version 1.0 by Frederic Cordier "
	Dc.b	"24.03.00"
   END

