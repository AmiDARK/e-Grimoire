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
; selocalDataReset ProcNAME                            ; Called by 'Procedure' MACRO it start Local Data Structure definition.
; setLocalInteger ProcNAME, VarNAME, VALUE             ; Create a local Integer variable and set it to VALUE.
; setLocalInteger ProcNAME, VarNAME                    ; Create a local Integer variable and set it to #0.
; setLocalFloat ProcNAME, VarNAME, <'VALUE'>           ; Create a local Floating number variable and set it to VALUE.
; setLocalFloat ProcNAME, VarNAME                      ; Create a local Floating number variable and set it to default 0.0f.
; setLocalStaticString ProcNAME, VarNAME, LABEL        ; Create a local String variable using a LABEL containing the dc.b "String",10,0 definition.
; setLocalStaticString ProcNAME, VarNAME               ; Create a local String variable defined as en Empty string.
; setLocalString ProcNAME, VarNAME, <'VALUE'>          ; Create a local String variable using direct String entered using VALUE.
; setLocalString ProcNAME, VarNAME                     ; Create a local String variable defined as en Empty string.
; endLocDatas ProcNAME                                 ; Called by 'EndProcedure' MACRO, it closes the Local Data Structure definition.
; buildLocalDatas ProcNAME                             ; Called by 'Procedure' MACRO, it allocate memory to create the Local Data Structure.
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

; *************************************************************** Internal Variables Counter
; 1.1 This macro reset data structure counter
; It must be used to initialize a new local data structure 
selocalDataReset     MACRO
varl\1Count     SET 0
    LoadSys a5                                         ; Be sure that Internal System Structure is loaded into a5
    buildLocalDatas \1
    loadLocalDatas a3
    setLocalInteger \1,_prev
    setLocalInteger \1,_next
    setLocalInteger \1,_Size
                ENDM

; *****************************************************
; 1.2 This macro insert a single integer in the local data system : setLocalInteger ProcNAME, VarNAME(, VALUE)
setLocalInteger MACRO
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeInt,l\1\2+4(a3)                   ; Setup the Global variable as Integer variable
    IFNC        '\3',''                                ; Si la valeur est définit, alors on l'entre dans la variable
    move.l      #\3,l\1\2(a3)                           ; Set the direct value of the Integer variable
    ENDC
                ENDM

; *****************************************************
; 1.3 This macro insert a single float in the local data system : setLocalFloat ProcNAME, VarNAME(, <'VALUE'>)
setLocalFloat   MACRO                                  ; Add a new Float number variable in the Global Datas Structure
l\1\2           equ varl\1Count                        ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count     SET varl\1Count+6                      ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeFlt,l\1\2+4(a3)                   ; Setup the Global variable as Floating number variable.
    lea.l       lStr\1\2,a0                            ; Load the pointer of the String representation of the static floating number value into A0
    bsr         privConvertStrToFlt                    ; Call String to Floating number conversion method. Do not use stack but direct datas into A0.str -> D0.flt
    move.l      d0,l\1\2(a3)                           ; Set the floating number variable value.
    bra.s       Ste\1\2                                ; Jump to the end of the variable setup
    IFNC        '\3',''
lStr\1\2:   dc.b    \3,10,0                            ; Area where the string representation of the static floating number will be inserted
    ELSEIF
lStr\1\2:   dc.b "0.0",10,0                            ; Create the default 0.0f floating number value (setup)
            EVEN
lSte\1\2:                                              ; End of the floating number variable creation and setup
                ENDM

; *****************************************************
; 1.4 This macro insert a string in the local data system : setLocalStaticString ProcName, VarNAME (, LABEL)
setLocalStaticString MACRO                             ; Add a new String variable in the Global Datas Structure
l\1\2       equ varl\1Count                            ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count   SET varl\1Count+6                        ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeStr,l\1\2+4(a3)                   ; Setup the global variable as a String variable with static content (dc.b)
    IFNC        '\3',''
    lea.l       \3,a0                                  ; Load the pointer of the static string content into A0
    move.l      a0,l\1\2(a3)                           ; Save the pointer of the static String in the variable datas
    ENDC
                ENDM

; *****************************************************
; 1.5 This macro insert a string in the local data system : setLocalString ProcName, VarNAME (, <'VALUE'>)
setLocalString  MACRO                                  ; Add a new String variable in the Global Datas Structure
gl\1\2      equ varl\1Count                            ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
varl\1Count   SET varl\1Count+6                        ; Any data as they re direct or pointer uses 6 bytes.
    move.w      #TypeStr,l\1\2+4(a3)                   ; Setup the global variable as a String variable with static content (dc.b)
    IFNC        '\3',''
    lea.l       lStr\1\2,a0                            ; Load the pointer of the static string content into A0
    move.l      a0,l\1\2(a3)                           ; Save the pointer of the static String in the variable datas
    ENDC
    bra.s       lSte\1\2
    IFNC        '\3',''
lStr\1\2:
    dc.b         \3,10,0                               ; Insert String if available
    ENDC
                EVEN
lSte\1\2:
                ENDM

; *****************************************************
; 1.6 This macro terminate the data structure counter and affect it s size to a variable
endLocDatas        MACRO
\1Size      equ    varl\1Count
                   ENDM

; *****************************************************
; 1.7 Allocate the data in memory -> Output = A0
buildLocalDatas MACRO
build\1:
    Move.l      #\1Size,d0                             ; D0 = Memory size
    cmp.l       #0,d0
    beq.s       .bld2
    bsr         AllocClrFastMem
    move.l      d0,a0                                  ; A0 = D0 = Freshly created memblock
    move.l      #\1Size,8(a0)                          ; Save final structure size inside the memory itself
    move.l      localDatas(a5),(a0)                    ; A0.prev = localDatas(a5).previous local variables
    cmp.l       #0,(a0)                                ; If no previous local variables is available
    beq.s       .bld1                                  ; then Jump -> bld1
    move.l      (a0),a1                                ; A1 = previous local variables
    move.l      a0,4(a1)                               ; A1.Next = A0
.bld1:
    move.l      a0,localDatas(a5)                      ; The new localDatas(a5) = The new current one freshly created.
.bld2:
                ENDM


; *****************************************************
; 1.8 Clear the current local Variables.
DeleteLocal     MACRO
del\1:
    move.l      localDatas(a5),a1                      ; A1 = Memory block
    cmp.l       #0,a1                                  ; No memory block ?
    bne.s       .LocDel                                ; -> Jump .noLD
    CastErrorID noLocalDataToErase                     ; There should always be local datas to handle multi-depth-level datas (should contain at minima prev/next/size)
.LocDel:
    Move.l      (a1),localDatas(a5)                    ; A5 = A1.Prev = Previous local block (restore previous local variables to be current ones)
    Move.l      8(a1),d0                               ; D0 = Memory block size to remove
    bsr         FreeMm
                ENDM

