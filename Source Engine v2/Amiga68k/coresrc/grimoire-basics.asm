; **********************************************************
; * File Name : basicsSupport.Asm                          *
; *--------------------------------------------------------*
; * Description : This file contains macros used to emulate*
; *   some old basic languages style commands.             * 
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.07.08                          *
; **********************************************************
;
; List of Macros available in the BasicsSupport.asm file :
; ************************************************************************** START
; buildAllLoopsBuffer                        [INTERNAL]
; deleteAllLoopsBuffer                       [INTERNAL]
; BasicFOR Variable,StartValue,EndValue
; BasicFOR Variable,StartValue,EndValue,Step
; BasicNEXT
; BasicINC Variable                         Variable=Variable+1
; BasicINC Variable,DirectValue             Variable=Variable+DirectValue
; BasicINC Variable,Variable2               Variable=Variable+Variable2
; BasicDEC Variable                         Variable=Variable-1
; BasicDEC Variable,DirectValue             Variable=Variable-DirectValue
; BasicDEC Variable,Variable2               Variable=Variable-Variable2
; BasicLEN StringVar,OutputIntVar           OutputIntVar=String length without final 0
; BasicLEFT SourceString,LenInBytes,TargetString
; BasicRIGHT SourceString,LenInBytes,TargetString
; BasicMID SourceString,StartPos,LenInBytes,TargetString
; BasicASC SourceString,Pos,TargetInteger
; BasicCHR SourceString,Pos,TargetString
; BasicIF IntegerVar1,Operator,IntegerVar2
; BasicTHEN
; BasicELSE                                 Optional
; BasicENDIF
; BasicGOTO
; BasicGOSUB                                To Do : Add a high limit (too much consecutives gosub calls)
; BasicRETURN
; BasicLABEL

; Not yet done :
; --------------
; BasicDO
; BasicLOOP
; BasicStruct
; BasicEndStruct
; BasicWHILE
; BasicENDWHILE
; BasicREPEAT
; BasicUNTIL
; ************************************************************************** END
;


loadBasicIntegerArgument MACRO
basicArgCount SET basicArgCount+1
  IFD gl\1lbl
    loadGlobalDatas a3
    cmp.w      #TypeInt,gl\1+4(a3)
    beq.s      .lbia\<$basicArgCount>_ok
    CastErrorID VariableIsNotAnInteger
.lbia\<$basicArgCount>_ok:
    move.l     gl\1(a3),\2
  ELSEIF
    IFD proc\<$inProcName>\1_Label
      loadLocalDatas a4
      cmp.w      #TypeInt,proc\<$inProcName>\1+4(a4)
      beq.s      .lbia\<$basicArgCount>_ok
      CastErrorID VariableIsNotAnInteger
.lbia\<$basicArgCount>_ok:
      move.l     proc\<$inProcName>\1(a4),\2
    ELSEIF
      move.l     \1,\2
    ENDC
  ENDC
 ENDM


loadBasicStringSource MACRO
basicStringCount SET basicStringCount+1
    loadVarPtr \1,a2
    move.w     4(a2),d7
    cmp.w      #TypeStr,d7
    beq.s      .lbss\<$basicStringCount>_strOk
    cmp.w      #TypeStaticStr,d7
    beq.s      .lbss\<$basicStringCount>_strOk
    cmp.w      #TypeStrRef,d7
    beq.s      .lbss\<$basicStringCount>_strOk
    CastErrorID VariableIsNotAString
.lbss\<$basicStringCount>_strOk:
    move.l     (a2),\2
    move.l     \2,d7
    cmp.l      #0,d7
    bne.s      .lbss\<$basicStringCount>_ptrOk
    CastErrorID CannotEValuateStringUsingNullPointer
.lbss\<$basicStringCount>_ptrOk:
 ENDM


loadBasicStringTarget MACRO
basicStringCount SET basicStringCount+1
    loadVarPtr \1,a2
    cmp.w      #TypeStr,4(a2)
    beq.s      .lbst\<$basicStringCount>_strOk
    CastErrorID DirectDataNotSameTypeThanVariable
.lbst\<$basicStringCount>_strOk:
    move.l     (a2),\2
    move.l     \2,d7
    cmp.l      #0,d7
    bne.s      .lbst\<$basicStringCount>_ptrOk
    CastErrorID CannotEValuateStringUsingNullPointer
.lbst\<$basicStringCount>_ptrOk:
 ENDM


