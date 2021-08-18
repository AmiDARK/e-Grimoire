	Include	"Includes:Lvos.i"

InitLib	MACRO
	Move.l	$4,a6
	Lea.l	\1Name,a1
	Move.l	#0,d0
	Jsr		-408(a6)
	Lea.l	\1Base,a1
	Move.l	d0,(a1)
	ENDM
GfxCall	MACRO
		Lea.l	GfxBase,a6
		Move.l	(a6),a6
		Jsr		\1(a6)
	EndM

	InitLib	Gfx

	Move.l	#640,d0
	Move.l	#512,d1
	Move.l	#8,d2
	Move.l	#0,a0		; No Friend_Bitmap.
	GfxCall	_LVOAllocBitMap

	Rts



GfxBase:	Dc.l	0
GfxName:	Dc.b	"graphics.library",0