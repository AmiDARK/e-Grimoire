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
Let            MACRO
  ; *************************************************************************************************************************
  ; ******** 1. We must handle the setup of the variable itself. It's the definition of the variable that depend on the location
  ; This part is processed in the 1st compilation pass.
  ; **** 1.1 We check if we are inside a procedure. In which case we create a local variable.
; ******** 1. We detect if let is used with a macro method call to return a value inside the variable
  IFGE (NARG-2)                                          ; If at least 2 parameter, check if 2nd one is a function to call
    IFD   macro_\2_callable                              ; If a Macro label exists with the specified name, then we use it
      \2 \3,\4,\5,\6,\7,\8,\9,\A                         ; Call the Macro Method. Value will be returned inside Stack
  seGetFromStack \1                                      ; Push the value returned by the Macro Method inside the Variable.
    ELSEIF
      IFEQ (NARG-2)
        sePushToStack \2                                 ; We push Parameter 2 into the stack
        seGetFromStack \1                                ; Push the value available in the stack directly inside the variable.
      ELSEIF
        FAIL : Let only accept 2 parameters (Variable,Value/Variable) or Variable,Function,FunctionParameters
      ENDC
    ENDC


        ENDM