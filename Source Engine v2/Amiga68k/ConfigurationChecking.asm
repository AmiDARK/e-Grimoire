
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2022.04.07                     *
; * Last Update : 2022.04.07              *
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
; 3. The main Source Code is located here. It is is the program to run using the Source Engine.

startHere:
  ; 1. Create modify variables that are Strings.
  SetString cpu0,<"Micro-Processor : 68000">
  SetString cpu1,<"Micro-Processor : 68010">
  SetString cpu2,<"Micro-Processor : 68020">
  SetString cpu3,<"Micro-Processor : 68030">
  SetString cpu4,<"Micro-Processor : 68040">
  SetString cpu6,<"Micro-Processor : 68060">
  SetString cpu8,<"Micro-Processor : 68080">
  SetString cpuUnknown,<"Micro-Processor : Unknown model">

  SetString fpu1,<"Floating Point Unit Processor : 68881">
  SetString fpu2,<"Floating Point Unit Processor : 68882">
  SetString fpu4,<"Floating Point Unit Processor : 68040">
  SetString fpu6,<"Floating Point Unit Processor : 68060">
  SetString fpu8,<"Floating Point Unit Processor : 68080">
  SetString fpuIsNotAvailable,<"Floating Point Unit Processor : None">

  SetString ChipsetECS,<"Native Graphics : ECS/OCS">
  SetString ChipsetAGA,<"Native Graphics : AGA">

  SetString VampireNone,<"Additional Vampire Graphics : No Vampire V2 or V4 detected">
  SetString VampireC2P,<"Additional Vampire Graphics : Vampire V2 type detected with Chunky mode">
  SetString VampireSAGA,<"Additional Vampire Graphics : Vampire V4 type detected with Chunky mode and Super AGA">

  SetString AudioNative,<"Audio Chipset : Native Amiga 4 channels Audio Chipset"
  SetString AudioVampire,<"Audio Chipset : Vampire V2 or V4 audio chipset detected with 8 channels"

; ******************************************* 1. Check which CPU is detected and display a text about it
  move.b     grmProcessorModel(a5),d7
  cmp.b      #00,d7
  beq        cpuIs0
  cmp.b      #10,d7
  beq        cpuIs1
  cmp.b      #20,d7
  beq        cpuIs2
  cmp.b      #30,d7
  beq        cpuIs3
  cmp.b      #40,d7
  beq        cpuIs4
  cmp.b      #60,d7
  beq        cpuIs6
  cmp.b      #80,d7
  beq        cpuIs8
  logString  cpuUnknown
  bra        part2fpu
cpuIs0:
  logString  cpu0
  bra        part2fpu
cpuIs1:
  logString  cpu1
  bra        part2fpu
cpuIs2:
  logString  cpu2
  bra        part2fpu
cpuIs3:
  logString  cpu3
  bra        part2fpu
cpuIs4:
  logString  cpu4
  bra        part2fpu
cpuIs6:
  logString  cpu6
  bra        part2fpu
cpuIs8:
  logString  cpu8

; ******************************************* 2. Check which FPU is detected and display a text about it
part2fpu:
  move.b     grmFpuModel(a5),d7
  cmp.b      #00,d7
  beq        fpuIsNotPresent
  cmp.b      #81,d7
  beq        fpuIs1
  cmp.b      #82,d7
  beq        fpuIs2
  cmp.b      #40,d7
  beq        fpuIs4
  cmp.b      #60,d7
  beq        fpuIs6
  cmp.b      #80,d7
  beq        fpuIs8
fpuIsNotPresent:
  logString  fpuIsNotAvailable
  bra        part3gfx
fpuIs1:
  logString  fpu1
  bra        part3gfx
fpuIs2:
  logString  fpu2
  bra        part3gfx
fpuIs4:
  logString  fpu4
  bra        part3gfx
fpuIs6:
  logString  fpu6
  bra        part3gfx
fpuIs8:
  logString  fpu8

; ******************************************* 3. Check which Native graphic adapter is detected and display a text about it
part3gfx:
  move.b     grmGraphicChipsetType(a5),d7
  cmp.b      #2,d7
  beq.s      gfxIsAga
gfxIsEcsOcs:
  logString  ChipsetECS
  bra.s      part4AdditionalGfx
gfxIsAga:
  logString  ChipsetAGA

; ******************************************* 4. Check which Native graphic adapter is detected and display a text about it
part4AdditionalGfx:
  move.b     grmAdditionalVampireChipsetType(a5),d7
  cmp.b      #2,d7
  beq.s      AddgfxIsSuperAga
  cmp.b      #1,d7
  beq.s      AddgfxIsChunky
  logString  VampireNone
  bra.s      part5AudioChipset
AddgfxIsChunky:
  logString  VampireC2P
  bra.s      part4AdditionalGfx
AddgfxIsSuperAga:
  logString  VampireSAGA

; ******************************************* 4. Check which Native graphic adapter is detected and display a text about it
part5AudioChipset:
  move.b     grmAudioChipset(a5),d7
  cmp.b      #2,d7
  beq.s      audioVampire
  logString  AudioNative
  bra.s      finDuTest
audioVampire:
  logString  AudioVampire

finDuTest


; ************************************ Quit Grimoire System
  grimoireLeaveEngine