; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.02.12              *
; * Version : 1.0                         *
; * File : BASIC Procedures System        *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains all the required MACROS to create Procedures/Functions similar to BASICS ones.
; It also contain complete variable definition for Procedures/Functions

;
; buildLocalDatas ProcNAME                             ; Called by 'Procedure' MACRO, it allocate memory to create the Local Data Structure.
; setLocalInteger ProcNAME, VarNAME, VALUE             ; Create a local Integer variable and set it to VALUE.
; setLocalInteger ProcNAME, VarNAME                    ; Create a local Integer variable and set it to #0.
; setLocalFloat ProcNAME, VarNAME, <'VALUE'>           ; Create a local Floating number variable and set it to VALUE.
; setLocalFloat ProcNAME, VarNAME                      ; Create a local Floating number variable and set it to default 0.0f.
; setLocalStaticString ProcNAME, VarNAME, LABEL        ; Create a local String variable using a LABEL containing the dc.b "String",10,0 definition.
; setLocalStaticString ProcNAME, VarNAME               ; Create a local String variable defined as en Empty string.
; setLocalString ProcNAME, VarNAME, <'VALUE'>          ; Create a local String variable using direct String entered using VALUE.
; setLocalString ProcNAME, VarNAME                     ; Create a local String variable defined as en Empty string.
; DeleteLocal ProcNAME                                 ; Called by 'EndProcedure' MACRO, it releases the memory previously allocated by BuildLocalDatas

    include     "seVariablesType.asm"
    include     "seStackSystem.asm"


loadLocalDatas       MACRO
    Move.l      localDatas(a5),\1
                     ENDM

loadLocalData        MACRO
    loadLoalDatas a3
    Move.l      l\1\2,\3
                     ENDM


; *****************************************************
; 1.7 Allocate the data in memory -> Output = A0
buildLocalDatas MACRO
    ; ******************************** 1nd compiler PASS
varl\1Count     SET 0
    ; ******************************** 2nd compiler PASS
build\1:
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),a0                      ; A0 = Load current local variables stored in localDatas(a5)
    move.l      fvbPos(a5),a1                          ; a1 = Current position for next variables buffer
    cmp.l       #0,a0
    beq.s       .noCurrentLocal
    move.l      a1,4(a0)                               ; PreviousOne.next = new Buffer
.noCurrentLocal:
    move.l      a0,(a1)                                ; newBuffer.prev = previous buffer
    move.l      #\1Size,8(a1)                          ; newBuffer.size = \1Size
    move.l      a1,localDatas(a5)                      ; Update local pointer for the newBuffer
    add.l       #\1Size,a1                             ; Update pointer position for next buffer
    move.l      a1,fvbPos(a5)                          ; Update full variable buffer for next buffer
.bld2:
    loadLocalDatas a3
    setLocalInteger \1,prev
    setLocalInteger \1,next
    setLocalInteger \1,Size
varStart\1     equ  varl\1Count

                ENDM


; *****************************************************
; 1.2 This macro insert a single integer in the local data system : setLocalInteger ProcNAME, VarNAME(, VALUE)
setLocalInteger MACRO
    ; ******************************** 1nd compiler PASS
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    ; ******************************** 2nd compiler PASS
l\1_\2_Label:
    loadLocalDatas a3
    move.w      #TypeInt,l\1\2+4(a3)                   ; Setup the Global variable as Integer variable
    IFNC        '\3',''                                ; Si la valeur est définit, alors on l'entre dans la variable
    move.l      #\3,l\1\2(a3)                           ; Set the direct value of the Integer variable
    ENDC
                ENDM

