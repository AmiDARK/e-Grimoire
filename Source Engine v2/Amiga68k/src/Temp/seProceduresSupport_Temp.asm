; Optimize addParamSupport to no more need \1 (procedure name)
; Update LoadLocalVar to no more need the procedure name as argument.
; Continue update of procedures support

Procedure       MACRO
    ; *************************************************************************************************************************
    ; ******** 1. We must handle the setup of the procedure itself. It's the definition of the procedure.
    ; This part is processed in the 1st compilation pass.

    ; 0 = Security, check if a procedure definition is asked from inside a procedure
    IFNE InProcedure
      Fail ; Compilation ERROR : A Procedure cannot be set inside another one.
    ENDC

InProcedure     SET 1       ; 1 = We are inside a procedure definition
InProcedureName SET \1      ; And the procedure name is extracted from argument 1

    ; 1. We firstly check if a procedure with the same name was already defined and push a compilation FAIL if it's the case
    IFD         proc_\1
      Fail ; Compilation ERROR : A procedure with the same name is already defined : \1

    ; 1.1 If it's not the case, we can create the procedure itseld
    ELSEIF
paramCount      SET 0

    ; 1.2 We makes the program jump after the procedure because procedure can be reached only by a call method.
    bra         ep\1

    ; 1.3 We create the procedure call entry point
proc_\1:

    ; 1.3.1 Check if recursive procedures call does not override the allowed buffer limitation.
    add.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    cmp.w       #DepthBufferSize,procedureDepth(a5)
    blt.s       .ok
    CastErrorID TooMuchProcedureCallsWithoutReturn
.ok:

    ; 1.3.2 Reset the Procedure/Local variables support system that will also allocate memory for the variables buffer
    buildLocalDatas \1                 ; Start to create local variables datas (should contains at mimum the next/prev/size variables )

    SetInteger \2ArgsCount, (NARG-1)/2 ; Create a variable to store the amount of parameters

    ; 1.3.3 Now add support for up to 16 parameters formatted using : Param Name, Param Type
    IFNE NARG-1
      IFEQ NARG-3      ; **************** Parameter #1
            addParamSupport \1,\2,\3 ; All parameters are defined using 2 arguments : Param Name, Param Type
      ELSEIF
        IFEQ NARG-5      ; **************** Parameter #2
          addParamSupport \1,\4,\5
        ELSEIF
          IFEQ NARG-7      ; **************** Parameter #3
            addParamSupport \1,\6,\7
          ELSEIF
            IFEQ NARG-9      ; **************** Parameter #4
              addParamSupport \1,\8,\9
            ELSEIF
              IFEQ NARG-11      ; **************** Parameter #5
                addParamSupport \1,\a,\b
              ELSEIF
                IFEQ NARG-13      ; **************** Parameter #6
                  addParamSupport \1,\c,\d
                ELSEIF
                  IFEQ NARG-15      ; **************** Parameter #7
                    addParamSupport \1,\e,\f
                  ELSEIF
                    IFEQ NARG-17      ; **************** Parameter #8
                      addParamSupport \1,\g,\h
                    ELSEIF
                      IFEQ NARG-19      ; **************** Parameter #9
                        addParamSupport \1,\i,\j
                      ELSEIF
                        IFEQ NARG-21      ; **************** Parameter #10
                          addParamSupport \1,\k,\l
                        ELSEIF
                          IFEQ NARG-23      ; **************** Parameter #11
                            addParamSupport \1,\m,\n
                          ELSEIF
                            IFEQ NARG-25      ; **************** Parameter #12
                              addParamSupport \1,\o,\p
                            ELSEIF
                              IFEQ NARG-27      ; **************** Parameter #13
                                addParamSupport \1,\q,\r
                              ELSEIF
                                IFEQ NARG-29      ; **************** Parameter #14
                                  addParamSupport \1,\s,\t
                                ELSEIF
                                  IFEQ NARG-31      ; **************** Parameter #15
                                    addParamSupport \1,\u,\v
                                  ELSEIF
                                    IFEQ NARG-33      ; **************** Parameter #16
                                      addParamSupport \1,\w,\x
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
      loadParams  \1,(NARG-1)/2
    ENDC

    ; 1.3.5 The procedure startup is created.
                ENDM




