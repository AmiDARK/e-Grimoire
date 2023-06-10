
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
  ; ******** Situation #1 : The data is a global variable (outside any procedure)
    IFD    gl\1lbl                           ; If global variable Label does exists
      loadGlobalDatas a4                     ;  Load global datas into A4 so all data can be allocated at creation
      move.l    gl\1(a4),(a3)+               ;  Push global variable inside the Stack
      move.w    gl\1+4(a4),(a3)+             ; *Debug purposes only*
    ELSEIF                                   ; Else
  ; ******** Situation #2 : The data is a local variable (from inside a procedure)
      IFD proc\<$inProcName>\1_Label         ;  If Local Variable Label does exists
        loadLocalDatas a4                    ;    Load local datas into A2 so all datas can be allocated at creation
        move.l  proc\<$inProcName>\1(a4),(a3)+ ;  Push register argument #1 inside local variable
        move.w  proc\<$inProcName>\1+4(a4),(a3)+ ; *Debug purposes only*
  ; ******** Situation #3 : The data is a global variable (from inside a procedure)
      ELSEIF
  ; ******** Situation #4 : The data is a data or adress register, or an adress register content
        move.l \1,(a3)+
        IFEQ (NARG-2)
          move.w \2,(a3)+
        ELSEIF
          move.w #0,(a3)+
        ENDC
      ENDC
    ENDC
    grmCall     grmSaveA3Stack
                ENDM

seGetFromStack  MACRO
    grmCall     grmLoadStackA3
  ; ******** Situation #1 : The data is a global variable (outside any procedure)
    IFD    gl\1lbl                           ; If global variable Label does exists
      loadGlobalDatas a4                     ;  Load global datas into A4 so all data can be allocated at creation
      move.w    -(a3),gl\1+4(a4)             ; *Debug purposes only*
      move.l    -(a3),gl\1(a4)               ;  Push global variable inside the Stack
    ELSEIF                                   ; Else
  ; ******** Situation #2 : The data is a local variable (from inside a procedure)
      IFD proc\<$inProcName>\1_Label         ;  If Local Variable Label does exists
        loadLocalDatas a4                    ;    Load local datas into A2 so all datas can be allocated at creation
        move.w  -(a3),proc\<$inProcName>\1+4(a4) ; *Debug purposes only*
        move.l  -(a3),proc\<$inProcName>\1(a4) ;  Push register argument #1 inside local variable
  ; ******** Situation #3 : The data is a global variable (from inside a procedure)
      ELSEIF
  ; ******** Situation #4 : The data is a data or adress register, or an adress register content
        IFEQ (NARG-2)
          move.w -(a3),\2
        ELSEIF
          move.w -(a3),Trash(a5)
        ENDC
        move.l -(a3),\1
      ENDC
    ENDC
    grmCall     grmSaveA3Stack
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
    grmCall     grmSeResetStack
                ENDM

; **************** Multi mode does not take care about variable format. it can read from 2 up to 8 parameters
seGetMultiFromStack  MACRO
    IFGE (NARG-2)
      seGetFromStack \1
      seGetFromStack \2
      IFGE (NARG-3)      ; **************** Variable #3 (optional)
        seGetFromStack \3
        IFGE (NARG-4)      ; **************** Variable #4 (optional)
          seGetFromStack \4
          IFGE (NARG-5)      ; **************** Variable #5 (optional)
            seGetFromStack \5
            IFGE (NARG-6)      ; **************** Variable #6 (optional)
              seGetFromStack \6
              IFGE (NARG-7)      ; **************** Variable #7 (optional)
                seGetFromStack \7
                IFGE (NARG-8)      ; **************** Variable #8 (optional)
                  seGetFromStack \8
                  IFGE (NARG-9)      ; **************** More than 8 variables to read cas an error
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
                ENDM

; **************** Multi mode does not take care about variable format. it can read from 2 up to 8 parameters
seMultiPushToStack  MACRO
    IFGE (NARG-2)
      sePushToStack \1
      sePushToStack \2
      IFGE (NARG-3)      ; **************** Variable #3 (optional)
        sePushToStack \3
        IFGE (NARG-4)      ; **************** Variable #4 (optional)
          sePushToStack \4
          IFGE (NARG-5)      ; **************** Variable #5 (optional)
            sePushToStack \5
            IFGE (NARG-6)      ; **************** Variable #6 (optional)
              sePushToStack \6
              IFGE (NARG-7)      ; **************** Variable #7 (optional)
                sePushToStack \7
                IFGE (NARG-8)      ; **************** Variable #8 (optional)
                  sePushToStack \8
                  IFGE (NARG-9)      ; **************** More than 8 variables to read cas an error
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
                ENDM

sePushToStackLib MACRO
    grmCall     grmLoadStackA3
    move.l \1,(a3)+
    IFEQ (NARG-2)
      move.w \2,(a3)+
    ELSEIF
      move.w #0,(a3)+
    ENDC
    grmCall     grmSaveA3Stack
                ENDM

seGetFromStackLib MACRO
    grmCall     grmLoadStackA3
    IFEQ (NARG-2)
      move.w -(a3),\2
    ELSEIF
      move.w -(a3),Trash(a5)
    ENDC
    move.l -(a3),\1
    grmCall     grmSaveA3Stack
                ENDM

        