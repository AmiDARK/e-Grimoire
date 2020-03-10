
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

SaveSP          MACRO
    move.l      a7,savedSP
                ENDM

LoadSP          MACRO
    move.l      savedSP,a7
                ENDM

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
    ; bsr         seReporter_log                         ; Temporar error reporting through CLI: or CON:

; *********************************************
; Final method to cast the error through an IntuitionLib requester
CastFinalError:
    bsr         hotEnd

    bsr         openIntuition                                      ; reOpen the IntuitionLib as it was closed by quitEngine
    move.l      d0,a6
;    AutoReqM    #0,myIntuiText,myIntuilText,myIntuilText,0,0,180,80
    move.l      #0,a0                                  ; pointer to window structure
    lea         myIntuiText,a1                         ; IntuiText for the body 
    Move.l      #0,a2                                   ; Intuitext for pos text
    lea         myIntuiltext,a3                        ; Intuitext for NegText, must be valid
    move.l      #0,d0                                  ; PosFlags left activates by clicking
    move.l      #0,d1                                  ; NegFlags activates by clicking
    move.l      #180,d2                                ; Width of the requester in pixels
    move.l      #80,d3                                 ; height of requester in pixels
    intuiCall   AutoRequest                            ; Display the requester
    ; As both options are used to quit application, we do not take care of D0 content.

; Doc for the Intuition Requester : http://www.pjhutchison.org/emulation/AmigaAsmTutorial.txt

    ; Open the requester to display the error, wait to close button and close the requester.
    bsr         closeIntuitionA6                       ; close IntuitionLib
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
error000:    dc.b     "Unknown Error occured",0
error001:    dc.b     "Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15",0
error002:    dc.b     "The entered variable is not a STRING.",0
error003:    dc.b     "The entered variable is not an INTEGER.",0
error004:    dc.b     "The value entered is not an INTEGER.",0
error005:    dc.b     "The Stack variable is not an Integer",0
error006:    dc.b     "The TempVar register is invalid (Range is 0-15)",0
error007     dc.b     "The entered String cannot be converted to Floating Number",0
error008:    dc.b     "The entered variable is not compatible with receiver",0
error009:    dc.b     "The entered String cannot be converted to Integer value",0
error010:    dc.b     "invalid EndProcedure reached",0
error011:    dc.b     "'Return' was reached without any preceding 'Gosub' (Goto Used?)",0
error012:    dc.b     "Gosub are forbidden inside Procedures and Functions",0
error013:    dc.b     "Goto are forbidden inside Procedures and Functions",0
error014:    dc.b     "Too much 'Gosub' called (>16384) without any 'return'",0
error015:    dc.b     "Too much 'Procedures/Functions' calls (>16384) without any EndProcedure/EndFunction",0
error016:    dc.b     "Global Data Structure is defined twice",0
error017:    dc.b     "String size exceed 16382 bytes",0
error018:    dc.b     "Cannot open dos.library version 0",0
error019:    dc.b     "Cannot open graphics.library version 0",0
error020:    dc.b     "Cannot open intuition.library version 0",0
error021:    dc.b     "Cannot open mathffp.library version 0",0
error022:    dc.b     "Cannot allocate a memory buffer which size is 0 bytes",0
error023:    dc.b     "Cannot release a memory buffer which size is 0 bytes",0
error024:    dc.b     "Cannot release a memory buffer from a null pointer",0
error025:    dc.b     "Cannot report requested error as its id is out of range",0
error026:    dc.b     "Global data structure allocated but size was not saved",0
error027:    dc.b     "Cannot evaluate String length on a null pointer",0
error028:    dc.b     "Cannot open dos.library version 0",0
error029:    dc.b     "The selected variable is not a String",0
error030:    dc.b     "deleteLocalDatas caleed without any local data to delete",0
error031:    dc.b     "The procedure Called requires no parameters",0
error032:    dc.b     "Cannot load global variable as its type is unknown",0
error033:    dc.b     "Not enough memory available",0
error034:    dc.b     "Direct data stack overflow",0
error035:    dc.b     "Cannot read data from 'Direct data stack' as it is empty",0
error036:    dc.b     "Too much parameters entered to call the procedure",0
error037:    dc.b     "Internal Stack was already allocated",0
error038:    dc.b     "Cannot release Internal Stack as it does not exists",0
error039:    dc.b     "Internal stack does not exists",0
error040:    dc.b     "",0
error041:    dc.b     "",0
error042:    dc.b     "",0
error043:    dc.b     "",0
error044:    dc.b     "",0
error045:    dc.b     "",0
error046:    dc.b     "",0
error047:    dc.b     "",0
error048:    dc.b     "",0
error049:    dc.b     "",0
             EVEN
