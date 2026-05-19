; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2026.05.19                     *
; * Version : 0.1                         *
; * File : BasicStringsSupport.asm        *
; * Author : Frederic Cordier             *
; *****************************************
; This file checks BASIC string support commands.
; *********************************************

  include     "coresrc/grimoire-coldStart.asm"
  grimoireStartupSequence                                      ; Start Grimoire System


startHere:

  ; ***********************************************************************************************
  ; * Test 1 : Create source and target strings.                 *
  ; *-----------------------------------------------------------*
  ; *          Dynamic and static sources are both tested.      *
  ; *          All targets are mutable strings.                 *
  ; *************************************************************
  SetString       dynSource,<"ABCDEFGH">
  SetStaticString staticSource,<"12345678">

  SetString leftTarget
  SetString rightTarget
  SetString midTarget
  SetString chrTarget

  SetInteger ascValue,0
  SetInteger expectedAscValue,67
  SetInteger expectedStaticAscValue,49


  ; ***********************************************************************************************
  ; * Test 2 : BasicLEFT from a dynamic source string.           *
  ; *-----------------------------------------------------------*
  ; *          Expected output: ABC                             *
  ; *************************************************************
  BasicLEFT dynSource,#3,leftTarget
  logDirectString leftTitle,<"BasicLEFT dynamic source result should be ABC">
  logString leftTarget


  ; ***********************************************************************************************
  ; * Test 3 : BasicRIGHT from a dynamic source string.          *
  ; *-----------------------------------------------------------*
  ; *          Expected output: FGH                             *
  ; *************************************************************
  BasicRIGHT dynSource,#3,rightTarget
  logDirectString rightTitle,<"BasicRIGHT dynamic source result should be FGH">
  logString rightTarget


  ; ***********************************************************************************************
  ; * Test 4 : BasicMID from a static source string.             *
  ; *-----------------------------------------------------------*
  ; *          StartPos is zero-based. Expected output: 345     *
  ; *************************************************************
  BasicMID staticSource,#2,#3,midTarget
  logDirectString midTitle,<"BasicMID static source result should be 345">
  logString midTarget


  ; ***********************************************************************************************
  ; * Test 5 : BasicASC from a dynamic source string.            *
  ; *-----------------------------------------------------------*
  ; *          Position 2 is character C, ASCII value 67.       *
  ; *************************************************************
  BasicASC dynSource,#2,ascValue

  ; **************************************************** Condition Level 1.1 - BasicASC value
  BasicIF ascValue,Equal,expectedAscValue
    BasicTHEN
      logDirectString ascOk,<"BasicASC dynamic source comparison OK">
    BasicELSE
      logDirectString ascKo,<"BasicASC dynamic source comparison KO">
  BasicENDIF


  ; ***********************************************************************************************
  ; * Test 6 : BasicCHR from a dynamic source string.            *
  ; *-----------------------------------------------------------*
  ; *          Position 2 is character C. Expected output: C    *
  ; *************************************************************
  BasicCHR dynSource,#2,chrTarget
  logDirectString chrTitle,<"BasicCHR dynamic source result should be C">
  logString chrTarget


  ; ***********************************************************************************************
  ; * Test 7 : BasicLEFT from a static source string.            *
  ; *-----------------------------------------------------------*
  ; *          Expected output: 1234                            *
  ; *************************************************************
  BasicLEFT staticSource,#4,leftTarget
  logDirectString leftStaticTitle,<"BasicLEFT static source result should be 1234">
  logString leftTarget


  ; ***********************************************************************************************
  ; * Test 8 : BasicASC from a static source string.             *
  ; *-----------------------------------------------------------*
  ; *          Position 0 is character 1, ASCII value 49.       *
  ; *************************************************************
  BasicASC staticSource,#0,ascValue

  ; **************************************************** Condition Level 1.2 - BasicASC static value
  BasicIF ascValue,Equal,expectedStaticAscValue
    BasicTHEN
      logDirectString ascStaticOk,<"BasicASC static source comparison OK">
    BasicELSE
      logDirectString ascStaticKo,<"BasicASC static source comparison KO">
  BasicENDIF


  ; Label Called by BasicGoto Macro to reach the end of the code.
  BasicLABEL reachTheEnd

; ************************************ Quit Grimoire System
  grimoireLeaveEngine
