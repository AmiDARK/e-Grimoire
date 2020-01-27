
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : sys_lib_macros                 *
; * Author : Frederic Cordier             *
; *****************************************
; This file contain basic macros for AmigaOS libraries call

; *****************************************************
execCall		MACRO
	move.l 		$4.w,a6
	jsr 		\1(a6)
				ENDM

; *****************************************************
dosCall 		MACRO
	move.l 		a6,-(sp)
	move.l 		dosBase(a5),a6
	jsr 		\1(a6)
	move.l 		(sp)+,a6
				ENDM

; *****************************************************
graphicsCall 	MACRO
	movem.l 	d0/d1/a0/a1/a6,-(sp)
	move.l 		gfxBase(a5),a6
	jsr 		\1(a6)
	movem.l		(sp)+,d0/d1/a0/a1/a6
				ENDM

; *****************************************************
intuiCall		MACRO
	movem.l 	d0/d1/a0/a1/a6,-(sp)
	move.l 		intuitionBase(a5),a6
	jsr 		\1(a6)
	movem.l		(sp)+,d0/d1/a0/a1/a6
				ENDM

; *****************************************************
layersCall		MACRO
	movem.l 	d0/d1/a0/a1/a6,-(sp)
	move.l 		layersBase(a5),a6
	jsr 		\1(a6)
	movem.l		(sp)+,d0/d1/a0/a1/a6
				ENDM

; *****************************************************
mathFFPCall		MACRO
	movem.l 	d0/d1/a0/a1/a6,-(sp)
	move.l 		mathFFPBase(a5),a6
	jsr 		\1(a6)
	movem.l		(sp)+,d0/d1/a0/a1/a6
				ENDM
