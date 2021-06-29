

; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.30                     *
; * Last Update : ----.--.--              *
; * Version : 0.1                         *
; * File : Source Engine Error Handler    *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the ErrorHandler system
; 
; CastErrorID ErrorID (MACRO)                  ; Cast an error using its ID
; CastCustomErrorName ERRORNAME (MACRO)        ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; CastError( D0=ErrorID )                      ; Cast an error using its ID
; CastCustomError (A0=ERRORNAME)               ; Cast an error using a label that point to the dc.b "myError",0 description of the error to cast.
; CastFinalError (INTERNAL)                    ; Create the final error (Requester) and close the engine.

; Methods CastError, CastCustomError and CastFinalError must follows for continuity.

    bra         seHct
; *********************************************
; Cast an existing error using its ID number
; INPUT : D0 = ErrorID
CastError:
    lea.l       errorPos(pc),a0
    tst.l       d0
    bmi.s       .errd0
    cmp.l       #lastErrorID,d0
    ble.s       .ctu
.errd0:
    move.l      #errorIDIsIncorrect,d0
.ctu:
    Lsl.l       #2,d0
    add.l       d0,a0
    move.l      (a0),a0

; *********************************************
; Cast a custom error using its label reference to the error text
; INPUT : A0 = pointer to the error text
CastCustomError:
;    lea         castedError(pc),a1
;    move.l      a0,(a1)
    lea         myIntuiTextToUse(pc),a1
    move.l      a0,(a1)
    bsr         seReporter_log                         ; Temporar error reporting through CLI: or CON:

; *********************************************
; Final method to cast the error through an IntuitionLib requester
CastFinalError:
    bsr         hotEnd

;    bsr         openIntuition                                      ; reOpen the IntuitionLib as it was closed by quitEngine
;    move.l      d0,a6
;;    AutoReqM    #0,myIntuiText,myIntuilText,myIntuilText,0,0,180,80
;    move.l      #0,a0                                  ; pointer to window structure
;    lea         myIntuiText,a1                         ; IntuiText for the body 
;    Move.l      #0,a2                                   ; Intuitext for pos text
;    lea         myIntuiltext,a3                        ; Intuitext for NegText, must be valid
;    move.l      #0,d0                                  ; PosFlags left activates by clicking
;    move.l      #0,d1                                  ; NegFlags activates by clicking
;    move.l      #180,d2                                ; Width of the requester in pixels
;    move.l      #80,d3                                 ; height of requester in pixels
;    intuiCall   AutoRequest                            ; Display the requester
    ; As both options are used to quit application, we do not take care of D0 content.

; Doc for the Intuition Requester : http://www.pjhutchison.org/emulation/AmigaAsmTutorial.txt

    ; Open the requester to display the error, wait to close button and close the requester.
;    bsr         closeIntuitionA6                       ; close IntuitionLib
    ; Quit the program..
    bsr         cliOrWbFinish
    moveq       #0,d0
    LoadSP
    rts

; *********************************************
; To store temporarly the pointer of the true message of the casted error.
; castedError:    dc.l    0

myIntuiText:
    dc.b   2                                           ; it_FrontPen
    dc.b   0                                           ; it_BackPen
    dc.b   0                                           ; it_DrawMode
    dc.b   0                                           ; useless except for word alignment
    dc.w   0                                           ; it_LeftEdge
    dc.w   0                                           ; it_TopEdge
    dc.l   0                                           ; APTR it_ITextFont (or null for default one)
myIntuiTextToUse:
    dc.l   0                                           ; Pointer to null terminated text
    dc.l   0                                           ; it_NextxText
; End of my IntuiText custom structure

myIntuiltext:
    dc.b   2                                           ; it_FrontPen
    dc.b   0                                           ; it_BackPen
    dc.b   0                                           ; it_DrawMode
    dc.b   0                                           ; useless except for word alignment
    dc.w   0                                           ; it_LeftEdge
    dc.w   0                                           ; it_TopEdge
    dc.l   0                                           ; APTR it_ITextFont (or null for default one)
    dc.l   lText                                       ; Pointer to null terminated text
    dc.l   0                                           ; it_NextxText
lText:
    dc.b   "Quit",0
    EVEN

savedSP:
    dc.l    0

; *********************************************
; List of all true error messages in order.
errorPos:
    dc.l    error000,error001,error002,error003,error004
    dc.l    error005,error006,error007,error008,error009
    dc.l    error010,error011,error012,error013,error014
    dc.l    error015,error016,error017,error018,error019
    dc.l    error020,error021,error022,error023,error024
    dc.l    error025,error026,error027,error028,error029
    dc.l    error030,error031,error032,error033,error034
    dc.l    error035,error036,error037,error038,error039
    dc.l    error040,error041,error042,error043,error044
    dc.l    error045,error046,error047,error048,error049
    dc.l    0

