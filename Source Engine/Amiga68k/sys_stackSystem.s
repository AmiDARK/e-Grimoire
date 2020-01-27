
; Variable structure :
; 0.L : Variable itself (Integer,Float) or its pointer (string)
; 4.W : Variable type ( TypeStr, TypeFlt, TypeInt, etc. )
; 6.L : In case of String=Size, in case of Dim or Array=Size of array

; Send a String to Stack
: INPUT : A0 = String Pointer, D0 = String Length (or -1 if not evaluated)
StrToStack 	MACRO
	move.l 	a3,(sp)+
	Move.l 	StackAdr(a5),a3
	Move.l 	a0,(a3)+
	Move.w  #TypeStr,(a3)+
	Move.l 	d0,(a3)+
	Move.l 	a3,StackAdr(a5)
	move.l  -(sp),a3
			ENDM

; OUTPUT : AO = String Pointer, D0 = String Length
pullStrFromStack	MACRO
	move.l 	a3,(sp)+
	Move.l 	StackAdr(a5),a3
	sub.l 	#10,a3
	Move.l	a3,StackAdr(a5)
	Move.l  (a3),a0
	move.l  #6(a3),d0
	clr.l 	(a3)+
	clr.w 	(a3)+
	clr.l 	(a3)+
	move.l  -(sp),a3
			ENDM