; **********************************************************
; * Method Name : BasicLABEL                              *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicLABEL Label                                    *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Define a BASIC branch label usable by BasicGOTO and *
; *   BasicGOSUB. BASIC labels are prefixed internally to *
; *   avoid jumping to raw ASM labels by mistake.          *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.02                          *
; **********************************************************
BasicLABEL MACRO
  IFEQ NARG-1
    IFEQ inProcedure-8
      Fail ; Compilation ERROR : BasicLABEL cannot be defined inside a Procedure.
    ELSEIF
bla_\1:
    ENDC
  ELSEIF
    Fail ; BasicLABEL Requires only one parameter, the label to define
  ENDC
 ENDM


; **********************************************************
; * Method Name : buildAllLoopsBuffer                       *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   buildAllLoopsBuffer                        [INTERNAL] *
; *--------------------------------------------------------*
; * Description : This method is used to create a buffer   *
; *   that was previously calculated to be able to handle  *
; *   the maximal detected amount of imbricated for/next   *
; *   uses.                                                *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
buildAllLoopsBuffer MACRO
    move.l     #finalAllLoopsBuffer,d7         ; Is defined by adding all cumulatives For/Next 
    grmCall    grmBuildAllLoopsBuffer
               ENDM


; **********************************************************
; * Method Name : deleteAllLoopsBuffer                      *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   deleteAllLoopsBuffer                       [INTERNAL] *
; *--------------------------------------------------------*
; * Description : This method release the buffer that was  *
; *   previously reserved for the use of For/next methods. *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
deleteAllLoopsBuffer MACRO
finalAllLoopsBuffer equ higherForNext+1   ; Set finalAllLoopsBuffer to see if we must create buffer
  IFGE blockForNext
    FAIL ; At least one (or more) <<BasicNEXT>> is/are missing.
  ELSEIF
    IFGE finalAllLoopsBuffer-1            ; if at least 1 for/next buffer is required
      move.l     #finalAllLoopsBuffer,d7
      grmCall    grmDeleteAllLoopsBuffer
    ENDC
  ENDC
 ENDM       




buildGosubsBuffer MACRO
  move.l     #seMaxGosubCalls,d7         ; Is defined by adding all cumulatives Gosub/Return
  grmCall    grmBuildGosubsBuffer
                  ENDM

deleteGosubsBuffer MACRO
  move.l     #seMaxGosubCalls,d7
  grmCall    grmDeleteGosubsBuffer
 ENDM       


; **********************************************************
; * Method Name : BasicGOSUB                               *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicGOSUB                                           *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Jump at a specific position in the source code defi- *
; *   -ned by a label. This method must be used in conjunc-*
; *   -tion with a BasicRETURN macro to continue program   *
; *   just after the BasicGOSUB.                           *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2022.02.20                          *
; **********************************************************
; Add support to detect in BasicRETURN if we are in a Gosub call or not.
;BasicRETURN MACRO
;    rts
;            ENDM
        
;BasicGOSUB MACRO
;    add.l      #1,gosubDepth(a5)       ; Load buffer into a4
;    bsr        \1
; ENDM
BasicGOSUB     MACRO
  IFEQ NARG-1
blockGosub Set blockGosub+1
    tst.w      procedureDepth(a5)
    beq.s      .bGS\<$blockGosub>_p0
    CastErrorID GosubNotAllowedFromInsideAProcedure
.bGS\<$blockGosub>_p0:
    Move.l     GosubsBuffer(a5),a4
    ; ******** 1. Check if buffer was created
    cmp.l      #0,a4
    bne.s      .bGS\<$blockGosub>_p1
    CastErrorID GosubsBufferNotSet
.bGS\<$blockGosub>_p1:
    ; ******** 2. Check if buffer limit is reached
    cmpa.l     GosubsBufferLimit(a5),a4
    blt.s      .bGS\<$blockGosub>_p2
    CastErrorID TooMuchGosubCallWithoutReturn
.bGS\<$blockGosub>_p2:
  lea.l      .bGS\<$blockGosub>_rtrn(pc),a3
    move.l     a3,(a4)+
    move.l     a4,GosubsBuffer(a5)
    bra        bla_\1
.bGS\<$blockGosub>_rtrn:
  ELSEIF
    Fail ; BasicGOSUB Requires only one parameter, the label to call
  ENDC
 ENDM


