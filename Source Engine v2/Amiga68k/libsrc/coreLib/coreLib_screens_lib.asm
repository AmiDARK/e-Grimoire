openScreensLib_v1:
    lea         ScreensLib(pc),a1
    move.l      #0,d0
    exeCall     OpenLibrary
    tst.l       d0
    bne.s       saveLib
    CastErrorIDInternal CannotOpenScreensLibrary
saveLib:
    LoadSys     a5
    move.l      d0,gScreens.Base(a5)
    grmScreensCall grmScrnConstructor
    rts

closeScreensLib_v1:
    move.l      $4.w,a6
    tst.l       gScreens.Base(a5)
    beq.s       .ende
    move.l      gScreens.Base(a5),a1
    exeCall     CloseLibrary
.ende
    rts