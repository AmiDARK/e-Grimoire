; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : sys_structures_macros          *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains required macros to create the Source Engine internal structures


; *************************************************************** Internal Structures counter
; 1. This macro reset data structure counter
; It must be used to initialize a new structure (before the 1st data of the structure)
sedataReset MACRO
eCount 		SET 0
			ENDM
; *****************************************************
; 2. This macro insert an amount of integer to the counter
setL 		MACRO
eCount 		SET eCount-4*(\2)
se\1 		equ eCount
			ENDM
; *****************************************************
; 3. This macro insert an amount of word to the counter
setW 		MACRO
eCount 		SET eCount-2*(\2)
se\1		equ eCount
			ENDM
; *****************************************************
; 4. This macro insert an amount of bytes to the counter
setB 		MACRO
eCount 		SET eCount-1*(\2)
se\1 		equ eCount
			ENDM

; *****************************************************
; 5. This macro makes a variable to be set to reflect the counter value
; This macro must be used at the end of a structure definition to store the size of the structure
countData 	MACRO
se\1		equ eCount
			ENDM