; *********************************************
; True error messages cast through the Intuition Requester to inform user of what happened.
error000:    dc.b     "Error#0 : Unknown Error occured",10,0
error001:    dc.b     "Error#1 : Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15",10,0
error002:    dc.b     "Error#2 : The entered variable is not a STRING.",10,0
error003:    dc.b     "Error#3 : The entered variable is not an INTEGER.",10,0
error004:    dc.b     "Error#4 : The value entered is not an INTEGER.",10,0
error005:    dc.b     "Error#5 : The Stack variable is not an Integer",10,0
error006:    dc.b     "Error#6 : The TempVar register is invalid (Range is 0-15)",10,0
error007:    dc.b     "Error#7 : The entered String cannot be converted to Floating Number",10,0
error008:    dc.b     "Error#8 : The entered variable is not compatible with receiver",10,0
error009:    dc.b     "Error#9 : The entered String cannot be converted to Integer value",10,0
error010:    dc.b     "Error#10 : invalid EndProcedure reached",10,0
error011:    dc.b     "Error#11 : 'Return' was reached without any preceding 'Gosub' (Goto Used?)",10,0
error012:    dc.b     "Error#12 : Gosub are forbidden inside Procedures and Functions",10,0
error013:    dc.b     "Error#13 : Goto are forbidden inside Procedures and Functions",10,0
error014:    dc.b     "Error#14 : Too much 'Gosub' called (>16384) without any 'return'",10,0
error015:    dc.b     "Error#15 : Too much 'Procedures/Functions' calls (>16384) without any EndProcedure/EndFunction",10,0
error016:    dc.b     "Error#16 : Global Data Structure is defined twice",10,0
error017:    dc.b     "Error#17 : String size exceed 16382 bytes",10,0
error018:    dc.b     "Error#18 : Cannot open dos.library version 0",10,0
error019:    dc.b     "Error#19 : Cannot open graphics.library version 0",10,0
error020:    dc.b     "Error#20 : Cannot open intuition.library version 0",10,0
error021:    dc.b     "Error#21 : Cannot open mathffp.library version 0",10,0
error022:    dc.b     "Error#22 : Cannot allocate a memory buffer which size is 0 bytes",10,0
error023:    dc.b     "Error#23 : Cannot release a memory buffer which size is 0 bytes",10,0
error024:    dc.b     "Error#24 : Cannot release a memory buffer from a null pointer",10,0
error025:    dc.b     "Error#25 : Cannot report requested error as its id is out of range",10,0
error026:    dc.b     "Error#26 : Global data structure allocated but size was not saved",10,0
error027:    dc.b     "Error#27 : Cannot evaluate String length on a null pointer",10,0
error028:    dc.b     "Error#28 : Cannot open dos.library version 0",10,0
error029:    dc.b     "Error#29 : The selected variable is not a String",10,0
error030:    dc.b     "Error#30 : deleteLocalDatas caleed without any local data to delete",10,0
error031:    dc.b     "Error#31 : The procedure Called requires no parameters",10,0
error032:    dc.b     "Error#32 : Cannot load global variable as its type is unknown",10,0
error033:    dc.b     "Error#33 : Not enough memory available",10,0
error034:    dc.b     "Error#34 : Direct data stack overflow",10,0
error035:    dc.b     "Error#35 : Cannot read data from 'Direct data stack' as it is empty",10,0
error036:    dc.b     "Error#36 : Too much parameters entered to call the procedure",10,0
error037:    dc.b     "Error#37 : Internal Stack was already allocated",10,0
error038:    dc.b     "Error#38 : Cannot release Internal Stack as it does not exists",10,0
error039:    dc.b     "Error#39 : Internal stack does not exists",10,0
error040:    dc.b     "Error#40 : Whole variables buffer exceeded. Try to increase 'extraVarBuffer' variable.",10,0
error041:    dc.b     "Error#41 : cannot load global data pointer as it is null",10,0
error042:    dc.b     "Error#42 : Cannot remove an undefined local variables buffer",10,0
error043:    dc.b     "Error#43 : Full Variable Buffer not allocated",10,0
error044:    dc.b     "Error#44 : Illegal amount of parameters to call this procedure",10,0
error045:    dc.b     "Error#45 : Some arguments are of an incorrect type in the procedure call",10,0
error046:    dc.b     "",10,0
error047:    dc.b     "",10,0
error048:    dc.b     "",10,0
error049:    dc.b     "",10,0
             EVEN

seHct:
