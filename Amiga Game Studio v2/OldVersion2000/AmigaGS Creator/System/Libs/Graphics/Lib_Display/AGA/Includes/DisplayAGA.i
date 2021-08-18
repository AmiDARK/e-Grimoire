; DisplayAGA Includes:

AGS_DISPLAY		Equ	-30
		; In : /
		; Out: /
WB_DISPLAY		Equ	-36
		; In : /
		; Out: /
AGS_WAITVBL		Equ	-42
		; In : /
		; Out: /
AGS_SCREEN		Equ	-48
		; In : A0=ScreenBase
		; Out: /
AGS_SETCOLOR	Equ	-54
		; In : D0=COULEUR / D1=Rouge / D2=Vert / D3=Bleu
		; Out: /
AGS_COPPER		Equ	-60
		; In : /
		; Out: A0=CopperBase
REFRESH_COPPER	Equ	-66
		; In : /
		; Out: /
SCREEN_OFFSET	Equ	-72
		; In : D0=XOffset / D1=YOffset
		; Out: /
