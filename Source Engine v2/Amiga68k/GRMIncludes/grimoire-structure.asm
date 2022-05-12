; ***************************************************
; * Source Engine                                   *
; *-------------------------------------------------*
; * Date : 2020.01.24                               *
; * Last Update : 2020.01.28                        *
; * Version : 0.2                                   *
; * File : Source Engine Internal System Structures *
; * Author : Frederic Cordier                       *
; ***************************************************
; This file contains macros and informations to create internal Structures
; for the Source Engine. This file is devoted to be 'included' by the parser
; in the final source code, and used directly by the header_coldStart.s file
; when the Source Engine is used directly from a 68k assembler.

; MACROS to setup structure contents :
; sedataReset             Tell that we start to define a new internal Structures
; setL NAME,COUNT         Add COUNT Integer(s) (.l) variables under the name NAME
; setW NAME,COUNT         Add COUNT Word(s) (.w) variables under the name NAME
; setB NAME,COUNT         Add COUNT Byte(s) (.b) variables under the name NAME
; countData NAME         Save the current size of the structure under a constant named NAME
;
; LoadSys AReg
;
; Methods to allocate memory for structures :
; A0=AllocSys
; A0=AllocScreen


; **********************************************************************
; grimoire-hardwareDetector.library :
;------------------------------------
CPU_68000      Equ     0       ; 
CPU_68010      Equ     0       ; 1L<<CPU_68010
CPU_68020      Equ     1       ; 
CPU_68030      Equ     2       ; 
CPU_68040      Equ     3       ; 
FPU_68881      Equ     4       ; 
FPU_68882      Equ     5       ; 
FPU_68040      Equ     6       ; 
CPU_68060      Equ     7       ; 
FPU_68060      Equ     7       ; 
CPU_68080      Equ    10       ; Vampire only
FPU_68080      Equ    10       ; Vampire only
AMM_68080      Equ    10       ; Vampire only /Apollo 'AC68060' /
CPU_ADDR32     Equ    13       ;
MMU_AVAIL      Equ    14       ; /* MMU is present */
FPU_AVAIL      Equ    15       ; /* FPU presence */
;
CPX_68000      Equ    0
CPX_68010      Equ    0
CPX_68020      Equ    2^CPU_68020
CPX_68030      Equ    2^CPU_68030
CPX_68040      Equ    2^CPU_68040
FPX_68881      Equ    2^FPU_68881
FPX_68882      Equ    2^FPU_68882
FPX_68040      Equ    2^FPU_68040
CPX_68060      Equ    2^CPU_68060
FPX_68060      Equ    2^FPU_68060
CPX_68080      Equ    2^CPU_68080
FPX_68080      Equ    2^FPU_68080
AMX_68080      Equ    2^AMM_68080
CPX_ADDR32     Equ    2^CPU_ADDR32
MMX_AVAIL      Equ    2^MMU_AVAIL
FPX_AVAIL      Equ    2^FPU_AVAIL

;
; **********************************************************************
; Static variables :
;-------------------
;Hires, Lowres, Laced, HamMode, True64, DualPlayfield, SagaPIP, SagaC2P, Cybergraphx, Picasso96, RTG, PI
bLowres        Equ    31
bHires         Equ    30
bSuperHires    Equ    29
bLaced         Equ    28
bHamMode       Equ    27
bTrue64        Equ    26
bDualPlayfield Equ    25
bSagaPIP       Equ    24
bSagaC2P       Equ    23
bSagaChunky    Equ    bSagaC2P
bCybergraphx   Equ    22
bPicasso96     Equ    21
bRTG           Equ    20
bDoubleBuffer  Equ    19

Lowres         Equ    2^bLowres
Hires          Equ    2^bHires
SuperHires     Equ    2^bSuperHires
Laced          Equ    2^bLaced
HamMode        Equ    2^bHamMode
True64         Equ    2^bTrue64
DualPlayfield  Equ    2^bDualPlayfield
SagaPIP        Equ    2^bSagaPIP
SagaC2P        Equ    2^bSagaC2P
SagaChunky     Equ    SagaC2P
Cybergraphx    Equ    2^bCybergraphx
Picasso96      Equ    2^bPicasso96
RTG            Equ    2^bRTG
DoubleBuffer   Equ    2^bDoubleBuffer

ScreenMinWidth Equ 320
ScreenMinHeight Equ 16
ScreenMaxWidth Equ 2048
ScreenMaxHeight Equ 2048

