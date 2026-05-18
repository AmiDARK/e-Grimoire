
; **********************************************************
; * Method Name : buildGlobalVariables                     *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   buildGlobalVariables                                 *
; *--------------------------------------------------------*
; * Description :                                          *
; * This method will create the global variable buffer by  *
; * using a space inside the full variable buffer          *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
buildGlobalVariables MACRO
    ; ******************************** 1nd compiler PASS
varCount        SET 0
    ; ******************************** 2nd compiler PASS
    move.l     #glblSize,d6                    ; 2022.03.27 Updated to allow to push the buildGlobalVariables inside .library
    ; d6(=glblSize)->d7=VariableStoreAmountOfParameters
    grmCall    grmBuildGlobalVariables         ; 2022.03.28 Call grimoire-core.library/grmBuildGlobalVariables function
    SetInteger prev\1,d7                       ; Create a variable to store the amount of parameters
                    ENDM

; **********************************************************
; * Method Name : DeleteGlobal                             *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   DeleteGlobal                                         *
; *--------------------------------------------------------*
; * Description :                                          *
; * This method will release the global variable buffer    *
; * from the full variable buffer                          *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          * 
; **********************************************************
deleteGlobal     MACRO
    ; ******************************** 1nd compiler PASS
glblSize      equ     varCount                 ; End of the Global Data Structure setup.
varBufferSize equ     glblSize
    ; ******************************** 2nd compiler PASS
;globalDatasDelete:
    loadGlobalDatas a3                         ; Load global variables before releasing their owned string buffers
    releaseVmsStringBuffers a3,glblSize
    move.l      #glblSize,d6                   ; 2022.03.27 Order updated to makes this method compatible
    grmCall     grmDeleteGlobal                ; 2022.03.28 Call grimoire-core.library/grmDeleteGlobal function
                ENDM

; **********************************************************
; * Method Name : loadGlobalDatas                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   loadGlobalDatas An                                   *
; *--------------------------------------------------------*
; * Description :                                          *
; * This macro will load the global variables buffer poin- *
; * -ter into an adress register                           *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
loadGlobalDatas MACRO
    move.l      globalDatas(a5),\1
                ENDM

