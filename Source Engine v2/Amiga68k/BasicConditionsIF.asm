; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2026.05.19                     *
; * Version : 0.1                         *
; * File : BasicConditionsIF.asm          *
; * Author : Frederic Cordier             *
; *****************************************
; This file checks every BasicIF/BasicTHEN/BasicELSE/BasicENDIF
; comparison operator with both true and false runtime results.
; *********************************************

  include     "coresrc/grimoire-coldStart.asm"
  grimoireStartupSequence                                      ; Start Grimoire System


startHere:

  ; ***********************************************************************************************
  ; * Test 1 : Create Integer reference variables.              *
  ; *-----------------------------------------------------------*
  ; *          These values are reused by the following IF      *
  ; *          comparison tests.                                *
  ; *************************************************************
  SetInteger ifLeftValue,10
  SetInteger ifEqualValue,10
  SetInteger ifLowerValue,9
  SetInteger ifUpperValue,11
  SetInteger ifSmallValue,1
  SetInteger ifBigValue,2


  ; ***********************************************************************************************
  ; * Test 2 : True comparisons for every BasicIF operator.     *
  ; *-----------------------------------------------------------*
  ; *          Each condition must execute its BasicTHEN block. *
  ; *************************************************************

  ; **************************************************** Condition Level 1.1 - Equal TRUE
  BasicIF ifLeftValue,Equal,#10
    BasicTHEN
      logDirectString ifEqualTrueOk,<"BasicIF Equal TRUE comparison OK">
    BasicELSE
      logDirectString ifEqualTrueKo,<"BasicIF Equal TRUE comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.2 - NotEqual TRUE
  BasicIF ifLeftValue,NotEqual,#11
    BasicTHEN
      logDirectString ifNotEqualTrueOk,<"BasicIF NotEqual TRUE comparison OK">
    BasicELSE
      logDirectString ifNotEqualTrueKo,<"BasicIF NotEqual TRUE comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.3 - Superior TRUE
  BasicIF ifLeftValue,Superior,#9
    BasicTHEN
      logDirectString ifSuperiorTrueOk,<"BasicIF Superior TRUE comparison OK">
    BasicELSE
      logDirectString ifSuperiorTrueKo,<"BasicIF Superior TRUE comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.4 - Inferior TRUE
  BasicIF ifLeftValue,Inferior,#11
    BasicTHEN
      logDirectString ifInferiorTrueOk,<"BasicIF Inferior TRUE comparison OK">
    BasicELSE
      logDirectString ifInferiorTrueKo,<"BasicIF Inferior TRUE comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.5 - SuperiorOrEqual TRUE
  BasicIF ifLeftValue,SuperiorOrEqual,#10
    BasicTHEN
      logDirectString ifSuperiorOrEqualTrueOk,<"BasicIF SuperiorOrEqual TRUE comparison OK">
    BasicELSE
      logDirectString ifSuperiorOrEqualTrueKo,<"BasicIF SuperiorOrEqual TRUE comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.6 - InferiorOrEqual TRUE
  BasicIF ifLeftValue,InferiorOrEqual,#10
    BasicTHEN
      logDirectString ifInferiorOrEqualTrueOk,<"BasicIF InferiorOrEqual TRUE comparison OK">
    BasicELSE
      logDirectString ifInferiorOrEqualTrueKo,<"BasicIF InferiorOrEqual TRUE comparison KO">
  BasicENDIF


  ; ***********************************************************************************************
  ; * Test 3 : False comparisons for every BasicIF operator.    *
  ; *-----------------------------------------------------------*
  ; *          Each condition must skip BasicTHEN and execute   *
  ; *          its BasicELSE block.                             *
  ; *************************************************************

  ; **************************************************** Condition Level 1.7 - Equal FALSE
  BasicIF ifLeftValue,Equal,#11
    BasicTHEN
      logDirectString ifEqualFalseKo,<"BasicIF Equal FALSE comparison KO">
    BasicELSE
      logDirectString ifEqualFalseOk,<"BasicIF Equal FALSE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.8 - NotEqual FALSE
  BasicIF ifLeftValue,NotEqual,#10
    BasicTHEN
      logDirectString ifNotEqualFalseKo,<"BasicIF NotEqual FALSE comparison KO">
    BasicELSE
      logDirectString ifNotEqualFalseOk,<"BasicIF NotEqual FALSE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.9 - Superior FALSE
  BasicIF ifLeftValue,Superior,#10
    BasicTHEN
      logDirectString ifSuperiorFalseKo,<"BasicIF Superior FALSE comparison KO">
    BasicELSE
      logDirectString ifSuperiorFalseOk,<"BasicIF Superior FALSE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.10 - Superior FALSE using lower value
  BasicIF ifSmallValue,Superior,ifBigValue
    BasicTHEN
      logDirectString ifSuperiorLowerFalseKo,<"BasicIF Superior lower FALSE comparison KO">
    BasicELSE
      logDirectString ifSuperiorLowerFalseOk,<"BasicIF Superior lower FALSE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.11 - Inferior FALSE
  BasicIF ifLeftValue,Inferior,#10
    BasicTHEN
      logDirectString ifInferiorFalseKo,<"BasicIF Inferior FALSE comparison KO">
    BasicELSE
      logDirectString ifInferiorFalseOk,<"BasicIF Inferior FALSE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.12 - Inferior FALSE using higher value
  BasicIF ifBigValue,Inferior,ifSmallValue
    BasicTHEN
      logDirectString ifInferiorHigherFalseKo,<"BasicIF Inferior higher FALSE comparison KO">
    BasicELSE
      logDirectString ifInferiorHigherFalseOk,<"BasicIF Inferior higher FALSE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.13 - SuperiorOrEqual FALSE
  BasicIF ifLeftValue,SuperiorOrEqual,#11
    BasicTHEN
      logDirectString ifSuperiorOrEqualFalseKo,<"BasicIF SuperiorOrEqual FALSE comparison KO">
    BasicELSE
      logDirectString ifSuperiorOrEqualFalseOk,<"BasicIF SuperiorOrEqual FALSE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.14 - InferiorOrEqual FALSE
  BasicIF ifLeftValue,InferiorOrEqual,#9
    BasicTHEN
      logDirectString ifInferiorOrEqualFalseKo,<"BasicIF InferiorOrEqual FALSE comparison KO">
    BasicELSE
      logDirectString ifInferiorOrEqualFalseOk,<"BasicIF InferiorOrEqual FALSE comparison OK">
  BasicENDIF


  ; ***********************************************************************************************
  ; * Test 4 : Supported argument combinations.                 *
  ; *-----------------------------------------------------------*
  ; *          BasicIF must accept direct/direct, direct/var,   *
  ; *          variable/direct, and variable/variable values.   *
  ; *************************************************************

  ; **************************************************** Condition Level 1.15 - Direct/Direct
  BasicIF #40,Inferior,#50
    BasicTHEN
      logDirectString ifDirectDirectOk,<"BasicIF direct/direct comparison OK">
    BasicELSE
      logDirectString ifDirectDirectKo,<"BasicIF direct/direct comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.16 - Direct/Variable
  BasicIF #10,Equal,ifEqualValue
    BasicTHEN
      logDirectString ifDirectVariableOk,<"BasicIF direct/variable comparison OK">
    BasicELSE
      logDirectString ifDirectVariableKo,<"BasicIF direct/variable comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.17 - Variable/Direct
  BasicIF ifLeftValue,Superior,#9
    BasicTHEN
      logDirectString ifVariableDirectOk,<"BasicIF variable/direct comparison OK">
    BasicELSE
      logDirectString ifVariableDirectKo,<"BasicIF variable/direct comparison KO">
  BasicENDIF

  ; **************************************************** Condition Level 1.18 - Variable/Variable
  BasicIF ifLeftValue,Inferior,ifUpperValue
    BasicTHEN
      logDirectString ifVariableVariableOk,<"BasicIF variable/variable comparison OK">
    BasicELSE
      logDirectString ifVariableVariableKo,<"BasicIF variable/variable comparison KO">
  BasicENDIF


  ; ***********************************************************************************************
  ; * Test 5 : Minimal BasicIF block without BasicELSE.         *
  ; *-----------------------------------------------------------*
  ; *          The TRUE case must execute BasicTHEN.            *
  ; *          The FALSE case must silently skip BasicTHEN.     *
  ; *************************************************************

  ; **************************************************** Condition Level 1.19 - TRUE without ELSE
  BasicIF ifLowerValue,Inferior,ifLeftValue
    BasicTHEN
      logDirectString ifWithoutElseTrueOk,<"BasicIF without ELSE TRUE comparison OK">
  BasicENDIF

  ; **************************************************** Condition Level 1.20 - FALSE without ELSE
  BasicIF ifUpperValue,Inferior,ifLeftValue
    BasicTHEN
      logDirectString ifWithoutElseFalseKo,<"BasicIF without ELSE FALSE comparison KO">
  BasicENDIF
  logDirectString ifWithoutElseFalseOk,<"BasicIF without ELSE FALSE skip OK">


  ; ***********************************************************************************************
  ; * Test 6 : Nested BasicIF blocks.                           *
  ; *-----------------------------------------------------------*
  ; *          This checks nested THEN execution and nested ELSE *
  ; *          execution in the same parent BasicIF block.      *
  ; *************************************************************

  ; **************************************************** Condition Level 1.21 - Nested Start
  BasicIF ifLeftValue,Equal,ifEqualValue
    BasicTHEN
      logDirectString ifNestedParentOk,<"BasicIF nested parent comparison OK">

      ; ********************************************** Condition Level 2.1 - Nested TRUE
      BasicIF ifUpperValue,Superior,ifLeftValue
        BasicTHEN
          logDirectString ifNestedThenOk,<"BasicIF nested THEN comparison OK">
        BasicELSE
          logDirectString ifNestedThenKo,<"BasicIF nested THEN comparison KO">
      BasicENDIF
      ; ********************************************** Condition Level 2.1 - Nested Ended

      ; ********************************************** Condition Level 2.2 - Nested ELSE
      BasicIF ifLowerValue,Superior,ifLeftValue
        BasicTHEN
          logDirectString ifNestedElseKo,<"BasicIF nested ELSE comparison KO">
        BasicELSE
          logDirectString ifNestedElseOk,<"BasicIF nested ELSE comparison OK">
      BasicENDIF
      ; ********************************************** Condition Level 2.2 - Nested Ended

    BasicELSE
      logDirectString ifNestedParentKo,<"BasicIF nested parent comparison KO">
  BasicENDIF
  ; **************************************************** Condition Level 1.21 - Nested Ended


  ; Label Called by BasicGoto Macro to reach the end of the code.
  BasicLABEL reachTheEnd

; ************************************ Quit Grimoire System
  grimoireLeaveEngine