; *****************************************************
; 2. End a procedure or function
EndProcedure     MACRO

    ; 0 = Security, check if we are inside a procedure before asking to close one
    IFEQ InProcedure
      Fail ; Compilation ERROR : a Procedure opening is required before EndProcedure.
    ENDC

endProc_\1_closing:
    LoadSys    a5

    ; 2.1 We check if 1 returned argument is set to be returned and see it's type.
    ; Situation 1 : We can see here if it's a parameter from the procedure, from global variables, or direct integer value
    IFEQ NARG-1

      ; 2.1.1 If varLabel exists, then we'll return a value from a variable that is located inside the procedure
varLabel         SET InProcedureName\1lbl      ;   Construct the procedure variable label to check for existence
      IFD       varLabel                       ;   If label exists, then we return a parameter from within the procedure
varName          SET InProcedureName\1         ;   Construct the variable name
        LoadLocalVar \1,\2,d6,d7
        move.l       d6,endProcVar(a5)
        move.w       d7,endProcVar+4(a5)

      ELSEIF
        ; 2.1.2 If gl\1bl exists, then we'll return a value from a variable that is located in the global area
        IFD   gl\1lbl
          LoadGlobalVar  \1,d6,d7
          move.l         d6,endProcVar(a5)
          move.w         d7,endProcVar+4(a5)
        ELSEIF

          ; 2.1.3 Now, the only available solution remain that we return a direct integer value.
          move.l  #\2,endProcVar(a5)
          move.w  #TypeInt,endproc_\1_tOutput+4(a5) ; Save the variable type as Integer

        ENDC
      ENDC
    ELSEIF

      ; 2.2.1 Second situation, we can return direct value using extra information for float or String
      IF NARG-2

          ; ******** Case 1 Return a Direct Value param1=ProcedureName, param2=Type, param3=Value
          IFC     '\2','AsString' or '\2','SetString'
            lea.l   endproc_\1_tOutput(pc),a0            ; Load the pointer of the static string content into A0
            move.l  a0,endProcVar(a5)
            move.w  #TypeStr,endproc_\1_tOutput+4(a5)    ; Save the variable type as String
          ELSEIF
            IFC     '\2','AsFloat' or '\2','SetFloat'
              lea.l endproc_\1_tOutput(pc),a0  ; Load the pointer of the String representation of the static floating number value into A0
              bsr     privConvertStrToFlt      ; Call String to Floating number conversion method. Do not use stack but direct datas into A0.str -> D0.flt
              move.l  d0,endProcVar(a5)        ; Set the floating number variable value.
              move.w  #TypeFlt,endproc_\1_tOutput+4(a5) ; Setup the Global variable as Floating number variable.
            ELSEIF
              FAIL ; Compilation Error : Cannot understand the returned value type
            ENDC
          ENDC

      ELSEIF

        ; 2.3.1 Latest situation, if we do not have 1 or 2 arguments, only 0 arguments is allowed then.
        ; Other cases will return compilation error.
        IFNE NARG
          FAIL ; Compilation Error : Illegal amount of argument in the EndProcedure call (only 0,1 or 2 are allowed)
        ENDC
      ENDC

    ENDC

    ; 2.4 RELEASE BUFFER USED TO STORE LOCAL VARIABLES 
    DeleteLocal \1 ; Delete local variables datas if exists.
    
    ; 2.5 Check Calls<>Returns integrity ********************************
    sub.w       #1,procedureDepth(a5)                  ; Security that count the recursive depth to avoid Goto/Gosub jump in a procedure
    bpl.s       ep\1return
    CastErrorID TooMuchEndProcedureReached
    
    ; 2.6  Here we can put the String/Flt(String) datas used for direct output when created
    IF NARG-3
endproc_\1_tOutput:
      dc.b        \3,10,0
    ENDC
ep\1return:
    rts
ep\1:

    ; 2.7 We update procedure datas to say "we are no more inside a procedure"
InProcedure     SET 0       ; 0 = We are no more inside a procedure definition
InProcedureName SET ""      ; And the procedure name is resetted

                ENDM
