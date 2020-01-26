; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.24                     *
; * Version : 0.1                         *
; * File : system_structures              *
; * Author : Frederic Cordier             *
; *****************************************
;



; *****************************************************
execCall		MACRO
	move.l 		$4.w,a6
	jsr 		\1(a6)
				ENDM

; *****************************************************
dosCall 		MACRO
	move.l 		a6,-(sp)
	move.l 		dosBase(a5),a6
	jsr 		\1(a6)
	move.l 		(sp)+,a6
				ENDM

; *****************************************************
graphicsCall 	MACRO
	movem.l 	d0/d1/a0/a1/a6,-(sp)
	move.l 		gfxBase(a5),a6
	jsr 		\1(a6)
	movem.l		(sp)+,d0/d1/a0/a1/a6
				ENDM

; *****************************************************
intuiCall		MACRO
	movem.l 	d0/d1/a0/a1/a6,-(sp)
	move.l 		intuitionBase(a5),a6
	jsr 		\1(a6)
	movem.l		(sp)+,d0/d1/a0/a1/a6
				ENDM

; *****************************************************
layersCall		MACRO
	movem.l 	d0/d1/a0/a1/a6,-(sp)
	move.l 		layersBase(a5),a6
	jsr 		\1(a6)
	movem.l		(sp)+,d0/d1/a0/a1/a6
				ENDM

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

; *****************************************************
; 6. This is a PARSER only macro. It is used to reset internal line counter (debug purposes).
; It must be used at the beginning of a source code emulation
lineCountReset	MACRO
	move.l 	#0,seCurrentLine(a5)
				ENDM

; *****************************************************
; 7. This is a PARSER only macro. It is used to increment the line counter (debug purposes).
; This macro will allow to set in which line of the original source code we are. It must be added
; before each new command inserted (debug purposes)
lineSet 		MACRO
	Move.l 	#\1,seCurrentLine(a5)
				ENDM

; *****************************************************
; 8. This is a PARSER only macro. It is used to add a file definition in the file list (debug purposes).
; This macro is to be called at the end of the source code, as many timaes as there are files in the project.
; It will add all file name as dc.l to use them for debug purposes
; Example : addFileToList source1, "Source1.s"
; Will give : source1: 	dc.l "Source1.s",0
addFileToList	MACRO
fl\1:
	dc.l \2,0
	Even
				ENDM

; *****************************************************
; 9. This is a PARSER only macro. It is used to define in which file we are (debug purposes).
; It must be used in conjunction with the macro #8 and be added at each new line modification macro use ( LineIncrement )
; Example : setCurrentFile source1
; Will give : Move.l #source1,FileName(a5)
setCurrentFile 	MACRO
	Move.l 	#\1,FileName(a5) 				; Makes seFileName pointer to point to the name of the chosen file
				ENDM

To do : Create a macro to get variables
Each location (global, or local inside method/function styles likes in AMOSPro, C or JAVA) own its own data memory block.
The block is initialized when the location is reached. Global data remain valid until the program ends
but local data are deleted when a method is leaved (EndFunction/EndProcedure)
It is then possible to store the current data memory block in a register(a5) then we can load/save data easily
Firstly I must set macro that allow the creation of the data structure. CReation will be done when the command Procedure/Function will be called.
The parser will have to check inside the procedure all datas that are created and then list them in order to create the structure and close its creation
it will consist in a set of macro to :
- Start data definition
- Insert data (.l, .f, .string )
- End data definition
- Allocate (local) data definition.
- Allocate (global) data definition.
- Release (local) data definition.
- Release (global) data definition
Start data definition will call sedataReset to reset counter
Add a data will work with setL for integer, float, string, pointer an boolean (=0 or =1)
Data access can be made using macros to load/save data value.
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
	

; **************************************************** Internal Source Engine system_structures

	sedataReset 							; Reset counter for data list
	; *************************************************************** Internal
	setL	Task,1 							; The Source Engine Task
	setB	IsAgaDetected,1					; = 0 if ECS, =1 if AGA
	setB	unused1,1 						; To word alignment.
	; *************************************************************** OS Libraries
	setL 	dosBase,1 						; Pointer to the dos.library
	setL	gfxBase,1						; Pointer to the graphics.library
	setL	intuitionBase,1					; Pointer to the Intuition.library
	setL	layersBase,1 					; Pointer to the Layers.library

	; *************************************************************** Data Areas for global/local datas
	setL 	globalDatas,1 					; Pointer to the global data definition of the program (deleted at the end of the program)
	setL 	localDatas,1 					; Pointer to the current procedure/Function/ClassMethod data area (deleted when it is quitted)
	setL	ParametersList,1 				; Pointer to the list of parameters to send to the method/function

	; *************************************************************** Screens Datas
seMaxScreens	equ		16					; We currently handle a maximum of 16 screens
	setL	Screens,seMaxScreens			; Screens structures
	setL	ScrPri,seMaxScreens				; Screens priority list
	setW 	CurrentScreen 					; ScreenID ( 0-seMaxScreens-1) to Define in which screen drawing will be done

	; *************************************************************** Copper List support
	setL	ForceRefresh,1 					; Data to define the required level of refreshing (Coppers, Screens, etc.)
	setL	CopLogic,1						; Pointer of memory block for logic copper (non visible one)
	setL	CopView,1						; Pointer of memory block for current copper (used to display screen)
	setL	CopSprites,1 					; Relative shifting from the start of copper to reach the 1st sprite.
	setL	CopPalettes,1 					; Relative shifting from the start of copper to reach the 1st color of the palette.

	; *************************************************************** Blitter Objects
	setL	BobBank,1 						; Pointer of memory block that define Blitter obejcts

	; *************************************************************** Debug datas
	setL 	CurrentLine,1 					; Where is the run in the current source code ?
	setL 	FileName,1 						; Pointer to the name of the CurrentFile
	; *************************************************************** Global structure length
	countData	SysStructLen 				; The length in bytes of the structure defined above.




; **************************************************** Screen Source Engine system_structures

	sedataReset 							; Reset counter for data list
	; *************************************************************** Internal
seMaxPalette 	equ		256
	setL 	EcPhysic,8 						; Space to handle max 8 bitplanes
	setL 	EcLogic,8						; Space to handle max 8 bitplanes
	setW 	bplAmount,1 					; Store the bitmaps amount 
	setL 	ColorAmount,1 					; Store the amount of colors in the screen
	setL 	scrCon0,1 						; BplCon0 datas
	setL 	scrCon1,1 						; BplCon1 datas
	setL 	scrCon2,1 						; BplCon2 datas
	setL 	scrCon3,1 						; BplCon3 datas
	setW 	dpf2cshift,1 					; Define which color palette is used for 2nd layer in dual playfield

	setL 	colPalette,seMaxPalette			; Store the 256 colors of the screen
	countData	ScrStructLen 				; The length in bytes of the structure defined above.
