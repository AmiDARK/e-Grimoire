;
; FX Ilbm picture viewer library.
;
InitRESERVED	Equ		-30
IlbmConvert		Equ		-36
;					In	:	A0=ScreenBase / A1=Form/Ilbm Base
IlbmXSize		Equ		-42
;					In	:	A0=Ilbm Base
;					Out	:	D0=XSize
IlbmYSize		Equ		-48
;					In	:	A0=Ilbm Base
;					Out	:	D0=YSize
IlbmDepth		Equ		-54
;					In	:	A0=Ilbm Base
;					Out	:	D0=Depth ( how many bits planes )
IlbmPalette		Equ		-60
;					In	:	A0=Ilbm Base
;					Out	:	A0=1st Color in CMAP
