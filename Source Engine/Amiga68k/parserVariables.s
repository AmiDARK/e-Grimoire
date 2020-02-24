; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.02.12              *
; * Version : 1.0                         *
; * File : variablesSystem PARSER MACROs  *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the macro to handle the Source Engine global and locales variables system.
; It is primarly devoted to be used by the parser to create datas in the main source code (global)
; and in procedures/function (local) for a fast and convenient access to datas.
; Support for multi-depth local variables is now available.

;
; TO DO :
; - Update the SaveAsLocal & DeleteLocal macros to handle multiple local variables groups (case of a function entering another function)
; - Add EndProcedure that return Int/Float/String/Dynamic Array
; - Add Return (from procedure) that return Int/Float/String/Dynamic Array
; - Check which cases need to create a copy of the variables and which one not when pushing variable to Stack.
;

; *************************************************************** Internal Variables Counter
; 1.1 This macro reset data structure counter
; It must be used to initialize a new local/global data structure (before the 1st data of the structure)
segDataReset 	MACRO
varCount	SET 0
				ENDM

; *****************************************************
; 1.2 This macro insert a single integer, float or string in the GLOBAL data system
addgVariable	MACRO
varCount 	SET varCount-6 				; Any data as they re direct or pointer uses 6 bytes.
gl\1: 		equ varCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier
				ENDM

; *****************************************************
; 1.3 This macro insert a single String or a dimensionned (static or dynamic) integer, float or string in the GLOBAL data system
addgCpxVariable	MACRO
varCount 	SET varCount-10 			; Any data as they re direct or pointer uses 6 bytes.
gl\1: 		equ varCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier + 4 Bytes dim/array size
				ENDM

; *****************************************************
; 1.4 This macro terminate the data structure counter and affect it s size to a variable
endgDatas 		MACRO
glblSize: 		equ	varCount
				ENDM

; *****************************************************
; 1.5 Allocate the data in memory -> Output = A0
buildglobalDatas MACRO
	Move.l 	#glblSize,d0					; D0 = Memory size
	bsr.w 	AllocClrFastMem
	move.l 	a0,globalDatas(a5)
	move.l 	#glblSize,globalSize(a5)
					ENDM

; *************************************************************** Internal Variables Counter
; 1.6 This macro reset data structure counter
; It must be used to initialize a new local data structure 
selocalDataReset 	MACRO
varlCount	SET 0
addlVariable 	\1,prev_\1
addlVariable 	\1,next_\1
addlVariable    \1,finalSize
				ENDM

; *****************************************************
; 1.7 This macro insert a single integer, float or string in the local data system
addlVariable	MACRO
varlCount 	SET varlCount-6 			; Any data as they re direct or pointer uses 6 bytes.
\1\2: 		equ varlCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier
				ENDM

; *****************************************************
; 1.8 This macro insert a single String or a dimensionned (static or dynamic) integer, float or string in the local data system
addlCpxVariable	MACRO
varCount 	SET varlCount-10 			; Any data as they re direct or pointer uses 6 bytes.
\1\2: 		equ varlCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier + 4 Bytes dim/array size
				ENDM

; *****************************************************
; 1.9 This macro terminate the data structure counter and affect it s size to a variable
endlDatas 		MACRO
\1_Size: 		equ	varlCount
				ENDM

; *****************************************************
; 1.10 Allocate the data in memory -> Output = A0
buildlocalDatas MACRO
	Move.l 	#\1_size,d0				; D0 = Memory size
	bsr.w 	AllocClrFastMem
	move.l 	#\1_Size,8(a0) 			; Save final structure size inside the memory itself
	move.l 	localDatas(a5),(a0) 	; A0.prev = previous local variables
	cmp.l 	#0,(a0) 				; If no previous local variables is available
	beq.s 	.bld1 					; then Jump -> bld1
	move.l 	(a0),a1 				; A1 = previous local variables
	move.l 	a0,4(a1)  				; A1.Next = A0
.bld1:
	move.l a0,localDatas(a5)
					ENDM
