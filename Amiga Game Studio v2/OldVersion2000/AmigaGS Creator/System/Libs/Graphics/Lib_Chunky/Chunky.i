;
; ChunkyCPU.i
;

Set_ChunkyBase		Equ	-30
				;	In	:	A0=Chunky Screen	(mem=any)
Set_ScreenBase		Equ	-36
				;	In	:	A0=Screen Base		(mem=chip)
Set_ChunkySize		Equ	-42
				;	In	:	D0=XSize / D1=YSize	(320*200 ou 160*100)
Chunky				Equ	-48
				;	In	:	/
Chunky_Plot			Equ	-54
				;	In	:	D0=XPos / D1=YPOS / D2=Ink
