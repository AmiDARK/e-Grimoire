
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS Graphics.library       *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to Graphics.library calls.
;
; openGraphicsLib()

openGraphicsLib:
	move.l	$4,a6
	lea 	graphicsName(pc),a1 	; Load the "graphics.library" name to a1
	Moveq	#0,d0					; Open All versions of graphics.library
	jsr		_LVOOpenLibrary(a6)		; Call exec.library/OpenLibrary method
	move.l	d0,graphicsBase(a5) 	; Save Graphics.library BASE to gfxBase
	rts

graphicsBase:	dc.b	"graphics.library",0
