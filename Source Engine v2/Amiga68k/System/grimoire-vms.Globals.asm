
; **********************************************************
; * Method Name : buildGlobalVariables                     *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   buildGlobalVariables                                 *
; *--------------------------------------------------------*
; * Description :                                          *
; * This method will create the global variable buffer by  *
; * using a space inside the full variable buffer          *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
buildGlobalVariables MACRO
    ; ******************************** 1nd compiler PASS
varCount        SET 0
    ; ******************************** 2nd compiler PASS
    LoadSys    a5                                 ; Be sure that Internal System Structure is loaded into a5
globalDatasBuild:
    move.l     globalDatas(a5),d7                 ; d0 = pointer to globalDatas
    tst.l      d7                                 ; d0 <> 0 ?
    beq.s      .bgdNullIsOk                       ; No -> All is ok go to .bgdNullIsOk
    CastErrorID globalDataDefinedTwice         ; globalDatas buffer is already declared. Error.
.bgdNullIsOk:
    Move.l     #glblSize,d6                       ; D1 = globalDatas buffer size
    tst.l      d6                                 ; Are some variables defined ? (d1<>0 ?)
    beq.s      .bgdEnd                            ; d1=0 -> No global variables at all. -> Jump to .bgdEnd
    ; Will now affect the next slot from WholeVariablesBuffer for the global variables structure
    move.l     fvbPos(a5),d7                      ; D0 = Current position inside the fullVariablesBuffer
    tst.l      d7
    bne.s      .FullBufferIsOk
    CastErrorID FullVariableBufferNotSet
.FullBufferIsOk:
    sub.l      #glblSize,d7                       ; push d0 upper in the buffer (buffer is used from end to start)
    move.l     d7,globalDatas(a5)                 ; Save pointer to the GlobalDatas Structure 
    move.l     d6,globalSize(a5)                  ; Save Global Data Structure size in the internal engine data structure object "globalSize"
    move.l     fullVarBuffer(a5),d6
    cmp.l      d7,d6                              ; is new position exceed the buffer size (is it < to start buffer pointer ?)
    blt.s      .notOverSized                      ; no buffer exceeding, ok -> .notOverSized
    CastErrorID WholeVariablesBufferExceeded
.notOverSized:
    move.l     d7,fvbPos(a5)                      ; fvbPos(a5) = From where the next buffer will be pushed upper in the fullVarBuffer(a5)
    loadGlobalDatas a3                         ; Load global datas into A4 so all data can be allocated at creation
.bgdEnd:
    SetInteger prev\1,d7                       ; Create a variable to store the amount of parameters
                    ENDM

; **********************************************************
; * Method Name : DeleteGlobal                             *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   DeleteGlobal                                         *
; *--------------------------------------------------------*
; * Description :                                          *
; * This method will release the global variable buffer    *
; * from the full variable buffer                          *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          * 
; **********************************************************
deleteGlobal     MACRO
    ; ******************************** 1nd compiler PASS
glblSize      equ     varCount                      ; End of the Global Data Structure setup.
varBufferSize equ     glblSize
    ; ******************************** 2nd compiler PASS
;globalDatasDelete:
    move.l      globalDatas(a5),d7
    tst.l       d7
    beq.w       noGlobalDataIsPossible
    Move.l      globalSize(a5),d6
    tst.l       d6
    bne.w       globalDataSizeDefinedIsOk
    move.l      #glblSize,d6
    tst.l       d6
    bne.w       globalDataSizeDefinedIsOk
    CastErrorID globalDataSetWithoutSize
globalDataSizeDefinedIsOk:
    add.l       d6,d7
    move.l      d7,fvbPos(a5)                          ; Removes GlobalDatas from fullVarBuffer by updating fvbPos pointer.
noGlobalDataIsPossible:
    Move.l      #0,globalDatas(a5)                     ; Clear old registers
    move.l      #0,globalSize(a5)                      ; Clear old registers
                ENDM

; **********************************************************
; * Method Name : loadGlobalDatas                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   loadGlobalDatas An                                   *
; *--------------------------------------------------------*
; * Description :                                          *
; * This macro will load the global variables buffer poin- *
; * -ter into an adress register                           *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
loadGlobalDatas MACRO
    move.l      globalDatas(a5),\1
                ENDM


