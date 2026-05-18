
; **********************************************************
; * Method Name : buildLocalDatas                          *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   buildLocalDatas                                      *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used internally by the 'Procedure' ma- *
; *   -cro to create the local variables buffer from the   *
; *   full variable buffer, for the current procedure.     *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
buildLocalDatas MACRO
    ; ******************************** 2nd compiler PASS
build\<$inProcName>:
    ; 1. If we have variables, we load the current local buffer and current position in the full variables buffer
    move.l      #varProc\<$inProcName>Size,d6  ; 2022.03.27 Pushed here to allow to push the buildLocalDatas inside a .library / D6 = Variables buffer size
    grmCall     grmBuildLocalVariables
    SetInteger  procprev,d7                    ; Create a variable to store the amount of parameters
    SetInteger  procsize,d6
build\<$inProcName>End:
 ENDM

; **********************************************************
; * Method Name : DeleteLocal                              *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   DeleteLocal                                          *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method will release the variable buffer that was*
; *   previously created by the macro 'buildLocalDatas'    *
; *--------------------------------------------------------*
; * Version : 1.1                                          *
; * Last update date : 2022.03.28                          *
; **********************************************************
DeleteLocal     MACRO
    ; ******************************** 1nd compiler PASS
varProc\<$inProcName>Size   equ varProc\<$inProcName>Count
    ; ******************************** 2nd compiler PASS
deleteLocalVars\<$inProcName>:
    loadLocalDatas a4
    releaseVmsStringBuffers a4,varProc\<$inProcName>Size
    move.l      #varProc\<$inProcName>Size,d6  ; Get local data buffer size
    grmCall     grmDeleteLocalVariables
                ENDM


; **********************************************************
; * Method Name : loadLocalDatas                           *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   loadLocalDatas An                                    *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro is used to load the pointer to the current*
; *   procedure local variables buffer into an adress re-  *
; *   -gister.                                             *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
loadLocalDatas       MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\1
                     ENDM   

; **********************************************************
; * Method Name : loadLocalData                            *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   loadLocalData VarName,An                             *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method will load the pointer to the local varia-*
; *   -ble inside the specified adress register.           *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
loadLocalData        MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\2
    move.l      proc\<$inProcName>\1(a4),\2
                     ENDM

; **********************************************************
; * Method Name : leaLocalData                             *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   leaLocalData VarName,An                              *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This method will load the pointer to the local varia-*
; *   -ble inside the specified adress register.           *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
leaLocalData         MACRO
    LoadSys     a5                             ; Be sure that Internal System Structure is loaded into a5
    move.l      localDatas(a5),\2
    lea.l       proc\<$inProcName>\1(a4),\2
                     ENDM
