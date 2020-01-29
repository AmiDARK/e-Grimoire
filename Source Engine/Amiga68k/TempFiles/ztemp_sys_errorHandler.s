
; ******************************************
; * Source Engine                          *
; *----------------------------------------*
; * Date : 2020.01.27                      *
; * Version : 0.1                          *
; * File : Error Handler for Source Engine *
; * Author : Frederic Cordier              *
; ******************************************
; This file contain the Error Handler for the Source Engine
;
;

; ****************************************
; Error coming from the Stack :
StkErr		Equ		512
notAsStr 	Equ 	1+StkErr	; The entered data is not a string data
notAsInt 	Equ 	2+StkErr	; The entered data is not an Integer data
notAsFlt	Equ		3+StkErr 	; The entered data is not a floating 








genError:
	







	rts









; *********************************************************** Stack Error Messages
StkErrList :
	dc.l	stk01,stk02,stk03
stk01:
 	dc.b	"The entered value is not a string",0
stk02:
 	dc.b	"The entered value is not an integer",0
stk03:
	dc.b	"The entered value is not a floating number",0




