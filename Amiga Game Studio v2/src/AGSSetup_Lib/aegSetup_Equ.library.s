
; *************************************************************** Internal Structures counter
; 1. This macro reset data structure counter
; It must be used to initialize a new structure (before the 1st data of the structure)
sedataReset MACRO
eCount SET 0
 ENDM

; *****************************************************
; 2. This macro add chain list
seAddChainPointers MACRO
 setL \1_Previous,1
 setL \1_Next,1
 ENDM

; *****************************************************
; 2. This macro insert an amount of integer to the counter
setL MACRO
\1 equ eCount
eCount SET eCount+4*(\2)
 ENDM

; *****************************************************
; 3. This macro insert an amount of word to the counter
setW MACRO
\1 equ eCount
eCount SET eCount+2*(\2)
 ENDM

; *****************************************************
; 4. This macro insert an amount of bytes to the counter
setB MACRO
\1 equ eCount
eCount SET eCount+1*(\2)
ENDM

; *****************************************************
; 5. This macro makes a variable to be set to reflect the counter value
; This macro must be used at the end of a structure definition to store the size of the structure
countData MACRO
\1 equ eCount
 ENDM

 sedataReset aegSystem                            ; Reset counter for data list
; *************************************************************** OS Libraries
 setL    SYSHEADER,1                              ; Header "SYSL"
 setL    DosBase,1                                ; Pointer to the dos.library
 setL    GraphicsBase,1                           ; Pointer to the graphics.library
 setL    IntuitionBase,1                          ; Pointer to the Intuition.library
 setL    LayersBase,1                             ; Pointer to the Layers.library
 setL    MathFFPBase,1                            ; Pointer to the mathFFP.library
; *************************************************************** AEG Libraries
 setL    AEGHEADER,1                              ; Header "AEGL"
 setL    aegHardwareDetector,1                    ; Pointer to the library aegHardwareDetector.library
 setL    aegMemoryHandler,1                       ; Pointer to the library aegMemoryHandler.library
 setL    aegHardwareSpecificMH,1                  ; Pointer to the library AmigaClassicsMH.library or AmigaVampireMH.library
 setL    aegBlitterSystem,1                       ; Pointer to the library aegBlittingSystem.library
 setL    aegHardwareSpecificBS,1                  ; Pointer to the library AmigaBlitterBS.library, AmigaVampireBS.library or AmigaCPUFastBS.library
 setL    aegMemoryBanks,1                         ; Pointer to the library aegMemoryBanks.library
 setL    aegMemoryBlocks,1                        ; Pointer to the library aegMemoryBlocks.library
 setL    aegDisplayDevice,1                       ; Pointer to the library aegDisplayDevice.library
 setL    aegHardwareSpecificDD,1                  ; Pointer to the library aegViewAGA.library, aegViewECS.library or aegViewSAGA.library
 setL    aegScreensSupport,1                      ; Pointer to the library aegScreensAGA.library, aegScreensECS.library or aegScreensSAGA.library
 setL    aegDrawingGraphics,1                     ; Pointer to the library aegDrawingAGA.library, aegDrawingECS.library or aegDrawingSAGA.library
 setL    aegObjects2D,1                           ; Pointer to the library aeg2DObjectsAGA.library, aeg2DObjectsECS.library or aeg2DObjectsSAGA.library
 setL    aegSprites,1                             ; Pointer to the library aeg2DSpritesAGA.library, aeg2DSpritesECS.library or aeg2DSpritesSAGA.library
 setL    aegIcons2D,1                             ; Pointer to the library aeg2DIconsAGA.library, aeg2DIconsECS.library or aeg2DIconsSAGA.library
 setL    aegSoft3DRenderer,1                      ; Pointer to the library aeg3DSoftRenderAGA.library, aeg3DSoftRenderECS.library or aeg3DSoftRenderSAGA.library
 setL    aegAudioDevice,1                         ; Pointer to the library aegAudioDevice.library
 setL    aegAudioDriver,1                         ; Pointer to the library AudioDriverClassics or aegSagaAudio.library
 setL    aeg2DSoundInterface,1                    ; Pointer to the library aeg2DSoundsSystem.library
 setL    aegInputDevices,1                        ; Pointer to the library aegInputDevices.library
 seSize  equ eCount

; *************************************************************** AEG Macro to open a specific library
; LibPointer(d0) = Open Library ( LibName(a1),MinVersion(d0) ) -> LibPointer(d0) Save to \3(a5) structure
initAegLibrary MACRO
  lea \1(pc),a1                    ; a1 = LibName (dc.b "",0)
  move.l #\2,d0                    ; d0 = Minimal Library Version Required
  ExeCall OpenLibrary              ; Call Exec.library/OpenLibrary
  moveq #\4,d1                     ; D1 Contain the errorCode for this library if it failed to open
  tst.l d0                         ; Is Library Pointer = NULL ?
  beq QuitPrematurely              ; Yes -> Library Cannot Be Opened
  move.l d0,\3(a5)                 ; Save LibPointer to LibPointerSave(InternalStructure)
 ENDM