BasicRETURN    MACRO
blockReturn Set blockReturn+1
  tst.w        procedureDepth(a5)
  beq.s        .bRT\<$blockReturn>_p0
  CastErrorID  ReturnCalledWithoutGosub
.bRT\<$blockReturn>_p0:
  Move.l       GosubsBuffer(a5),a4
  ; ******** 1. Check if a gosub was called before
  cmpa.l       GosubsBufferStart(a5),a4
  bgt.s        .bRT\<$blockReturn>_p1
  CastErrorID  ReturnReachedWithGosubCall
.bRT\<$blockReturn>_p1:
  move.l       -(a4),a3
  move.l       a4,GosubsBuffer(a5)
  jmp          (a3)
 ENDM


; **********************************************************
; * Method Name : BasicFOR                                 *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   BasicFOR Variable,StartValue,EndValue                *
; *   BasicFOR Variable,StartValue,EndValue,Step           *
; *--------------------------------------------------------*
; * Description : This method is used to create loops using*
; *   a style similar to basic languages. StartValue and   *
; *   EndValue can be both local/global variables or direct*
; *   values. Step is optional. If not used, its value will*
; *   be automatically be set to 1.                        *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2021.07.04                          *
; **********************************************************
BasicFOR       MACRO
  ; 1. Security Checking A : For macro requires at least 3 parameter ( VAR, START, END ), auto step=1
  IFGE NARG-3
    ; 2. Security Checking B : For macro must not use more than 4 parameters (VAR, STARt, END, STEP)
    IFGE NARG-5
      CastErrorID BasicFORUses3Or4Parameters
    ELSEIF
    ; 3. Define constants for this For/Next block
blockForNext Set blockForNext+1          ; And the current ForNext block is... (1st one =0 as default value =-1)
blockForNextB Set blockForNextB+1        ; And the current ForNext block is... (1st one =0 as default value =-1)
      IFGE blockForNext-higherForNext
higherForNext set blockForNext
      ENDC
bid\<$blockForNext> set blockForNext
      ; LoadSys    a5                      ; Be sure that Internal System Structure is loaded into a5
      ; 4. Load the For/Next parameters/Arguments into Dn registers and check for compatibles types
      vmsGetPush  \2,d5                  ; d5 = Start Position
      cmp.w      #TypeInt,saveType(a5)
      bne.s      .bFN\<$blockForNextB>_ce
      vmsGetPush  \3,d6                  ; d6 = End Position
      cmp.w      #TypeInt,saveType(a5)
      bne.s      .bFN\<$blockForNextB>_ce
      IFEQ NARG-4
        vmsGetPush \4,d7                 ; D7 = Step from arguments
        cmp.w    #TypeInt,saveType(a5)
        bne.s    .bFN\<$blockForNextB>_ce
      ELSEIF
        move.l   #1,d7                  ; D7 = Step (default=1)
      ENDC
      loadVarPtr \1,a4                  ; A4 = Pointer to the variable to use for the loop
      cmp.w      #TypeInt,4(a4)
      beq.s      .bFN\<$blockForNextB>_p1
.bFN\<$blockForNextB>_ce:
      CastErrorID ForNextRequiresIntegerVariablesOrValue
.bFN\<$blockForNextB>_p1:
      move.l     a4,d4                  ; d4 = Pointer to the variable to use for the loop
      ; 5. Update variable to meet the Start Value
      move.l     d5,(a4)                ; Variable = Start value
      ; 6. Load the For/Next block buffer to save informations about For/Next loop
      Move.l     AllLoopsBuffer(a5),a4   ; Load buffer into a4
      cmp.l      #0,a4
      bne.s      .bFN\<$blockForNextB>_p2
      CastErrorID AllLoopsBufferNotSet
.bFN\<$blockForNextB>_p2:
      move.l     #bid\<$blockForNext>,d5 ; d5 = ID of the For/Next Block
      lsl.l      #4,d5                  ; a For/Next block uses 16 bytes VarPtr.l, EndValue.l, Step.l, PointerForLoop.l
      add.l      d5,a4                  ; a4 = Pointer to the current For/Next data save buffer
      move.l     d4,(a4)+               ; Save Variable Pointer
      move.l     d7,(a4)+               ; Save Step
      move.l     d6,(a4)+               ; Save Final Value
      lea.l      BasicFor\<$blockForNextB>lbl(pc),a3
      move.l     a3,(a4)                ; Save pointer for loop
    ENDC
  ENDC
BasicFor\<$blockForNextB>lbl:
 ENDM

