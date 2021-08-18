******************************
****** EXEC lib version ******
*  Macro par Eynard Fabien   *
******************************

* bit test -> 	bit0 -> 68010
*		bit1 -> 68020
*		bit2 -> 68030???
*		bit3 -> 68040? il ne peut être que là
*		bit4 -> 68881
*		bit5 ->???????
*		bit6 -> 68040/68060 FPU
* 		bit7 -> 68060
	clr.l d0		; nettoie les registres D0
	lea $4,a0		; Charge Adresse ExecBase
	move.l	(a0),a0		; Transfert le Buffer
	move.w  296(A0),d0	; Recup FLAG CPU - D0
	RTS
