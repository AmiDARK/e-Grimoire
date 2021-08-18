; *****************************************
; *                                       *
; * AMIGA GAME STUDIO DEVELOPMENT PROJECT *
; *                                       *
; *---------------------------------------*
; *                                       *
; * INCLUDEs & MACROs list Ver1.1a        *
; * Date : 25th May 2000 at 10:32         *
; * Libraries : 12AGS libs / 1EXT lib     *
; *                                       *
; *****************************************
;
; ******************************************************************
;                              INCLUDES
;                             ----------
;

; Devices libraries functions :
;------------------------------
	IncDir	"AmigaGS:Includes/Devices/"
	Include	"FileIO.i"				; Load/Save Files
	Include	"Joystick.i"			; Joystick

; Graphics libraries functions :
;-------------------------------
	IncDir	"AmigaGS:Includes/Graphics/"
	Include	"DisplayAGA.i"			; Copper List
	Include	"ScreensAGA.i"			; Opening Screens
	Include	"FxIlbm.i"				; Unpack ILBM Pictures
	Include	"Chunky.i"				; Display Chunky Screens
	Include	"IconsAGA.i"			; Use 16*16(2-256colors) icons
	Include	"FXMosaic.i"			; Use 2x 4x 8x 16x 32x Mosaics

; Mathematics Libraries functions :
;----------------------------------
	IncDir	"AmigaGS:Includes/Math/"
	Include	"FastMathFFP.i"			; Math FFP AGS Library.

; Memory libraries functions :
;-----------------------------
	IncDir	"AmigaGS:Includes/Memory/"
	Include	"MemoryBanks.i"			; Use Memory Banks
	Include	"MemoryCopy.i"			; Copy/Clear Memory Zones.

; System libraries functions :
;-----------------------------
	IncDir	"AmigaGS:Includes/System/"
	Include	"System/System.i"

;
; ******************************************************************
;                               MACROS
;                              --------
;

; General Instructions :
;-----------------------
	IncDir	"AmigaGS:Macros/"
	Include	"libraries.macro"

; Devices libraries Instructions :
;---------------------------------
	IncDir	"AmigaGS:Macros/Devices/"

; Graphics libraries Instructions :
;----------------------------------
	IncDir	"AmigaGS:Macros/Graphics/"
	Include	"DisplayAGA.macro"
	Include	"ScreensAGA.macro"
	Include	"FXMosaic.Macro"

; Mathematics Libraries Instructions :
;-------------------------------------
	IncDir	"AmigaGS:Macros/Math/"

; Memory libraries Instructions :
;--------------------------------
	IncDir	"AmigaGS:Macros/Memory/"
	Include	"MemoryBanks.macro"

; System libraries Instructions :
;--------------------------------
	IncDir	"AmigaGS:Macros/System/"
	Include	"System.Macro"

