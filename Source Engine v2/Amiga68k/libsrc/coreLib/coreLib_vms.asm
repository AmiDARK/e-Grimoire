; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Internal System branchments list *
; * Author : Frederic Cordier                             *
; *********************************************************


; **********************************************************
; * Method Name : vmsbuildFullVariablesBuffer              *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   vmsbuildFullVariablesBuffer                          *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro will create the full variable buffer that *
; *   will be used for the global variable buffer, and for *
; *   the procedures local variables buffer                *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
vmsbuildFullVariablesBuffer:
    move.l      #seVariablesBuffer,d0                  ; D0 = Size required to allocate all variables
    bsr         AllocClrFastMem                        ; Allocate memory for the whole variables buffer
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      d0,fullVarBuffer(a5)
    add.l       #seVariablesBuffer,d0                  ; Push D0 at the end of the buffer.
    move.l      d0,fvbPos(a5)
    rts

; **********************************************************
; * Method Name : vmsDeleteFullVariablesBuffer             *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   vmsDeleteFullVariablesBuffer                         *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro will release the full variable buffer that*
; *   was previously created by the macro called :         *
; *                            vmsbuildFullVariablesBuffer *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
vmsDeleteFullVariablesBuffer:
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      #seVariablesBuffer,d0                  ; D0 = Size required to allocate all variables
    move.l      fullVarBuffer(a5),a1
    bsr         FreeMm
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      #0,fullVarBuffer(a5)
    move.l      #0,fvbPos(a5)
    rts



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
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
buildGlobalVariables:
    ; ******************************** 1nd compiler PASS
    LoadSys    a5                                 ; Be sure that Internal System Structure is loaded into a5
globalDatasBuild:
    move.l     globalDatas(a5),d7                 ; d0 = pointer to globalDatas
    tst.l      d7                                 ; d0 <> 0 ?
    beq.s      .bgdNullIsOk                       ; No -> All is ok go to .bgdNullIsOk
    CastErrorID globalDataDefinedTwice         ; globalDatas buffer is already declared. Error.
.bgdNullIsOk:
    tst.l      d6                                 ; Are some variables defined ? (d1<>0 ?)
    beq.s      .bgdEnd                            ; d1=0 -> No global variables at all. -> Jump to .bgdEnd
    ; Will now affect the next slot from WholeVariablesBuffer for the global variables structure
    move.l     fvbPos(a5),d7                      ; D0 = Current position inside the fullVariablesBuffer
    tst.l      d7
    bne.s      .FullBufferIsOk
    CastErrorID FullVariableBufferNotSet
.FullBufferIsOk:
    sub.l      d6,d7                       ; push d0 upper in the buffer (buffer is used from end to start)
    move.l     d7,globalDatas(a5)                 ; Save pointer to the GlobalDatas Structure 
    move.l     d6,globalSize(a5)                  ; Save Global Data Structure size in the internal engine data structure object "globalSize"
    move.l     fullVarBuffer(a5),d6
    cmp.l      d7,d6                              ; is new position exceed the buffer size (is it < to start buffer pointer ?)
    blt.s      .notOverSized                      ; no buffer exceeding, ok -> .notOverSized
    CastErrorID WholeVariablesBufferExceeded
.notOverSized:
    move.l     d7,fvbPos(a5)                      ; fvbPos(a5) = From where the next buffer will be pushed upper in the fullVarBuffer(a5)
    loadGlobalDatas a3                            ; Load global datas into A4 so all data can be allocated at creation
.bgdEnd:
    rts

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
; * Version : 1.1                                          *
; * Last update date : 2021.06.05                          * 
; **********************************************************
deleteGlobal:
    tst.l       d6                                     ; with .library format
    bne.w       globalDataSizeDefinedIsOk
    Move.l      globalSize(a5),d7
    tst.l       d7
    bne.w       globalDataSizeDefinedIsOk
    move.l      globalDatas(a5),d7
    tst.l       d7
    beq.w       noGlobalDataIsPossible
    CastErrorID globalDataSetWithoutSize
globalDataSizeDefinedIsOk:
    add.l       d6,d7
    move.l      d7,fvbPos(a5)                          ; Removes GlobalDatas from fullVarBuffer by updating fvbPos pointer.
noGlobalDataIsPossible:
    Move.l      #0,globalDatas(a5)                     ; Clear old registers
    move.l      #0,globalSize(a5)                      ; Clear old registers
    rts

; **********************************************************
; * Method Name : buildLocalVariables                      *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   bildLocalVariables                                   *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used internally by the 'Procedure' ma- *
; *   -cro to create the local variables buffer from the   *
; *   full variable buffer, for the current procedure.     *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
buildLocalVariables:
    ; ******************************** 2nd compiler PASS
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),d7              ; D7 = Load current local variables stored in localDatas(a5)
    move.l      fvbPos(a5),d5                  ; D0 = Current position for next variables buffer
    tst.l       d5
    bne.s       .FullBufferIsOk
    CastErrorID FullVariableBufferNotSet
.FullBufferIsOk:
    sub.l       d6,d5                          ; D0 = D0 - ProcedureVariableBufferSize = New Local variable buffer
    move.l      fullVarBuffer(a5),d4           ; D1 = Start of whole variables buffer
    cmp.l       d5,d4                          ; is new position exceed the buffer size (is it < to start buffer pointer ?)
    blt.s       .notOverSized                  ; no buffer exceeding, ok -> .notOverSized
    CastErrorID WholeVariablesBufferExceeded
