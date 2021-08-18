; MemoryBank.i
	_ReserveAsChipData		Equ	-30
	_ReserveAsFastData		Equ	-36
	_ReserveAsPublicData	Equ	-42
	_ReserveAs24BitDMAData	Equ	-48
	_BankBase				Equ	-54
	_EraseBank				Equ	-60
	_EraseAll				Equ	-66

; End.MB.i

; Memory Bank Error Messages.
	InvalidBank				Equ	-1
	BankAlreadyExist		Equ	-2
	NotEnoughtChipMemory	Equ	-3
	NotEnoughFastMemory		Equ	-4
	NotEnoughPublicMemory	Equ	-5
	NotEnough24BitDMAMemory	Equ	-6
	CannotEraseBank			Equ	-7
; End.MBEM.i