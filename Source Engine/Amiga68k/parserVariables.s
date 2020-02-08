; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.02.08              *
; * Version : 0.2                         *
; * File : variablesSystem PARSER MACROs  *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the macro to handle the Source Engine variables system.
; It is primarly devoted to be used by the parser to create datas in the main source code (global)
; and in procedures/function (local) for a fast and convenient access to datas.

; ***************************************************************************************************************************
; 																								SETUP VARIABLES STRUCTURES ************
;
; seDataReset 				Start define a new variables structure
; addVariable NAME 			Add a single integer, float or string in the list
; addCpxVariable NAME 		Add a a single String or a dimensionned (static or dynamic) integer, float or string
; endDatas STRUCTURENAME	Store the size of the structure in an Integer (.l) constant
; buildDatas STRUCTURENAME	Allocate memory for the structure
; SaveAsLocal  				Update Source Engine internal structure for local variables (Function/Procedure)
; 							to use the freshly created one. This MACRO must be used just after the 'buildDatas' one.
; SaveAsGlobal 				Update Source Engine internal structure for global variables (Main source code)
;							to use the previously created one. This MACRO must be used just after the 'buildDatas' one.
; DeleteLocal 				This macro release memory previously used by a local variable structure. It must be used when
; 							a procedure or function ends or return (EndProcedure, EndFunction, Return, Return WITHVARIABLE)
; DeleteGlobal 				This macro release memory previously used for the main source as global variables. It must be
; 							used at the end of a program (after last line or after an 'end' function call that quit the application.)
; 							Error handler must also call this macro when exiting the program
;
; TO DO : Update the SaveAsLocal & DeleteLocal macros to handle multiple local variables groups (case of a function entering another function)

; *************************************************************** Internal Variables Counter
; 1.1 This macro reset data structure counter
; It must be used to initialize a new local/global data structure (before the 1st data of the structure)
seDataReset 	MACRO
varCount	SET 0
				ENDM

; *****************************************************
; 1.2 This macro insert a single integer, float or string in the list
addVariable		MACRO
varCount 	SET varCount-6 				; Any data as they re direct or pointer uses 6 bytes.
var\1 		equ varCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier
				ENDM

; *****************************************************
; 1.3 This macro insert a single String or a dimensionned (static or dynamic) integer, float or string
addCpxVariable	MACRO
varCount 	SET varCount-10 			; Any data as they re direct or pointer uses 6 bytes.
var\1 		equ varCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier + 4 Bytes dim/array size
				ENDM

; *****************************************************
; 1.4 This macro terminate the data structure counter and affect it s size to a variable
endDatas 		MACRO
var\1 		equ	varCount
				ENDM

; *****************************************************
; 1.5 Allocate the data in memory -> Output = A0
buildDatas 		MACRO
	Move.l 	var\1,d0 						; D0 = Memory size
	Move.l 	#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	exeCall AllocMem
	Move.l 	a0,a4 							; Move to a4 as secondary data (dim/array/string) may requires to alloc mem too
				ENDM

; *****************************************************
; 1.6 Makes the allocation made in 5. being stored as Local Variables.
SaveAsLocal		MACRO
	Move.l 	a0,localDatas(a5)
				ENDM

; *****************************************************
; 1.7 Makes the allocation made in 5. being stored as Global Variables.
SaveAsGlobal	MACRO
	Move.l 	a0,globalDatas(a5)
				ENDM

; *****************************************************
; 1.8 Clear the current local Variables.
DeleteLocal 	MACRO
	move.l 		localDatas(a5),a0
	Move.l 		#\1,d0
	exeCall 	FreeMem
	Clr.l 		localDatas(a5)
				ENDM

; *****************************************************
; 1.8 Clear the global Variables.
DeleteGlobal 	MACRO
	move.l 		localDatas(a5),a0
	Move.l 		#\1,d0
	exeCall 	FreeMem
	Clr.l 		localDatas(a5)
				ENDM
