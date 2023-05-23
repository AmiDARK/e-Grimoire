openScreensLib_v1:
CheckForVampireSuperAGA:
    move.b      grmAdditionalVampireChipsetType(a5),d7
    cmp.b       #2,d7
    beq.s       AddGfxIsSuperAga
CheckForVampireChunkyOnly:
    cmp.b       #1,d7
    beq.s       AddGfxIsChunky
CheckForAGA:
    move.b      grmGraphicChipsetType(a5),d7
    cmp.b       #2,d7
    beq.w       AddGfxIsAga
AddGfxIsEcsOcs:
    lea         EcsScreensLib(pc),a1
    move.l      #0,d0
    exeCall     OpenLibrary
    tst.l       d0
    bne.w       saveLib
    CastErrorIDInternal CannotOpenEcsScreensLibrary
AddGfxIsSuperAga:
    lea         SuperAgaScreensLib(pc),a1
    move.l      #0,d0
    exeCall     OpenLibrary
    tst.l       d0
    bne.s       saveLib
    CastErrorIDInternal CannotOpenSAGAScreensLibrary
AddGfxIsChunky:
    lea         ChunkyScreensLib(pc),a1
    move.l      #0,d0
    exeCall     OpenLibrary
    tst.l       d0
    bne.s       saveLib
    CastErrorIDInternal CannotOpenChunkyScreensLibrary
AddGfxIsAga:
    lea         AgaScreensLib(pc),a1
    move.l      #0,d0
    exeCall     OpenLibrary
    tst.l       d0
    bne.s       saveLib
    CastErrorIDInternal CannotOpenAGAScreensLibrary
saveLib:
    LoadSys     a5
    move.l      d0,gScreens.Base(a5)
    rts

SuperAgaScreensLib:
    dc.b        "system/grimoire-screensSaga.library",0
    EVEN
ChunkyScreensLib:
    dc.b        "system/grimoire-screensChunky.library",0
    EVEN
AgaScreensLib:
    dc.b        "system/grimoire-screensAgaT.library",0
    EVEN
EcsScreensLib:
    dc.b        "system/grimoire-screensEcs.library",0
    EVEN

closeScreensLib_v1:
    move.l      $4.w,a6
    tst.l       gScreens.Base(a5)
    beq.s       .ende
    move.l      gScreens.Base(a5),a1
    exeCall     CloseLibrary
.ende
    rts