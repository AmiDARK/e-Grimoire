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
; * Version : 0.9                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
Procedure       MACRO
  ; ******** 1. We must handle the setup of the procedure itself. It's the definition of the procedure.
  ; This part is processed in the 1st compilation pass.
  ; *************************************************************************************************************************
  ; 1.1 Security, check if a procedure definition is asked from inside a procedure
  IFEQ inProcedure-8
    Fail ; Compilation ERROR : A Procedure cannot be set inside another one.
  ELSEIF

inProcedure     SET 8             ; 8 = We are inside a procedure definition
inProcName      SET inProcName+1  ; And the procedure name a calculation for unique identifiers
varProc\<$inProcName>Count  SET 0 ; Set procedure variable size to 0.

    ; 1.2 We makes the program jump after the procedure because procedure can be reached only by a call method.
    bra         endProc\<$inProcName>Ended           ; Jump after the procedure

  ; 1.3 We create the procedure call entry point
procedure_\1:
    LoadSys    a5
    ; 1.3.1 Check if recursive procedures call does not override the allowed buffer limitation.
    add.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    cmp.w       #seMaxProceduresCalls,procedureDepth(a5)
    blt.s       .ok
    CastErrorID TooMuchProcedureCallsWithoutReturn
.ok:

    ; 1.3.2 Reset the Procedure/Local variables support system that will also allocate memory for the variables buffer
    buildLocalDatas                                     ; Start to create local variables datas (should contains at mimum the next/prev/size variables )

    ; There are 3 variables at the beginning of each procedure
    ; 2. = size\1                        Created inside the buildLocalDatas macro
    SetInteger ArgsCount\1, (NARG-1)/2 ; Create a variable to store the amount of parameters
    ; 3. = ArgsCount\1
    ; After these 3 variables came the parameters
    ; After the parameters came the variables created inside the procedure

    ; 1.3.3 Now add support for up to 16 parameters formatted using : Param Name, Param Type
    IFNE NARG-1
      IFEQ NARG-3      ; **************** Parameter #1
        addParamSupport \2,\3 ; All parameters are defined using 2 arguments : Param Name, Param Type
      ELSEIF
        IFEQ NARG-5      ; **************** Parameter #2
          addParamSupport \4,\5
        ELSEIF
          IFEQ NARG-7      ; **************** Parameter #3
            addParamSupport \6,\7
          ELSEIF
            IFEQ NARG-9      ; **************** Parameter #4
              addParamSupport \8,\9
            ELSEIF
              IFEQ NARG-11      ; **************** Parameter #5
                addParamSupport \a,\b
              ELSEIF
                IFEQ NARG-13      ; **************** Parameter #6
                  addParamSupport \c,\d
                ELSEIF
                  IFEQ NARG-15      ; **************** Parameter #7
                    addParamSupport \e,\f
                  ELSEIF
                    IFEQ NARG-17      ; **************** Parameter #8
                      addParamSupport \g,\h
                    ELSEIF
                      IFEQ NARG-19      ; **************** Parameter #9
                        addParamSupport \i,\j
                      ELSEIF
                        IFEQ NARG-21      ; **************** Parameter #10
                          addParamSupport \k,\l
                        ELSEIF
                          IFEQ NARG-23      ; **************** Parameter #11
                            addParamSupport \m,\n
                          ELSEIF
                            IFEQ NARG-25      ; **************** Parameter #12
                              addParamSupport \o,\p
                            ELSEIF
                              IFEQ NARG-27      ; **************** Parameter #13
                                addParamSupport \q,\r
                              ELSEIF
                                IFEQ NARG-29      ; **************** Parameter #14
                                  addParamSupport \s,\t
                                ELSEIF
                                  IFEQ NARG-31      ; **************** Parameter #15
                                    addParamSupport \u,\v
                                  ELSEIF
                                    IFEQ NARG-33      ; **************** Parameter #16
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
      ; 1.3.5 And then, we load parameters from where they were stored in the procedure call
      loadProcParams  (NARG-1)/2
    ENDC
  ENDC
  ; 1.3.5 The procedure startup is created.
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
; * Last update date : 2021.06.05                          *
; **********************************************************
EndProcedure     MACRO
  ; 0 = Security, check if we are inside a procedure before asking to close one
  IFNE inProcedure-8
    Fail ; Compilation ERROR : a Procedure opening is required before EndProcedure.
  ELSEIF

endProc\<$inProcName>closing:
    LoadSys    a5

;    ; 2.4 RELEASE BUFFER USED TO STORE LOCAL VARIABLES 
    DeleteLocal \1 ; Delete local variables datas if exists.
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
; * Version : 0.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
callProcedure   MACRO
.callProc\1:
  bsr         procedure_\1
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
; * Last update date : 2021.06.05                          *
; **********************************************************
addParamSupport MACRO 
        \2      \1                      ; Example : AsInteger  VarName,(Value)
                ENDM

; **********************************************************
; * Method Name : loadParams                               *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   loadParams AMOUNT_OF_PARAMETERS                      *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used by the 'Procedure' macro to load  *
; *   inside pre-defined procedures arguments (local var)  *
; *   all the values that were sent to it directly from the*
; *   'callProcedure' call.                                *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.07                          *
; **********************************************************
loadProcParams  MACRO
loadParams\<$inProcName>:
    Move.l      #\1,d7                         ; D7 = Amount of params to load.
    tst.l       d7
    beq         lpEnd\<$inProcName>            ; No params ? YES -> Jump directly at the end
    sub.l       #1,d7                          ; D7 -1 to count limits with positive value
    loadLocalDatas a3
    add.l       #6*2,a3                        ; Jump after procPrec, procSize & ArgsCount\1
    move.l      (a3),d6                        ; D6 = Procedure arguments count
    cmp.l       d7,d6
    beq.s       .isOK\<$inProcName>
    CastErrorID IllegalAmountOfParametersToCallProcedure
.isOK\<$inProcName>:
    move.l      d7,d0
lpLoop\<$inProcName>:
    seGetFromStack d5,d6                         ; D5 = Variable, D6 = VariableType
    cmp.w        4(a3),d6
    beq.s        .lpLoopCt\<$inProcName>
    CastErrorID ArgumentIsNotOfTheCorrectTypeForProcCall
.lpLoopCt\<$inProcName>:
    move.l       d5,(a3)+
    move.w       d6,(a3)+
    dbra         d7,lpLoop\<$inProcName>

;    cmp.w       #TypeStr,d6
;    beq.s       .lClone
;    cmp.w       #TypeNewStr,d6
;    bne.s       .lpload
;.lClone:
;    move.l      d5,a0
;    bsr         cloneString
;    move.l      #TypeNewStr,d6
;    move.l      a0,d5
.lpload:
    move.l      d5,(a3)
    move.w      d6,4(a3)
    sub.l       #6,a3                                  ; A3 = previous parameters (parameters are written in order and read in reversed order)
    sub.l       #1,d7                                  ; Next parameters ?
    bpl.w       lpLoop\<$inProcName>                   ; YES -> Continue reading from Stack.
lpEnd\<$inProcName>:
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

