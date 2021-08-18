;
; Fredrick Making Game Environment Library TESTER V1.0
;
	Move.l	$4,a6
	Lea.l	Name,a1
	Moveq.l	#0,d0
	Jsr		-408(a6)	; OldOpenLibrary.
	Move.l	d0,a1
;	Jsr		-414(a6)
	Rts
Name:	Dc.b	"AmigaGS:Libs/Graphics/fxmosaic.library",0

