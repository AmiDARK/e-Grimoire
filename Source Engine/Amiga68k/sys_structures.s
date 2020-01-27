; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.24                     *
; * Version : 0.1                         *
; * File : system_structures              *
; * Author : Frederic Cordier             *
; *****************************************
;

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
	setL 	globalSize,1 				 	; Size of the global Data Structure
	setL 	localDatas,1 					; Pointer to the current procedure/Function/ClassMethod data area (deleted when it is quitted)
	setL 	localSize,1 					; Size of the Local Data structure
	setL	ParametersList,1 				; Pointer to the list of parameters to send to the method/function
	setL 	StackAdr,1 						; Current Position in the parameters, temp values Stack
	setL 	ParamsSize,1 					; Size of the stack in bytes

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
