
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.01.31              *
; * Version : 0.2                         *
; * File : game Engine for Source Engine  *
; * Author : Frederic Cordier             *
; *****************************************
; Idea to use to define Procedure variables.
; Use a SET (inProcedureName) with auto increment on each procedure creation.
; With this each procedure will have its own variable in a slot number.
; Special Argument : \<NAME> allow to convert name to integer and \<$NAME> to convert name to hexadecimal value.

; Default setting "starting out of a procedure"
inProcedure     SET 0
inProcedureName SET 0

; Can be used to extract procedure arguments when a procedure is called.

Struct         MACRO
    ; **** If we are not inside a structure definition, we can start the new structure definition
    IFEQ  inProcedure
inProcedure     SET 1
inProcedureName SET inProcedureName+1
    ; **** If we are already inside a structure definition, cast a compilation error
    ELSEIF
      FAIL "ERROR STC01 : Cannot define a new structure inside a structure definition"
    ENDC


 ENDM
       
EndStruct      MACRO
inProcedure SET 0
        ENDM
         
SetInteger     MACRO
    IFNE  inProcedure
proc\<$inProcedureName>.\1          equ 0                ; 4 bytes = data/pointer itself + 2 bytes = data type identifier
proc\<$inProcedureName>.\1_Label:
    rts
    ELSEIF
      FAIL "ERROR STC02 : Cannot identify structure"
    ENDC
 ENDM

LoadToD0     MACRO
  move.l   #proc\<$inProcedureName>.\1,d0
             ENDM

        
  rts

  Struct TT
  SetInteger VAR
  LoadToD0 VAR
  EndStruct
  rts

