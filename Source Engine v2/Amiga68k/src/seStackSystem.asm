
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.29                     *
; * Last Update :                         *
; * Version : 0.1                         *
; * File : seVariablesStack.asm           *
; * Author : Frederic Cordier             *
; *****************************************


sePushToStack   MACRO
    move.l      a3,tempSave(a5)
    Move.l      ZeStackPos(a5),a3                      ; A1 = Load 1st byte of stack memory block
    cmp.l       #0,a3
    bne.s       .cttPTS\<$inProcName>
    CastErrorID InternalStackDoesNotExists
.cttPTS\<$inProcName>:
    move.l      \1,(a3)+
    move.w      \2,(a3)+
    move.l      a3,ZeStackPos(a5)
    move.l      tempSave(a5),a3
                ENDM

seGetFromStack  MACRO
    move.l      a3,tempSave(a5)
    Move.l      ZeStackPos(a5),a3                      ; A1 = Load 1st byte of stack memory block
    cmpa.l      #0,a3
    bne.s       .cttGFS\<$inProcName>
    CastErrorID InternalStackDoesNotExists
.cttGFS\<$inProcName>:
    move.w      -(a3),\2
    move.l      -(a3),\1
    move.l      a3,ZeStackPos(a5)
    move.l      tempSave(a5),a3
                ENDM

seGetFromStackP MACRO
    move.l      a3,tempSave(a5)
    Move.l      ZeStackPos(a5),a3                      ; A1 = Load 1st byte of stack memory block
    cmpa.l      #0,a3
    bne.s       .cttGFS\<$inProcName>
    CastErrorID InternalStackDoesNotExists
.cttGFS\<$inProcName>:
    move.l      (a3)+,\1
    move.w      (a3)+,\2
    move.l      a3,ZeStackPos(a5)
    move.l      tempSave(a5),a3
                ENDM

seResetStack    MACRO
;    move.l      d7,tempSave(a5)
;    move.l      StackAdr(a5),d7
;    move.l      d7,ZeStackPos(a5)
;    move.l      tempSave(a5),d7
    move.l      StackAdr(a5),ZeStackPos(a5)
                ENDM
        