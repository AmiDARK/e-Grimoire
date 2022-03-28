
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.01.31              *
; * Version : 0.2                         *
; * File : game Engine for Source Engine  *
; * Author : Frederic Cordier             *
; *****************************************

; Can be used to extract procedure arguments when a procedure is called.

Amount  Equ 4

    Rts
    REPT  Amount
    dc.b  "TEST",0,0
    ENDR