; **********************************************************
; * Method Name : BasicNEXT                                *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   BasicNEXT                                            *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method is used coupled with a BasicFOR method to*
; *   create a loop system similar to the For/Next ones in *
; *   classics basic languages. No need to push the varia- *
; *   name after BasicNEXT as it will be ignored as loop   *
; *   system is auto-detect?                               *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2021.07.04                          *
; **********************************************************
BasicNEXT      MACRO
blockForNextB set blockForNextB+1
  ; LoadSys    a5                      ; Be sure that Internal System Structure is loaded into a5
  ; 1. Load the For/Next data save buffer and datas from it.
  Move.l      AllLoopsBuffer(a5),a4   ; Load buffer into a4
  move.l      #bid\<$blockForNext>,d7 ; d7 = ID of the For/Next Block
  lsl.l       #4,d7                  ; a For/Next block uses 16 bytes VarPtr.l, EndValue.l, Step.l, PointerForLoop.l
  add.l       d7,a4                  ; a4 = Pointer to the current For/Next data save buffer
  Move.l      (a4)+,a3               ; a3 = Pointer to the variable value
  move.l      (a3),d7                ; d7 = Variable value
  move.l      (a4)+,d6               ; d6 = Step Value
  add.l       d6,d7                  ; d7 = d7 + Step Value (d6)
  move.l      d7,(a3)                ; Save the variable value to its register
  move.l      (a4)+,d5               ; d5 = Last Value
  tst.l       d6
  bpl.s       .bFN\<$blockForNextB>_inc
  ; 2. Check limit for decremental step
.bFN\<$blockForNextB>_dec:
  cmp.l       d5,d7                  ; does the variable (d7) reach the ending value (d5)
  blt.s       .bFN\<$blockForNextB>_cntn
  move.l      (a4),a4
  jmp         (a4)                   ; End value not reached, continue to loop
  ; 3. Check limit for incremental step
.bFN\<$blockForNextB>_inc:
  cmp.l       d7,d5                  ; does the variable (d7) reach the ending value (d5)
  blt.s       .bFN\<$blockForNextB>_cntn
  move.l      (a4),a4
  jmp         (a4)                   ; End value not reached, continue to loop
  ; 4. The loop is over.
.bFN\<$blockForNextB>_cntn:
blockForNext set blockForNext-1          ; And the current ForNext block is... (1st one =0 as default value =-1)
 ENDM

; **********************************************************
; * Method Name : BasicINC                                 *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicINC Variable                                    *
; *   BasicINC Variable,DirectValue                        *
; *   BasicINC Variable,Variable2                          *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to do specific decrease of a vari-*
; *   -able value.                                         *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.07.01                          *
; **********************************************************
BasicINC MACRO
chkIntCount set chkIntCount+1
  loadIntegerVar \1,a4
  IFEQ NARG-2
    vmsGetPush \2,d7     
  ELSEIF
    move.l     #1,d7
  ENDC
  add.l      d7,(a4)
 ENDM

; **********************************************************
; * Method Name : BasicDEC                                 *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicDEC Variable                                    *
; *   BasicDEC Variable,DirectValue                        *
; *   BasicDEC Variable,Variable2                          *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to do specific decrease of a vari-*
; *   -able value.                                         *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.07.01                          *
; **********************************************************
BasicDEC MACRO
chkIntCount set chkIntCount+1
  loadIntegerVar \1,a4
  IFEQ NARG-2
    vmsGetPush \2,d7     
  ELSEIF
    move.l     #1,d7
  ENDC
  sub.l      d7,(a4)
 ENDM


; **********************************************************
; * Method Name : BasicLEN                                 *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicLEN StringVar,OutputIntVar                      *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Read an existing String variable and store its length*
; *   without the final zero byte into an existing Integer *
; *   variable.                                            *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.18                          *
; **********************************************************
BasicLEN MACRO
  IFEQ NARG-2
basicLenCount SET basicLenCount+1
    loadVarPtr \1,a4
    move.w     4(a4),d7
    cmp.w      #TypeStr,d7
    beq.s      .bLen\<$basicLenCount>_strOk
    cmp.w      #TypeStaticStr,d7
    beq.s      .bLen\<$basicLenCount>_strOk
    cmp.w      #TypeStrRef,d7
    beq.s      .bLen\<$basicLenCount>_strOk
    CastErrorID VariableIsNotAString
