; Includes equates to defined the type of variable currently supported by the VMS.
  Include    "coresrc/grimoire-vms.Types.asm"

; Include files to handles variables of the supported types.
  Include    "coresrc/grimoire-vms.Integers.asm"
;  Include    "coresrc/grimoire-vms.Floats.asm"
  Include    "coresrc/grimoire-vms.Strings.asm"
;  Include    "coresrc/grimoire-vms.Arrays.asm"

; Include files for specific variables access
  Include    "coresrc/grimoire-vms.globals.asm"
  Include    "coresrc/grimoire-vms.Locals.asm"
;  Include    "coresrc/grimoire-vms.Classes.asm"



; **********************************************************
; * Method Name : vmsGetPush                               *
; *--------------------------------------------------------*
; * Usage  : 
; *   vmsGetPush An,Variable(global/local)                 *
; *   vmsGetPush (An),Variable(global/local)               *
; *   vmsGetPush Dn,Variable(global/local)                 *
; *   vmsGetPush DirectValue,Variable(global/local)        *
; *   vmsGetPush Variable(global/local),An                 *
; *   vmsGetPush Variable(global/local),(An)               *
; *   vmsGetPush Variable(global/local),Dn                 *
; *   vmsGetPush Variable(global/local),DirectValue        *
; *   vmsGetPush DirectValue,Dn                            *
; *--------------------------------------------------------*
; * Description :                                          *
; *   Get Argument#1 and push it into Argument#2           *
; *   This method can be used to :                         *
; *   - Push datas to a global or local variable using a   *
; *     direct value, a data register or an adress register*
; *   - Get datas from a global of local variable and push *
; *     it to a data register or adress register           *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
vmsGetPush     MACRO
  IFEQ NARG-2
    checkIfRegister \1
    ; ******** 1. If Register is in 1st location, we push register value inside variable ( REG,VAR )
    IFEQ isRegister-1
      IFD    gl\2lbl                           ; If global variable Label does exists
        loadGlobalDatas a3                       ;   Load global datas into A3 so all data can be allocated at creation
        move.l    \1,gl\2(a3)                    ;   Push register argument #1 inside global variable 
        move.w    gl\2+4(a3),saveType(a5)        ; *Debug purposes only*
      ELSEIF                                     ; Else
      ; **** 2. If a local variable exists we will read it.   
        IFD proc\<$inProcName>\2_Label           ;   If Local Variable Label does exists
          loadLocalDatas a4                      ;     Load local datas into A2 so all datas can be allocated at creation
          move.l  \1,proc\<$inProcName>\2(a4)    ;     Push register argument #1 inside local variable
          move.w    proc\<$inProcName>\2+4(a4),saveType(a5) ; *Debug purposes only*
        ELSEIF
          FAIL ; "Compilation Error : Unknown variable in parameter #2"
        ENDC
      ENDC
    ; ******** 2. check if Register is located in the 2nd argument ( VAR,REG )
    ELSEIF
      checkIfRegister \2
      IFEQ isRegister-1
        ; **** 1. If a global variable exists we will read it.   
        IFD    gl\1lbl                                       ; If global variable Label does exists
          loadGlobalDatas a3                                 ;    Load global datas into A3 so all data can be allocated at creation
          move.l    gl\1(a3),\2                              ;    Push global variable value to argument #2
          move.w    gl\1+4(a3),saveType(a5)
        ELSEIF                                               ;   Else
          ; **** 2. If a local variable exists we will read it.   
          IFD proc\<$inProcName>\1_Label
            loadLocalDatas a4
            move.l    proc\<$inProcName>\1(a4),\2
            move.w    proc\<$inProcName>\1+4(a4),saveType(a5)
          ELSEIF
            move.l    #\1,\2
            move.w    #TypeInt,saveType(a5)
          ENDC
        ENDC

      ; ******** 3. Last situation, direct datas is set as 1st argument (DIRECTVALUE, VAR )
      ELSEIF
        IFD    gl\1lbl                           ; If global variable Label does exists
          loadGlobalDatas a3                     ;   Load global datas into A3 so all data can be allocated at creation
          move.l    #\2,gl\1(a3)                 ;   Push register argument #1 inside global variable (DirectValue,VariableGlobal)
          move.w    gl\1+4(a3),saveType(a5)      ; *Debug purposes only*
        ELSEIF                                   ; Else
        ; **** 2. If a local variable exists we will read it.   
          IFD proc\<$inProcName>\1_Label         ;   If Local Variable Label does exists
            loadLocalDatas a4                    ;     Load local datas into A2 so all datas can be allocated at creation
            move.l  #\2,proc\<$inProcName>\1(a4) ;     Push register argument #1 inside local variable
            move.w  proc\<$inProcName>\1+4(a4),saveType(a5) ; *Debug purposes only*
          ELSEIF
            IFD    gl\2lbl                           ; If global variable Label does exists
              loadGlobalDatas a3                     ;   Load global datas into A3 so all data can be allocated at creation
              move.l    #\1,gl\2(a3)                 ;   Push register argument #1 inside global variable (DirectValue,VariableGlobal)
              move.w    gl\2+4(a3),saveType(a5)      ; *Debug purposes only*
            ELSEIF                                   ; Else
            ; **** 2. If a local variable exists we will read it.   
              IFD proc\<$inProcName>\2_Label         ;   If Local Variable Label does exists
                loadLocalDatas a4                    ;     Load local datas into A2 so all datas can be allocated at creation
                move.l  #\1,proc\<$inProcName>\2(a4) ;     Push register argument #1 inside local variable
                move.w  proc\<$inProcName>\2+4(a4),saveType(a5) ; *Debug purposes only*
              ELSEIF
                FAIL ; "vmsGetPush requires a known variable at parameter #1 or #2"
              ENDC
            ENDC
          ENDC
        ENDC
      ENDC ; ******** 3. Close situation #3
    ENDC ; ******** 2. Close situation #2
  ENDC ; ******** 1. Close Situation #1
 ENDM


