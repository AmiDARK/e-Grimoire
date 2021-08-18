;
; LIBRARY.INIT // Initialiseles librairies.
;
; Mise en place des librairies AMIGA.
	Lea.l		DosBase,a3
	Move.b		d0,d2			; D2=How Many Amiga.library
	Move.l		a0,a2			; A2=Libraries Base.
	Subq.b		#1,d2
IR1:
	Move.l		(a2)+,(a3)+
	Subq.b		#1,d2
	Bpl.b		IR1
;
; Mise en place des librairies AmigaGS.
	Lea.l		FileIOBase,a3
	Move.b		d1,d2			; D2=How Many AmigaGS.library
	Move.l		a1,a2			; A2=Libraries Base.
	Subq.b		#1,d2
IR2:
	Move.l		(a2)+,(a3)+
	Subq.b		#1,d2
	Bpl.b		IR2
;
	Bra.w		_xxxInit2
;
; ***************************************************************
;
; Librairies AMIGA mises en place par l'initialisation :
;-------------------------------------------------------
DosBase:		Dc.l	0
GraphicsBase:	Dc.l	0
IntuitionBase:	Dc.l	0
MathFFPBase:	Dc.l	0
MathTransBase:	Dc.l	0

; Librairies AmigaGS mises en place par l'initialisation :
;---------------------------------------------------------
FileIOBase:			Dc.l	0
DisplayBase:		Dc.l	0
ScreensBase:		Dc.l	0
FXMosaicBase:		Dc.l	0
ChunkyBase:			Dc.l	0
IconsBase:			Dc.l	0
IlbmBase:			Dc.l	0
JoyportBase:		Dc.l	0
MemBanksBase:		Dc.l	0
MemCopyBase:		Dc.l	0
FastMathFFP:		Dc.l	0
AGSSystemBase:		Dc.l	0
FontTextBase:		Dc.l	0
CacheCPUBase:		Dc.l	0
Others:			Dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
_xxxInit2:
