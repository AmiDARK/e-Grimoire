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
bTypeStruct		equ	10		; Byte 10 for structures/types

; *****************************************************
; 3. Objects variables types :
bTypeMemBlock	equ 12		; Byte 10 for Memory Blocks (Exclusive)

; *****************************************************
; Available Variables Type Constant values
TypeInt			equ	2^bTypeInt			; = 1
TypeFlt 		equ 2^bTypeFlt			; = 2
TypeStr			equ 2^bTypeStr 			; = 4
TypeNewStr 		equ 2^bTypeNewStr 		; = 8
TypeStackNewStr	equ 2^bTypeStakNewStr 	; = 16
TypeDim			equ 2^bTypeDim 			; = 256
TypeDynArr		equ	2^bTypeDynArr 		; = 512
TypeStruct 		equ 2^bTypeStruct		; = 1024
TypeMemBlock	equ 2^bTypeMemBlock 	; = 4096