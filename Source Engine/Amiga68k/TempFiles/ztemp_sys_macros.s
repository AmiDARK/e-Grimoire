
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : sys_macros                     *
; * Author : Frederic Cordier             *
; *****************************************
; This file contain all system sys_macros




; To do : Create a macro to get variables
; Each location (global, or local inside method/function styles likes in AMOSPro, C or JAVA) own its own data memory block.
; The block is initialized when the location is reached. Global data remain valid until the program ends
; but local data are deleted when a method is leaved (EndFunction/EndProcedure)
; It is then possible to store the current data memory block in a register(a5) then we can load/save data easily
; Firstly I must set macro that allow the creation of the data structure. CReation will be done when the command Procedure/Function will be called.
; The parser will have to check inside the procedure all datas that are created and then list them in order to create the structure and close its creation
; it will consist in a set of macro to :
; - Start data definition
; - Insert data (.l, .f, .string )
; - End data definition
; - Allocate (local) data definition.
; - Allocate (global) data definition.
; - Release (local) data definition.
; - Release (global) data definition
; Start data definition will call sedataReset to reset counter
; Add a data will work with setL for integer, float, string, pointer an boolean (=0 or =1)
; Data access can be made using macros to load/save data value.
; *****************************************************
; 5. This macro allow the parser to directly send a data in a memory
UpdateInt 		MACRO
				ENDM

; *****************************************************
; 4. This macro load an integer data in a register. It is useful 
LoadLocalInt 		MACRO
	move.l 		localDatas(a5),a6
	move.l 		\1(a6),\2
				ENDM


; *****************************************************
; 1. This Macro start the local variables definition
StartLocalVars 	MACRO
eCount			SET 0
				ENDM

; *****************************************************
; 2. This Macro add an undefined type var to the list
AddLocalVar 	MACRO
	setL 		\1,1 						; Add the value itself
	setW 		\1,1						; The 2 bytes will store the Data Type
				ENDM

; *****************************************************
; 3. Close the varList
EndLocalVars 	MACRO
var\1	equ eCount
				ENDM
	
