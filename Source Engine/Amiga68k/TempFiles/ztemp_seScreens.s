; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.24                     *
; * Version : 0.1                         *
; * File : seScreens.s                    *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the methods that handle screens.
; It also contains MACRO that allow a fast and easy use of
; these methods directly from any assembler compiler that
; can handle MACRO


; *****************************************************
; 1. This macro define the label to start a new method/function
SourceMethod	MACRO
sm\1:
				ENDM
; *****************************************************
; 2. This macro define the end of a method/function with a return
SourceEndMethod	MACRO
	rts
				ENDM

; *****************************************************
; 3. This macro insert a call to the error Handler with error code
errorCall		MACRO
\1:
	move.l 	#\2,d0
	bra 	genError
				END


; *****************************************************************
; * Method : Screen Open Number, Width, Height, Depth, Type       *
; *                        D0      D1     D2      D3     D4       *
; *---------------------------------------------------------------*
; * This method will create a screen if it does not already exist *
; * otherwise it will return an error through the error handler   *
; *---------------------------------------------------------------*
; * D0 = Screen Number ( 0 - 15 )                                 *
; * D1 = Screen Width ( must be multiple of 16 pixels )           *
; * D2 = Screen Height                                            *
; * D3 = Depth ( 1 - 8 bitplanes )                                *
; * D4 = Type ( Lowres, Hires, SHires, UHres, EHB, HAM, DPF )     *
; *---------------------------------------------------------------*
; * MACRO : seScreenOpen Number, Width, Height, Depth, Type       *
; *****************************************************************
MACRO seScreenOpen
	Move.l 	#\1,d0 					; D0 = Screen Number
	Move.l 	#\2,d1					; D1 = Screen Width (in pixels)
	Move.l  #\3,d2 					; D2 = Screen Height (in lines)
	Move.l  #\4,d3 					; D3 = Screen Depth (in bitplanes 1-6 ECS, 1-8 AGA)
	Move.l	#\5,d4 					; D4 = Screen Type ( Lowres, Hires, SHires, UHres, EHB, HAM, DPF )
	Jsr 	smScreenOpen
ENDM

SourceMethod ScreenOpen
	; *****************************************************
	; 1. Check if Screen ID is correct
	cmp.l 	#0,d0
	bmi		soErr0 					; soErr0 = Screen ID is invalid ( valid 0 - (seMaxScreens-1) )
	cmp.l 	#seMaxScreens,d0
	bge		soErr0 					; soErr0 = Screen ID is Invalid ( valid 0 - (seMaxScreens-1) )
	; *****************************************************
	; 2. check if the screen exists
	lea.l 	#seScreens(a5),a0
	move.w 	d0,d5 					; D5 = D0 = Screen Number
	lsl.w 	#2,d5 					; D5 = *4 (.l alignment)
	Move.l 	(a0,d0.w),a0
	bne 	soErr1 					; soErr1 = Screen Already exists
	; *****************************************************
	; 3. Check for bitplanes limits
	cmpi.l 	#0,d0
	blt		soErr2 					; soErr2 = Bitplanes amount is invalid ( valid > 0 )
	cmp.b 	#1,seIsAgaDetected(a5)
	bne.b 	soCr1
	cmp.l 	#8,d0 					; Higher limit is 8 bitplanes on AGA
	bgt		soErr3 					; soErr3 = Bitplanes amount is invalid ( valid < 8 on AGA )
	bra.b 	soCr2
soCr1:
	cmp.l 	#6,d0 					; Higher limit is 6 bitplanes on ECS
	bgt 	soErr4					; soErr4 = Bitplanes amount is invalid ( valid < 6 on ECS )
soCr2:
	; *****************************************************
	; 5. Check for width limits
	cmp.l 	#320,d1
	blt 	soErr5 					; soErr5 = Screen Width is invalid ( valid 320 - 4096 )
	cmp.l 	#4096,d1
	bgt 	soErr5 					; soErr5 = Screen Width is invalid ( valid 320 - 4096 )
	; *****************************************************
	; 6. Check for width multiple of 32
	Move.l	d1,d5
	And.l 	#$1FE0,d5
	Cmp.l 	d0,d5
	bne 	soErr6 					; soErr6 = Screen Width is invalid (Width must be multiple of 32 pixels)
	; *****************************************************
	; 7. Check for screen height
	Cmp.l 	#16,d2
	blt 	soErr7 					; soErr7 = Screen Height is invalid ( valid > 15 )
	; *****************************************************
	; 8. Now that everything is ok, create the Screen Structure



	bra 	soEnd
	; *****************************************************
	errorCall soErr1, 1
	errorCall soErr1, 3
	errorCall soErr1, 4
	errorCall soErr1, 4
	errorCall soErr1, 5
	errorCall soErr1, 6
	errorCall soErr1, 7
soEnd:
SourceEndMethod