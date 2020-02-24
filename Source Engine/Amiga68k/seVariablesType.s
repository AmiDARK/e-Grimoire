; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : Supported variables types      *
; * Author : Frederic Cordier             *
; *****************************************
; This file contain the values that defines the various primitives or complexes variables types.

; *****************************************************
; 1. Primitives variables types :
bTypeInt		equ	0 		; Byte 0 for Integer 
bTypeFlt		equ 1		; Byte 1 for float
bTypeStr 		equ 2		; Byte 2 for Static String (dc.l)
bTypeNewStr		equ 3		; Byte 3 for String created with AllocMem (and that must be erased)
bTypeStakNewStr	equ 4		; Byte 4 Temporar New String (can be put to a variable without a real copy'n'paste)

; *****************************************************
; 2. Complexes variables types :
bTypeDim		equ 8 		; Byte 8 for Dim (Integer, Float or String)
bTypeDynArr		equ 9 		; Byte 9 for Dynamic Array (Integer, Float or String)

; *****************************************************
; 3. Objects variables types :
bTypeMemBlock	equ 10		; Byte 10 for Memory Blocks (Exclusive)

; *****************************************************
; Available Variables Type Constant values
TypeInt			equ	2^bTypeInt
TypeFlt 		equ 2^bTypeFlt
TypeStr			equ 2^bTypeStr
TypeNewStr 		equ 2^bTypeNewStr
TypeStackNewStr	equ 2^bTypeStakNewStr
TypeDim			equ 2^bTypeDim
TypeDynArr		equ	2^bTypeDynArr
TypeMemBlock	equ 2^bTypeMemBlock