.notOverSized:
    move.l      d5,fvbPos(a5)                  ; fvbPos(a5) = From where the next buffer will be pushed upper in the fullVarBuffer(a5)
    move.l      d5,localDatas(a5)
    rts

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
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
deleteLocalVariables:
    ; ******************************** 1nd compiler PASS
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    Move.l      localDatas(a5),d7                      ; d6 = Current local buffer pointer
    tst.l       d7
    bne.s       .delLocal
    CastErrorID CannotEraseUndefinedLocalBuffer
.delLocal:
    ; Restore the previous LocalDatas or empty is no more available
    loadLocalDatas a0                                  ; a0 = Pointer to the adress to previous local buffer pointer
    move.l      (a0),d6                                ; d6= Local procprev
    move.l      d6,localDatas(a5)                      ; We restore the previous buffer
    ; Move the full variable buffer to the next local value or global if no more.
    Tst.l       d6
    bne.s       .dlff
    move.l      globalDatas(a5),d6
.dlff:
    move.l      d6,fvbPos(a5)                          ; Restore the fvbPos(a5) pointer to its origin before using current local buffer
    rts

; **********************************************************
; * Method Name : buildAllLoopsBuffer                       *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   buildAllLoopsBuffer                        [INTERNAL] *
; *--------------------------------------------------------*
; * Description : This method is used to create a buffer   *
; *   that was previously calculated to be able to handle  *
; *   the maximal detected amount of imbricated for/next   *
; *   uses.                                                *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
buildAllLoopsBuffer:
    LoadSys    a5                              ; Be sure that Internal System Structure is loaded into a5
    move.l     AllLoopsBuffer(a5),d6
    tst.l      d6
    beq.s      .fnBufferIsNullOK    
    CastErrorID AllLoopsBufferIsAlreadyAllocated
.fnBufferIsNullOK:
    tst.l      d7
    beq.s      .ForNextEndCreation
    add.l      #1,d7                           ; Add 1 security buffer
    lsl.l      #4,d7                           ; each For/Next data block requires 12 bytes (4x.l : variable.ptr, End value, Step value, PointerForLoop.l)
    move.l     fvbPos(a5),d6                   ; d6 = Current position in the full buffer variable
    tst.l      d6
    bne.s      .FullBufferIsOk_ck2
    CastErrorID AllLoopsBufferNotSet
.FullBufferIsOk_ck2:
    sub.l      d7,d6                           ; d6 = New position in the buffer = Start of For/Next data blocks
    move.l     d6,fnbPos(a5)                   ; update buffer position for next buffer to allocate
    move.l     d6,AllLoopsBuffer(a5)           ; Define the AllLoopsBuffer(a5)
.ForNextEndCreation:
    rts


; **********************************************************
; * Method Name : deleteAllLoopsBuffer                      *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   deleteAllLoopsBuffer                       [INTERNAL] *
; *--------------------------------------------------------*
; * Description : This method release the buffer that was  *
; *   previously reserved for the use of For/next methods. *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
deleteAllLoopsBuffer:
    ; if at least 1 for/next buffer is required
    LoadSys    a5                              ; Be sure that Internal System Structure is loaded into a5
    move.l     fnbPos(a5),d6                   ; d6 = Current position in the full buffer variable
    move.l     AllLoopsBuffer(a5),d5           ; d7 = Current AllLoopsBuffer(a5)
    cmp.l      d6,d5
    beq.s      .bufAtGoodPositionForRelease    
    CastErrorID SomeBuffersMustBeReleasedBeforeAllLoopsOne
.bufAtGoodPositionForRelease:
;    add.l      #1,d7
    lsl.l      #4,d7                           ; each For/Next data block requires 12 bytes (4x.l : variable.ptr, End value, Step value, PointerForLoop.l)+
    add.l      d7,d6
    move.l     d6,fvbPos(a5)                   ; update the global buffer position with the for/next buffer release
    clr.l      AllLoopsBuffer(a5)              ; clear the for/next buffer.
    rts




buildGosubsBuffer:
    LoadSys    a5
    move.l     GosubsBufferStart(a5),d6
    tst.l      d6
    beq.s      .gsBufferIsNullOK
    CastErrorID GosubsBufferIsAlreadyAllocated
.gsBufferIsNullOK:
    tst.l      d7
    beq.s      .GosubEndCreation
    add.l      #1,d7                 ; Added 1 security buffer
    lsl.l      #2,d7                 ; d7 = d7 * 4 because pointers are .l
    move.l     fvbPos(a5),d6         ; d6 = Current position in the full buffer variable
    tst.l      d6
    bne.s      .fullBufferIsOk_ck3
    CastErrorID GosubsBufferNotSet
.fullBufferIsOk_ck3:
    move.l     d6,GosubsBufferLimit(a5) ; Position that must not be overpassed
    sub.l      d7,d6
    move.l     d6,fvbPos(a5)         ; update buffer position for next buffer to allocate
    move.l     d6,GosubsBufferStart(a5)
    move.l     d6,GosubsBuffer(a5)
.GosubEndCreation:
    rts

deleteGosubsBuffer:
    LoadSys    a5
    move.l     fnbPos(a5),d6
    move.l     GosubsBufferStart(a5),d5
    cmp.l      d6,d5
    beq.s      .bufAtGoodPositionForRelease2
    CastErrorID SomeBuffersMustBeReleasedBeforeGosubsOne
.bufAtGoodPositionForRelease2:
    add.l      #1,d7
    lsl.l      #2,d7
    add.l      d7,d6
    move.l     d6,fvbPos(a5)
    clr.l      GosubsBuffer(a5)
    clr.l      GosubsBufferStart(a5)
    clr.l      GosubsBufferLimit(a5)
    rts