.bLen\<$basicLenCount>_strOk:
    move.l     (a4),a0
    cmp.l      #0,a0
    bne.s      .bLen\<$basicLenCount>_ptrOk
    CastErrorID CannotEValuateStringUsingNullPointer
.bLen\<$basicLenCount>_ptrOk:
    moveq      #0,d6
.bLen\<$basicLenCount>_loop:
    tst.b      (a0)+
    beq.s      .bLen\<$basicLenCount>_done
    addq.l     #1,d6
    bra.s      .bLen\<$basicLenCount>_loop
.bLen\<$basicLenCount>_done:
    loadVarPtr \2,a4
    cmp.w      #TypeInt,4(a4)
    beq.s      .bLen\<$basicLenCount>_outOk
    CastErrorID VariableIsNotAnInteger
.bLen\<$basicLenCount>_outOk:
    move.l     d6,(a4)
  ELSEIF
    Fail ; BasicLEN requires exactly two parameters : StringVar,OutputIntVar
  ENDC
 ENDM


; **********************************************************
; * Method Name : BasicLEFT                                *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicLEFT SourceString,LenInBytes,TargetString       *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Copy the first LenInBytes bytes from SourceString    *
; *   into a mutable TargetString and append final zero.   *
; *   SourceString can be TypeStr, TypeStaticStr or        *
; *   TypeStrRef. TargetString must be TypeStr.            *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.19                          *
; **********************************************************
BasicLEFT MACRO
  IFEQ NARG-3
basicStringCount SET basicStringCount+1
    loadBasicStringSource \1,a0
    loadBasicIntegerArgument \2,d5
    loadBasicStringTarget \3,a1
    cmp.l      #0,d5
    bgt.s      .bLeft\<$basicStringCount>_lenPositive
    CastErrorID StringLengthOutOfRange
.bLeft\<$basicStringCount>_lenPositive:
    cmp.l      #vmsStringBufferSize-2,d5
    ble.s      .bLeft\<$basicStringCount>_copyStart
    CastErrorID StringSizeTooBig
.bLeft\<$basicStringCount>_copyStart:
    move.w     #vmsStringBufferSize-3,d7
.bLeft\<$basicStringCount>_copyLoop:
    tst.l      d5
    beq.s      .bLeft\<$basicStringCount>_done
    move.b     (a0)+,d6
    beq.s      .bLeft\<$basicStringCount>_lengthError
    move.b     d6,(a1)+
    subq.l     #1,d5
    dbra       d7,.bLeft\<$basicStringCount>_copyLoop
    CastErrorID StringSizeTooBig
.bLeft\<$basicStringCount>_lengthError:
    CastErrorID StringLengthOutOfRange
.bLeft\<$basicStringCount>_done:
    move.b     #10,(a1)+
    clr.b      (a1)
  ELSEIF
    Fail ; BasicLEFT requires exactly three parameters : SourceString,LenInBytes,TargetString
  ENDC
 ENDM


; **********************************************************
; * Method Name : BasicRIGHT                               *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicRIGHT SourceString,LenInBytes,TargetString      *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Copy the last LenInBytes bytes from SourceString     *
; *   into a mutable TargetString and append final zero.   *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.19                          *
; **********************************************************
BasicRIGHT MACRO
  IFEQ NARG-3
basicStringCount SET basicStringCount+1
    loadBasicStringSource \1,a0
    loadBasicIntegerArgument \2,d5
    loadBasicStringTarget \3,a1
    cmp.l      #0,d5
    bgt.s      .bRight\<$basicStringCount>_measure
    CastErrorID StringLengthOutOfRange
.bRight\<$basicStringCount>_measure:
    move.l     a0,a2
    moveq      #0,d6
.bRight\<$basicStringCount>_measureLoop:
    tst.b      (a2)+
    beq.s      .bRight\<$basicStringCount>_measured
    addq.l     #1,d6
    bra.s      .bRight\<$basicStringCount>_measureLoop
.bRight\<$basicStringCount>_measured:
    cmp.l      d6,d5
    ble.s      .bRight\<$basicStringCount>_lenOk
    CastErrorID StringLengthOutOfRange
.bRight\<$basicStringCount>_lenOk:
    cmp.l      #vmsStringBufferSize-2,d5
    ble.s      .bRight\<$basicStringCount>_sizeOk
    CastErrorID StringSizeTooBig
