
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Version : 0.1                         *
; * File : AmigaOS mmathFFP.library       *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains macro to simplify access to mmathFFP.library calls.
;
; LoadMathFFPLib               (MACRO)
; callMathFFP \Method          (MACRO)
; openMathFFPLib()             (coldStart)
; closeMathFFPLib()            (hotEnd)
; Stack.Int = ConvertFltToInt( Stack.Float )
; Stack.FFP = ConvertIntToFlt( Stack.Integer )
; Stack.FFP = ConvertStrToFlt( Stack.StringPointer )
; Stack.Int = ConvertStrToInt( Stack.StringPointer )
; D0.Int = privConvertFltToInt( D0.Float )
; D0.FFP = privConvertIntToFlt( D0.Integer )
; D0.FFP = privConvertStrToFlt( A0.String )
; D0.Int = privConvertStrToInt( A0.String )

    include     "LVO/mathffp_lib.i"

loadMathFFPLib          MACRO
    move.l      MathFFPBase(a5),a6
                        ENDM

callMathFFP             MACRO
    jsr     _LVO\1(a6)
                        ENDM

; *************************************************************
; Convert a Floating Point Number to an Integer. [Call using Stack]
; INPUT: Stack Float Value (a4)
; OUTPUT : Stack Integer Number (a4)
ConvertFltToInt MACRO
    grmFPUCall grmStackA4ConvertFltToInt
  ENDM
; *************************************************************
; Convert a Floating Point Number to an Integer. [Call not using Stack]
; INPUT: D0 = Float Value
; OUTPUT : D0 = Integer Number
privConvertFltToInt MACRO
    grmFPUCall grmConvertFltToInt
  ENDM

; *************************************************************
; Convert an Integer to a Floating Point Number. [Call using Stack]
; INPUT: Stack Integer Value (a4)
; OUTPUT : Stack FFP Number (a4)
ConvertIntToFlt MACRO
    grmFPUCall grmStackA4ConvertIntToFlt
  ENDM
; *************************************************************
; Convert a Static String into a Floating Point Number. [Call not using Stack]
; INPUT: D0 = Integer Value
; OUTPUT : D0 = FFP Number
privConvertIntToFlt MACRO
    grmFPUCall grmConvertIntToFlt
  ENDM

; *************************************************************
; Convert a Static String into a Floating Point Number. [Call using Stack]
; INPUT: Stack String Pointer (a4)
; OUTPUT : Stack FFP Number (a4)
ConvertStrToFlt MACRO
    grmFPUCall grmStackA4ConvertStrToFlt
  ENDM
; *************************************************************
; Convert a Static String into a Floating Point Number. [Call not using Stack]
; INPUT: A0 = String Pointer
; OUTPUT : D0 = FFP Number
privConvertStrToFlt MACRO
    grmFPUCall grmConvertStrToFlt
  ENDM

; *************************************************************
; Convert a Static String into an Integer Number. [Call using Stack]
; INPUT: Stack String Pointer (a4)
; OUTPUT : Stack Integer Number (a4)
ConvertStrToInt MACRO
    grmFPUCall grmStackA4ConvertStrToInt
  ENDM
; *************************************************************
; Convert a Static String into an Integer Number. [Call not using Stack]
; INPUT: A0 = String Pointer
; OUTPUT : D0 = Integer Number
privConvertStrToInt MACRO
    grmFPUCall grmConvertStrToInt
  ENDM