; **********************************************************
; * Method Name : checkIfRegister                          *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   checkIfRegister ArgToCheck                           *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is internally called by the other macro   *
; *   'vmsGetPush'. It will check if the argument is a data*
; *   register or an adress register. If it's the case, the*
; *   temporar label 'isRegister' will be set to '1'.      *
; *   If the argument is not a register, then the temporar *
; *   label will be set to '0'.                            *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
checkIfRegister MACRO
isRegister      SET 0
      vmsGetRegisterArgument '\1',d0,D0
      vmsGetRegisterArgument '\1',d1,D1
      vmsGetRegisterArgument '\1',d2,D2
      vmsGetRegisterArgument '\1',d3,D3
      vmsGetRegisterArgument '\1',d4,D4
      vmsGetRegisterArgument '\1',d5,D5
      vmsGetRegisterArgument '\1',d6,D6
      vmsGetRegisterArgument '\1',d7,D7
      vmsGetRegisterArgument '\1',a0,A0
      vmsGetRegisterArgument '\1',a1,A1
      vmsGetRegisterArgument '\1',a2,A2
      vmsGetRegisterArgument '\1',a3,A3
      vmsGetRegisterArgument '\1',a4,A4
      vmsGetRegisterArgument '\1',a5,A5
      vmsGetRegisterArgument '\1',a6,A6
      vmsGetRegisterArgument '\1',a7,A7
      vmsGetRegisterArgument '\1','(a0)','(A0)'
      vmsGetRegisterArgument '\1','(a1)','(A1)'
      vmsGetRegisterArgument '\1','(a2)','(A2)'
      vmsGetRegisterArgument '\1','(a3)','(A3)'
      vmsGetRegisterArgument '\1','(a4)','(A4)'
      vmsGetRegisterArgument '\1','(a5)','(A5)'
      vmsGetRegisterArgument '\1','(a6)','(A6)'
      vmsGetRegisterArgument '\1','(a7)','(A7)'
      vmsGetRegisterArgument '\1','(a0)+','(A0)+'
      vmsGetRegisterArgument '\1','(a1)+','(A1)+'
      vmsGetRegisterArgument '\1','(a2)+','(A2)+'
      vmsGetRegisterArgument '\1','(a3)+','(A3)+'
      vmsGetRegisterArgument '\1','(a4)+','(A4)+'
      vmsGetRegisterArgument '\1','(a5)+','(A5)+'
      vmsGetRegisterArgument '\1','(a6)+','(A6)+'
      vmsGetRegisterArgument '\1','(a7)+','(A7)+'
      vmsGetRegisterArgument '\1','-(a0)','-(A0)'
      vmsGetRegisterArgument '\1','-(a1)','-(A1)'
      vmsGetRegisterArgument '\1','-(a2)','-(A2)'
      vmsGetRegisterArgument '\1','-(a3)','-(A3)'
      vmsGetRegisterArgument '\1','-(a4)','-(A4)'
      vmsGetRegisterArgument '\1','-(a5)','-(A5)'
      vmsGetRegisterArgument '\1','-(a6)','-(A6)'
      vmsGetRegisterArgument '\1','-(a7)','-(A7)'
 ENDM
        
