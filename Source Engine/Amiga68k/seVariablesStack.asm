
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.29                     *
; * Last Update :                         *
; * Version : 0.1                         *
; * File : seVariablesStack.asl           *
; * Author : Frederic Cordier             *
; *****************************************

sePushToStack   MACRO
sePushToStack\@:
    Move.l      StackAdr(a5),a0                        ; A1 = Load 1st byte of stack memory block
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
sePullFromStack\@:
    Move.l      StackAdr(a5),a0                        ; A1 = Load 1st byte of stack memory block
    move.l      ZeStackPos(a5),a1
    cmp.l       a0,a1
    bne.b       .ctu                      ; Cannot push this data as Stack is already FULL.
    CastErrorID ErrorDataStackIsEmpty
.ctu:
    Move.w      -(a0),\2
    move.l      -(a0),\1
    move.l      a0,ZeStackPos(a5)
                ENDM