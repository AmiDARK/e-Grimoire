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

; ***************************************************************************************************************************
; 																								SETUP VARIABLES STRUCTURES ************
;
; The following macros exists in 2 versions : 1 for global variables datas (g), 1 for local function/procedure variables datas (l).
; se[g/l]DataReset 						Start define a new variables structure 
; add[g/l]Variable (LocalGroup,)NAME 	Add a single integer, float or string in the list
; add[g/l]CpxVariable (LocalGroup,)NAME Add a a single String or a dimensionned (static or dynamic) integer, float or string
; end[g/l]Datas STRUCTURENAME			Store the size of the structure in an Integer (.l) constant
; build[g/l]Datas STRUCTURENAME			Allocate memory for the structure
; DeleteLocal 							This macro release memory previously used by a local variable structure. It must be used when
; 										a procedure or function ends or return (EndProcedure, EndFunction, Return, Return WITHVARIABLE)
; DeleteGlobal 							This macro release memory previously used for the main source as global variables. It must be
; 										used at the end of a program (after last line or after an 'end' function call that quit the application.)
; 										Error handler must also call this macro when exiting the program
;
; Local variables always contain the LocalGroup name before the variable name. It is added to avoid conflict with identical variables names in two
; different procedure/function. it is used to store the variable name under the form : LocalGroup_NAME
;
; TO DO : Update the SaveAsLocal & DeleteLocal macros to handle multiple local variables groups (case of a function entering another function)
;
; *************************************************************
; 1. How to create global variables :
;---------------------------------
; Global datas are inserted directly at the beginning of the Source code. As they are definition, this will not add code.
; Only the "buildgDatas" insert will be added as direct source code to allocate memory for the global variables.
; Here is how to proceed :
; 1. Insert : "segDataReset"
; 2. Insert all singles variables with "addgVariable" and all complex variables with "addgCpxVariable"
; 3. Once done, insert "endgDatas"
; 4. Insert "buildgDatas"
; 5. Macro "DeleteGlobal" must be used as the last line of the source code conversion.

; *************************************************************
; 2. How to create local variables :
;-----------------------------------
; Local variables are variables that are available only from inside a function or method.
; They must be inserted at the beginning of the method/function/procedure
; here is how to proceed :
; 1. Insert : "selDataReset"
; 2. Insert all singles variables with "addlVariable" and all complex variables with "addlCpxVariable"
; 3. Once done, insert "endlDatas"
; 4. Insert "buildlDatas"
; 5. Macro "DeleteLocal" must be inserted at the end of a procedure or function

; *************************************************************
; 3. How to create a new procedure or function :
; ----------------------------------------------
; A procedure or function is a complex task as it can contain parameters.
; So, here is how the procedure must be created
; 1. Insert : "Procedure" or "Function" + NAME
; 2. Insert local variables for the variables that have to be created inside the procedure/function
; 3. Pull from Stack all the parameters variables.
;
; Exemple :
;----------
; Procedure define :
;         Procedure LoadImage( FileName As String, Index As Integer )
;            Path As String;
;         EndProcedure
;
; Procedure call : LoadImage( "MyImage.jpg", 4 )
;
; Result :
;---------
; Procedure LoadImage
; selDataReset LoadImage
; addlVariable LoadImage,FileName
; addlVariable LoadImage,Index
; addlVariable LoadImage,Path
; endlDatas
; buildlDatas
; getLocalIntegerVarFromStack LoadImage,Index
; getLocalStringVarFromStack LoadImage,FileName
; 
; ...
; ... -> Here will be the code of the procedure itself
; ...
; DeleteLocal
; EndProcedure

; *************************************************************
; 4. How to call a procedure or function :
;-----------------------------------------
; To call a procedure of function, you must pass its parameters into the Stack.
;
; Example 1 - Procedure call : LoadImage( "MyImage.jpg", 4 )
; ----------------------------------------------------------
; pushStaticStringToStack "MyImage.jpg",1   			// 1 = TempVarID #1
; pushStaticIntegerToStack 4,2                          // 2 = TempVarID #2
; callProcedure LoadImage
;
; In this small example, variables were static values entered but you can also push global/local variables to the Stack
; Depending on what the parameters entered are
;
; Example 2 - Procedure call : LoadImage( myFileName, 4 )  			// if myFileName is a global String variable
; -------------------------------------------------------
; pushGlobalVarIntegerToStack myFileName
; pushStaticIntegerToStack 4,1                          // 1 = TempVarID #1
; callProcedure LoadImage

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
buildgDatas 		MACRO
	Move.l 	#glblSize,d0					; D0 = Memory size
	bsr.w 	AllocClrFastMem
	move.l 	a0,globalDatas(a5)
	move.l 	#glblSize,globalSize(a5)
					ENDM

; *************************************************************** Internal Variables Counter
; 1.6 This macro reset data structure counter
; It must be used to initialize a new local data structure 
selDataReset 	MACRO
varlCount	SET 0
addlVariable 	\1,prev
addlVariable 	\1,next
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
buildlDatas 		MACRO
	Move.l 	#\1_size,d0				; D0 = Memory size
	bsr.w 	AllocClrFastMem
	move.l 	#\1_Size,8(a0) 			; Save final structure size inside the memory itself
	move.l 	localDatas(a5),(a0) 	; A0.prev = previous local variables
	cmp.l 	#0,(a0) 				; If no previous local variables is available
	beq.s 	.bld1 					; then Jump -> bld1
	move.l 	(a0),a1 				; A1 = previous local variables
	move.l 	a0,4(a1)  				; A1.Next = A0
.bld1:					
					ENDM
; *****************************************************
; 1.11 Clear the current local Variables.
DeleteLocal 	MACRO
	move.l 		localDatas(a5),a1 	; A1 = Memory block
	cmp.l 		#0,a1 				; No memory block ?
	beq.s		.noLD 				; -> Jump .noLD
	Move.l 		8(a1),d0 			; D0 = Memory block size to remove
	Move.l 		(a1),localDatas(a5)	; A5 = A1.Prev = Previous local block
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
; 1.18 add a RETURN from a label
Return 			MACRO
	sub.w 	#1,gosubDepth(a5)
	bpl.s	.ok
	CastErrorID		TooMuchReturnReached
.ok:
	rts
				ENDM
