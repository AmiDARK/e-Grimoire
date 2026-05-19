; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2026.05.19                     *
; * Version : 0.1                         *
; * File : BasicStringsSupportErrors.asm  *
; * Author : Frederic Cordier             *
; *****************************************
; This file checks BASIC string support error cases.
;
; IMPORTANT :
;   Runtime errors stop the normal execution flow.
;   Keep only ONE error test active at a time.
;   Comment every other BasicLEFT/RIGHT/MID/ASC/CHR error case
;   before compiling and running this file.
; *********************************************

  include     "coresrc/grimoire-coldStart.asm"
  grimoireStartupSequence                                      ; Start Grimoire System


startHere:

  ; ***********************************************************************************************
  ; * Test 1 : Create source and target variables.              *
  ; *-----------------------------------------------------------*
  ; *          The source strings contain ABCDEFGH plus LF.    *
  ; *          Valid byte positions are 0 to 8.                *
  ; *************************************************************
  SetString       dynSource,<"ABCDEFGH">
  SetStaticString staticSource,<"12345678">

  SetString targetString
  SetStaticString staticTarget,<"STATIC TARGET">

  SetInteger targetInteger,0
  SetInteger invalidLength,32
  SetInteger invalidPosition,32


  ; ***********************************************************************************************
  ; * Test 2 : BasicLEFT length out of range.                   *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringLengthOutOfRange / #70.   *
  ; *************************************************************
  logDirectString leftTooLongTitle,<"Testing BasicLEFT length out of range">
  BasicLEFT dynSource,#32,targetString


  ; ***********************************************************************************************
  ; * Test 3 : BasicRIGHT length out of range.                  *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringLengthOutOfRange / #70.   *
  ; *************************************************************
;  logDirectString rightTooLongTitle,<"Testing BasicRIGHT length out of range">
;  BasicRIGHT dynSource,#32,targetString


  ; ***********************************************************************************************
  ; * Test 4 : BasicMID start position out of range.            *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringPositionOutOfRange / #69. *
  ; *************************************************************
;  logDirectString midPositionTooFarTitle,<"Testing BasicMID position out of range">
;  BasicMID dynSource,#32,#1,targetString


  ; ***********************************************************************************************
  ; * Test 5 : BasicMID length out of range.                    *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringLengthOutOfRange / #70.   *
  ; *************************************************************
;  logDirectString midLengthTooLongTitle,<"Testing BasicMID length out of range">
;  BasicMID dynSource,#6,#8,targetString


  ; ***********************************************************************************************
  ; * Test 6 : BasicASC position out of range.                  *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringPositionOutOfRange / #69. *
  ; *************************************************************
;  logDirectString ascPositionTooFarTitle,<"Testing BasicASC position out of range">
;  BasicASC dynSource,#32,targetInteger


  ; ***********************************************************************************************
  ; * Test 7 : BasicCHR position out of range.                  *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringPositionOutOfRange / #69. *
  ; *************************************************************
;  logDirectString chrPositionTooFarTitle,<"Testing BasicCHR position out of range">
;  BasicCHR dynSource,#32,targetString


  ; ***********************************************************************************************
  ; * Test 8 : BasicLEFT using a static target string.          *
  ; *-----------------------------------------------------------*
  ; *          Expected error: DirectDataNotSameTypeThanVariable*
  ; *          because TargetString must be TypeStr.            *
  ; *************************************************************
;  logDirectString leftStaticTargetTitle,<"Testing BasicLEFT static target error">
;  BasicLEFT dynSource,#3,staticTarget


  ; ***********************************************************************************************
  ; * Test 9 : BasicRIGHT using a static target string.         *
  ; *-----------------------------------------------------------*
  ; *          Expected error: DirectDataNotSameTypeThanVariable*
  ; *          because TargetString must be TypeStr.            *
  ; *************************************************************
;  logDirectString rightStaticTargetTitle,<"Testing BasicRIGHT static target error">
;  BasicRIGHT dynSource,#3,staticTarget


  ; ***********************************************************************************************
  ; * Test 10 : BasicMID using a static target string.          *
  ; *-----------------------------------------------------------*
  ; *          Expected error: DirectDataNotSameTypeThanVariable*
  ; *          because TargetString must be TypeStr.            *
  ; *************************************************************
;  logDirectString midStaticTargetTitle,<"Testing BasicMID static target error">
;  BasicMID dynSource,#0,#3,staticTarget


  ; ***********************************************************************************************
  ; * Test 11 : BasicCHR using a static target string.          *
  ; *-----------------------------------------------------------*
  ; *          Expected error: DirectDataNotSameTypeThanVariable*
  ; *          because TargetString must be TypeStr.            *
  ; *************************************************************
;  logDirectString chrStaticTargetTitle,<"Testing BasicCHR static target error">
;  BasicCHR dynSource,#0,staticTarget


  ; ***********************************************************************************************
  ; * Test 12 : BasicASC using a string target instead of int.  *
  ; *-----------------------------------------------------------*
  ; *          Expected error: VariableIsNotAnInteger / #3.    *
  ; *************************************************************
;  logDirectString ascWrongTargetTitle,<"Testing BasicASC non-integer target error">
;  BasicASC dynSource,#0,targetString


  ; ***********************************************************************************************
  ; * Test 13 : BasicLEFT length out of range using variable.   *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringLengthOutOfRange / #70.   *
  ; *************************************************************
;  logDirectString leftVariableTooLongTitle,<"Testing BasicLEFT variable length out of range">
;  BasicLEFT dynSource,invalidLength,targetString


  ; ***********************************************************************************************
  ; * Test 14 : BasicASC position out of range using variable.  *
  ; *-----------------------------------------------------------*
  ; *          Expected error: StringPositionOutOfRange / #69. *
  ; *************************************************************
;  logDirectString ascVariableTooFarTitle,<"Testing BasicASC variable position out of range">
;  BasicASC dynSource,invalidPosition,targetInteger


  ; Label Called by BasicGoto Macro to reach the end of the code.
  BasicLABEL reachTheEnd

; ************************************ Quit Grimoire System
  grimoireLeaveEngine