;
;   Name             Value                            ; Bytes per Pixel ; Description
;-----------------------------------------------------------------------------
;SagaC2POFF     Equ    SAGA_VIDEO_FORMAT_OFF        ; 0 |     -
;SagaC2P8Bits   Equ    SAGA_VIDEO_FORMAT_CLUT8      ; 1 |     1           ;    CLUT 8
;SagaC2P16Bits  Equ    SAGA_VIDEO_FORMAT_RGB16      ; 2 |     2           ;   R5|G6|B5
;SagaC2P15Bits  Equ    SAGA_VIDEO_FORMAT_RGB15      ; 3 |     2           ; -|R5|G5|B5
;SagaC2P24Bits  Equ    SAGA_VIDEO_FORMAT_RGB24      ; 4 |     3           ;   R8|G8|B8
;SagaC2P32Bits  Equ    SAGA_VIDEO_FORMAT_RGB32      ; 5 |     4           ; -|R8|G8|B8
;SagaC2PYUV422  Equ    SAGA_VIDEO_FORMAT_YUV422     ; 6 |     2           ;   Y4|U2|V2
;SagaC2PPl1Bit  Equ    SAGA_VIDEO_FORMAT_PLANAR1BIT ; 8 |
;SagaC2PPl2Bit  Equ    SAGA_VIDEO_FORMAT_PLANAR2BIT ; 9 |
;SagaC2PPl4Bit  Equ    SAGA_VIDEO_FORMAT_PLANAR4BIT ; A |


; **********************************************************************
; grimoire-core.library :
;------------------------

grmCall         MACRO
    move.l  gCore.Base(a5),a6
    jsr     \1(a6)
                ENDM

