; *****************************************************
; 1. Primitives variables types :
bTypeInt           equ 0                       ; Bit 0 for Integer 
bTypeFlt           equ 1                       ; Bit 1 for float
bTypeStr           equ 2                       ; Bit 2 for mutable String buffers
bTypeBigInt        equ 3                       ; Bit 3 for Bit-Integer (64bits integer)
bTypeStaticInt     equ 4                       ; Bit 4 for static read-only Integer constants
bTypeStaticFlt     equ 5                       ; Bit 5 for static read-only Float constants
bTypeStaticStr     equ 6                       ; Bit 6 for static read-only Strings stored as dc.b
bTypeStaticBigInt  equ 7                       ; Bit 7 for static read-only Big-Integer constants
; *****************************************************
; 2. Complexes variables types :
bTypeArray         equ 8                       ; Bit 8 for Dim (Integer, Float or String)
bTypeDynArray      equ 9                       ; Bit 9 for Dynamic Array (Integer, Float or String)
bTypeStruct        equ 10                      ; Bit 10 for structures/types
bTypeStrRef        equ 11                      ; Bit 11 for non-owning mutable String references

; *****************************************************
; 3. Objects variables types :
bTypeMemBlock      equ 12                      ; Bit 12 for Memory Blocks (Exclusive)

; *****************************************************
; Available Variables Type Constant values
TypeInt            equ 2^bTypeInt              ; = 1
TypeFlt            equ 2^bTypeFlt              ; = 2
TypeStr            equ 2^bTypeStr              ; = 4
TypeBigInt         equ 2^bTypeBigInt           ; = 8
TypeStaticInt      equ 2^bTypeStaticInt        ; = 16
TypeStaticFlt      equ 2^bTypeStaticFlt        ; = 32
TypeStaticStr      equ 2^bTypeStaticStr        ; = 64
TypeStaticBigInt   equ 2^bTypeStaticBigInt     ; = 128
TypeArray          equ 2^bTypeArray            ; = 256
TypeDynArray       equ 2^bTypeDynArray         ; = 512
TypeStruct         equ 2^bTypeStruct           ; = 1024
TypeStrRef         equ 2^bTypeStrRef           ; = 2048
TypeMemBlock       equ 2^bTypeMemBlock         ; = 4096

; *****************************************************
; Differents variables area
bLockGlobal        equ 0
bLockProcedure     equ 1
bLockClass         equ 2
bLockClassMethod   equ 3