; *****************************************************
; 1.11 Clear the current local Variables.
DeleteLocal 	MACRO
	move.l 		localDatas(a5),a1 	; A1 = Memory block
	cmp.l 		#0,a1 				; No memory block ?
	beq.s		.noLD 				; -> Jump .noLD
	Move.l 		(a1),localDatas(a5)	; A5 = A1.Prev = Previous local block
	Move.l 		8(a1),d0 			; D0 = Memory block size to remove
	exeCall 	FreeMem
.noLD:
				ENDM

; *****************************************************
; 1.12 Clear the global Variables.
DeleteGlobal 	MACRO
	move.l 		globalDatas(a5),a0
	Move.l 		#globalSize,d0
	exeCall 	FreeMem
	Clr.l 		globalDatas(a5)
				ENDM

;
; 1.13 Add the static string to the string buffer.
addgStaticString	MACRO
glob/1:
	dc.b	\2, 0
					ENDM


; *****************************************************
; 1.13 Start a new procedure, function or label
Procedure 		MACRO
proc_\1:
				ENDM
Function 		MACRO
proc_\1:
				ENDM
Label 		MACRO
lab_\1:
				ENDM

; *****************************************************
; 1.14 End a procedure or function
EndProcedure 	MACRO
	sub.w 	#1,procedureDepth(a5) 			; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
	bpl.s	.ok
	CastErrorID		TooMuchEndProcedureReached
.ok:
	DeleteLocal
	rts
				ENDM

; *****************************************************
; 1.14B End a procedure or function returning an Integer
EndProcedure 	MACRO
	sub.w 	#1,procedureDepth(a5) 			; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
	bpl.s	.ok
	CastErrorID		TooMuchEndProcedureReached
.ok:
	DeleteLocal
	pushStaticIntegerToStack	\1,0
	rts
				ENDM

; *****************************************************
; 1.14C End a procedure or function returning a Float Number
EndProcedure 	MACRO
	sub.w 	#1,procedureDepth(a5) 			; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
	bpl.s	.ok
	CastErrorID		TooMuchEndProcedureReached
.ok:
	DeleteLocal
	pushStaticFloatToStack	\1,0
	rts
				ENDM

; *****************************************************
; 1.14D End a procedure or function returning a String
EndProcedure 	MACRO
	sub.w 	#1,procedureDepth(a5) 			; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
	bpl.s	.ok
	CastErrorID		TooMuchEndProcedureReached
.ok:
	DeleteLocal
	pushStaticStringToStack	\1,0
	rts
				ENDM


; *****************************************************
; 1.15 call a procedure of function
callProcedure	MACRO
	add.w 	#1,procedureDepth(a5) 			; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
	cmp.w	#16384,procedureDepth(a5)
	blt.s	.ok
	CastErrorID		TooMuchProcedureCallsWithoutReturn
	bsr.l 	proc_\1
				ENDM


; *****************************************************
; 1.16 add a GOSUB to a Label
Gosub 			MACRO
	cmp.w 	#0,procedureDepth(a5) 			; Check if we are inside a Procedure or Function
	beq.s	.ok 							; NO -> Jump .ok
	CastErrorID		GosubNotAllowedFromInsideAProcedure
.ok:
	add.w 	#1,gosubDepth(a5)
	cmp.w	#16384,gosubDepth(a5)
	blt.s	.ok2
	CastErrorID		TooMuchGosubCalledWithoutReturn
.ok2:
	bsr.l 	lab_\1
				ENDM

; *****************************************************
; 1.17 add a GOTO to a label (must not be used on Procedure nor function)
Goto 			MACRO
	cmp.w 	#0,procedureDepth(a5) 			; Check if we are inside a Procedure or Function
	beq.s	.ok 							; NO -> Jump .ok
	CastErrorID		GosubNotAllowedFromInsideAProcedure
.ok:
	bra.l 	lab_\1
				ENDM

; *****************************************************
; 1.18 add a RETURN from a label (called with Gosub) or from inside a Procedure
Return 			MACRO
	cmp.w 	#0,procedureDepth(a5) 			; Check if we are inside a Procedure or Function
	beq.s	.fromGosub
	sub.w	#1,procedureDepth(a5)
	DeleteLocal
	rts
.fromGosub:
	sub.w 	#1,gosubDepth(a5)
	bpl.s	.ok
	CastErrorID		TooMuchReturnReached
.ok:
	rts
				ENDM