.bRight\<$basicStringCount>_sizeOk:
    move.l     d6,d7
    sub.l      d5,d7
    add.l      d7,a0
    tst.l      d5
    beq.s      .bRight\<$basicStringCount>_done
    move.l     d5,d7
    subq.l     #1,d7
.bRight\<$basicStringCount>_copyLoop:
    move.b     (a0)+,d6
    move.b     d6,(a1)+
    dbra       d7,.bRight\<$basicStringCount>_copyLoop
.bRight\<$basicStringCount>_done:
    move.b     #10,(a1)+
    clr.b      (a1)
  ELSEIF
    Fail ; BasicRIGHT requires exactly three parameters : SourceString,LenInBytes,TargetString
  ENDC
 ENDM


; **********************************************************
; * Method Name : BasicMID                                 *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicMID SourceString,StartPos,LenInBytes,TargetStr  *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Copy LenInBytes bytes from SourceString starting at  *
; *   byte offset StartPos into mutable TargetString.      *
; *   StartPos is zero-based.                              *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.19                          *
; **********************************************************
BasicMID MACRO
  IFEQ NARG-4
basicStringCount SET basicStringCount+1
    loadBasicStringSource \1,a0
    loadBasicIntegerArgument \2,d4
    loadBasicIntegerArgument \3,d5
    loadBasicStringTarget \4,a1
    cmp.l      #0,d4
    bge.s      .bMid\<$basicStringCount>_posOk
    CastErrorID StringPositionOutOfRange
.bMid\<$basicStringCount>_posOk:
    cmp.l      #0,d5
    bgt.s      .bMid\<$basicStringCount>_lenOk
    CastErrorID StringLengthOutOfRange
.bMid\<$basicStringCount>_lenOk:
    cmp.l      #vmsStringBufferSize-2,d5
    ble.s      .bMid\<$basicStringCount>_seekStart
    CastErrorID StringSizeTooBig
.bMid\<$basicStringCount>_seekStart:
    tst.l      d4
    beq.s      .bMid\<$basicStringCount>_copyStart
.bMid\<$basicStringCount>_seekLoop:
    tst.b      (a0)+
    beq.s      .bMid\<$basicStringCount>_positionError
    subq.l     #1,d4
    bne.s      .bMid\<$basicStringCount>_seekLoop
.bMid\<$basicStringCount>_copyStart:
    tst.b      (a0)
    beq.s      .bMid\<$basicStringCount>_positionError
    move.w     #vmsStringBufferSize-3,d7
.bMid\<$basicStringCount>_copyLoop:
    tst.l      d5
    beq.s      .bMid\<$basicStringCount>_done
    move.b     (a0)+,d6
    beq.s      .bMid\<$basicStringCount>_lengthError
    move.b     d6,(a1)+
    subq.l     #1,d5
    dbra       d7,.bMid\<$basicStringCount>_copyLoop
    CastErrorID StringSizeTooBig
.bMid\<$basicStringCount>_positionError:
    CastErrorID StringPositionOutOfRange
.bMid\<$basicStringCount>_lengthError:
    CastErrorID StringLengthOutOfRange
.bMid\<$basicStringCount>_done:
    move.b     #10,(a1)+
    clr.b      (a1)
  ELSEIF
    Fail ; BasicMID requires exactly four parameters : SourceString,StartPos,LenInBytes,TargetString
  ENDC
 ENDM


; **********************************************************
; * Method Name : BasicASC                                 *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicASC SourceString,Pos,TargetInteger              *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Read the byte at zero-based Pos from SourceString    *
; *   and store it into TargetInteger. Out of range gives  *
; *   zero.                                                *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.19                          *
; **********************************************************
BasicASC MACRO
  IFEQ NARG-3
basicStringCount SET basicStringCount+1
    loadBasicStringSource \1,a0
    loadBasicIntegerArgument \2,d5
    moveq      #0,d6
    cmp.l      #0,d5
    bge.s      .bAsc\<$basicStringCount>_posOk
    CastErrorID StringPositionOutOfRange
.bAsc\<$basicStringCount>_posOk:
    tst.l      d5
    beq.s      .bAsc\<$basicStringCount>_read
.bAsc\<$basicStringCount>_seekLoop:
    tst.b      (a0)+
    beq.s      .bAsc\<$basicStringCount>_positionError
    subq.l     #1,d5
    bne.s      .bAsc\<$basicStringCount>_seekLoop
.bAsc\<$basicStringCount>_read:
    moveq      #0,d6
    move.b     (a0),d6
    bne.s      .bAsc\<$basicStringCount>_write
