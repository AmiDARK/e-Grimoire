
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : linesCounter                   *
; * Author : Frederic Cordier             *
; *****************************************
; This file contain macros used by PARSER to allow line counter debug system
; Line counter allow the engine to keep track to which line the code is running
; This line number can then be used by error Handler to return the line of the error.
; This is useable when debug mode is enabled.

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
