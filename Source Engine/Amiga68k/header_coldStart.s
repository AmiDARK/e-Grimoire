
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : header_coldStart               *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the hearth of the Amiga68k Source Engine.
; It handle all setup stuffs, and all releases.

	; Source Engine Internal Structures
	#include "sys_struct_macros.s" 		; Includes MACROS to define system internal structures sddataReset, SetL, SetW, SetB, countDatas
	#include "sys_structures.s"         ; Includes Source Engine internal structures.

	#include "sys_lib_macros.s" 		; Includes MACROS to exeCall, dosCall, graphicsCall, intuitionCall, layersCall


coldStart MACRO



		ENDM

; Backup the memory pointer to the Source Engine Internal Structure
SysStructBackyp:	dc.l	0
