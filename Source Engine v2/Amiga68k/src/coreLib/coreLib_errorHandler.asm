; *********************************************************
; * Source Engine                                         *
; *-------------------------------------------------------*
; * Date : 2022.03.22                                     *
; * Last Update : 2022.03.22                              *
; * Version : 0.1                                         *
; * File : Source Engine Internal System branchments list *
; * Author : Frederic Cordier                             *
; *********************************************************

CastErrorIDInt:

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
; Cast a custom error using its label reference to the error text
; INPUT : A0 = pointer to the error text
CastCustomErrorMessage:
;    lea         castedError(pc),a1
;    move.l      a0,(a1)
    lea         myIntuiTextToUse(pc),a1
    move.l      a0,(a1)
    move.l      DosBase(a5),d7
    tst.l       d7
    beq.s       .silentFail
    seReporter_log                              ; Temporar error reporting through CLI: or CON:
.silentFail:

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
; Final method to cast the error through an IntuitionLib requester
CastFinalError:
    bra         hotEndGrimoire

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
    dc.l    error050,error051,error052,error053,error054
    dc.l    error055,error056,error057,error058,error059
    dc.l    error060,error061,error062,error063,error064
    dc.l    error065,error066,error067,error068,error069
    dc.l    0

; *********************************************
; True error messages cast through the Intuition Requester to inform user of what happened.
  IFEQ fullErrorMessages-1
error000:    dc.b     "Error#0 : Unknown Error occured.",10,0
error001:    dc.b     "Error#1 : Invalid stack temporar variable ID. Stack temporar variable allowed range is 0-15.",10,0
error002:    dc.b     "Error#2 : The entered variable is not a STRING.",10,0
error003:    dc.b     "Error#3 : The entered variable is not an INTEGER.",10,0
error004:    dc.b     "Error#4 : The value entered is not an INTEGER.",10,0
error005:    dc.b     "Error#5 : The Stack variable is not an Integer.",10,0
error006:    dc.b     "Error#6 : The TempVar register is invalid (Range is 0-15).",10,0
error007:    dc.b     "Error#7 : The entered String cannot be converted to Floating Number.",10,0
error008:    dc.b     "Error#8 : The entered variable is not compatible with receiver.",10,0
error009:    dc.b     "Error#9 : The entered String cannot be converted to Integer valu.e",10,0
error010:    dc.b     "Error#10 : invalid EndProcedure reached.",10,0
error011:    dc.b     "Error#11 : 'Return' was reached without any preceding 'Gosub' (Goto Used?).",10,0
error012:    dc.b     "Error#12 : Gosub are forbidden inside Procedures and Functions.",10,0
error013:    dc.b     "Error#13 : Goto are forbidden inside Procedures and Functions.",10,0
error014:    dc.b     "Error#14 : Too much 'Gosub' called (>16384) without any 'return'.",10,0
error015:    dc.b     "Error#15 : Too much 'Procedures/Functions' calls (>16384) without any EndProcedure/EndFunction.",10,0
error016:    dc.b     "Error#16 : Global Data Structure is defined twice.",10,0
error017:    dc.b     "Error#17 : String size exceed 16382 bytes.",10,0
error018:    dc.b     "Error#18 : Cannot open dos.library version 0.",10,0
error019:    dc.b     "Error#19 : Cannot open graphics.library version 0.",10,0
error020:    dc.b     "Error#20 : Cannot open intuition.library version 0.",10,0
error021:    dc.b     "Error#21 : Cannot open mathffp.library version 0.",10,0
error022:    dc.b     "Error#22 : Cannot allocate a memory buffer which size is 0 bytes.",10,0
error023:    dc.b     "Error#23 : Cannot release a memory buffer which size is 0 bytes.",10,0
error024:    dc.b     "Error#24 : Cannot release a memory buffer from a null pointer.",10,0
error025:    dc.b     "Error#25 : Cannot report requested error as its id is out of range.",10,0
error026:    dc.b     "Error#26 : Global data structure allocated but size was not saved.",10,0
error027:    dc.b     "Error#27 : Cannot evaluate String length on a null pointer.",10,0
error028:    dc.b     "Error#28 : Cannot open 'System/grimoire-fpConvert.library'.",10,0
error029:    dc.b     "Error#29 : The selected variable is not a String.",10,0
error030:    dc.b     "Error#30 : deleteLocalDatas caleed without any local data to delete.",10,0
error031:    dc.b     "Error#31 : The procedure Called requires no parameters.",10,0
error032:    dc.b     "Error#32 : Cannot load global variable as its type is unknown.",10,0
error033:    dc.b     "Error#33 : Not enough memory available.",10,0
error034:    dc.b     "Error#34 : Direct data stack overflow.",10,0
error035:    dc.b     "Error#35 : Cannot read data from 'Direct data stack' as it is empty.",10,0
error036:    dc.b     "Error#36 : Too much parameters entered to call the procedure.",10,0
error037:    dc.b     "Error#37 : Internal Stack was already allocated.",10,0
error038:    dc.b     "Error#38 : Cannot release Internal Stack as it does not exists.",10,0
error039:    dc.b     "Error#39 : Internal stack does not exists.",10,0
error040:    dc.b     "Error#40 : Whole variables buffer exceeded. Try to increase 'extraVarBuffer' variable.",10,0
error041:    dc.b     "Error#41 : cannot load global data pointer as it is null.",10,0
error042:    dc.b     "Error#42 : Cannot remove an undefined local variables buffer.",10,0
error043:    dc.b     "Error#43 : Full Variable Buffer not allocated.",10,0
error044:    dc.b     "Error#44 : Illegal amount of parameters to call this procedure.",10,0
error045:    dc.b     "Error#45 : Some arguments are of an incorrect type in the procedure call.",10,0
error046:    dc.b     "Error#46 : The last called procedure did not return any value.",10,0
error047:    dc.b     "Error#47 : The direct data is not of the same type than the variable to update.",10,0
error048:    dc.b     "Error#48 : Unknown variable identifier.",10,0
error049:    dc.b     "Error#49 : Illegal amount of parameters to call BasicFOR. Needs Variable,StartValue, FinalValue (,optional Step).",10,0
error050:    dc.b     "Error#50 : The Basic For/Next requires integer variables or direct values as parameters.",10,0
error051:    dc.b     "Error#51 : The Basic Loops buffer must be allocated only once.",10,0
error052:    dc.b     "Error#52 : Some buffers must be released before releasing Basic Loops buffer one.",10,0
error053:    dc.b     "Error#53 : Internal buffer for Loops datas support is not created.",10,0
error054:    dc.b     "Error#54 : Vampire card model is not recognized.",10,0
error055:    dc.b     "Error#55 : Basic 'RETURN' function reached without any 'GOSUB' call",10,0
error056:    dc.b     "Error#56 : Cannot open grimoire-hardwareDetector.library.",10,0
error057:    dc.b     "Error#57 : Screen ID is invalid. Valid values are 0-7.",10,0
error058:    dc.b     "Error#58 : Screen Dimensions are invalid. Valid values are 320<width<2048, 32<height<2048 pixels.",10,0
error059:    dc.b     "Error#59 : Screen width must be multiple of 16.",10,0
error060:    dc.b     "Error#60 : Cannot open dedicaced grimoire-screens.library.",10,0
error061:    dc.b     "Error#61 : Cannot open grimoire-displayDriver.library.",10,0
error062:    dc.b     "Error#62 : ",10,0
error063:    dc.b     "Error#63 : ",10,0
error064:    dc.b     "Error#64 : ",10,0
error065:    dc.b     "Error#65 : ",10,0
error066:    dc.b     "Error#66 : ",10,0
error067:    dc.b     "Error#67 : ",10,0
error068:    dc.b     "Error#68 : ",10,0
error069:    dc.b     "Error#69 : ",10,0
             EVEN
  ELSEIF
