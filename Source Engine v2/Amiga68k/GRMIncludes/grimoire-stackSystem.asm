
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
    grmCall     grmLoadStackA3
    move.l      \1,(a3)+
    move.w      \2,(a3)+
    grmCall     grmSaveA3Stack
                ENDM

seGetFromStack  MACRO
    grmCall     grmLoadStackA3
    move.w      -(a3),\2
    move.l      -(a3),\1
    grmCall     grmSaveA3Stack
                ENDM

; **************** Multi mode does not take care about variable format. it can read from 2 up to 8 parameters
seGetMultiFromStack  MACRO
    grmCall     grmLoadStackA3
    IFGE (NARG-1)
      sub.l       #2,a3
      move.l      -(a3),\1
      sub.l       #2,a3
      move.l      -(a3),\2
      IFGE (NARG-2)      ; **************** Variable #3 (optional)
        sub.l       #2,a3
        move.l      -(a3),\3
        IFGE (NARG-3)      ; **************** Variable #4 (optional)
          sub.l       #2,a3
          move.l      -(a3),\4
          IFGE (NARG-4)      ; **************** Variable #5 (optional)
            sub.l       #2,a3
            move.l      -(a3),\5
            IFGE (NARG-5)      ; **************** Variable #6 (optional)
              sub.l       #2,a3
              move.l      -(a3),\6
              IFGE (NARG-6)      ; **************** Variable #7 (optional)
                sub.l       #2,a3
                move.l      -(a3),\7
                IFGE (NARG-7)      ; **************** Variable #8 (optional)
                  sub.l       #2,a3
                  move.l      -(a3),\8
                  IFGE (NARG-8)      ; **************** More than 8 variables to read cas an error
                    FAIL ; Cannot extract more than 8 variables at once when using seGetMultiFromStack
                  ENDC
                ENDC
              ENDC
            ENDC
          ENDC
        ENDC
      ENDC
    ELSEIF
      FAIL ; seGetMultiFromStack requires at least, 2 parameters to extract ( 2-8 parameters allowed )
    ENDC
    grmCall     grmSaveA3Stack
                ENDM


seGetFromStackP MACRO
    grmCall     grmLoadStackA3
    move.l      (a3)+,\1
    move.w      (a3)+,\2
    grmCall     grmSaveA3Stack
                ENDM

seResetStack    MACRO
    grmCall     grmSeResetStack
                ENDM