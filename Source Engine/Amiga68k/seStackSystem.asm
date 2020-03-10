
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.29                     *
; * Last Update :                         *
; * Version : 0.1                         *
; * File : seVariablesStack.asl           *
; * Author : Frederic Cordier             *
; *****************************************

seCreateStack:
    move.l      StackAdr(a5),a0
    cmp.l       #0,a0
    beq.s       .ok1
    CastErrorID InternalStackAlreadyCreated
.ok1:
    move.l      #StackBufferSize,d0
    mulu        #6,d0
    bsr         AllocClrFastMem
    tst.l       d0
    bne.s       .ok2
    CastErrorID NotEnoughFreeMemory
.ok2:
    move.l      d0,StackAdr(a5)                        ; Save start of Stack memory (for AllocMem/FreeMem)
    move.l      d0,ZeStackPos(a5)                      ; Initialize Stack at its 1st position
    move.l      #StackBufferSize*6,StackSize(a5)
    rts

seReleaseStack:
    move.l      StackSize(a5),d0
    tst.l       d0
    bne.s       .okR1
    CastErrorID CannotReleaseInternalStack
.okR1:
    move.l      StackAdr(a5),a1
    bsr         FreeMm
    move.l      #0,StackSize(a5)
    move.l      #0,StackAdr(a5)
    move.l      #0,ZeStackPos(a5)
    rts

sePushToStack   MACRO
sPushToStack\@:
    Move.l      StackAdr(a5),a0                        ; A1 = Load 1st byte of stack memory block
    cmp.l       #0,a0
    bne.s       .ctt
    CastErrorID InternalStackDoesNotExists
.ctt:
    Move.l      #StackBufferSize,d0                    ; D0 = Stack buffer size in amount of variables
    Mulu        #6,d0                                  ; D0 = True buffer size in amount of bytes (each variable is 6 bytes)
    add.l       d0,a0                                  ; A1
    move.l      ZeStackPos(a5),a1
    cmp.l       a0,a1
    bgt.b       .ctu                      ; Cannot push this data as Stack is already FULL.
    CastErrorID DirectDataStackOverflow
.ctu:
    Move.l      ZeStackPos(a5),a0
    Move.l      \1,(a0)+
    move.w      \2,(a0)+
    move.l      a0,ZeStackPos(a5)
                ENDM

sePullFromStack MACRO
sPullFromStack\@:
    Move.l      StackAdr(a5),a0                        ; A1 = Load 1st byte of stack memory block
    cmp.l       #0,a0
    bne.s       .ctt
    CastErrorID InternalStackDoesNotExists
.ctt:
    move.l      ZeStackPos(a5),a1
    cmp.l       a0,a1
    bne.b       .ctu                                   ; ZeStackPos > StackAdr = Datas Remains To REad -> Jump .ctu
    CastErrorID ErrorDataStackIsEmpty                  ; Cannot push this data as Stack is already FULL.
.ctu:
;    clr.l       \2
    Move.w      -(a0),\2
    move.l      -(a0),\1
    move.l      a0,ZeStackPos(a5)
                ENDM