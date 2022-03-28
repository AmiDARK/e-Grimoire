; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Internal System branchments list *
; * Author : Frederic Cordier                             *
; *********************************************************

seCreateStack:
    move.l      StackAdr(a5),a0
    cmp.l       #0,a0
    beq.s       .ok1
    CastErrorID InternalStackAlreadyCreated
.ok1:
    move.l      #DepthBufferSize,d0
    mulu        #6,d0
    bsr         AllocClrFastMem
    tst.l       d0
    bne.s       .ok2
    CastErrorID NotEnoughFreeMemory
.ok2:
    move.l      d0,StackAdr(a5)                        ; Save start of Stack memory (for AllocMem/FreeMem)
    move.l      d0,ZeStackPos(a5)                      ; Initialize Stack at its 1st position
    move.l      #DepthBufferSize*6,StackSize(a5)
    rts

seReleaseStack:
    move.l      StackSize(a5),d0
    tst.l       d0
    bne.s       .okR1
    CastErrorID CannotReleaseInternalStack
.okR1:
    move.l      StackAdr(a5),a1
    bsr         FreeMm
    clr.l       StackSize(a5)
    clr.l       StackAdr(a5)
    clr.l       ZeStackPos(a5)
    rts

sePushToStack:
    move.l      a3,tempSave(a5)
    Move.l      ZeStackPos(a5),a3                      ; A1 = Load 1st byte of stack memory block
    cmp.l       #0,a3
    bne.s       .cttPTS
    CastErrorID InternalStackDoesNotExists
.cttPTS:
    move.l      d6,(a3)+
    move.w      d7,(a3)+
    move.l      a3,ZeStackPos(a5)
    move.l      tempSave(a5),a3
    rts

seGetFromStack:
    move.l      a3,tempSave(a5)
    Move.l      ZeStackPos(a5),a3                      ; A1 = Load 1st byte of stack memory block
    cmpa.l      #0,a3
    bne.s       .cttGFS
    CastErrorID InternalStackDoesNotExists
.cttGFS:
    move.w      -(a3),d7
    move.l      -(a3),d6
    move.l      a3,ZeStackPos(a5)
    move.l      tempSave(a5),a3
    rts

seGetFromStackP:
    bsr         seGetFromStack
    exg.l       d6,d7
    rts

seResetStack:
    move.l      StackAdr(a5),ZeStackPos(a5)
    rts

pushVarToStack:
    move.w      saveType(a5),d7                        ; D7 = Variable type
    bsr         sePushToStack                          ; Push d6,d7 to Stack
    rts