; *****************************************************
; 1.3 This macro insert a single float in the local data system : setLocalFloat ProcNAME, VarNAME(, <'VALUE'>)
setLocalFloat   MACRO                                  ; Add a new Float number variable in the Global Datas Structure
    ; ******************************** 1nd compiler PASS
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    ; ******************************** 2nd compiler PASS
l_\1_\2_Label:
    loadLocalDatas a3
    move.w      #TypeFlt,l\1\2+4(a3)                   ; Setup the Global variable as Floating number variable.
    lea.l       lStr\1\2,a0                            ; Load the pointer of the String representation of the static floating number value into A0
    bsr         privConvertStrToFlt                    ; Call String to Floating number conversion method. Do not use stack but direct datas into A0.str -> D0.flt
    move.l      d0,l\1\2(a3)                           ; Set the floating number variable value.
    bra.s       Ste\1\2                                ; Jump to the end of the variable setup
    IFNC        '\3',''
lStr\1\2:   dc.b \3,10,0                               ; Area where the string representation of the static floating number will be inserted
    ELSE
lStr\1\2:   dc.b "0.0",10,0                            ; Create the default 0.0f floating number value (setup)
    ENDC
            even
lSte\1\2:                                              ; End of the floating number variable creation and setup
                ENDM

; *****************************************************
; 1.4 This macro insert a string in the local data system : setLocalStaticString ProcName, VarNAME (, LABEL)
setLocalStaticString MACRO                             ; Add a new String variable in the Global Datas Structure
    ; ******************************** 1nd compiler PASS
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    ; ******************************** 2nd compiler PASS
l_\1_\2_Label:
    loadLocalDatas a3
    move.w      #TypeStr,l\1\2+4(a3)                   ; Setup the global variable as a String variable with static content (dc.b)
    IFNC        '\3',''
    lea.l       \3,a0                                  ; Load the pointer of the static string content into A0
    move.l      a0,l\1\2(a3)                           ; Save the pointer of the static String in the variable datas
    ENDC
                ENDM

; *****************************************************
; 1.5 This macro insert a string in the local data system : setLocalString ProcName, VarNAME (, <'VALUE'>)
setLocalString  MACRO                                  ; Add a new String variable in the Global Datas Structure

    ; ******************************** 1nd compiler PASS
; ******** 1. Position the variable inside the buffer if it was not already created
    IFNDEF      l\1\2                                  ; 1stly, we check if the variable was already created or not.
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    ENDC
    ; ******************************** 2nd compiler PASS
; ******** 2. Set the variable.
l_\1_\2_Label:
      loadLocalDatas a3
      move.w      #TypeStr,l\1\2+4(a3)                   ; Setup the local variable as a String variable with static content (dc.b)
      lea.l       lStr\1\2,a0                            ; Load the pointer of the static string content into A0
      move.l      a0,l\1\2(a3)                           ; Save the pointer of the static String in the variable datas
      bra         lSte\1\2
      IFNC        '\3',''
lStr\1\2:
      dc.b \3,10,0                               ; Insert String if available
      ELSEIF
lStr\1\2:
      dc.b 10,0                                  ; Insert Empty String if available
      ENDC
      even
lSte\1\2:
                ENDM

; *****************************************************
; 1.6 Clear the current local Variables.
DeleteLocal     MACRO
    ; ******************************** 1nd compiler PASS
\1Size          equ varl\1Count
varBuffer       SET varBuffer+varl\1Count
    ; ******************************** 2nd compiler PASS
del\1:
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    Move.l      localDatas(a5),a1                      ; a0 = Current local buffer pointer
    cmp.l       #0,a1
    bne.s       .deleteLocal
    CastErrorID CannotEraseUndefinedLocalBuffer
.deleteLocal:
    move.l      (a1),localDatas(a5)                    ; We restore the previous buffer
    move.l      a1,fvbPos(a5)                          ; Restore the fvbPos(a5) pointer to its origin before using current local buffer
    move.l      #\1Size,d0
    bsr         clearSmallMemory                       ; We clear what was inside the buffer from A1, length = #\1Size
                ENDM


; *****************************************************
; 1.7 Load a local variable into registers
LoadLocalVar    MACRO
    loadLocalDatas a3
    move.l      \1\2(a3),\3                            ; Save the pointer of the static String in the variable datas
    move.w      \1\2+4(a3),\4                          ; Setup the global variable as a String variable with static content (dc.b)
                ENDM
