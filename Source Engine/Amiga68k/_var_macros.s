; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.24                     *
; * Version : 0.1                         *
; * File : var_Macros                     *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all MACROS used to handle internal Source Engine variables (system)
; These MACRO are separated in 3 components developed to be used by the PARSER when creating "final source code"
; MACRO(s) 1 to 5 must be used in the same order to setup the Data Structure required
; MACRO(s) 6 or 7 allow to make allocation in 5 being Local(6) or Global(7)
; MACRO(s) 8 to 11 initialize Integer, Float, empty String and Static string as new (content =0 =NULL or point to a dc.b "",0)
;                         Static String can be reset to Dynamic String at run time
; MACRO(s) 11 to 13 Initialize Static Dim (fixed size) of Integer, Float and String as new (content =0 or NULL)
; MACRO(s) 14 to 16 Initialize Dynamic Array of Integer, Float and String as new (content =0 or NULL)

; *************************************************************** Internal Variables Counter
; 1. This macro reset data structure counter
; It must be used to initialize a new local/global data structure (before the 1st data of the structure)
sedataReset 	MACRO
varCount	SET 0
				ENDM

; *****************************************************
; 2. This macro insert an integer, float or string in the list
addVariable		MACRO
varCount 	SET varCount-6 				; Any data as they re direct or pointer uses 6 bytes.
var\1 		equ varCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier
				ENDM

; *****************************************************
; 3. This macro insert an integer, float or string static dim/dynamic array to the list
addArrVariable	MACRO
varCount 	SET varCount-10 				; Any data as they re direct or pointer uses 6 bytes.
var\1 		equ varCount 				; 4 bytes = data/pointer itself + 2 bytes = data type identifier + 4 Bytes dim/array size
				ENDM


; *****************************************************
; 4. This macro terminate the data structure counter and affect it s size to a variable
endDatas 		MACRO
var\1 		equ	varCount
				ENDM

; *****************************************************
; 5. Allocate the data in memory -> Output = A0
buildDatas 		MACRO
	Move.l 	var\1,d0 						; D0 = Memory size
	Move.l 	#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	move.l 	$4.w,a6 						; A6 = ExecBase
	jsr 	AllocMem(a6) 					; Call AllocMem -A A4 = MemoryBlock
	Move.l 	a0,a4 							; Move to a4 as secondary data (dim/array/string) may requires to alloc mem too
				ENDM

; *****************************************************
; 6. Makes the allocation made in 5. being stored as Local Variables.
SaveAsLocal		MACRO
	Move.l 	a0,localDatas(a5)
				ENDM

; *****************************************************
; 7. Makes the allocation made in 5. being stored as Global Variables.
SaveAsGlobal	MACRO
	Move.l 	a0,globalDatas(a5)
				ENDM

; *****************************************************
; Datas types that can be used
available_variables_type:
TypeInt		equ	1 			; Byte 1 for Integer 
TypeFlt 	equ 2			; Byte 2 for float
TypeStr		equ 4			; Byte 3 for Static String (dc.l)
TypeNewStr 	equ 8			; Byte 4 for String created with AllocMem (and that must be erased)
TypeDim		equ 16 			; Byte 5 for Dim (Integer, Float or String)
TypeDynArr	equ	32 			; Byte 6 for Dynamic Array (Integer, Float or String)

; *****************************************************
; 8. Initialize a variable : integer
SetAsInteger 	MACRO
	Move.w 		#TypeInt,\1+4(a4)
				ENDM

; *****************************************************
; 9. Initialize a variable : float
SetAsFloat	 	MACRO
	Move.w 		#TypeFlt,\1+4(a4)
				ENDM

; *****************************************************
; 10. Initialize a variable : String (empty)
SetAsString 	MACRO
	move.w 		#TypeStr,\1+4(a4)
				ENDM

; *****************************************************
; 11. Initialize a variable : String (with string set)
SetAsString 	MACRO
	move.w 		#TypeStr,\1+4(a4)
	lea.l 		dcb\1,a0
	move.l 		a0, \1(a4) 				; Save the pointer to the dc.l where the default string is located
				ENDM

; *****************************************************
; 12. Initialize a variable ; Integer Dim(\2) 
SetAsDimInteger	MACRO
	move.w 		#TypeDim+TypeInt,\1+4(a4) 		; Set as type TypeDim+TypeInt = Dim Integer(FixedSize=\2)
	move.l 		\2,d0
	move.l 		d0,\1+6(a4) 					; Set the array size
	Lsl.l 		#2,d0 							; D0 Integer Count * 4 = Total Memory Required
	Move.l 		#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	Jsr 		AllocMem(a6) 					; A6 should already contains ExecBase as BuildDatas was previously called
	move.l 		a0,\1(a4) 						; Save the pointer to the Dim Integer(\2) Datas.
				ENDM

; *****************************************************
; 13. Initialize a variable ; Float Dim(\2)
SetAsDimFloat 	MACRO
	move.w 		#TypeDim+TypeFlt,\1+4(a4) 		; Set as type TypeDim+TypeFlt = Dim Float(FixedSize=\2)
	move.l 		\2,d0
	move.l 		d0,\1+6(a4) 					; Set the array size
	Lsl.l 		#2,d0 							; D0 Integer Count * 4 = Total Memory Required
	Move.l 		#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	Jsr 		AllocMem(a6) 					; A6 should already contains ExecBase as BuildDatas was previously called
	move.l 		a0,\1(a4) 						; Save the pointer to the Dim Float(\2) Datas.
				ENDM

; *****************************************************
; 14. Initialize a variable ; String Dim(\2)
SetAsDimString 	MACRO
	move.w 		#TypeDim+TypeStr,\1+4(a4) 		; Set as type TypeDim+TypeStr = Dim String(FixedSize=\2)
	move.l 		\2,d0
	move.l 		d0,\1+6(a4) 					; Set the array size
	Lsl.l 		#2,d0 							; D0 Integer Count * 4 = Total Memory Required
	Move.l 		#Public|Clear,d1 				; D1 = Datas will be stored in fast if available and must be clear
	Jsr 		AllocMem(a6) 					; A6 should already contains ExecBase as BuildDatas was previously called
	move.l 		a0,\1(a4) 						; Save the pointer to the Dim Integer(\2) Datas.
				ENDM

; *****************************************************
; 15. Initialize a variable ; Integer Array() 
SetAsArrInteger	MACRO
	move.w 		#TypeDynArr+TypeInt,\1+4(a4) 	; Set as type TypeArr+TypeInt = Integer Array()
	; Dynamic arrays are empties at setup so, we do not do memory allocation now.
				ENDM

; *****************************************************
; 16. Initialize a variable ; Float Array()
SetAsArrFloat 	MACRO
	move.w 		#TypeDynArr+TypeFlt,\1+4(a4) 	; Set as type 8+2 = Float Array()
	; Dynamic arrays are empties at setup so, we do not do memory allocation now.
				ENDM

; *****************************************************
; 17. Initialize a variable ; String Array()
SetAsArrString	MACRO
	move.w 		#TypeDynArr+TypeStr,\1+4(a4) 	; Set as type 8+4 = Float String()
	; Dynamic arrays are empties at setup so, we do not do memory allocation now.
				ENDM

; Create the macro to modify and read datas (from DO, to D0) for integer, float, string, dim and arrays
; String must have a checking, if static then no freemem. if dynamic, uses freemem then allocate new string and copy the datas
; Make a size checking to cas error if length > 16384 for example.

; Also think about a temporar variable system (some sort of buffer)
; That may allow to be used for complex lines disassembling that do alternate calculations.
