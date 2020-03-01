
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.30                     *
; * Last Update : ----.--.--              *
; * Version : 0.1                         *
; * File : Source Engine Error Handler    *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the ErrorHandler system
; 
; CastErrorID ErrorID (MACRO)                   ; Cast an error using its ID
; CastCustomErrorName ERRORNAME (MACRO)        ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; CastError( D0=ErrorID )                      ; Cast an error using its ID
; CastCustomError (A0=ERRORNAME)               ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; CastFinalError (INTERNAL)                    ; Create the final error (Requester) and close the engine.

; *********************************************
; MACRO to simplify error casting inside the Source Engine methods
; castErrorID ErrorID (MACRO)                   ; Cast an error using its ID
CastErrorID        MACRO
    move.l     #\1,d0
    bra.w     CastError
                   ENDM

; *********************************************
; MACRO to simplify error casting inside the Source Engine methods
; castCustomErrorName ERRORNAME (MACRO)        ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
CastCustomErrorNAME        MACRO
    move.l     #\1,a0
    bra.w     castCustomError
                ENDM



; Methods CastError, CastCustomError and CastFinalError must follows for continuity.

; *********************************************
; Cast an existing error using its ID number
; INPUT : D0 = ErrorID
CastError:
    lea.l    error000,a0
    Lsl.l     #2,d0
    add.l    d0,a0

; *********************************************
; Cast a custom error using its label reference to the error text
; INPUT : A0 = pointer to the error text
CastCustomError:
    move.l     a0,castedError

; *********************************************
; Final method to cast the error through an IntuitionLib requester
CastFinalError:
    bsr     quitEngine                                     ; Close the Engine before output the error requester
    bsr     openIntuitionLib                             ; reOpen the IntuitionLib as it was closed by quitEngine
    ; Open the requester to display the error, wait to close button and close the requester.
    bsr     closeIntuitionLib                            ; close IntuitionLib
    ; Quit the program..
    moveq    #0,d0
    rts

; *********************************************
; To store temporarly the pointer of the true message of the casted error.
castedError:    dc.l    0

; *********************************************
; List of all true error messages in order.
errorPos:
    dc.l     error000,error001,error002,error003,error004
    dc.l     error005,error006,error007,error008,error009
    dc.l    error010,error011,error012,error013,error014
    dc.l    error015,error016,error017,error018,error019
    dc.l    0

; *********************************************
; Error names that can be used as reference for the CastErrorID Macro :
InvalidStackVarID                    equ        1        ; "Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15."
VariableIsNotAString                 equ        2        ; "The entered variable is not a STRING."
VariableIsNotAnInteger               equ        3        ; "The entered variable is not an INTEGER."
ValueIsNotAnInteger                  equ        4        ; "The value entered is not an INTEGER."
ValueIsNotAString                    equ        5        ; "The Stack variable is not an Integer"
InvalidTempVarID                     equ        6        ; "The TempVar register is invalid (Range is 0-15)" // LoadTempVarAREG
StringIsNotAFFPValue                 equ        7        ; "The entered String cannot be converted to Floating Number" // MathFFPLib.ConvertStrToFlt
NotACompatibleVarType                equ        8        ; "The entered variable is not compaible with receiver" // seVariables.s
StringIsNotAnINTValue                equ        9        ; "The entered String cannot be converted to Integer value" // MathFFPLib.ConvertStrToInt
TooMuchEndProcedureReached           equ        10       ; "invalid EndProcedure reached" // parserVariables EndProcedure security.
TooMuchReturnReached                 equ        11       ; "'Return' was reached without any preceding 'Gosub' (Goto Used?)"
GosubNotAllowedFromInsideAProcedure  equ        12       ; "Gosub are forbidden inside Procedures and Functions"
GotoNotAllowedFromInsideAProcedure   equ        13       ; "Goto are forbidden inside Procedures and Functions"
TooMuchGosubCalledWithoutReturn      equ        14       ; "Too much 'Gosub' called (>16384) without any 'return'"
TooMuchProcedureCallsWithoutReturn   equ        15       ; "Too much 'Procedures/Functions' calls (>16384) without any EndProcedure/EndFunction"
globalDataDefinedTwice               equ        16       ; "Global Data Structure is defined twice"
StringSizeTooBig                     equ        17       ; "String size exceed 16382 bytes"

; *********************************************
; True error messages cast through the Intuition Requester to inform user of what happened.
error000:    dc.b     "Unknown Error occured",0
error001:    dc.b     "Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15",0
error002:    dc.b     "The entered variable is not a STRING.",0
error003:    dc.b     "The entered variable is not an INTEGER.",0
error004:    dc.b     "The value entered is not an INTEGER.",0
error005:    dc.b     "The Stack variable is not an Integer",0
error006:    dc.b     "The TempVar register is invalid (Range is 0-15)",0
error007    dc.b      "The entered String cannot be converted to Floating Number",0
error008:    dc.b     "The entered variable is not compaible with receiver",0
error009:    dc.b     "The entered String cannot be converted to Integer value",0
error010:    dc.b     "invalid EndProcedure reached",0
error011:    dc.b     "'Return' was reached without any preceding 'Gosub' (Goto Used?)",0
error012:    dc.b     "Gosub are forbidden inside Procedures and Functions",0
error013:    dc.b     "Goto are forbidden inside Procedures and Functions",0
error014:    dc.b     "Too much 'Gosub' called (>16384) without any 'return'",0
error015:    dc.b     "Too much 'Procedures/Functions' calls (>16384) without any EndProcedure/EndFunction",0
error016:    dc.b     "Global Data Structure is defined twice",0
error017:    dc.b     "String size exceed 16382 bytes",0
error018:    dc.b     "",0
error019:    dc.b     "",0
