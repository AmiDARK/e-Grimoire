

buildForNextBuffer MACRO
    LoadSys    a5                                 ; Be sure that Internal System Structure is loaded into a5
    move.l     forNextBuffer(a5),d7
    tst.l      d7
    beq.s      .fnBufferIsNullOK    
    CastErrorID forNextBufferIsAlreadyAllocated
.fnBufferIsNullOK:
    move.l     #finalForNextBuffer,d7
    tst.l      d7
    beq.s      .ForNextEndCreation
    add.l      #1,d7                   ; Add 1 security buffer
    mulu.l     #12,d7                  ; each For/Next data block requires 12 bytes (3x.l : variable.ptr, End value, Step value)
    move.l     fvbPos(a5),d6           ; d6 = Current position in the full buffer variable
    tst.l      d6
    bne.s      .FullBufferIsOk_ck2
    CastErrorID FullVariableBufferNotSet
.FullBufferIsOk_ck2:
    sub.l      d7,d6                   ; d6 = New position in the buffer = Start of For/Next data blocks
    move.l     d6,fvbPos(a5)           ; update buffer position for next buffer to allocate
    move.l     d6,forNextBuffer(a5)    ; Define the forNextBuffer(a5)
.ForNextEndCreation:
 ENDM


deleteForNextBuffer MACRO
finalForNextBuffer equ higherForNext+1   ; Set finalForNextBuffer to see if we must create buffer
  IFGE blockForNext
    FAIL : At least one (or more) <<BasicNEXT>> is/are missing.
  ENDC
  IFGE finalForNextBuffer-1            ; if at least 1 for/next buffer is required
    LoadSys    a5                                 ; Be sure that Internal System Structure is loaded into a5
    move.l     fvbPos(a5),d6           ; d6 = Current position in the full buffer variable
    move.l     forNextBuffer(a5),d7    ; d7 = Current forNextBuffer(a5)
    cmp.l      d6,d7
    beq.s      .bufAtGoodPositionForRelease    
    CastErrorID SomeBuffersMustBeReleasedBeforeForNextOne
.bufAtGoodPositionForRelease:
    move.l     #finalForNextBuffer,d7
    mulu.l     #12,d7                  ; each For/Next data block requires 12 bytes (3x.l : variable.ptr, End value, Step value)
    add.l      d7,d6
    move.l     d6,fvbPos(a5)           ; update the global buffer position with the for/next buffer release
    clr.l      forNextBuffer(a5)       ; clear the for/next buffer.
  ENDC
 ENDM
        



BasicFOR       MACRO
  ; 1. Security Checking A : For macro requires at least 3 parameter ( VAR, START, END ), auto step=1
  IFGE NARG-3
    ; 2. Security Checking B : For macro must not use more than 4 parameters (VAR, STARt, END, STEP)
    IFGE NARG-5
      CastErrorID BasicFORUses3Or4Parameters
    ELSEIF
    ; 3. Define constants for this For/Next block
blockForNext Set blockForNext+1          ; And the current ForNext block is... (1st one =0 as default value =-1)
      IFGE blockForNext-higherForNext
higherForNext set blockForNext
      ENDC
bid\<$blockForNext> equ blockForNext
      LoadSys    a5                      ; Be sure that Internal System Structure is loaded into a5
      ; 4. Load the For/Next parameters/Arguments into Dn registers and check for compatibles types
      vmsGetPush  \2,d5                  ; d5 = Start Position
      cmp.w      #TypeInt,saveType(a5)
      bne.s      .bFN\<$blockForNext>_ce
      vmsGetPush  \3,d6                  ; d6 = End Position
      cmp.w      #TypeInt,saveType(a5)
      bne.s      .bFN\<$blockForNext>_ce
      IFEQ NARG-4
        vmsGetPush \4,d7                 ; D7 = Step from arguments
        cmp.w    #TypeInt,saveType(a5)
        bne.s    .bFN\<$blockForNext>_ce
      ELSEIF
        move.l   #1,d7                  ; D7 = Step (default=1)
      ENDC
      loadVarPtr \1,a4                  ; A4 = Pointer to the variable to use for the loop
      cmp.w      #TypeInt,4(a4)
      beq.s      .bFN\<$blockForNext>_p1
.bFN\<$blockForNext>_ce:
      CastErrorID ForNextRequiresIntegerVariablesOrValue
.bFN\<$blockForNext>_p1:
      move.l     a4,d4                  ; d4 = Pointer to the variable to use for the loop
      ; 5. Update variable to meet the Start Value
      move.l     d5,(a4)                ; Variable = Start value
      ; 6. Load the For/Next block buffer to save informations about For/Next loop
      Move.l     forNextBuffer(a5),a4   ; Load buffer into a3
      cmp.l      #0,a4
      bne.s      .bFN\<$blockForNext>_p2
      CastErrorID forNextBufferNotCreated
.bFN\<$blockForNext>_p2:
      move.l     #bid\<$blockForNext>,d5 ; d5 = ID of the For/Next Block
      mulu       #12,d5
      add.l      d5,a4                  ; a4 = Pointer to the current For/Next data save buffer
      move.l     d4,(a4)+               ; Save Variable Pointer
      move.l     d7,(a4)+               ; Save Step
      move.l     d6,(a4)                ; Save Final Value
    ENDC
  ENDC
BasicFor\<$blockForNext>lbl:
 ENDM

BasicNEXT      MACRO
  LoadSys    a5                      ; Be sure that Internal System Structure is loaded into a5
  ; 1. Load the For/Next data save buffer and datas from it.
  Move.l      forNextBuffer(a5),a4   ; Load buffer into a4
  move.l      #bid\<$blockForNext>,d7 ; d7 = ID of the For/Next Block
  mulu        #12,d7                 ; a For/Next block uses 12 bytes VarPtr.l, EndValue.l, Step.l
  add.l       d7,a4                  ; a4 = Pointer to the current For/Next data save buffer
  Move.l      (a4)+,a3               ; a3 = Pointer to the variable value
  move.l      (a3),d7                ; d7 = Variable value
  move.l      (a4)+,d6               ; d6 = Step Value
  add.l       d6,d7                  ; d7 = d7 + Step Value (d6)
  move.l      d7,(a3)                ; Save the variable value to its register
  move.l      (a4),d5                ; d5 = Last Value
  tst.l       d7
  bpl.s       .bFN\<$blockForNext>_inc
  ; 2. Check limit for decremental step
.bFN\<$blockForNext>_dec:
  cmp.l       d5,d7                  ; does the variable (d7) reach the ending value (d5)
  bge         BasicFor\<$blockForNext>lbl ; End value not reached, continue to loop
  bra.s       .bFN\<$blockForNext>_cntn
  ; 3. Check limit for incremental step
.bFN\<$blockForNext>_inc:
  cmp.l       d7,d5                  ; does the variable (d7) reach the ending value (d5)
  bge         BasicFor\<$blockForNext>lbl ; End value not reached, continue to loop
  ; 4. The loop is over.
.bFN\<$blockForNext>_cntn:
blockForNext set blockForNext-1          ; And the current ForNext block is... (1st one =0 as default value =-1)
 ENDM