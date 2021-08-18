
; *************************************************************** Internal Structures counter
; 1. This macro reset data structure counter
; It must be used to initialize a new structure (before the 1st data of the structure)
sedataReset MACRO
eCount SET 0
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
    setL    DosBase,1                                ; Pointer to the dos.library
    setL    GraphicsBase,1                           ; Pointer to the graphics.library
    setL    IntuitionBase,1                          ; Pointer to the Intuition.library
    setL    LayersBase,1                             ; Pointer to the Layers.library
    setL    MathFFPBase,1                            ; Pointer to the mathFFP.library