grmConstructor                 Equ   -30       ; D0 -> D0
grmDestructor                  Equ   -36       ; D0 -> D0
grmStartGrimoire               Equ   -42       ; . -> A5 (Structure pointer)
grmHotEndGrimoire              Equ   -48       ; . -> .
grmCastErrorID                 Equ   -54       ; D0 (ErrorID) -> .
grmLoadSys                     Equ   -60       ; . -> A5 (Structure pointer)
grmAllocClrChipMem             Equ   -66       ; (D0=Size) -> (D0=Buffer)
grmAllocChipMem                Equ   -72       ; (D0=Size) -> (D0=Buffer)
grmAllocClrFastMem             Equ   -78       ; (D0=Size) -> (D0=Buffer)
grmAllocFastMem                Equ   -84       ; (D0=Size) -> (D0=Buffer)
grmFreeMm                      Equ   -90       ; (D0=Size,A1=Buffer) -> .
grmFreeMem                     Equ   -90       ; (D0=Size,A1=Buffer) -> .
grmclearSmallMemory            Equ   -96       ; (D0=Size,A1=Buffer) -> .
grmBuildGlobalVariables        Equ  -102       ; (D6=#glblSize) -> (D7=inBufferPosition)
grmDeleteGlobal                Equ  -108       ; (d6=#glblSize) -> .
grmBuildLocalVariables         Equ  -114       ; (d6=##varProc\<$inProcName>Size) -> (D6=ProcedureVariablesSize,D7=ProcedurePrevious)
grmDeleteLocalVariables        Equ  -120       ; . -> .
grmBuildAllLoopsBuffer         Equ  -126       ; (D6=#finalAllLoopsBuffer) -> .
grmDeleteAllLoopsBuffer        Equ  -132       ; (D7=#finalAllLoopsBuffer) -> .
grmCastCustomError             Equ  -138
grmLoadStackA3                 Equ  -144       ; (D4,D6=Variable(Value,Type)) -> .
grmSaveA3Stack                 Equ  -150       ; . -> (D4,D5=Variable(Value,Type))
grmSeResetStack                Equ  -156       ; . -> .

;grmSeResetStack                Equ  -150       ; . -> .
;grmLoadProcedureParameters     Equ  -156       ; d7 = Arguments counts
;grmPushVarToStack              Equ  -162       ; (d6,d7=Variable,Type) -> .
;grmGetProcedureReturn          Equ  -168       ; . -> (d6,d7=Variable,Type)


; **********************************************************************
; grimoire-fpu.library :
;-----------------------

grmFPUCall         MACRO
    move.l  gFPU.Base(a5),a6
    jsr     \1(a6)
                ENDM

;grmConstructor                 Equ   -30       ; D0 -> D0
;grmDestructor                  Equ   -36       ; D0 -> D0
grmConvertFltToInt             Equ   -42       ; D0 -> D0
grmConvertIntToFlt             Equ   -48       ; D0 -> D0
grmConvertStrToFlt             Equ   -54       ; A0 -> D0
grmConvertStrToInt             Equ   -60       ; A0 -> D0
grmStackA4ConvertFltToInt      Equ   -66       ; -(a4) -> (a4)+
grmStackA4ConvertIntToFlt      Equ   -72       ; -(a4) -> (a4)+
grmStackA4ConvertStrToFlt      Equ   -78       ; -(a4) -> (a4)+
grmStackA4ConvertStrToInt      Equ   -84       ; -(a4) -> (a4)+


; **********************************************************************
; grimoire-hardwareDetector.library :
;------------------------------------

grmHWDCall         MACRO
    move.l  gHardwareDetect.Base(a5),a6
    jsr     \1(a6)
                ENDM

;grmConstructor                 Equ   -30       ; D0 -> D0
;grmDestructor                  Equ   -36       ; D0 -> D0
grmDetectHardware              Equ   -42       ; A0 -> D0
grmGetHardwareDetails          Equ   -48       ; A0 -> D0

; *******************3***************************************************
; grimoire-hardwareDetector.library :
;------------------------------------

grmScreensCall         MACRO
    move.l  gScreensSupport.Base(a5),a6
    jsr     \1(a6)
                ENDM

;grmConstructor                 Equ   -30       ; D0 -> D0
;grmDestructor                  Equ   -36       ; D0 -> D0
grmGetBestScreenMode           Equ   -42       ; A0 -> D0
grmGetBestScreenModeEx         Equ   -48       ; A0 -> D0
grmOpenScreen                  Equ   -54
grmOpenScreenEx                Equ   -60
grmCloseScreen                 Equ   -66
grmGetScreenExists             Equ   -72

; *************************************************************************************************
; Mathematics comparizon modes

isNotEqual        equ 0
isEqual           equ 1
isInferior        equ 2
isInferiorOrEqual equ isInferior+isEqual ; =3
isSuperior        equ 4
isSuperiorOrEqual equ isSuperior+isEqual ; =5


; *************************************************************** Internal Structures counter
; 1. This macro reset data structure counter
; It must be used to initialize a new structure (before the 1st data of the structure)
sedataReset     MACRO
eCount          SET 0
    setL    \1_Previous,1
    setL    \1_Next,1
                ENDM

; *****************************************************
; 2. This macro insert an amount of integer to the counter
setL            MACRO
\1      equ     eCount
eCount          SET eCount+4*(\2)
                ENDM

; *****************************************************
; 3. This macro insert an amount of word to the counter
setW            MACRO
\1      equ     eCount
eCount          SET eCount+2*(\2)
                ENDM

; *****************************************************
; 4. This macro insert an amount of bytes to the counter
setB            MACRO
\1      equ     eCount
eCount          SET eCount+1*(\2)
                ENDM

; *****************************************************
; 5. This macro makes a variable to be set to reflect the counter value
; This macro must be used at the end of a structure definition to store the size of the structure
countData       MACRO
\1      equ     eCount
                ENDM

; **************************************************** Internal Source Engine system_structures

    sedataReset Global                         ; Reset counter for data list

    setL    gCore.Base,1                             ; grimoire-core.library base
    setL    gHardwareDetect.Base,1                   ; grimoire-hardwareDetector.library
    setL    gFPConv.Base,1                           ; grimoire-fpconvert.library base
    setL    gScreensSupport.Base,1                   ; grimoire-screensECS/AGA/SAGA.library
    ; *************************************************************** Internal
    setL    Task,1                                   ; The Source Engine Task
    setW    sysDMA,1                                 ; Register to save Amiga System DMA
    setB    IsAgaDetected,1                          ; = 0 if ECS, =1 if AGA, =2 if RTG (not yet supported), =3 for VAMPIRE ? (not yet supported)
    setB    unused1,1                                ; To word alignment.

    ; *************************************************************** OS Libraries
    setL    DosBase,1                                ; Pointer to the dos.library
    setL    GraphicsBase,1                           ; Pointer to the graphics.library
    setL    IntuitionBase,1                          ; Pointer to the Intuition.library
    setL    LayersBase,1                             ; Pointer to the Layers.library
    setL    MathFFPBase,1                            ; Pointer to the mathFFP.library
    ; *************************************************************** Hardware Details
    setL    hardwareDetectorHeader,1                 ; 'GRIM'
    setL    hardwareDetectorHeaderfollow,1           ; 'R-HD'
    setL    grmAttnFlags,1                           ; AttnFlags from exec.library
    setB    grmProcessorModel,1                      ; 00=68000, 10=68010, 20=68020, 3.=68030, 40=68040, 60=68060 or 80=68080
    setB    grmFpuModel,1                            ; 00=none, 40=68040, 60=68060, 81=68881, 82=68882 or 80=68080
    setB    grmGraphicChipsetType,1                  ; 1=ECS/OCS, 2=AGA
    setB    grmAdditionalVampireChipsetType,1        ; 1=C2P, 2=Super AGA.
    setB    grmIsAdditionalGraphics,1                ; 1=RTG available, 2=CyberGraphics available, 4=Picasso96 available
    setB    grmAudioChipset,1                        ; 1=Native amiga classics one, 2=SAGA Audio, 4=AHI driver

    ; *************************************************************** Screens Datas
    setL    Screens,seMaxScreens                     ; Screens structures
    setL    ScrPri,seMaxScreens                      ; Screens priority list
    setW    CurrentScreen,1                          ; ScreenID ( 0-seMaxScreens-1) to Define in which screen drawing will be done

    ; *************************************************************** Copper List support
    setL    ForceRefresh,1                           ; Data to define the required level of refreshing (Coppers, Screens, etc.)
    setL    CopLogic,1                               ; Pointer of memory block for logic copper (non visible one)
    setL    CopView,1                                ; Pointer of memory block for current copper (used to display screen)
    setL    CopSprites,1                             ; Relative shifting from the start of copper to reach the 1st sprite.
    setL    CopPalettes,1                            ; Relative shifting from the start of copper to reach the 1st color of the palette.

    ; *************************************************************** Data Areas for global/local datas
    setW    noTypeCheck,1                            ; if set to 0, variables will work like in PYTHON with no type checking and overwrite data.
    setL    fullVarBuffer,1                          ; Set start of the whole variables buffer (contains all global & locals + recursives variables)
    setL    fvbPos,1                                 ; The position where to start the next variables buffer.
    setL    globalDatas,1                            ; Pointer to the global data definition of the program (deleted at the end of the program)
    setL    globalSize,1                             ; Size of the global Data Structure
    setL    localDatas,1                             ; Pointer to the current procedure/Function/ClassMethod data area (deleted when it is quitted)
    setL    localSize,1                              ; Size of the Local Data structure

    ; *************************************************************** Data Areas for global/local datas
    setL    StackAdr,1                               ; Current Position in the parameters, temp values Stack
    setL    ZeStackPos,1                             ; The Stack inside which StackAdr point to
    setL    StackSize,1                              ;
    setL    StackAdrPos,1                            ; Current Adress position in the Stack
    setL    tempSave,1                               ;
    setW    saveType,1                               ; Used to save variable type when reading it
    setL    ParametersList,1                         ; Pointer to the list of parameters to send to the method/function
    setL    ParamsSize,1                             ; Size of the stack in bytes
    setL    TempVars,1                               ; Memory Buffer where each TempVar is : 5*.w ( = 2*.l + 1*.w ) ( * MaxTempVarBuffer for total Temporar Variables )
    setW    procedureDepth,1                         ; Security to prevent any goto or gosub to be used from inside a procedure.
;   setW    gosubDepth,1                             ; Security to prevent any goto or gosub to be used from inside a procedure.
    ; *************************************************************** Data Areas for Basic methods buffers
    setL    AllLoopsBuffer,1                         ; The buffer to store for/next datas (Variable.ptr, FinalValue, Step)
    setL    fnbPos,1
    setL    DoBuffer,1                               ; The buffer to store do/loop datas 
    setL    gosubDepth,1                             ; TheGosub/Return depth.
    ; *************************************************************** Blitter Objects
    setL    BobBank,1                                ; Pointer of memory block that define Blitter obejcts

    ; *************************************************************** Debug datas
    setL    CurrentLine,1                            ; Where is the run in the current source code ?
    setL    FileName,1                               ; Pointer to the name of the CurrentFile

    ; *************************************************************** Global structure length
    setL    branchList,1                             ; Pointer to the list of branchments calls that can be sent to the librery.

    countData   SysStructureLen                      ; The length in bytes of the structure defined above.



; **************************************************** Internal Source Engine system_structures

    sedataReset ScreensStructure                     ; Reset counter for data list
    setL    ScLogic,8                                ; Define drawing not viewed bitplanes (for double buffer, otherwise = ScPhysic ones)
    setL    ScPhysic,8                               ; Define visible bitplanes (displayed)
    setW    ScWidth,1
    setW    ScHeight,1
    setL    ScDepth,1                                ; Define the amount of bitplanes
    setW    ScGfxMode,1
    setW    ScPixelFormat,1
    setL    AGAPMode,1                               ; Must contain "AGAP", structure get from Amos Professional Unity update I've created
    setW    ScNbCol,1                                ; Define the amount of colors availables (from 0 to 256, 4096 for HAM6 and -1 ($FFFF) for HAM8)
    setW    ScPal,256                                ; Define 256 colors 'higb bits'
    setW    ScSeparator1,1                           ; Define the separator between High & Low bits color palette
    setW    ScPalL,256                               ; Define 256 colors 'low bits'
    setL    ScAllocLogic,8                           ; Define the pointer of bitplanes memory allocation for 16 bits alignment
    setL    ScAllocPhysic,8                          ; Define the pointer of bitplanes memory allocation for 16 bits alignment
    setL    ScAllocSize,1                            ; Define the size of 1 bitplane allocation for 16 bits alignment.
    setW    ScScreenID,1                             ; Define the Screen ID number

    setW    ScDual,1                                 ; define the 2nd screen used for dual playfield of <>-1 ($FFFF)
    setW    ScAWinX,1                                ; Define the X coordinate of the Screen in the current copper list display
    setW    ScAWinY,1                                ; Define the Y coordinate of the Screen in the current copper list display
    setW    ScAWinTX,1                               ; Define the visible 'width' in pixels of the screen view in the current copper list display
    setW    ScAWinTY,1                               ; Define the visible 'height" in pixels of the screen view in the current copper list display
    setW    ScViewOffX,1                             ; Define the X Screen offset (in pixels) from the left start of the screen on X Axis
    setW    ScViewOffY,1                             ; Define the Y Screen offset (in pixels, lines) from the top start of the screen on X Axis.
    setW    ScRefreshMode,1                          ; Define the refresh mode (0=Draw only on Physic, 1=Draw only on Logic, 2=Draw on both Logic&Physic=
    setW    ScInkA,1                                 ; Define the color used to draw graphics
    setW    ScInkB,2                                 ; Define the color used for background graphics drawing
    setW    ScPen,1                                  ; Define the color used for text drawinf
    setW    ScCursorX,1                              ; Define the screen Cursor X pixel coordinate in screen
    setW    ScCursorY,1                              ; Define the screen Cursor Y pixel coordinate in screen
    setW    ScClipTopX,1                             ; Define the screen clipping top left X (axis) coordinate
    setW    ScClipTopY1,1                            ; Define the screen clipping top left Y (ordinate) coordinate
    setW    ScClipBottomX,1                          ; Define the screen clipping bottom right X (axis) coordinate
    setW    ScClipBottomY,1                          ; Define the screen clipping bottom right Y (ordinate) coordinate
    setW    ScPattern,1                              ; Define the ID of the pattern used for graphic filling methods.
    setL    ScLayerInfo,1                            ; Define the Layer information for planar screens
    setL    ScLayer,1                                ; Define the Layer port information for planar screens
    setL    ScRastPort,1                             ; Define the Raster Port information for planar screens
    setL    ScRegion,1
    setL    ScBitMap,1                               ; Define the BitMap structure used for planar screens.
    setW    ScBplCon0,1                              ; Define BplCon0 value for the screen, to insert in Copper list
    setW    ScBplCon2,1                              ; Define BplCon2 value for the screen, to insert in Copper list
    setW    ScBplCon3,1                              ; Define BplCon3 value for the screen, to insert in Copper list
    setW    ScColPalBankID,1                         ; Define the 16 colors bank ID for dual playfield screen
    setB    ScCursor,8*8                             ; Contain the graphic for the 8x8 pixels cursor

    countData   ScreensStructureLen                  ; The length in bytes of the structure defined above.
