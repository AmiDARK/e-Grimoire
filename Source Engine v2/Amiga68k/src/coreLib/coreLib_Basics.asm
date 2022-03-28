; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Internal System branchments list *
; * Author : Frederic Cordier                             *
; *********************************************************
LoadProcedureParameters:
  loadLocalDatas a2
  add.l       #(6*3),a2                      ; Jump after procPrec, procSize & ArgsCount\1
  move.l      -6(a2),d6                      ; D6 = Procedure arguments count * 2 + 1
  cmp.l       d7,d6
  beq.s       .isOK
  CastErrorID IllegalAmountOfParametersToCallProcedure
.isOK:
  sub.l       #1,d7                          ; D7 -1 to count limits with positive value
  bsr         seResetStack
lpLoop:
  bsr         seGetFromStackP                ; d6,d7 Get values from Stack
   cmp.w      4(a2),d6                       ; Is parameter of the correct type ?
  beq.s       .lpLoopCt
  CastErrorID ArgumentIsNotOfTheCorrectTypeForProcCall
.lpLoopCt:
  move.l      d5,(a2)+                       ; Write parameter value
  move.w      d6,(a2)+                       ; write parameter type
  dbra        d7,lpLoop
  bsr         seResetStack
;  cmp.w       #TypeStr,d6
;  beq.s       .lClone
;  cmp.w       #TypeNewStr,d6
;  bne.s       .lpload
;.lClone:
;  move.l      d5,a0
;  bsr         cloneString
;  move.l      #TypeNewStr,d6
;  move.l      a0,d5
;  bpl.w       lpLoop\<$inProcName>                   ; YES -> Continue reading from Stack.
    rts

getProcedureReturn
  bsr         seResetStack
  bsr         seGetFromStackP                         ; d6,d7 Get values from Stack
  cmp.l       #0,d7
  bne.s       gPR
  CastErrorID ProcedureDidNotReturnAnyValue
gPR:
  rts


