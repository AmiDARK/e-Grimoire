; *****************************************************
; 1. Primitives variables types :
bTypeInt           equ 0                       ; Bit 0 for Integer 
bTypeFlt           equ 1                       ; Bit 1 for float
bTypeStr           equ 2                       ; Bit 2 for Strings (setup always do a copy of the String if it's direct data in dc.b)
bTypeBigInt        equ 3                       ; Bit 3 for Bit-Integer (64bits integer)
; *****************************************************
; 2. Complexes variables types :
bTypeArray         equ 8                       ; Bit 8 for Dim (Integer, Float or String)
bTypeDynArray      equ 9                       ; Bit 9 for Dynamic Array (Integer, Float or String)
bTypeStruct        equ 10                      ; Bit 10 for structures/types

; *****************************************************
; 3. Objects variables types :
bTypeMemBlock      equ 12                      ; Bit 12 for Memory Blocks (Exclusive)

; *****************************************************
; Available Variables Type Constant values
TypeInt            equ 2^bTypeInt              ; = 1
TypeFlt            equ 2^bTypeFlt              ; = 2
TypeStr            equ 2^bTypeStr              ; = 4
TypeBigInt         equ 2^bTypeBigInt           ; = 8
TypeArray          equ 2^bTypeArray            ; = 256
TypeDynArray       equ 2^bTypeDynArray         ; = 512
TypeStruct         equ 2^bTypeStruct           ; = 1024
TypeMemBlock       equ 2^bTypeMemBlock         ; = 4096

; *****************************************************
; Differents variables area
bLockGlobal        equ 0
bLockProcedure     equ 1
bLockClass         equ 2
bLockClassMethod   equ 3
