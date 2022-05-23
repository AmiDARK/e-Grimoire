; *****************************************************************************
; * Project           : e-Grimoire                                            *
; *---------------------------------------------------------------------------*
; * Component         : Source Engine                                         *
; * Component Version : 2.0                                                   *
; * Platform          : Amiga 680x0 compatible                                *
; *---------------------------------------------------------------------------*
; *                                                                           *
; * File : seProcedureSupport.asm                                             *
; *                                                                           *
; *---------------------------------------------------------------------------*
; * Available MACROS and Functions :                                          *
; *                                                                           *
; * M | Procedure NAME,(Optional ArgsList{ArgName,ArgType,...})               *
; * M | |-> addParamSupport VariableName, VariableType        [Internal only] *
; * M | |-> loadProcParams                                    [Internal only] *
; * M | EndProcedure (Optional ReturnedValue(Global/Local/DirectValue))       *
; *   |                                                                       *
; * M | callProcedure procName, (Optional Parameters sent using variableName  *
; * M | |-> pushVarToStack VariableValue,VariableType         [Internal only] *
; *                                                                           *
; *****************************************************************************


; **********************************************************
; * Method Name : Procedure                                *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   Procedure NAME,ArgsList{ArgName,ArgType}...          *
; *--------------------------------------------------------*
; * Description : This method will allow the creation of a *
; *   procedure style system. The procedure must be closed *
; *   with the macro 'EndProcedure'                        *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
Procedure       MACRO
  ; ******** 1. We must handle the setup of the procedure itself. It's the definition of the procedure.
  ; This part is processed in the 1st compilation pass.
  ; *************************************************************************************************************************
  ; 1.1 Security, check if a procedure definition is asked from inside a procedure
  IFEQ inProcedure-8
    Fail ; Compilation ERROR : A Procedure cannot be set inside another one.
  ELSEIF
    ; 1.2 Define default temporar labels for evaluation
inProcedure     SET 8             ; 8 = We are inside a procedure definition
inProcName      SET inProcName+1  ; And we set the procedure name (a calculation for unique identifiers)
varProc\<$inProcName>Count  SET 0 ; Set procedure variable size/amount to 0.
    ; 1.3 We makes the program jump after the procedure because procedure can be reached only by a call method.
    bra         endProc\<$inProcName>Ended           ; Jump after the procedure
    ; 1.4 We create the procedure call entry point. It here that a "CallProcedure" will arrive.
procedure_\1:
    ; LoadSys    a5
    ; 1.3.1 Check if recursive procedures call does not override the allowed buffer limitation.
    add.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    cmp.w       #seMaxProceduresCalls,procedureDepth(a5)
    blt.s       .ok
    CastErrorID TooMuchProcedureCallsWithoutReturn
.ok:
    ; 1.4.2 Reset the Procedure/Local variables support system that will also allocate memory for the variables buffer
    buildLocalDatas                                     ; Start to create local variables datas (should contains at mimum the next/prev/size variables )
    ; Build Local datas will create 2 internal variables for the handling of procedure recursive local variables buffers switch using a chained method
  ; 1.4.3 Setup the amount of parameters required for this procedure to works correctly
    SetInteger ArgsCount\1,argProc\1final ; Create a variable to store the amount of parameters
  ; 1.4.4 Now we read all the arguments that were passed to the procedure using the CallProcedure method.
argProc\<$inProcName>Count  SET 0 ; Default push to 0 arguments in a procedure definition.
    IFGE (NARG-2)      ; **************** Parameter #1 (optional)
      addParamSupport \2,\3 ; All parameters are defined using 2 arguments : Param Name, Param Type
      IFGE (NARG-4)      ; **************** Parameter #2 (optional)
        addParamSupport \4,\5
        IFGE (NARG-6)      ; **************** Parameter #3 (optional)
          addParamSupport \6,\7
          IFGE (NARG-8)      ; **************** Parameter #4 (optional)
            addParamSupport \8,\9
            IFGE (NARG-10)      ; **************** Parameter #5 (optional)
              addParamSupport \a,\b
              IFGE (NARG-12)      ; **************** Parameter #6 (optional)
                addParamSupport \c,\d
                IFGE (NARG-14)      ; **************** Parameter #7 (optional)
                  addParamSupport \e,\f
                  IFGE (NARG-16)      ; **************** Parameter #8 (optional)
                    addParamSupport \g,\h
                    IFGE (NARG-18)      ; **************** Parameter #9 (optional)
                      addParamSupport \i,\j
                      IFGE (NARG-20)      ; **************** Parameter #10 (optional)
                        addParamSupport \k,\l
                        IFGE (NARG-22)      ; **************** Parameter #11 (optional)
                          addParamSupport \m,\n
                          IFGE (NARG-24)      ; **************** Parameter #12 (optional)
                            addParamSupport \o,\p
                            IFGE (NARG-26)      ; **************** Parameter #13 (optional)
                              addParamSupport \q,\r
                              IFGE (NARG-28)      ; **************** Parameter #14 (optional)
                                addParamSupport \s,\t
                                IFGE (NARG-30)      ; **************** Parameter #15 (optional)
                                  addParamSupport \u,\v
                                  IFGE (NARG-32)      ; **************** Parameter #16 (optional)
                                    addParamSupport \w,\x
                                  ENDC
                                ENDC
                              ENDC
                            ENDC
                          ENDC
                        ENDC
                      ENDC
                    ENDC
                  ENDC
                ENDC
              ENDC
            ENDC
          ENDC
        ENDC
      ENDC
    ENDC
argProc\1final EQU argProc\<$inProcName>Count        ; Evaluation of the amount of parameters the procedure requires in the 2nd pass
    ; 1.5 And then, we load parameters from where they were stored in the procedure call directly into the local variables
    ; that are created using the Procedure definition.
    loadProcParams \1
  ENDC
  ; 1.6 The procedure startup is created. Now the following code will be inside the procedure. End of the Macro
 ENDM

; **********************************************************
; * Method Name : addParamSupport                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   addParamSupport VariableName, VariableType           *
; *                                                        *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to allow, inside a procedure, to  *
; *   insert a procedure argument as local variable.       *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
addParamSupport MACRO 
argProc\<$inProcName>Count SET argProc\<$inProcName>Count+1
        \2      \1                      ; Example : AsInteger  VarName,(Value)
                ENDM

; **********************************************************
; * Method Name : loadProcParams                           *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   loadProcParams                                       *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used by the 'Procedure' macro to load  *
; *   inside pre-defined procedures arguments (local var)  *
; *   all the values that were sent to it directly from the*
; *   'callProcedure' call.                                *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
loadProcParams  MACRO
loadParams\<$inProcName>:
  vmsGetPush  ArgsCount\1,d7                 ; D7 = Amount of parameters the procedure requires.
  tst.l       d7
  beq         lpEnd\<$inProcName>            ; No params ? YES -> Jump directly at the end
  loadLocalDatas a2
  add.l       #(6*3),a2                      ; Jump after procPrec, procSize & ArgsCount\1
  move.l      -6(a2),d6                       ; D6 = Procedure arguments count * 2 + 1
  cmp.l       d7,d6
  beq.s       .isOK\<$inProcName>
  CastErrorID IllegalAmountOfParametersToCallProcedure
.isOK\<$inProcName>:
  sub.l       #1,d7                          ; D7 -1 to count limits with positive value
  seResetStack
lpLoop\<$inProcName>:
  seGetFromStack d5,d6                      ; D5 = Variable, D6 = VariableType
   cmp.w       4(a2),d6                       ; Is parameter of the correct type ?
  beq.s       .lpLoopCt\<$inProcName>
  CastErrorID ArgumentIsNotOfTheCorrectTypeForProcCall
.lpLoopCt\<$inProcName>:
  move.l      d5,(a2)+                       ; Write parameter value
  move.w      d6,(a2)+                       ; write parameter type
  dbra        d7,lpLoop\<$inProcName>
  seResetStack
;  cmp.w       #TypeStr,d6
;  beq.s       .lClone
;  cmp.w       #TypeNewStr,d6
;  bne.s       .lpload
;.lClone:
;  move.l      d5,a0
;  bsr         cloneString
;  move.l      #TypeNewStr,d6
;  move.l      a0,d5
;  bpl.w       lpLoop\<$inProcName>                   ; YES -> Continue reading from Stack.
lpEnd\<$inProcName>:
                ENDM

; **********************************************************
; * Method Name : EndProcedure                             *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   EndProcedure                                         *
; *   EndProcedure (Optional)ReturnedVar(Global/Local)     *
; *   EndProcedure (Optional)DirectValue                   *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro closes a previously opened 'Procedure'.   *
; *   It can return an optional parameter that can be a lo-*
; *   -cal variable to the procedure, a global variable, or*
; *   a direct integer value                               *
; *--------------------------------------------------------*
; * Version : 0.9                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
EndProcedure     MACRO
  ; 0 = Security, check if we are inside a procedure before asking to close one
  IFNE inProcedure-8
    Fail ; Compilation ERROR : a Procedure opening is required before EndProcedure.
  ELSEIF
endProc\<$inProcName>closing:
    ; LoadSys    a5
    seResetStack                 ; Push stack to the 1st argument position .
    ; **** 1.1 If a variable or a value is pushed at exit
    IFEQ NARG-1
      vmsGetPush \1,d6
      move.w     saveType(a5),d7
      sePushToStack d6,d7          ; Extracted from \1 variable or direct value.
    ELSEIF
      sePushToStack #0,#0          ; No returned value.
    ENDC
;    ; 2.4 RELEASE BUFFER USED TO STORE LOCAL VARIABLES 
    DeleteLocal ; Delete local variables datas if exists.
endProc\<$inProcName>EarlyEnd: 
    rts
  ENDC
endProc\<$inProcName>Ended: 
    ; 2.7 We update procedure datas to say "we are no more inside a procedure"
inProcedure     SET 0       ; 0 = We are no more inside a procedure definition
                ENDM

; **********************************************************
; * Method Name : callProcedure                            *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   callProcedure ProcedureName                          *
; *   callProcedure ProcedureName, ParamsList{Variables}   *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to call a procedure. It must be   *
; *   adapted to the argument list the procedure needs. If *
; *   the procedure requires no parameters, then this macro*
; *   will have to be called without parameters. If parame-*
; *   -ters are required, they must be entered one after   *
; *   other without the variable type but the sent varia-  *
; *   -bles must follow the respectives variables types    *
; *   required by the procedure and in the same order than *
; *   the procedure definition order.                      *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
callProcedure   MACRO
procCallName  SET  procCallName+1
cp\<$procCallName>Count  SET 0 ; Set procedure variable size to 0.
callProc\<$procCallName>:
  seResetStack                 ; Push stack to the 1st argument position .
  IFGE NARG-2                  ; Check if at least 1 parameter is set to be sent to the procedure (Depend on procedure definition)
    pushVarToStack \2 ; Push variable to stack, type is read from the variable itself
    IFGE NARG-3      ; **************** Parameter #2 (Depend on procedure definition)
      pushVarToStack \3 ; 
      IFGE NARG-4      ; **************** Parameter #3 (Depend on procedure definition)
        pushVarToStack \4 ; 
        IFGE NARG-5      ; **************** Parameter #4 (Depend on procedure definition)
          pushVarToStack \5 ; 
          IFGE NARG-6      ; **************** Parameter #5 (Depend on procedure definition)
            pushVarToStack \6 ; 
            IFGE NARG-7      ; **************** Parameter #6 (Depend on procedure definition)
              pushVarToStack \7 ; 
              IFGE NARG-8      ; **************** Parameter #7 (Depend on procedure definition)
                pushVarToStack \8 ; 
                IFGE NARG-9      ; **************** Parameter #8 (Depend on procedure definition)
                  pushVarToStack \9 ; 
                  IFGE NARG-10      ; **************** Parameter #9 (Depend on procedure definition)
                    pushVarToStack \a ; 
                    IFGE NARG-11      ; **************** Parameter #10 (Depend on procedure definition)
                      pushVarToStack \b ; 
                       IFGE NARG-12      ; **************** Parameter #11 (Depend on procedure definition)
                        pushVarToStack \c ; 
                        IFGE NARG-13      ; **************** Parameter #12 (Depend on procedure definition)
                          pushVarToStack \d ; 
                          IFGE NARG-14      ; **************** Parameter #13 (Depend on procedure definition)
                            pushVarToStack \e ; 
                            IFGE NARG-15      ; **************** Parameter #14 (Depend on procedure definition)
                              pushVarToStack \f ; 
                              IFGE NARG-16      ; **************** Parameter #15 (Depend on procedure definition)
                                pushVarToStack \g ; 
                                IFGE NARG-17      ; **************** Parameter #16 (Depend on procedure definition)
                                  pushVarToStack \h ; 
                                ENDC
                              ENDC
                            ENDC
                          ENDC
                        ENDC
                      ENDC
                    ENDC
                  ENDC
                ENDC
              ENDC
            ENDC
          ENDC
        ENDC
      ENDC
    ENDC
  ENDC
cp\<$procCallName>fCount EQU cp\<$procCallName>Count ; Nombre final de paramètres envoyés à la procédure
  move.l      #argProc\1final,d7                       ; The Procedure amount of parameters required
  cmp.l       #cp\<$procCallName>fCount,d7             ;
  beq.s       callProc\<$procCallName>FF
  CastErrorID IllegalAmountOfParametersToCallProcedure ; Error, the amount of parameters used does not meet procedure requirements.
callProc\<$procCallName>FF:
  ; Call the Procedure itself
    bsr          procedure_\1
              ENDM


; **********************************************************
; * Method Name : pushVarToStack                            *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   pushVarToStack VariableName                          *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method is internally used by the 'callProcedure'*
; *   macro to push arguments in the stack so they can be  *
; *   received by the procedure and pushed inside its local*
; *   variables created by the Procedure arguments list.   *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
pushVarToStack  MACRO
cp\<$procCallName>Count set cp\<$procCallName>Count+1  ; Increate the Amount of parameters sent to the Procedure
    vmsGetPush  \1,d6                                  ; D6 = Variable value (local/global)
    move.w      saveType(a5),d7                        ; D7 = Variable type
    sePushToStack d6,d7                                ; Push d6,d7 to Stack
                ENDM


; **********************************************************
; * Method Name : getProcedureReturn                       *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   getProcedureReturn VariableToReceiveData             *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to receive the data outputted by a*
; *   procedure when leaving. The Variable used to receive *
; *   the value value must be global or local to the proce-*
; *   -dure from which the macro call is done. And the two *
; *   variables type (sent by procedure, and receving one) *
; *   must be the same.                                    *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
getProcedureReturn MACRO
nextProcReturn     set nextProcReturn+1
  seResetStack
  seGetFromStack  d6,d7                   ; Get values from Stack
  cmp.l       #0,d7
  bne.s       gPR\<$nextProcReturn>
  CastErrorID ProcedureDidNotReturnAnyValue
gPR\<$nextProcReturn>:
  updateVar   \1,d6,d7
                   ENDM

;    ; 2.1 We check if 1 returned argument is set to be returned and see it's type.
;    ; Situation 1 : We can see here if it's a parameter from the procedure, from global variables, or direct integer value
;    IFEQ NARG-1
;      ; 2.1.1 If varLabel exists, then we'll return a value from a variable that is located inside the procedure
;      IFD       \<$inProcName>\1lbl       ;   If label exists, then we return a parameter from within the procedure
;varName          SET inProcName\1         ;   Construct the variable name
;        LoadLocalVar \1,\2,d6,d7
;        move.l       d6,endProcVar(a5)
;        move.w       d7,endProcVar+4(a5)
;
;      ELSEIF
;        ; 2.1.2 If gl\1bl exists, then we'll return a value from a variable that is located in the global area
;        IFD   gl\1lbl
;          LoadGlobalVar  \1,d6,d7
;          move.l         d6,endProcVar(a5)
;          move.w         d7,endProcVar+4(a5)
;        ELSEIF
;
;          ; 2.1.3 Now, the only available solution remain that we return a direct integer value.
;          move.l  #\2,endProcVar(a5)
;          move.w  #TypeInt,endproc_\1_tOutput+4(a5) ; Save the variable type as Integer
;
;        ENDC
;      ENDC
;    ELSEIF
;
;    ENDC
;
;    
;    ; 2.5 Check Calls<>Returns integrity ********************************
;    sub.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
;    bpl.s       ep\1return
;    CastErrorID TooMuchEndProcedureReached
;    
;    ; 2.6  Here we can put the String/Flt(String) datas used for direct output when created
;ep\1return:
;    rts
;endproc_\1_tOutput:
;      dc.b        \3,10,0
;    ENDC
;endProc\<$inProcName>Ended: 
;    ; 2.7 We update procedure datas to say "we are no more inside a procedure"
;varProc\<$inProcName>Size EQU varProc\<$inProcName>Count
;inProcedure     SET 0       ; 0 = We are no more inside a procedure definition

