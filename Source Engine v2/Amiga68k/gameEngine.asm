
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
	include	"src/header_coldStart.asm"
; *********************************************
; 2. The main Source Code is located here. It is is the program to run using the Source Engine.
startHere:
    buildGlobalVariables				               ; Start global data Structure here.

	SetInteger xSize,320
	SetInteger ySize,192
	SetInteger Depth,8
;	 SetFloat MySize,"-1.75"
    SetString resultIsOk,<"Result is OK">
	 SetString resultIsNotOk,<"Result is NOT ok">
;	 SetString getFromProcedureString
    callProcedure zeTest,resultIsOk                 ; ****************** REINSERT THE ARGUMENT PUSHS BEFORE TESTING.
;    getProcedureReturn getFromProcedureString
;    logGlobalString getFromProcedureString

    Procedure zeTest,MyEntry,AsString         ; ****************** ARGUMENT READING SHOULD BE OK NOW.
       SetString TestName,<"Here is a test for a local variable">
       logLocalString TestName
       logLocalString MyEntry
    EndProcedure zeTest,TestName

    logGlobalString resultIsNotOk

    DeleteGlobal						       ; Remove all global datas from memory before leaving main source code
endOfMain:
    rts                                                ; End of the Execution
; Once the "rts" call is done, the 'gameStart' program is finished. Engine will go back to the
; header_coldStart.s to execute methods to release all memories remaining under use on the engine.

