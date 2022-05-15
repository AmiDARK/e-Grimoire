; ***************************************************
; * Source Engine                                   *
; *-------------------------------------------------*
; * Date : 2020.01.24                               *
; * Last Update : 2020.01.28                        *
; * Version : 0.2                                   *
; * File : Source Engine Internal System Structures *
; * Author : Frederic Cordier                       *
; ***************************************************
; This file contains macros and informations to create internal Structures
; for the Source Engine. This file is devoted to be 'included' by the parser
; in the final source code, and used directly by the header_coldStart.s file
; when the Source Engine is used directly from a 68k assembler.

getBestScreenMode MACRO
macro_getBestScreenMode:
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
        FAIL ; Wrong amount of parameters : getBestScreenModeEx Width,Height,PixelFormat (,GFXMode)
      ENDC
    ENDC
        ; body...
        ENDM

OpenScreen MACRO
macro_OpenScreen:
    ; OpenScreen d3=ScreenID,d4=Width,d5=Height,d6=BestScreenMode
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
        ENDM