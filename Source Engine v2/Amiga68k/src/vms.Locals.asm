
; **********************************************************
; * Method Name : buildLocalDatas                          *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   buildLocalDatas                                      *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used internally by the 'Procedure' ma- *
; *   -cro to create the local variables buffer from the   *
; *   full variable buffer, for the current procedure.     *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
buildLocalDatas MACRO
    ; ******************************** 2nd compiler PASS
build\<$inProcName>:
    ; 1. If we have variables, we load the current local buffer and current position in the full variables buffer
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),d7              ; D7 = Load current local variables stored in localDatas(a5)
    move.l      fvbPos(a5),d0                  ; D0 = Current position for next variables buffer
    tst.l       d0
    bne.s       .FullBufferIsOk
    CastErrorID FullVariableBufferNotSet
.FullBufferIsOk:
    move.l      #varProc\<$inProcName>Size,d6  ; D1 = Variables buffer size
    sub.l       d6,d0                          ; D0 = D0 - ProcedureVariableBufferSize = New Local variable buffer
    move.l      fullVarBuffer(a5),d1           ; D1 = Start of whole variables buffer
    cmp.l       d0,d1                          ; is new position exceed the buffer size (is it < to start buffer pointer ?)
    blt.s       .notOverSized                  ; no buffer exceeding, ok -> .notOverSized
    CastErrorID WholeVariablesBufferExceeded
.notOverSized:
    move.l      d0,fvbPos(a5)                  ; fvbPos(a5) = From where the next buffer will be pushed upper in the fullVarBuffer(a5)
    move.l      d0,localDatas(a5)
    SetInteger  procprev,d7                    ; Create a variable to store the amount of parameters
    SetInteger  procsize,d6
build\<$inProcName>End:
 ENDM

; **********************************************************
; * Method Name : DeleteLocal                              *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   DeleteLocal                                          *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method will release the variable buffer that was*
; *   previously created by the macro 'buildLocalDatas'    *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
DeleteLocal     MACRO
    ; ******************************** 1nd compiler PASS
varProc\<$inProcName>Size   equ varProc\<$inProcName>Count
    ; ******************************** 2nd compiler PASS
deleteLocalVars\<$inProcName>:
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    Move.l      localDatas(a5),d7                      ; d6 = Current local buffer pointer
    tst.l       d7
    bne.s       delLocal\<$inProcName>
    CastErrorID CannotEraseUndefinedLocalBuffer
delLocal\<$inProcName>:
    ; Restore the previous LocalDatas or empty is no more available
;    loadLocalData  procprev,a0                         ; a0 = Pointer to the adress to previous local buffer pointer
    move.l      (a0),d0
    move.l      d0,localDatas(a5)                    ; We restore the previous buffer
    ; Move the full variable buffer to the next local value or global if no more.
    Tst.l       d0
    bne.s       .\<$inProcName>ff
    move.l      globalDatas(a5),d0
.\<$inProcName>ff:
    move.l      d0,fvbPos(a5)                        ; Restore the fvbPos(a5) pointer to its origin before using current local buffer
                ENDM


; **********************************************************
; * Method Name : loadLocalDatas                           *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   loadLocalDatas An                                    *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to load the pointer to the current*
; *   procedure local variables buffer into an adress re-  *
; *   -gister.                                             *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
loadLocalDatas       MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\1
                     ENDM   

; **********************************************************
; * Method Name : loadLocalData                            *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   loadLocalData VarName,An                             *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method will load the pointer to the local varia-*
; *   -ble inside the specified adress register.           *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
loadLocalData        MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\2
    move.l      proc\<$inProcName>\1(a3),\2
                     ENDM

; **********************************************************
; * Method Name : leaLocalData                             *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   leaLocalData VarName,An                              *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method will load the pointer to the local varia-*
; *   -ble inside the specified adress register.           *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
leaLocalData         MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\2
    lea.l       proc\<$inProcName>\1(a3),\2
                     ENDM
