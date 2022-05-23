
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.29                     *
; * Last Update :                         *
; * Version : 0.1                         *
; * File : seVariablesStack.asm           *
; * Author : Frederic Cordier             *
; *****************************************

; ******** This small macro check if param \1 = param \2 or \3. Ideal to check if a param is a register.
CheckIfRegister MACRO
  IFEQ  isRegister                           ; If no register was already found
    IFC \1,'\2'                             ; if \1=\2
isRegister      Set 1                        ; 1 = register found in the data \1
    ELSEIF
      IFC \1,'\3'                           ; if \1=\3
isRegister      Set 1                        ; 1 = register found in the data \1
      ENDC
    ENDC
  ENDC
                ENDM

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
        IFD    gl\2lbl                       ; If global variable Label does exists
          loadGlobalDatas a4                 ;   Load global datas into A2 so all data can be allocated at creation
          move.l    gl\1(a4),(a3)+           ;   Push register argument #1 inside global variable (DirectValue,VariableGlobal)
          move.w    gl\1+4(a4),(a3)+         ; *Debug purposes only*
        ELSEIF
  ; ******** Situation #4 : The data is a data or adress register, or an adress register content
isRegister      Set 0                        ; 0 = No register found in the data \1
          CheckIfRegister '\1',(a0),(A0)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a1),(A1)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a2),(A2)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a3),(A3)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a4),(A4)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a5),(A5)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a6),(A6)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a7),(A7)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a0)+,(A0)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a1)+,(A1)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a2)+,(A2)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a3)+,(A3)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a4)+,(A4)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a5)+,(A5)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a6)+,(A6)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a7)+,(A7)+   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a0),-(A0)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a1),-(A1)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a2),-(A2)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a3),-(A3)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a4),-(A4)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a5),-(A5)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a6),-(A6)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a7),-(A7)   : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d0),(D0)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d1),(D1)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d2),(D2)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d3),(D3)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d4),(D4)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d5),(D5)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d6),(D6)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d7),(D7)     : Check if parameter \1 contain a data or adress register
          ; ******** If a register was found, we push it
          IFNE isRegister
            move.l \1,(a3)+
            IFEQ NARG-2
              move.w \2,(a3)+
            ELSEIF
              move.w #0,(a3)+
            ENDC
          ELSEIF
            move.l \1,(a3)+
            IFEQ NARG-2
              move.w \2,(a3)+
            ELSEIF
              move.w #0,(a3)+
            ENDC
          ENDC
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
        IFD    gl\2lbl                       ; If global variable Label does exists
          loadGlobalDatas a4                 ;   Load global datas into A2 so all data can be allocated at creation
          move.w    -(a3),gl\1+4(a4)         ; *Debug purposes only*
          move.l    -(a3),gl\1(a4)           ;   Push register argument #1 inside global variable (DirectValue,VariableGlobal)
        ELSEIF
  ; ******** Situation #4 : The data is a data or adress register, or an adress register content
isRegister      Set 0                        ; 0 = No register found in the data \1
          CheckIfRegister '\1',(a0),(A0)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a1),(A1)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a2),(A2)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a3),(A3)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a4),(A4)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a5),(A5)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a6),(A6)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a7),(A7)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a0)+,(A0)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a1)+,(A1)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a2)+,(A2)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a3)+,(A3)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a4)+,(A4)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a5)+,(A5)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a6)+,(A6)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(a7)+,(A7)+     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a0),-(A0)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a1),-(A1)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a2),-(A2)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a3),-(A3)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a4),-(A4)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a5),-(A5)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a6),-(A6)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',-(a7),-(A7)     : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d0),(D0)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d1),(D1)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d2),(D2)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d3),(D3)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d4),(D4)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d5),(D5)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d6),(D6)       : Check if parameter \1 contain a data or adress register
          CheckIfRegister '\1',(d7),(D7)       : Check if parameter \1 contain a data or adress register
          ; ******** If a register was found, we push it
          IFNE isRegister
            IFEQ NARG-2
              move.w -(a3),\2
            ELSEIF
              sub.w  #2,a3
            ENDC
            move.l -(a3),\1
          ELSEIF
            IFEQ NARG-2
              move.w -(a3),\2
            ELSEIF
              sub.w  #2,a3
            ENDC
            move.l -(a3),\1
          ENDC
        ENDC
      ENDC
    ENDC
    grmCall     grmSaveA3Stack
                ENDM

; **************** Multi mode does not take care about variable format. it can read from 2 up to 8 parameters
seGetMultiFromStack  MACRO
    grmCall     grmLoadStackA3
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
    grmCall     grmSaveA3Stack
                ENDM

; **************** Multi mode does not take care about variable format. it can read from 2 up to 8 parameters
seMultiPushToStack  MACRO
    grmCall     grmLoadStackA3
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
    grmCall     grmSaveA3Stack
                ENDM


seResetStack    MACRO
    grmCall     grmSeResetStack
                ENDM