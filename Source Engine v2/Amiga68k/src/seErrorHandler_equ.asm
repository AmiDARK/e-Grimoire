
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.30                     *
; * Last Update : ----.--.--              *
; * Version : 0.1                         *
; * File : Source Engine Error Handler    *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the ErrorHandler system Equates

; CastErrorID ErrorID (MACRO)                  ; Cast an error using its ID
; CastCustomErrorName ERRORNAME (MACRO)        ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.

startErrDatas   MACRO
errCount        SET 0
                ENDM

addNewError     MACRO
errCount        SET errCount+1
\1              equ errCount
                ENDM

countErrDatas   MACRO
lastErrorID     equ errCount
                ENDM


; *********************************************
; Error names that can be used as reference for the CastErrorID Macro :
	startErrDatas
	addNewError     InvalidStackVarID                      ; 001 "Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15."
	addNewError     VariableIsNotAString                   ; 002 "The entered variable is not a STRING."
	addNewError     VariableIsNotAnInteger                 ; 003 "The entered variable is not an INTEGER."
	addNewError     ValueIsNotAnInteger                    ; 004 "The value entered is not an INTEGER."
	addNewError     ValueIsNotAString                      ; 005 "The Stack variable is not an Integer"
	addNewError     InvalidTempVarID                       ; 006 "The TempVar register is invalid (Range is 0-15)" // LoadTempVarAREG
	addNewError     StringIsNotAFFPValue                   ; 007 "The entered String cannot be converted to Floating Number" // MathFFPLib.ConvertStrToFlt
	addNewError     NotACompatibleVarType                  ; 008 "The entered variable is not compatible with receiver" // seVariables.s
	addNewError     StringIsNotAnINTValue                  ; 009 "The entered String cannot be converted to Integer value" // MathFFPLib.ConvertStrToInt
	addNewError     TooMuchEndProcedureReached             ; 010 "invalid EndProcedure reached" // parserVariables EndProcedure security.
	addNewError     TooMuchReturnReached                   ; 011 "'Return' was reached without any preceding 'Gosub' (Goto Used?)"
	addNewError     GosubNotAllowedFromInsideAProcedure    ; 012 "Gosub are forbidden inside Procedures and Functions"
	addNewError     GotoNotAllowedFromInsideAProcedure     ; 013 "Goto are forbidden inside Procedures and Functions"
	addNewError     TooMuchGosubCalledWithoutReturn        ; 014 "Too much 'Gosub' called (>16384) without any 'return'"
	addNewError     TooMuchProcedureCallsWithoutReturn     ; 015 "Too much 'Procedures/Functions' calls (>16384) without any EndProcedure/EndFunction"
	addNewError     globalDataDefinedTwice                 ; 016 "Global Data Structure is defined twice"
	addNewError     StringSizeTooBig                       ; 017 "String size exceed 16382 bytes"
	addNewError     CannotOpenDosLibrary                   ; 018 "Cannot open dos.library version 0"
	addNewError     CannotOpenGraphicsLibrary              ; 019 "Cannot open graphics.library version 0"
	addNewError     CannotOpenIntuitionLibrary             ; 020 "Cannot open intuition.library version 0"
	addNewError     CannotOpenMathFFPLibrary               ; 021 "Cannot open mathffp.library version 0"
	addNewError     CannotAllocateZeroBytesBuffer          ; 022 "Cannot allocate a memory buffer which size is 0 bytes"
	addNewError     CannotReleaseZeroBytesBuffer           ; 023 "Cannot release a memory buffer which size is 0 bytes"
	addNewError     CannotReleaseNullPointerBuffer         ; 024 "Cannot release a memory buffer from a null pointer"
	addNewError     errorIDIsIncorrect                     ; 025 "Cannot report requested error as its id is out of range"
	addNewError     globalDataSetWithoutSize               ; 026 "Global data structure allocated but size was not saved"
	addNewError     CannotEValuateStringUsingNullPointer   ; 027 "Cannot evaluate String length on a null pointer"
	addNewError     CannotOpenDOSLibrary                   ; 028 "Cannot open dos.library version 0"
	addNewError     VariableTypeIsNotString                ; 029 "The selected variable is not a String"
	addNewError     noLocalDataToErase                     ; 030 "deleteLocalDatas caleed without any local data to delete"
	addNewError     ProcedureRequiresNoParameters          ; 031 "The procedure Called requires no parameters"
	addNewError     globalDataTypeNotRecognized            ; 032 "Cannot load global variable as its type is unknown"
	addNewError     NotEnoughFreeMemory                    ; 033 "Not enough memory available"
	addNewError     DirectDataStackOverflow                ; 034 "Direct data stack overflow"
	addNewError     ErrorDataStackIsEmpty                  ; 035 "Cannot read data from 'Direct data stack' as it is empty"
	addNewError     TooMuchProcedureCallParams             ; 036 "Too much parameters entered to call the procedure"
	addNewError     InternalStackAlreadyCreated            ; 037 "Internal Stack was already allocated"
	addNewError     CannotReleaseInternalStack             ; 038 "Cannot release Internal Stack as it does not exists"
	addNewError     InternalStackDoesNotExists             ; 039 "Internal stack does not exists"
	addNewError     WholeVariablesBufferExceeded           ; 040 "Whole variables buffer exceeded. Try to increase 'extraVarBuffer' variable."
	addNewError     noGlobalDataDefined                    ; 041 "cannot load global data pointer as it is null"
	addNewError     CannotEraseUndefinedLocalBuffer        ; 042 "Cannot remove an undefined local variables buffer"
	addNewError     FullVariableBufferNotSet               ; 043 "Full Variable Buffer not allocated"
    addNewError     IllegalAmountOfParametersToCallProcedure ; 044 "Illegal amount of parameters to call this procedure"
    addNewError     ArgumentIsNotOfTheCorrectTypeForProcCall ; 045 "Some arguments are of an incorrect type in the procedure call"
    addNewError     ProcedureDidNotReturnAnyValue          ; 046 "The last called procedure did not return any value"
    addNewError     DirectDataNotSameTypeThanVariable      ; 047 "The direct data is not of the same type than the variable to update"
    addNewError     UnknownVariableIdentifier              ; 048 "Unknown variable identifier"
    addNewError     BasicFORUses3Or4Parameters             ; 049 "Illegal amount of parameters to cal BasicFOR Variable,StartValue, FinalValue (,optional Step)"
    addNewError     ForNextRequiresIntegerVariablesOrValue ; 050 "The Basic For/Next requires integer variables or direct values as parameters"
    addNewError     forNextBufferIsAlreadyAllocated        ; 051 "The for/next buffer must be allocated only once"
    addNewError     SomeBuffersMustBeReleasedBeforeForNextOne ; 052 "Some buffers must be released before releasing For/Next buffer one."
    addNewError     forNextBufferNotCreated                ; 053 "Internal buffer for for/next datas is not created."
    addNewError     doBufferNotCreated                     ; 054 "Internal buffer for do/loop/while/until support is not created."
    addNewError     ReturnCalledWithoutGosub               ; 055 "Basic RETURN called without any Basic GOSUB
	countErrDatas

; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
; MACRO to simplify error casting inside the Source Engine methods
; castErrorID ErrorID (MACRO)                   ; Cast an error using its ID
CastErrorID        MACRO
    move.l      #\1,d0
    bra         CastError
                   ENDM

; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
; MACRO to simplify error casting inside the Source Engine methods
; castCustomErrorName ERRORNAME (MACRO)        ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
CastCustomErrorNAME        MACRO
    lea.l       \1,a0
    bra         castCustomError
                           ENDM

; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
SaveSP          MACRO
    move.l      a7,savedSP
                ENDM

; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
LoadSP          MACRO
    move.l      savedSP,a7
                ENDM

