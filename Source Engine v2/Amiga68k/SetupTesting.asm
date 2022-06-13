
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
  include     "GRMIncludes/grimoire-coldStart.asm"

; ************************************ Start Grimoire System
  grimoireStartupSequence
; *********************************************
; 2. You can add additional source code files here with procedure and classes.
;   include "Include Your Additional Procedures & Classes files here"
; *********************************************
; 3. The main Source Code is located here. It is the program to run using the Source Engine and Grimoire MACROS system.

startHere:
  ; 1. Create modify variables that are Strings.
;  SetString LoopString,<"Here is the string to display 1 Time">
;  logString LoopString

;  SetInteger Width,320
;  SetInteger Height,256

;  move.l     #320,d4
;  move.l     #256,d5
;  seMultiPushToStack d4,d5
;  seGetMultiFromStack d7,d6
;;  sePushToStack d4
;;  sePushToStack d5
;;  seGetFromStack d7
;;  seGetFromStack d6
;  cmp.l      d6,d4
;  beq.s      ok1
;  logDirectString Log1,<"D4 n'est pas egal a D6">
;ok1
;  cmp.w      d7,d5
;  beq.s      ok2
;  logDirectString Log2,<"D5 n'est pas egal a D7">
;ok2
;  cmp.l      #320,d6
;  beq.s      ok3
;  logDirectString Log3,<"D6 n'est pas egal a 320">
;ok3:
;  cmp.w      #256,d7
;  beq.s      ok4
;  logDirectString Log4,<"D7 n'est pas egal a 256">
;ok4:
  OpenScreen #1,#320,#256,#8,#0
  CloseScreen #1

;  GetScreenExist #1
reachTheEnd:

; ************************************ Quit Grimoire System
  grimoireLeaveEngine