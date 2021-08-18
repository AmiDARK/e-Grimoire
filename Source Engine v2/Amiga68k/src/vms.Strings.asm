; **********************************************************
; * Method Name : SetInteger                               *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   SetInteger VarName,VALUE
; *
; *--------------------------------------------------------*
; * Description :                                          *
; *--------------------------------------------------------*
; * Version : 
; * Last update date : 
; **********************************************************
SetString     MACRO
  ; *************************************************************************************************************************
  ; ******** 1. We must handle the setup of the variable itself. It's the definition of the variable that depend on the location
  ; This part is processed in the 1st compilation pass.
  ; **** 1.1 We check if we are inside a procedure. In which case we create a local variable.
  IFEQ  inProcedure-8
proc\<$inProcName>\1           equ varProc\<$inProcName>Count ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varProc\<$inProcName>Count     SET varProc\<$inProcName>Count+6
proc\<$inProcName>\1_Label:
    loadLocalDatas a3
    move.w            #TypeStr,proc\<$inProcName>\1+4(a3) ; Setup the Local variable as Integer variable
  ; **** 1.2 If a 2nd argument is set, we try to detect it and use it, otherwise we let the variable to its default value
    IFEQ NARG-2                                          ; If VALUE is set, we must affect it to the variable itself
      lea             proc\<$inProcName>\1_Data(pc),a0
      move.l          a0,d0
      move.l          d0,proc\<$inProcName>\1(a3)        ; Setup the Local variable Integer value
      bra.s           proc\<$inProcName>\1_Continue
proc\<$inProcName>\1_Data:
      dc.b            \2,10,0
      even
proc\<$inProcName>\1_Continue:
    ELSE
      move.l          #0,proc\<$inProcName>\1(a3)

    ENDC                                                 ; End of value inserting.
  ELSEIF

    ; **** 2.0 We check if the global variable was already defined (or not)
gl\1           equ varCount                              ;         Define the variable position in the structure
varCount       SET varCount+6                            ;         Increase the structure size by 6 bytes (Variable.l, VariableType.w )
gl\1lbl:                                                 ;         Create Label
    loadGlobalDatas a3                                   ;         Load global datas into A3 so all data can be allocated at creation
    move.w          #TypeStr,gl\1+4(a3)                  ;         Setup the Global variable as Integer variable

    ; **** 2.1 If a 2nd argument is set, we try to detect it and use it, otherwise we let the variable to its default value
    IFEQ NARG-2                                          ; If VALUE is set, we must affect it to the variable itself
      lea             gl\1lbl_Data(pc),a0
      move.l          a0,d0
      move.l          d0,gl\1(a3)                        ;         Setup the Global variable Integer value
      bra.s           gl\1lbl_Continue
gl\1lbl_Data:
      dc.b            \2,10,0
      even
gl\1lbl_Continue:
    ENDC                                                 ; End of value inserting.
  ENDC
 ENDM

AsString      MACRO
  IFEQ NARG-1
    SetString \1
  ELSEIF
    IFEQ  NARG-2
      SetString \1,\2
    ENDC
  ENDC
        ENDM
        
