
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.01.31              *
; * Version : 0.2                         *
; * File : game Engine for Source Engine  *
; * Author : Frederic Cordier             *
; *****************************************
; This file is formatted to makes the Source Engine being compiled under any
; Motorola 68k MACRO assembler (like Devpac3 for example) for Amiga OS 1.3 to 3.x

; *********************************************
; 1. We must firstly include this header file as it contains everything to setup the engine.
;    As assembler will include it at beginning, it will be executed before the 'gameStart' label.
	include	"header_coldStart.asm"
; *********************************************
; 2. The main Source Code is located here. It is is the program to run using the Source Engine.
startHere:
	buildFullVariablesBuffer                           ; Allocate memory for the whole variables (global+local+ local recursive calls)
	buildGlobalVariables				               ; Start global data Structure here.

	SetInteger xSize,320
	SetInteger ySize,200
	SetInteger Depth,8
	SetFloat MySize,"-1.75"
	SetString resultIsOk,<"Result is OK">
	SetString resultIsNotOk,<"Result is NOT ok">
	SetString getFromProcedure
;    logGlobalString myNewName
    callProcedure zeTest,resultIsOk             ; Send the String global variable 'resultIsOk' as parameter for the function
    gerProcedureReturn getFromProcedure
;    logGlobalString myNewName

    Procedure zeTest,MyEntry,AsString
       SetString TestName,<"Here is a test for a local variable">,zeTest
       logLocalString zeTest,TestName
       logLocalString zeTest,MyEntry            ; Print out, the string received as Parameter
    EndProcedure zeTest,TestName


	DeleteGlobal						               ; Remove all global datas from memory before leaving main source code
	DeleteFullVariablesBuffer                           ; Release the memory buffer allocated for all datas.
endOfMain:
    rts                                                ; End of the Execution
; Once the "rts" call is done, the 'gameStart' program is finished. Engine will go back to the
; header_coldStart.s to execute methods to release all memories remaining under use on the engine.


myNameIs:
    dc.b    "Fred is my name",10,0
    even
everythingOk:
	dc.b 	"Everything is ok",10,0
	even

