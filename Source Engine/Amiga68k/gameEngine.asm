
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
	seGlobDataReset 					; Start global data Structure here.
	SetVar xSize,AsInteger,320
	SetVar ySize,AsInteger,200
	SetVar Depth,AsInteger,8
	SetVar MySize,AsFloat,"-1.75"
;   SetVar myName,AsStaticString, myNameIs
	SetVar myNewName,AsString,<"My New Name Is Frederic Cordier">

    logGlobalString myNewName
    callProcedure zeTest
    logGlobalString myNewName

    Procedure zeTest,localVarStr,AsString
        logStaticString localVarStr
    EndProcedure zeTest


	endGlobDatas						; Ensure global data structure is closed at this point
	DeleteGlobal						; Remove all global datas from memory before leaving main source code
endOfMain:
    rts                                 ; End of the Execution
; Once the "rts" call is done, the 'gameStart' program is finished. Engine will go back to the
; header_coldStart.s to execute methods to release all memories remaining under use on the engine.


myNameIs:
    dc.b    "Fred is my name",10,0
    even
everythingOk:
	dc.b 	"Everything is ok",10,0
	even

