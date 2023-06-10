
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.03.28              *
; * Version : 0.3                         *
; * File : game Engine for Source Engine  *
; * Author : Frederic Cordier             *
; *****************************************
; This file is formatted to makes the Source Engine being compiled under any
; Motorola 68k MACRO assembler (like Devpac3 for example) for Amiga OS 1.3 to 3.x
; *********************************************


; 1. We must firstly include this header file as it contains everything to setup the engine.
;    As assembler will include it at beginning, it will be executed before the 'gameStart' label.
  include     "coresrc/grimoire-coldStart.asm"

; ************************************ Start Grimoire System
    grimoireStartupSequence
; *********************************************
; 2. You can add additional source code files here with procedure and classes.
;   include "Include Your Additional Procedures & Classes files here"
; *********************************************
; 3. The main Source Code is located here. It is is the program to run using the Source Engine.

startHere:

;  getBestScreenMode #320,#256,#8,#0
  ; 1. Create modify variables that are Strings.
  SetString LoopString,<"Here is the string to output 5 Times">
  SetString LoopString2,<"Here is the String to ouput 2 times * 5 times">
  SetString LoopString3,<"Here is the String to ouput 3 times * 5 times">

  SetInteger iLoop,0
  SetInteger jLoop,0
  SetInteger kLoop,0

  BasicGOSUB callLoops

;  ; 1. Create the global string to send to the procedure
  SetString Global1,<"Here is a global String to send to a procedure as parameter/argument">
;  ; 2. Call the procedure with the global String as parameter/argument
  callProcedure zeTest,Global1    ; Send the global string content to the procedure.
;  ; 7. Create Global String to receive a string from the Procedure
  SetString returnedString
;  ; 8. Get the string from the procedure output.
  getProcedureReturn returnedString
;  ; 9. Log the String from the Procedure output
  logString returnedString

  BasicGOTO reachTheEnd

  Procedure zeTest,FromGlobal,AsString          ; ****************** ARGUMENT READING SHOULD BE OK NOW.
     ; 3. Log the String received from global variable as a procedure parameter/argument
     logString FromGlobal                  ; Log global string received in the procedure
     ; 4. Create a local String to test local variables
     SetString Local1,<"Here is a String created locally for the procedure zeTest">
     ; 5. Log the local String to check that local variables are correctly created.
     logString Local1                 ; Log Procedure local string
     ; 6. Create a local String to send it as output for global variable.
     SetString Local2,<"Here is the String returned from the Procedure using getProcedureReturn">
  EndProcedure Local2

callLoops:
  BasicFOR iLoop,0,4,1   ; For iLoop=0 to 4 Step 1
    logString LoopString
    BasicFOR jLoop,2,3,1 ; For jLoop=2 to 3 step 1
      logString LoopString2
    BasicNEXT                     ; next jLoop
    BasicFOR kLoop,0,2,1 ; For kLoop=0 to 2 step 1
      logString LoopString3
    BasicNEXT                     ; next kLoop
  BasicNEXT                       ; next iLoop

  BasicRETURN

reachTheEnd:

; ************************************ Quit Grimoire System
  grimoireLeaveEngine