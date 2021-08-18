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
SetInteger     MACRO
  ; *************************************************************************************************************************
  ; ******** 1. We must handle the setup of the variable itself. It's the definition of the variable that depend on the location
  ; This part is processed in the 1st compilation pass.
  ; **** 1.1 We check if we are inside a procedure. In which case we create a local variable.
  IFEQ  inProcedure-8
proc\<$inProcName>\1           equ varProc\<$inProcName>Count ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varProc\<$inProcName>Count     SET varProc\<$inProcName>Count+6
proc\<$inProcName>\1_Label:
    loadLocalDatas a3
    move.w          #TypeInt,proc\<$inProcName>\1+4(a3) ;        Setup the Global variable as Integer variable
  ; **** 1.2 If a 2nd argument is set, we try to detect it and use it, otherwise we let the variable to its default value
    IFEQ NARG-2                                          ; If VALUE is set, we must affect it to the variable itself
      vmsGetPush      \1,\2
    ENDC                                                 ; End of value inserting.
  ELSEIF

    ; **** 2.0 We check if the global variable was already defined (or not)
gl\1           equ varCount                              ;         Define the variable position in the structure
varCount       SET varCount+6                            ;         Increase the structure size by 6 bytes (Variable.l, VariableType.w )
gl\1lbl:                                                 ;         Create Label
    loadGlobalDatas a3                                 ;         Load global datas into A3 so all data can be allocated at creation
    move.w          #TypeInt,gl\1+4(a3)                ;         Setup the Global variable as Integer variable

    ; **** 2.1 If a 2nd argument is set, we try to detect it and use it, otherwise we let the variable to its default value
    IFEQ NARG-2                                          ; If VALUE is set, we must affect it to the variable itself
      vmsGetPush      \1,\2
    ENDC                                                 ; End of value inserting.
  ENDC
 ENDM

AsInteger      MACRO
  IFEQ NARG-1
   SetInteger  \1
  ELSEIF
   IFEQ  NARG-2
    SetInteger  \1,\2
   ENDC
  ENDC
 ENDM
        
loadIntegerVar  MACRO
  loadVarPtr  \1,\2
  cmp.w       #TypeInt,4(\2)
  beq.s       CIC\<$chkIntCount>
  CastErrorID VariableIsNotAnInteger
CIC\<$chkIntCount>:
 ENDM
        