.bAsc\<$basicStringCount>_positionError:
    CastErrorID StringPositionOutOfRange
.bAsc\<$basicStringCount>_write:
    loadVarPtr \3,a4
    cmp.w      #TypeInt,4(a4)
    beq.s      .bAsc\<$basicStringCount>_outOk
    CastErrorID VariableIsNotAnInteger
.bAsc\<$basicStringCount>_outOk:
    move.l     d6,(a4)
  ELSEIF
    Fail ; BasicASC requires exactly three parameters : SourceString,Pos,TargetInteger
  ENDC
 ENDM


; **********************************************************
; * Method Name : BasicCHR                                 *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicCHR SourceString,Pos,TargetString               *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Read the byte at zero-based Pos from SourceString    *
; *   and copy it as a one-character mutable string.       *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.19                          *
; **********************************************************
BasicCHR MACRO
  IFEQ NARG-3
basicStringCount SET basicStringCount+1
    loadBasicStringSource \1,a0
    loadBasicIntegerArgument \2,d5
    moveq      #0,d6
    cmp.l      #0,d5
    bge.s      .bChr\<$basicStringCount>_posOk
    CastErrorID StringPositionOutOfRange
.bChr\<$basicStringCount>_posOk:
    tst.l      d5
    beq.s      .bChr\<$basicStringCount>_read
.bChr\<$basicStringCount>_seekLoop:
    tst.b      (a0)+
    beq.s      .bChr\<$basicStringCount>_positionError
    subq.l     #1,d5
    bne.s      .bChr\<$basicStringCount>_seekLoop
.bChr\<$basicStringCount>_read:
    move.b     (a0),d6
    bne.s      .bChr\<$basicStringCount>_write
.bChr\<$basicStringCount>_positionError:
    CastErrorID StringPositionOutOfRange
.bChr\<$basicStringCount>_write:
    loadBasicStringTarget \3,a1
    tst.b      d6
    beq.s      .bChr\<$basicStringCount>_done
    move.b     d6,(a1)+
.bChr\<$basicStringCount>_done:
    move.b     #10,(a1)+
    clr.b      (a1)
  ELSEIF
    Fail ; BasicCHR requires exactly three parameters : SourceString,Pos,TargetString
  ENDC
 ENDM


; **********************************************************
; * Method Name : BasicIF                                  *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicIF IntegerVar1,ComparisonOperator,IntegerVar2   *
; *   BasicTHEN                                            *
; *   BasicELSE                                            *
; *   BasicENDIF                                           *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Compare two Integer values or immediate Integer      *
; *   values and store the result in an internal dc.w.     *
; *   Supported operators are Equal, NotEqual, Superior,   *
; *   Inferior, SuperiorOrEqual and InferiorOrEqual.       *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.18                          *
; **********************************************************
BasicIF MACRO
  IFEQ NARG-3
basicIfIndex SET basicIfIndex+1
basicIfNested SET basicIfNested+1
basicCurrentIf\<$basicIfNested> SET basicIfIndex
basicIfHasThen\<$basicIfIndex> SET 0
basicIfHasElse\<$basicIfIndex> SET 0
    bra.s      bIf\<$basicIfIndex>_afterResult
bIf\<$basicIfIndex>_result:
    dc.w       0
    even
bIf\<$basicIfIndex>_afterResult:
    loadBasicIntegerArgument \1,d5
    loadBasicIntegerArgument \3,d6
    clr.w      bIf\<$basicIfIndex>_result
    cmp.l      d6,d5
basicIfOperator SET \2
basicIfOperatorFound SET 0
    IFNE basicIfOperator=Equal
basicIfOperatorFound SET 1
      beq.s    bIf\<$basicIfIndex>_true
    ENDC
    IFNE basicIfOperator=NotEqual
basicIfOperatorFound SET 1
      bne.s    bIf\<$basicIfIndex>_true
    ENDC
    IFNE basicIfOperator=Superior
basicIfOperatorFound SET 1
      bgt.s    bIf\<$basicIfIndex>_true
    ENDC
    IFNE basicIfOperator=Inferior
basicIfOperatorFound SET 1
      blt.s    bIf\<$basicIfIndex>_true
    ENDC
    IFNE basicIfOperator=SuperiorOrEqual
basicIfOperatorFound SET 1
      bge.s    bIf\<$basicIfIndex>_true
    ENDC
    IFNE basicIfOperator=InferiorOrEqual
