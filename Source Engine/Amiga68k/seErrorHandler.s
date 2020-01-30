
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.30                     *
; * Last Update : ----.--.--              *
; * Version : 0.1                         *
; * File : Source Engine Error Handler    *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the ErrorHandler system
; 
; castErrorID ErrorID (MACRO)			       ; Cast an error using its ID
; castCustomErrorName ERRORNAME (MACRO) 	   ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; castError( D0=ErrorID )                      ; Cast an error using its ID
; castCustomError (A0=ERRORNAME)               ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; castFinalError (INTERNAL)

; *********************************************
; MACRO to simplify error casting inside the Source Engine methods
; castErrorID ErrorID (MACRO)			       ; Cast an error using its ID
castErrorID		MACRO
	move.l 	#\1,d0
	bra.l 	castError
				ENDM

; *********************************************
; MACRO to simplify error casting inside the Source Engine methods
; castCustomErrorName ERRORNAME (MACRO) 	   ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
castCustomErrorNAME		MACRO
	move.l 	#\1,a0
	bra.l 	castCustomError
				ENDM


; *********************************************
; Cast an existing error using its ID number
; INPUT : D0 = ErrorID
castError:
	lea.l	error000,a0
	Lsl.l 	#2,d0
	add.l	d0,a0
	move.l 	a0,castedError
	bra.b	castFinalError

; *********************************************
; Cast a custom error using its label reference to the error text
; INPUT : A0 = pointer to the error text
castCustomError:
	move.l 	a0,castedError
; *********************************************
; Final method to cast the error through an IntuitionLib requester
castFinalError:
	quitEngine 									; Close the Engine before output the error requester
	openIntuitionLib 							; reOpen the IntuitionLib as it was closed by quitEngine
	; Open the requester to display the error, wait to close button and close the requester.
	closeIntuitionLib							; close IntuitionLib
	; Quit the program..
	moveq	#0,d0
	rts

castedError:	dc.l	0
errorPos:
	dc.l 	error000,error001,error002,error003,error004
	dc.l 	error005,error006,error007,error008,error009

error000:	dc.b 	"",0
error001:	dc.b 	"",0
error002:	dc.b 	"",0
error003:	dc.b 	"",0
error004:	dc.b 	"",0
error005:	dc.b 	"",0
error006	dc.b 	"",0
error007:	dc.b 	"",0
error008:	dc.b 	"",0
error009:	dc.b 	"",0