error000:    dc.b     "Error#0",10,0
error001:    dc.b     "Error#1",10,0
error002:    dc.b     "Error#2",10,0
error003:    dc.b     "Error#3",10,0
error004:    dc.b     "Error#4",10,0
error005:    dc.b     "Error#5",10,0
error006:    dc.b     "Error#6",10,0
error007:    dc.b     "Error#7",10,0
error008:    dc.b     "Error#8",10,0
error009:    dc.b     "Error#9",10,0
error010:    dc.b     "Error#10",10,0
error011:    dc.b     "Error#11",10,0
error012:    dc.b     "Error#12",10,0
error013:    dc.b     "Error#13",10,0
error014:    dc.b     "Error#14",10,0
error015:    dc.b     "Error#15",10,0
error016:    dc.b     "Error#16",10,0
error017:    dc.b     "Error#17",10,0
error018:    dc.b     "Error#18",10,0
error019:    dc.b     "Error#19",10,0
error020:    dc.b     "Error#20",10,0
error021:    dc.b     "Error#21",10,0
error022:    dc.b     "Error#22",10,0
error023:    dc.b     "Error#23",10,0
error024:    dc.b     "Error#24",10,0
error025:    dc.b     "Error#25",10,0
error026:    dc.b     "Error#26",10,0
error027:    dc.b     "Error#27",10,0
error028:    dc.b     "Error#28",10,0
error029:    dc.b     "Error#29",10,0
error030:    dc.b     "Error#30",10,0
error031:    dc.b     "Error#31",10,0
error032:    dc.b     "Error#32",10,0
error033:    dc.b     "Error#33",10,0
error034:    dc.b     "Error#34",10,0
error035:    dc.b     "Error#35",10,0
error036:    dc.b     "Error#36",10,0
error037:    dc.b     "Error#37",10,0
error038:    dc.b     "Error#38",10,0
error039:    dc.b     "Error#39",10,0
error040:    dc.b     "Error#40",10,0
error041:    dc.b     "Error#41",10,0
error042:    dc.b     "Error#42",10,0
error043:    dc.b     "Error#43",10,0
error044:    dc.b     "Error#44",10,0
error045:    dc.b     "Error#45",10,0
error046:    dc.b     "Error#46",10,0
error047:    dc.b     "Error#47",10,0
error048:    dc.b     "Error#48",10,0
error049:    dc.b     "Error#49",10,0
error050:    dc.b     "Error#50",10,0
error051:    dc.b     "Error#51",10,0
error052:    dc.b     "Error#52",10,0
error053:    dc.b     "Error#53",10,0
error054:    dc.b     "Error#54",10,0
error055:    dc.b     "Error#55",10,0
error056:    dc.b     "Error#56",10,0
error057:    dc.b     "Error#57",10,0
error058:    dc.b     "Error#58",10,0
error059:    dc.b     "Error#59",10,0
error060:    dc.b     "Error#60",10,0
error061:    dc.b     "Error#61",10,0
error062:    dc.b     "Error#62",10,0
error063:    dc.b     "Error#63",10,0
error064:    dc.b     "Error#64",10,0
error065:    dc.b     "Error#65",10,0
error066:    dc.b     "Error#66",10,0
error067:    dc.b     "Error#67",10,0
error068:    dc.b     "Error#68",10,0
error069:    dc.b     "Error#69",10,0
             EVEN
  ENDC