; **********************************************************
; * Method Name : vmsGetRegisterArgument                   *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   vmsGetRegisterArgument Argument1,Argument2,Argument3 *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is internally called by the other macro   *
; *   'checkIfRegister' to return isRegister=1 if the spe- *
; *   -cified argument is equal to the 2nd argument or to  *
; *   the 3rd argument.                                    *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
vmsGetRegisterArgument MACRO
  IFEQ  isRegister
    IFC \1,'\2'
isRegister      SET 1 
    ELSEIF
      IFC \1,'\3'
isRegister      SET 1 
      ENDC
    ENDC
  ENDC
 ENDM

; **********************************************************
; * Method Name : updateVar                   *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   updateVar VariableName,newVariableValue,ValueType    *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro will update a global or local variable wi-*
; *   -th direct datas (Value and Type).                   *
; *   The ValueType must be the same than the Variable one.*
; *--------------------------------------------------------*
; * Version : 0.1                                          *
; * Last update date : 2021.06.30                          *
; **********************************************************
updateVar MACRO
  IFEQ NARG-3
    ; 1.1 We firstly check for a global variable
    IFD gl\1lbl
newUpdateVar SET newUpdateVar+1
      loadGlobalDatas a3                       ; Load global datas into A3 so all data can be allocated at creation
      ; move.l d0,tempSave(a5)                 ; now uses d7 instead of d0
      move.w gl\1+4(a3),d7
      cmp.w  \3,d7                             ; We verify/check that the value use the same type than the variable itself.
      beq.s  updtVar\<$newUpdateVar>
      CastErrorID DirectDataNotSameTypeThanVariable
updtVar\<$newUpdateVar>:
      move.l \2,gl\1(a3)
      ; move.l tempSave(a5),d0                 ; now uses d7 instead of d0
    ELSEIF
      ; 1.2 If we are inside a procedure, we can push the direct value
      ;     directly inside a variable locale to it.
      IFEQ  inProcedure-8
        loadLocalDatas a4                      ;     Load local datas into A2 so all datas can be allocated at creation
        ; move.l d0,tempSave(a5)                 ; now uses d7 instead of d0
        move.w proc\<$inProcName>\1+4(a4),d7
        cmp.w  \3,d7  ; We verify/check that the value use the same type than the variable itself.
        beq.s  updtVar\<$newUpdateVar>
        CastErrorID DirectDataNotSameTypeThanVariable
updtVar\<$newUpdateVar>:
        move.l \2,proc\<$inProcName>\1(a4)
        ; move.l tempSave(a5),d0                 ; now uses d7 instead of d0
      ELSEIF
        CastErrorID UnknownVariableIdentifier
      ENDC
    ENDC
  ENDC
 ENDM
        

loadVarPtr MACRO
  IFD    gl\1lbl                             ; If global variable Label does exists
    loadGlobalDatas a3                       ;   Load global datas into A3 so all data can be allocated at creation
    lea.l     gl\1(a3),\2                    ;   Push register argument #1 inside global variable 
  ELSEIF                                     ; Else
  ; **** 2. If a local variable exists we will read it.   
    IFD proc\<$inProcName>\1_Label           ;   If Local Variable Label does exists
      loadLocalDatas a4                      ;     Load local datas into A2 so all datas can be allocated at creation
      lea.l     proc\<$inProcName>\1(a4),\2  ;     Push register argument #1 inside local variable
    ELSEIF
      FAIL ; "Compilation Error : Unknown variable in parameter #1"
    ENDC
  ENDC
 ENDM
