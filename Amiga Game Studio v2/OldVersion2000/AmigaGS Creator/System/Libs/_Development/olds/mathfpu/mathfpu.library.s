*******************************************************************************************
*   MathFPU.library.asm -- Example run-time library source code
*
*   Assemble and link, without startup code, to create MathFPU.library,
*     a LIBS: drawer run-time shared library
*
*  Linkage Info:
*  FROM     MathFPU.library.o
*  LIBRARY  LIB:Amiga.lib
*  TO       MathFPU.library
*
*BLink from MathFPU.library.o  LIB LIB:amiga.lib TO MathFPU.library
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

	Incdir	"dh3:Libraries/math/fpu/"
   INCLUDE "include/asmsupp.i"
   INCLUDE "include/mathfpubase.i"
   INCLUDE "include/mathfpu_rev.i"

;   LIST

_LVOOpenLibrary		Equ	-552
_LVOAlert			Equ	-108
_LVORemove			Equ	-252
_LVOCloseLibrary	Equ	-414
_LVOFreeMem			Equ	-$0d2

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
; MathFPU_rev.i (created by hand or preferable with the developer tool ``bumprev''
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
     DC.B    VERSION            ; UBYTE RT_VERSION  (defined in MathFPU_rev.i)
     DC.B    NT_LIBRARY         ; UBYTE RT_TYPE
     DC.B    MYPRI              ; BYTE  RT_PRI
     DC.L    LibName            ; APTR  RT_NAME
     DC.L    IDString           ; APTR  RT_ADSTRING
     DC.L    InitTable          ; APTR  RT_INIT  table for InitResident()

   ; this is the name that the library will have
LibName:   MathFPUNAME
   ; standard name/version/date ID string from bumprev-created MathFPU_rev.i
IDString:  VSTRING

dosName:   Dc.b	"dos.library",0

   ; force word alignment
   ds.w   0

   ; The romtag specified that we were "RTF_AUTOINIT".  This means that the RT_INIT
   ; structure member points to one of these tables below.  If the AUTOINIT bit was not
   ; set then RT_INIT would point to a routine to run.

InitTable:
   DC.L   MathFPUBase_SIZEOF ; size of library base data space
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






EndCode:
	Dc.b	"math fpu 68881/2,68040,68060 library"
	Dc.b	"Version 1.0 by Frederic Cordier "
	Dc.b	"19.03.00"
   END

