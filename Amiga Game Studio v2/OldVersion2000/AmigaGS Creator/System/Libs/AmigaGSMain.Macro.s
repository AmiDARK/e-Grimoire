InitLib	MACRO
	Move.l	$4,a6
	Lea.l	\1Name,a1
	Move.l	#0,d0
	Jsr		-408(a6)
	Lea.l	\1Base,a1
	Move.l	d0,(a1)
	ENDM

InitLibRESERVED	MACRO
	Lea.l	DosBase,a0
	Move.l	#AmigaLib,d0
	Lea.l	FileIOBase,a1
	Move.l	#AmigaGSLib,d1
	Lea.l	\1Base,a5
	Move.l	(a5),a6
;	Tst.l	a6
;	Beq.s	.nolib\1
	Jsr		-30(a6)			; Call function : InitRESERVED .
;.nolib\1
	ENDM

CloseLib	MACRO
	Lea.l	\1Base,a0
	Move.l	(a0),a1
	Tst.l	a1
	Beq.s	.nolibc\1
	Jsr		-414(a6)
.nolibc\1
	ENDM

;		CheckCPU CPU_NEEDED,BRA_IF_CPU_NOT_EQUAL,BRA_IF_CPU_EQUAL
CheckCPU	Macro
	Lea.l	CPU,a0
	Move.w	(a0),d0
	And.w	#\1,d0
	Tst.w	d0
	Beq.b	\2
	Bne.b	\3
	ENDM

;		CheckCPUBra CPU_NEEDED,BRA_IF_CPU_EQUAL
CheckCPUBra	Macro
	Lea.l	CPU,a0
	Move.w	(a0),d0
	And.w	#\1,d0
	Tst.w	d0
	Bne.b	\2
	ENDM

;
Cpu68010	Equ		1
Cpu68020	Equ		2
Cpu68030	Equ		4
Cpu68040	Equ		8
Fpu68881	Equ		16
Fpu68882	Equ		32
Fpu68040	Equ		64
Cpu68060	Equ		128
FpuOnly		Equ		Fpu68881+Fpu68882+Fpu68040+Cpu68060
FullFpu		Equ		Fpu68881+Fpu68882+Cpu68060

