

openMathFFPLib_v2:
    move.l      $4.w,a6
    lea.l       grm_fpconvert.library(pc),a1           ; Load the "grimoire-fpconvert.library" name to a1
    Move.l      #0,d0                                  ; Open All versions of graphics.library
    exeCall     OpenLibrary
    tst.l       d0
    beq.s       .noLib_fpc
    LoadSys     a5                                     ; (seInternalStructures.s) A5 = SysStructBackup (pointer to the buffer of the structure)
    move.l      d0,gFPConv.Base(a5)                       ; Save dos.library BASE to gfxBase

    LoadSys     a5
    grmFPUCall  grmStartGrimoireFPU
    rts
.noLib_fpc:
    CastErrorIDInternal CannotOpen_grm_fpuConvert.Library


closeMathFFPLib_v2:

    grmFPUCall  grmCloseGrimoireFPU

    move.l      $4.w,a6
    move.l     gFPConv.Base(a5),a1
    cmp.l       #0,a1
    beq.s       .ende
    exeCall     CloseLibrary
.ende
    rts