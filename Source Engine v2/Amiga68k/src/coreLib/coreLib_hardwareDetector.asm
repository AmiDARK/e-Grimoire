

openHardwareDetectorLib_v1:
    move.l      $4.w,a6
    lea.l       grm_hardwareDetector.library(pc),a1           ; Load the "grimoire-fpconvert.library" name to a1
    Move.l      #0,d0                                  ; Open All versions of graphics.library
    exeCall     OpenLibrary
    tst.l       d0
    beq.s       .noLib_hd
    move.l      d0,gHardwareDetect.Base(a5)                       ; Save dos.library BASE to gfxBase
; *************************************** Once the library is open, we ask it to detect CPU, FPU, Graphics & Audio chipsets
    grmHWDCall  grmDetectHardware
    move.l      (a4)+,hardwareDetectorHeader(a5)
    move.l      (a4)+,hardwareDetectorHeaderfollow(a5)
    move.l      (a4)+,grmAttnFlags(a5)
    move.l      (a4)+,grmProcessorModel(a5)            ; Push CPU, FPU, GraphicChipset & AdditionalVampireChipset
    move.w      (a4)+,grmIsAdditionalGraphics(a5)      ; Push AdditionalGraphics & AudioChipset
    rts
.noLib_hd:
    CastErrorID CannotOpen_grm_hardwareDetextor.Library


closeHardwareDetectorLib_v1:
    move.l      $4.w,a6
    move.l     gHardwareDetect.Base(a5),a1
    cmp.l       #0,a1
    beq.s       .ende
    exeCall     CloseLibrary
.ende
    rts