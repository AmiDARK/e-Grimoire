
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS intuition.library      *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to intuition.library calls.
;
; openIntuitionLib()

openIntuitionLib:
	move.l	$4,a6
	lea 	intuitionName(pc),a1 	; Load the "intuition.library" name to a1
	Moveq	#0,d0					; Open All versions of intuition.library
	jsr		_LVOOpenLibrary(a6)		; Call exec.library/OpenLibrary method
	move.l	d0,intuitionBase(a5) 	; Save intuition.library BASE to gfxBase
	rts

intuitionBase:	dc.b	"intuition.library",0
