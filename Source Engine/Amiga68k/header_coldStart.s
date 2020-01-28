
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.01.28              *
; * Version : 0.2                         *
; * File : header_coldStart               *
; * Author : Frederic Cordier             *
; *****************************************
; This file contains the hearth of the Amiga68k Source Engine.
; It handle all setup stuffs, and all releases.

; Source Engine Internal Structures
#include "seInternalStructures.s" 			; Includes all Source Engine internal data structures

; OS System Libraries
#include "AmigaOS/execLib.s"
#include "AmigaOS/graphicsLib.s"
#include "AmigaOS/intuitionLib.s"

; Source Engine Stack System (Direct Datas)
#include "seStackSystem.s"

main:
	bsr	coldStart
	bsr gameEngine
	bsr	quitEngine
	rts


; ********************************************* coldStart
; This method will setup the Source Engine
coldStart:
	bsr 	AllocSys								; Allocate memory for the internal Structure and save it into SysStructBackup
	bsr		loadSys									; A5 = SysStructBackup (pointer to the buffer of the structure)
	bsr		openGraphicsLib							; Open Graphics.library and save its base in the SysStructDatas
	bsr		openIntuitionLib						; Open Intuition.library and save its base in the SysStructDatas


	rts

; ********************************************* quitEngine
; This method will release all used memories to leave the Source Engine
quitEngine:


	bsr 	FreeSys 								; Release memory of the Internal Structure
	rts

; Backup the memory pointer to the Source Engine Internal Structure
SysStructBackup:	ds.l	0
