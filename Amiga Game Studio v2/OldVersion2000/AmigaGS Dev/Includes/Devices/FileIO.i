;
; FileIO.library .i
;
InitRESERVED	Equ	-30
LoadFile		Equ	-36
;					In : A0=FileName / A1=Adress / D0=FileLength
SaveFile		Equ	-42
;					In : A0=FileName / A1=Adress / D0=FileLength
LoadCustomFile	Equ	-48
;					In : A0/A1/D0=Idem(s) D1=Start Position
