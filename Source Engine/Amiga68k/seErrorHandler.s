
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
; CastErrorID ErrorID (MACRO)			       ; Cast an error using its ID
; CastCustomErrorName ERRORNAME (MACRO) 	   ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; CastError( D0=ErrorID )                      ; Cast an error using its ID
; CastCustomError (A0=ERRORNAME)               ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; CastFinalError (INTERNAL) 				   ; Create the final error (Requester) and close the engine.

; *********************************************
; MACRO to simplify error casting inside the Source Engine methods
; castErrorID ErrorID (MACRO)			       ; Cast an error using its ID
CastErrorID		MACRO
	move.l 	#\1,d0
	bra.l 	castError
				ENDM

; *********************************************
; MACRO to simplify error casting inside the Source Engine methods
; castCustomErrorName ERRORNAME (MACRO) 	   ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
CastCustomErrorNAME		MACRO
	move.l 	#\1,a0
	bra.l 	castCustomError
				ENDM



; Methods CastError, CastCustomError and CastFinalError must follows for continuity.

; *********************************************
; Cast an existing error using its ID number
; INPUT : D0 = ErrorID
CastError:
	lea.l	error000,a0
	Lsl.l 	#2,d0
	add.l	d0,a0

; *********************************************
; Cast a custom error using its label reference to the error text
; INPUT : A0 = pointer to the error text
CastCustomError:
	move.l 	a0,castedError

; *********************************************
; Final method to cast the error through an IntuitionLib requester
CastFinalError:
	quitEngine 									; Close the Engine before output the error requester
	openIntuitionLib 							; reOpen the IntuitionLib as it was closed by quitEngine
	; Open the requester to display the error, wait to close button and close the requester.
	closeIntuitionLib							; close IntuitionLib
	; Quit the program..
	moveq	#0,d0
	rts

; *********************************************
; To store temporarly the pointer of the true message of the casted error.
castedError:	dc.l	0

; *********************************************
; List of all true error messages in order.
errorPos:
	dc.l 	error000,error001,error002,error003,error004
	dc.l 	error005,error006,error007,error008,error009

; *********************************************
; Error names that can be used as reference for the CastErrorID Macro :
InvalidStackVarID		equ		1		; "Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15."
VariableIsNotAString 	equ		2		; "The entered variable is not a STRING."
VariableIsNotAnInteger	equ		3		; "The entered variable is not an INTEGER."
ValueIsNotAnInteger 	equ		4		; "The value entered is not an INTEGER."

; *********************************************
; True error messages cast through the Intuition Requester to inform user of what happened.
error000:	dc.b 	"Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15",0
error001:	dc.b 	"The entered variable is not a STRING.",0
error002:	dc.b 	"The entered variable is not an INTEGER.",0
error003:	dc.b 	"The value entered is not an INTEGER.",0
error004:	dc.b 	"",0
error005:	dc.b 	"",0
error006	dc.b 	"",0
error007:	dc.b 	"",0
error008:	dc.b 	"",0
error009:	dc.b 	"",0
