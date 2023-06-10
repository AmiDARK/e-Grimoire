; ***************************************************
; * Source Engine                                   *
; *-------------------------------------------------*
; * Date : 2023.05.30                               *
; * Last Update : 2023.05.30                        *
; * Version : 0.2                                   *
; * File : Source Engine Screens Handler System     *
; * Author : Frederic Cordier                       *
; ***************************************************
; This file contains macros and informations to use screens library
; for the Source Engine. This file is devoted to be 'included' by the parser
; in the final source code when the Source Engine is used directly from a 68k assembler.

macro_getBestScreenMode:
macro_getBestScreenMode_callable:
getBestScreenMode MACRO
  ; ********************************************************
  IFEQ (NARG-3) ; getBestScreenMode Width,Height,PixelFormat
    seMultiPushToStack \1,\2,\3
    grmScreensCall grmGetBestScreenMode
  ; ********************************************************
  ELSEIF
    IFEQ (NARG-4) ; getBestScreenModeEx Width,Height,PixelFormat,GFXMode
      seMultiPushToStack \1,\2,\3,\4
      grmScreensCall grmGetBestScreenModeEx
    ; ********************************************************
    ELSEIF
      FAIL ; Wrong amount of parameters : getBestScreenMode Width,Height,PixelFormat (,GFXMode)
    ENDC
  ENDC
  tst.b        Error(a5)
  bne          CloseEngine
 ENDM

macro_OpenScreen:
OpenScreen MACRO
  ; OpenScreen d3=ScreenID,d4=Width,d5=Height,d6=BestScreenMode
  ; OpenScreen d3=ScreenID,d4=Width,d5=Height,d6=PixelFormat,d7=GFXMode
  IFEQ (NARG-4)
    seMultiPushToStack \1,\2,\3,\4
    grmScreensCall grmOpenScreen
  ELSEIF
    IFEQ (NARG-5)
      seMultiPushToStack \1,\2,\3,\4,\5
      grmScreensCall grmOpenScreenEx
    ELSEIF
      FAIL ; Wrong amount of parameters : OpenScreen ScreenID,Width,Height,BestScreenMode(/PixelFormat,GFXMode)
    ENDC
  ENDC
  tst.b        Error(a5)
  bne          CloseEngine
 ENDM

macro_CloseScreen:
CloseScreen MACRO
  IFEQ (NARG-1)
    sePushToStack \1                           ; Push ScreenID into Stack
    grmScreensCall grmCloseScreen
  ELSEIF
    FAIL ; CloseScreen requires only 1 parameter (ScreenID)
  ENDC
  tst.b        Error(a5)
  bne          CloseEngine
 ENDM

macro_GetScreenExist:                          ; Name of the macro to define it exist when checked from elsewhere
macro_GetScreenExist_callable:                 ; Tell macro return a value and is iseable inside 'Let' macro to return value to variable
GetScreenExist MACRO
  IFEQ (NARG-1)
    sePushToStack \1
    grmScreensCall grmGetScreenExists
  ELSEIF
    FAIL ; GetScreenExists requires only 1 parameter (ScreenID)
  ENDC
  tst.b        Error(a5)
  bne          CloseEngine
 ENDM
