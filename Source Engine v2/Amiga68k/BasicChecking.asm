
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
  grimoireStartupSequence                                      ; Start Grimoire System

; *********************************************
; 2. You can add additional Includes here with procedure and classes.
;   include "Include Your Additional Procedures & Classes files here"

; *********************************************
; 3. The main Source Code is located here. It is is the program to run using the Source Engine.
startHere:

;  getBestScreenMode #320,#256,#8,#0

  ; *********************************************************************************************** 
  ; * Test 1 : Global mutable strings and nested BasicFOR/NEXT.   *
  ; *-------------------------------------------------------------*
  ; *          The callLoops subroutine logs three global strings *
  ; *          through nested loop blocks.                        *
  ; *************************************************************** 
  ; Create the Strings variables that will be used for the For/Next loops tests outputs.
  SetString LoopString,<"Here is the string to output 5 Times">
  SetString LoopString2,<"Here is the String to ouput 2 times * 5 times">
  SetString LoopString3,<"Here is the String to ouput 3 times * 5 times">
  ; Create the Integer variables that will be used for the For/Next loops.
  SetInteger iLoop,0
  SetInteger jLoop,0
  SetInteger kLoop,0
  ; Use a Basic Gosub style command to call the Test 1 subroutine.
  BasicGOSUB callLoops

  ; *********************************************************************************************** 
  ; * Test 2 : Send a global mutable string to a procedure.          *
  ; *----------------------------------------------------------------*
  ; *          The procedure receives it as a local string reference *
  ; *          and logs it from inside the procedure.                *
  ; ******************************************************************
  SetString Global1,<"Here is a global String to send to a procedure as parameter/argument">
  callProcedure zeTest,Global1    ; Send the global string content to the procedure.


  ; *********************************************************************************************** 
  ; * Test 3 : Return a local mutable string from a procedure.      *
  ; *---------------------------------------------------------------*
  ; *          The returned local buffer is recovered into a global *
  ; *          mutable string using getProcedureReturn.             *
  ; *****************************************************************
  SetString returnedString
  getProcedureReturn returnedString
  logString returnedString


  ; ***********************************************************************************************
  ; * Test 4 : Return a static string from a procedure.             *
  ; *---------------------------------------------------------------*
  ; *          The static dc.b content is copied into a global      *
  ; *          mutable string receiver.                             *
  ; *****************************************************************
  callProcedure zeStaticTest
  SetString returnedStaticString
  getProcedureReturn returnedStaticString
  logString returnedStaticString


  ; *********************************************************************************************** 
  ; * Test 5 : BasicLEN and BasicIF/THEN/ELSE/ENDIF.                *
  ; *---------------------------------------------------------------* 
  ; *          The returned static string is 76 text characters     *
  ; *          plus the final LF byte emitted before the zero byte. *
  ; *          BasicLEN must therefore return 77.                   *
  ; *          This block also checks nested IFs, NotEqual, and     *
  ; *          one expected ELSE branch.                            *
  ; ***************************************************************** 
  ; We get the length in bytes of the string returned by the procedure
  SetInteger returnedStaticStringLen,0
  SetInteger basicIfExpectedLen,77
  SetInteger basicIfLowerLen,76
  SetInteger basicIfUpperLen,78
  BasicLEN returnedStaticString,returnedStaticStringLen

  ; **************************************************** Condition Level 1.1 - Start
  BasicIF returnedStaticStringLen,Equal,#77
    BasicTHEN
      logDirectString basicLenOk,<"BasicLEN static return length OK">

      ; ************************************************ Condition Level 2.1 - Start
      BasicIF returnedStaticStringLen,Superior,#0
        BasicTHEN
          logDirectString basicIfNestedOk,<"BasicIF nested comparison OK">

          ; ******************************************** Condition Level 3.1 - Start
          BasicIF returnedStaticStringLen,NotEqual,#76
            BasicTHEN
              logDirectString basicIfNotEqualOk,<"BasicIF not equal comparison OK">
            BasicELSE
              logDirectString basicIfNotEqualKo,<"BasicIF not equal comparison KO">
          BasicENDIF
          ; ******************************************** Condition Level 3.1 - Ended

        BasicELSE
          logDirectString basicIfNestedKo,<"BasicIF nested comparison KO">
      BasicENDIF
      ; ************************************************ Condition Level 2.1 - Ended

      ; ************************************************ Condition Level 2.2 - Start
      BasicIF returnedStaticStringLen,Equal,#76
        BasicTHEN
          logDirectString basicIfFalseThenKo,<"BasicIF false THEN should not be output">
        BasicELSE
          logDirectString basicIfElseOk,<"BasicIF ELSE comparison OK">
      BasicENDIF
      ; ************************************************ Condition Level 2.2 - Ended

      ; ************************************************ Condition Level 2.3 - Start
      ; Test Inferior using two direct integer values.
      BasicIF #40,Inferior,#50
        BasicTHEN
          logDirectString basicIfDirectInferiorOk,<"BasicIF direct Inferior comparison OK">
        BasicELSE
          logDirectString basicIfDirectInferiorKo,<"BasicIF direct Inferior comparison KO">
      BasicENDIF
      ; ************************************************ Condition Level 2.3 - Ended

      ; ************************************************ Condition Level 2.4 - Start
      ; Test SuperiorOrEqual using one variable and one direct integer value.
      BasicIF returnedStaticStringLen,SuperiorOrEqual,#77
        BasicTHEN
          logDirectString basicIfSuperiorOrEqualOk,<"BasicIF SuperiorOrEqual comparison OK">
        BasicELSE
          logDirectString basicIfSuperiorOrEqualKo,<"BasicIF SuperiorOrEqual comparison KO">
      BasicENDIF
      ; ************************************************ Condition Level 2.4 - Ended

      ; ************************************************ Condition Level 2.5 - Start
      ; Test InferiorOrEqual using two integer variables.
      BasicIF returnedStaticStringLen,InferiorOrEqual,basicIfExpectedLen
        BasicTHEN
          logDirectString basicIfInferiorOrEqualOk,<"BasicIF InferiorOrEqual comparison OK">
        BasicELSE
          logDirectString basicIfInferiorOrEqualKo,<"BasicIF InferiorOrEqual comparison KO">
      BasicENDIF
      ; ************************************************ Condition Level 2.5 - Ended

      ; ************************************************ Condition Level 2.6 - Start
      ; Test Inferior using two integer variables.
      BasicIF returnedStaticStringLen,Inferior,basicIfUpperLen
        BasicTHEN
          logDirectString basicIfVarInferiorOk,<"BasicIF variable Inferior comparison OK">
        BasicELSE
          logDirectString basicIfVarInferiorKo,<"BasicIF variable Inferior comparison KO">
      BasicENDIF
      ; ************************************************ Condition Level 2.6 - Ended

      ; ************************************************ Condition Level 2.7 - Start
      ; Test the minimal BasicIF + BasicTHEN + BasicENDIF block, without BasicELSE.
      BasicIF basicIfLowerLen,Inferior,returnedStaticStringLen
        BasicTHEN
          logDirectString basicIfWithoutElseOk,<"BasicIF without ELSE comparison OK">
      BasicENDIF
      ; ************************************************ Condition Level 2.7 - Ended

    BasicELSE
      logDirectString basicLenKo,<"BasicLEN static return length KO">
  BasicENDIF
  ; **************************************************** Condition Level 1.1 - Ended

  BasicGOTO reachTheEnd


  ; *********************************************************************************************** TEST 1 SUB-PROGRAM
  ; * Subroutine used by Test 1.                                     *
  ; *----------------------------------------------------------------*
  ; * It checks nested BasicFOR/NEXT execution using global strings. *
  ; ******************************************************************
  BasicLABEL callLoops
  BasicFOR iLoop,0,4,1                                ; For iLoop=0 to 4 Step 1
    logString LoopString
    BasicFOR jLoop,2,3,1                              ; For jLoop=2 to 3 step 1
      logString LoopString2
    BasicNEXT                                         ; next jLoop
    BasicFOR kLoop,0,2,1                              ; For kLoop=0 to 2 step 1
      logString LoopString3
    BasicNEXT                                         ; next kLoop
  BasicNEXT                                           ; next iLoop
  ; Return juft after the BasicGosub call.
  BasicRETURN


  ; *********************************************************************************************** TEST 2 & 3 PROCEDURE
  ; * Procedure used by Test 2 and Test 3.                           *
  ; *----------------------------------------------------------------*
  ; * It logs the received string reference, creates a local string, *
  ; * logs it, then returns another local mutable string.            *
  ; ******************************************************************
  Procedure zeTest,FromGlobal,AsString          ; Procedure Start
     logString FromGlobal                       ; Log global string received in the procedure

     SetString Local1,<"Here is a String created locally for the procedure zeTest">
     logString Local1                           ; Log Procedure local string

     SetString Local2,<"Here is the String returned from the Procedure using getProcedureReturn">
  EndProcedure Local2                           ; Procedure End return Local2 variable.


  ; *********************************************************************************************** TEST 4 PROCEDURE
  ; * Procedure used by Test 4.                                    *
  ; *--------------------------------------------------------------*
  ; * It returns a static string stored as dc.b in the executable. *
  ; ****************************************************************
  Procedure zeStaticTest
     SetStaticString StaticLocal,<"Here is a Static String returned from the Procedure using getProcedureReturn">
  EndProcedure StaticLocal

  ; Label Called by BasicGoto Macro to reach the end of the code.
  BasicLABEL reachTheEnd

; ************************************ Quit Grimoire System
  grimoireLeaveEngine
