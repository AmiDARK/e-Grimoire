; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2023.05.23                              *
; * Version : 0.2                                         *
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
    move.l      ZeStackPos(a5),a3
    move.l      d4,(a3)+               ; Push variable data inside the Stack
    move.w      d5,(a3)+               ; Push variable type inside the Stack
    move.l      a3,ZeStackPos(a5)
    rts

seGetFromStack:
    move.l      ZeStackPos(a5),a3
    move.w      -(a3),d5               ; Get variable type from the stack
    move.l      -(a3),d4               ; Get variable data from the stack
    move.l      a3,ZeStackPos(a5)
    rts

seLoadStackA3:
    LoadSys     a5
    Move.l      ZeStackPos(a5),a3                      ; A1 = Load 1st byte of stack memory block
;    cmp.l       #0,a3
;    bne.s       cttPTS
;    CastErrorID InternalStackDoesNotExists
;cttPTS:
    rts 

seSaveA3Stack:
    LoadSys     a5
    move.l      a3,ZeStackPos(a5)
    rts

seResetStack:
    move.l      StackAdr(a5),ZeStackPos(a5)
    rts
