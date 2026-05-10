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
