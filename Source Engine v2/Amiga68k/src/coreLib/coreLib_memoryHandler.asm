; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Memory Handler functions         *
; * Author : Frederic Cordier                             *
; *********************************************************



; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
; This method allocate memory for the Source Engine internal structure
AllocSys:
    ; [Constructor] Allocate memory for the Source Engine Internal Data Structure
    Move.l      #SysStructureLen,d0                    ; D0 = System Structure Bytes Length
    bsr         AllocClrFastMem
    lea.l       SysStructBackup(pc),a0                 ; Save System Structure buffer pointer.
    Move.l      d0,(a0)
    rts

; **********************************************************
; * Method Name :                                          *
; *--------------------------------------------------------*
; * Usage  :                                               *
; *   
; *--------------------------------------------------------*
; * Description : 
; *
; *--------------------------------------------------------*
; * Version : x.y                                          *
; * Last update date : 2021.mm.dd                          *
; **********************************************************
; This method release memory used for the Source Engine internal structure
FreeSys
    ; [Destructor] Release memory allocated for the Source Engine internal Data Structure.
    lea.l       SysStructBackup(pc),a0             
    move.l      (a0),a1                                ; A1 = Pointer to the Internal System Structure
    cmp.l       #$0,a1
    Beq.s       .fsEnd                                 ; A1 = 0 -> .fsEnd
    Move.l      #SysStructureLen,d0                    ; D0 = System Structure Bytes Length
    bsr         FreeMm                                 ; Release memory used by Internal System Structure
.fsEnd:
    lea.l       SysStructBackup(pc),a0
    Move.L      #0,(a0)                                ; Clear memory to be sure it will no more be used
    move.l      #0,a5                                  ; Clear the A5 register that uses
    rts

