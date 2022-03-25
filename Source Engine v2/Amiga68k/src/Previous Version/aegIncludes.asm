; **********************************************************
; * Method Name : ForceIncludesXXXLibs                     *
; *--------------------------------------------------------*
; * Usage : Used as 1st lines of the source code, to force *
; *   the includes of the AEG system libraries inside the  *
; *   executable that will be compiled. It can setup single*
; *   (1 platform only) or cumulative includes (to support *
; *   multiple platform at once)                           *
; *--------------------------------------------------------*
; * Description : It will force the include of specific aeg*
; *   libraries inside the executable during compilation.  *
; *--------------------------------------------------------*
; * Version : 1.0                                          *
; * Last update date : 2021.08.25                          *
; **********************************************************
ForceIncludeECSLibs MACRO
 includeLibs set includeLibs | ecsLibType
 ENDM
; **********************************************************
ForceIncludeAGALibs MACRO
 includeLibs set includeLibs | agaLibType
 ENDM
; **********************************************************
ForceIncludeSAGALibs MACRO
 includeLibs set includeLibs | SagaLibType
 ENDM
; **********************************************************
ForceIncludeALLLibs MACRO
 includeLibs set includeLibs | (ecsLibType+agaLibType+SagaLibType)
 ENDM

; **********************************************************
; This one must be pushed just after the end of the source code to fix which libraries will be included inside the executable.
FixLibsIncludes MACRO
 includeLibs set includeLibs+0
 finalIncludeLibs equ includeLibs
 ENDM 

; **********************************************************
; This one must be added after everything in the whole source code to potentially includes (binary include) the aegLibraries inside
; the whole EXECUTABLE as binaries inserts.
; Syntax : aegLibrarySupport : ShortName, .libraryName, AdditionalLibNames
aegLibrarySupport MACRO
 IFEQ includeLIBS
Short\1:
  dc.b  "LIBS:\2",0
  EVEN
Size\1  equ  endOf\1-startOf\1
startOf\1:
  incbin "LIBS:\2"
endOf\1:
 ELSEIF
 ENDC

