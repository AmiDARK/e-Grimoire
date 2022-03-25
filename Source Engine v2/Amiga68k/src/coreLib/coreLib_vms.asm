; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Internal System branchments list *
; * Author : Frederic Cordier                             *
; *********************************************************


; **********************************************************
; * Method Name : vmsbuildFullVariablesBuffer              *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   vmsbuildFullVariablesBuffer                          *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro will create the full variable buffer that *
; *   will be used for the global variable buffer, and for *
; *   the procedures local variables buffer                *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
vmsbuildFullVariablesBuffer:
    move.l      #seVariablesBuffer,d0                  ; D0 = Size required to allocate all variables
    bsr         AllocClrFastMem                        ; Allocate memory for the whole variables buffer
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      d0,fullVarBuffer(a5)
    add.l       #seVariablesBuffer,d0                  ; Push D0 at the end of the buffer.
    move.l      d0,fvbPos(a5)
    rts

; **********************************************************
; * Method Name : vmsDeleteFullVariablesBuffer             *
; *--------------------------------------------------------*
; * Usage :                                                *
; *   vmsDeleteFullVariablesBuffer                         *
; *--------------------------------------------------------*
; * Description :                                          *
; *   This macro will release the full variable buffer that*
; *   was previously created by the macro called :         *
; *                            vmsbuildFullVariablesBuffer *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.06.05                          *
; **********************************************************
vmsDeleteFullVariablesBuffer:
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      #seVariablesBuffer,d0                  ; D0 = Size required to allocate all variables
    move.l      fullVarBuffer(a5),a1
    bsr         FreeMm
    LoadSys     a5                                     ; Be sure that Internal System Structure is loaded into a5
    move.l      #0,fullVarBuffer(a5)
    move.l      #0,fvbPos(a5)
    rts
