
; *****************************************
; * Source Engine                         *
; *---------------------------------------*
; * Date : 2020.01.27                     *
; * Last Update : 2020.01.31              *
; * Version : 0.2                         *
; * File : game Engine for Source Engine  *
; * Author : Frederic Cordier             *
; *****************************************
; This file is formatted to makes the Source Engine being compiled under any
; Motorola 68k MACRO assembler (like Devpac3 for example) for Amiga OS 1.3 to 3.x
; *********************************************
; 1. We must firstly include this header file as it contains everything to setup the engine.
;    As assembler will include it at beginning, it will be executed before the 'gameStart' label.
	include	"src/header_coldStart.asm"
; *********************************************
; 2. You can add additional source code files here with procedure and classes.
;   include "Include Your Additional Procedures & Classes files here"
; *********************************************
; 3. The main Source Code is located here. It is is the program to run using the Source Engine.
