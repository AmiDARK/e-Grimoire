;
; **********************************************
; *                                            *
; * Tente d'ouvrir un écran RTG et le referme. *
; *                                            *
; **********************************************
; Ver0.1 28.02.01
;
    incdir "includes:"
    include "rtgmaster/rtgmaster.i"
    include "rtgmaster/rtgsublibs.i"
    include "rtgmaster/rtgmaster_lib.i"
    include "rtgmaster/rtgc2p.i"
    include "exec/memory.i"
;
; Opening RTG Library system
    move.l $4,a6
    movem.l d0-d7/a0-a6,-(sp)
    movem.l (sp)+,d0-d7/a0-a6
    lea RTGname,a1
    moveq #0,d0
    jsr -408(a6)
    move.l d0,RTGbase





RTGbase:	dc.l	0
RTGname:	dc.b	"rtgmaster.library",0