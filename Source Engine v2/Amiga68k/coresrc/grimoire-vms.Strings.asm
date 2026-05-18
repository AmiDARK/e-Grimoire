; **********************************************************
; * Method Name : SetString                                *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   SetString VarName
; *   SetString VarName,VALUE
; *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Create a mutable String variable backed by an        *
; *   AllocVec memory buffer. Direct static text, when     *
; *   provided, is emitted as dc.b then copied into the    *
; *   mutable buffer.                                     *
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
    loadLocalDatas a4
    move.w            #TypeStr,proc\<$inProcName>\1+4(a4) ; Setup the Local variable as mutable String buffer
    move.l            #vmsStringBufferSize,d0
    move.l            #MEMF_PUBLIC|MEMF_CLEAR,d1
    execCall          AllocVec
    tst.l             d0
    bne.s             proc\<$inProcName>\1_BufferReady
    CastErrorID       NotEnoughFreeMemory
proc\<$inProcName>\1_BufferReady:
    move.l            d0,proc\<$inProcName>\1(a4)
  ; **** 1.2 If a 2nd argument is set, we try to detect it and use it, otherwise we let the variable to its default value
    IFEQ NARG-2                                          ; If VALUE is set, we must affect it to the variable itself
      lea             proc\<$inProcName>\1_Data(pc),a0
      move.l          d0,a1
      move.w          #vmsStringBufferSize-2,d7
proc\<$inProcName>\1_Copy:
      move.b          (a0)+,d6
      beq.s           proc\<$inProcName>\1_Continue
      move.b          d6,(a1)+
      dbra            d7,proc\<$inProcName>\1_Copy
      tst.b           (a0)
      beq.s           proc\<$inProcName>\1_Continue
      CastErrorID     StringSizeTooBig
      bra.s           proc\<$inProcName>\1_Continue
proc\<$inProcName>\1_Data:
      dc.b            \2,10,0
      even
proc\<$inProcName>\1_Continue:
    ENDC                                                 ; End of value inserting.
  ELSEIF
    ; **** 2.0 We check if the global variable was already defined (or not)
gl\1           equ varCount                              ;         Define the variable position in the structure
varCount       SET varCount+6                            ;         Increase the structure size by 6 bytes (Variable.l, VariableType.w )
gl\1lbl:                                                 ;         Create Label
    loadGlobalDatas a3                                   ;         Load global datas into A3 so all data can be allocated at creation
    move.w          #TypeStr,gl\1+4(a3)                  ;         Setup the Global variable as mutable String buffer
    move.l          #vmsStringBufferSize,d0
    move.l          #MEMF_PUBLIC|MEMF_CLEAR,d1
    execCall        AllocVec
    tst.l           d0
    bne.s           gl\1lbl_BufferReady
    CastErrorID     NotEnoughFreeMemory
gl\1lbl_BufferReady:
    move.l          d0,gl\1(a3)

    ; **** 2.1 If a 2nd argument is set, we try to detect it and use it, otherwise we let the variable to its default value
    IFEQ NARG-2                                          ; If VALUE is set, we must affect it to the variable itself
      lea             gl\1lbl_Data(pc),a0
      move.l          d0,a1
      move.w          #vmsStringBufferSize-2,d7
gl\1lbl_Copy:
      move.b          (a0)+,d6
      beq.s           gl\1lbl_Continue
      move.b          d6,(a1)+
      dbra            d7,gl\1lbl_Copy
      tst.b           (a0)
      beq.s           gl\1lbl_Continue
      CastErrorID     StringSizeTooBig
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


; **********************************************************
; * Method Name : releaseVmsStringBuffers                  *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   releaseVmsStringBuffers BufferPointer,BufferSize     *
; *                                                        *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Release every mutable String buffer found in a VMS   *
; *   variables buffer. Static strings are dc.b pointers   *
; *   and must not be released.                            *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.18                          *
; **********************************************************
releaseVmsStringBuffers MACRO
  IFGT \2
vmsStringReleaseCount SET vmsStringReleaseCount+1
    move.l          \1,a2
    move.w          #(\2/6)-1,d7
rvmsStr\<$vmsStringReleaseCount>Loop:
    cmp.w           #TypeStr,4(a2)
    bne.s           rvmsStr\<$vmsStringReleaseCount>Next
    move.l          (a2),a1
    cmp.l           #0,a1
    beq.s           rvmsStr\<$vmsStringReleaseCount>Clear
    execCall        FreeVec
rvmsStr\<$vmsStringReleaseCount>Clear:
    move.l          #0,(a2)
rvmsStr\<$vmsStringReleaseCount>Next:
    add.l           #6,a2
    dbra            d7,rvmsStr\<$vmsStringReleaseCount>Loop
  ENDC
                ENDM


; **********************************************************
; * Method Name : SetStaticString                         *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   SetStaticString VarName,VALUE                        *
; *                                                        *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Create a read-only String variable that points       *
; *   directly to a static dc.b string. Static strings do  *
; *   not allocate a mutable memory buffer and must be     *
; *   rejected by commands that modify string contents.    *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2026.05.10                          *
; **********************************************************
SetStaticString MACRO
  IFEQ NARG-2
    IFEQ  inProcedure-8
proc\<$inProcName>\1           equ varProc\<$inProcName>Count
varProc\<$inProcName>Count     SET varProc\<$inProcName>Count+6
proc\<$inProcName>\1_Label:
      loadLocalDatas a4
      move.w          #TypeStaticStr,proc\<$inProcName>\1+4(a4)
      lea             proc\<$inProcName>\1_Data(pc),a0
      move.l          a0,proc\<$inProcName>\1(a4)
      bra.s           proc\<$inProcName>\1_Continue
proc\<$inProcName>\1_Data:
      dc.b            \2,10,0
      even
proc\<$inProcName>\1_Continue:
    ELSEIF
gl\1           equ varCount
varCount       SET varCount+6
gl\1lbl:
      loadGlobalDatas a3
      move.w          #TypeStaticStr,gl\1+4(a3)
      lea             gl\1lbl_Data(pc),a0
      move.l          a0,gl\1(a3)
      bra.s           gl\1lbl_Continue
gl\1lbl_Data:
      dc.b            \2,10,0
      even
gl\1lbl_Continue:
    ENDC
  ELSEIF
    Fail ; SetStaticString requires exactly two parameters : VarName,VALUE
  ENDC
 ENDM
        