basicIfOperatorFound SET 1
      ble.s    bIf\<$basicIfIndex>_true
    ENDC
    IFEQ basicIfOperatorFound
      Fail ; BasicIF unknown comparison operator. Use Equal, NotEqual, Superior, Inferior, SuperiorOrEqual or InferiorOrEqual.
    ENDC
    bra        bIf\<$basicIfIndex>_else
bIf\<$basicIfIndex>_true:
    move.w     #1,bIf\<$basicIfIndex>_result
    bra        bIf\<$basicIfIndex>_then
  ELSEIF
    Fail ; BasicIF requires exactly three parameters : IntegerVar1,ComparisonOperator,IntegerVar2
  ENDC
 ENDM


BasicTHEN MACRO
  IFEQ basicIfNested
    Fail ; BasicTHEN requires a BasicIF before it.
  ELSEIF
currentBasicIf SET basicCurrentIf\<$basicIfNested>
    IFNE basicIfHasThen\<$currentBasicIf>
      Fail ; BasicTHEN was already defined for this BasicIF block.
    ENDC
basicIfHasThen\<$currentBasicIf> SET 1
    lea.l      bIf\<$currentBasicIf>_thenDirectError(pc),a0
    grmCall    grmCastCustomError
    rts
bIf\<$currentBasicIf>_thenDirectError:
    dc.b       "BasicTHEN was reached without a matching BasicIF branch.",10,0
    even
bIf\<$currentBasicIf>_then:
  ENDC
 ENDM


BasicELSE MACRO
  IFEQ basicIfNested
    Fail ; BasicELSE requires a BasicIF before it.
  ELSEIF
currentBasicIf SET basicCurrentIf\<$basicIfNested>
    IFEQ basicIfHasThen\<$currentBasicIf>
      Fail ; BasicELSE requires a BasicTHEN before it.
    ENDC
    IFNE basicIfHasElse\<$currentBasicIf>
      Fail ; BasicELSE was already defined for this BasicIF block.
    ENDC
basicIfHasElse\<$currentBasicIf> SET 1
    bra        bIf\<$currentBasicIf>_endif
bIf\<$currentBasicIf>_else:
  ENDC
 ENDM


BasicENDIF MACRO
  IFEQ basicIfNested
    Fail ; BasicENDIF requires a BasicIF before it.
  ELSEIF
currentBasicIf SET basicCurrentIf\<$basicIfNested>
    IFEQ basicIfHasThen\<$currentBasicIf>
      Fail ; BasicENDIF requires a BasicTHEN before it.
    ENDC
    IFEQ basicIfHasElse\<$currentBasicIf>
bIf\<$currentBasicIf>_else:
    ENDC
bIf\<$currentBasicIf>_endif:
basicIfNested SET basicIfNested-1
  ENDC
 ENDM

; **********************************************************
; * Method Name : BasicGOTO                                *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicGOTO Label                                      *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Jump at a specific position in the source code defi- *
; *   -ned by a label                                      *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2022.02.20                          *
; **********************************************************
BasicGOTO MACRO
blockGoto Set blockGoto+1
    tst.w      procedureDepth(a5)
    bne.s      .bGT\<$blockGoto>_err
    bra        bla_\1
.bGT\<$blockGoto>_err:
    CastErrorID GotoNotAllowedFromInsideAProcedure
 ENDM

; BasicStruct
; BasicEndStruct

; **********************************************************
; * Method Name : BasicStruct                              *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicStruct StructureName                            *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Start the creation of a data structure               *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2023.05.30                          *
; **********************************************************
;BasicSTRUCT MACRO
;  IFEQ inStruct-8
;    Fail ; Compilation ERROR : Cannot define a structure from inside another structure
;  ELSEIF
;inStruct     SET 8
;inStructName SET \1
;  ENDC
; ENDM

;BasicENDSTRUCT MACRO
;  IFEQ inStruct-8
;inStruct     SET 0
;  ELSEIF
;    Fail ; Compilation Error : BasicENDSTRUCT requires BasicSTRUCT before
;  ENDC
; ENDM
        











; **********************************************************
; * Method Name : BasicWHILE                               *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   BasicWHILE Variable,Comparizon,TargettedValue        *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to do a specific limited looping  *
; *   system that will loop until the variable reach the   *
; *   specified limit.                                     *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2022.02.21                          *
; **********************************************************
