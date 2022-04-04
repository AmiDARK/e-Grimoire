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
CPX_68010      Equ    1
CPX_68020      Equ    2
CPX_68030      Equ    4
CPX_68040      Equ    8
FPX_68881      Equ    16
FPX_68882      Equ    32
FPX_68040      Equ    64
CPX_68060      Equ    128
FPX_68060      Equ    128
CPX_68080      Equ    1024
FPX_68080      Equ    1024
AMX_68080      Equ    1024
CPX_ADDR32     Equ    8192
MMX_AVAIL      Equ    16384
FPX_AVAIL      Equ    32768

;
; **********************************************************************
; grimoire-core.library :
;------------------------

grmCall         MACRO
    move.l  gCore.Base(a5),a6
    jsr     \1(a6)
                ENDM

grmStartGrimoire               Equ   -30       ; . -> A5 (Structure pointer)
grmHotEndGrimoire              Equ   -36       ; . -> .
grmCastErrorID                 Equ   -42       ; D0 (ErrorID) -> .
grmLoadSys                     Equ   -48       ; . -> A5 (Structure pointer)
grmAllocClrChipMem             Equ   -54       ; (D0=Size) -> (D0=Buffer)
grmAllocChipMem                Equ   -60       ; (D0=Size) -> (D0=Buffer)
grmAllocClrFastMem             Equ   -66       ; (D0=Size) -> (D0=Buffer)
grmAllocFastMem                Equ   -72       ; (D0=Size) -> (D0=Buffer)
grmFreeMm                      Equ   -78       ; (D0=Size,A1=Buffer) -> .
grmclearSmallMemory            Equ   -84       ; (D0=Size,A1=Buffer) -> .
grmBuildGlobalVariables        Equ   -90       ; (D6=#glblSize) -> (D7=inBufferPosition)
grmDeleteGlobal                Equ   -96       ; (d6=#glblSize) -> .
grmBuildLocalVariables         Equ  -102       ; (d6=##varProc\<$inProcName>Size) -> (D6=ProcedureVariablesSize,D7=ProcedurePrevious)
grmDeleteLocalVariables        Equ  -108       ; . -> .
grmBuildAllLoopsBuffer         Equ  -114       ; (D6=#finalAllLoopsBuffer) -> .
grmDeleteAllLoopsBuffer        Equ  -120       ; (D7=#finalAllLoopsBuffer) -> .
grmSePushToStack               Equ  -126       ; (D4,D6=Variable(Value,Type)) -> .
grmSeGetFromStack              Equ  -132       ; . -> (D4,D5=Variable(Value,Type))
grmSeResetStack                Equ  -138       ; . -> .
grmLoadProcedureParameters     Equ  -144       ; d7 = Arguments counts
grmPushVarToStack              Equ  -150       ; (d6,d7=Variable,Type) -> .
grmGetProcedureReturn          Equ  -156       ; . -> (d6,d7=Variable,Type)


; **********************************************************************
; grimoire-fpu.library :
;-----------------------

grmFPUCall         MACRO
    move.l  gFPU.Base(a5),a6
    jsr     \1(a6)
                ENDM

grmConvertFltToInt             Equ   -30       ; D0 -> D0
grmConvertIntToFlt             Equ   -36       ; D0 -> D0
grmConvertStrToFlt             Equ   -42       ; A0 -> D0
grmConvertStrToInt             Equ   -48       ; A0 -> D0
grmStackA4ConvertFltToInt      Equ   -54       ; -(a4) -> (a4)+
grmStackA4ConvertIntToFlt      Equ   -60       ; -(a4) -> (a4)+
grmStackA4ConvertStrToFlt      Equ   -66       ; -(a4) -> (a4)+
grmStackA4ConvertStrToInt      Equ   -72       ; -(a4) -> (a4)+


; **********************************************************************
; grimoire-hardwareDetector.library :
;------------------------------------

grmHWDCall         MACRO
    move.l  gHardwareDetect.Base(a5),a6
    jsr     \1(a6)
                ENDM

grmConstructor                 Equ   -30       ; D0 -> D0
grmDestructor                  Equ   -36       ; D0 -> D0
grmDetectHardware              Equ   -42       ; A0 -> D0
grmGetHardwareDetails          Equ   -48       ; A0 -> D0


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
    setB    grmProcessorModel,1                      ; 0=68000, 1=68010, 2=68020, 3=68030, 4=68040, 6=68060 or 8=68080
    setB    grmFpuModel,1                            ; 0=none, 3=68030, 6=68060, 81=68881, 82=68882 or 80=68080
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

    countData    SysStructureLen                     ; The length in bytes of the structure defined above.
