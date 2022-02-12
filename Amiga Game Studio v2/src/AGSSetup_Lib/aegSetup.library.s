; * ***************************************
; *                                       *
; * Amiga-E-Grimoire Game Development Kit *
; *                                       *
; *---------------------------------------*
; *                                       *
; * Component    : Setup Library          *
; * Version      : 0.1                    *
; * Start Date   : 2021.08.18             * 
; * Last Edit On : 2021.08.20             *
; *                                       *
; *****************************************
; Structure Details :
;--------------------
;   1. Includes
;   2. MACROS
;   3. Internal Amiga .Library Style Structure
;   4. Functions Table (list of .Library functions)
; 


; ************************************* 1. Includes
	Incdir	"includes:"
	include "exec/types.i"
	include "exec/initializers.i"
	include "exec/librariesDVP.i"
	include "exec/lists.i"
	include "exec/nodes.i"
	include "exec/resident.i"
	include "libraries/dosDVP.i"
	include "exec/alerts.i"
;	Include "exec/exec_lib.i"
	include	"exec/exec.s"


maxInstancesAmount equ 8

; ************************************* 2. MACROS
XLIB MACRO
  XREF _LVO\1
 ENDM

CALLSYS MACRO
  jsr _LVO\1(a6)
 ENDM

ExeCall	MACRO
  loadExec a6
  CALLSYS \1(a6)
	NDM

loadExec MACRO
  move.l $4,\1
 ENDM

aegLibCall MACRO
    CALLSYS    \1
 ENDM



; ************************************* 3. Internal Amiga .Library Style Structure
 STRUCTURE  MyLib,LIB_SIZE
            ULONG ml_SysLib
            ULONG ml_DosLib
            ULONG ml_SegList
            UBYTE ml_Flags
            UBYTE ml_pad
            LABEL MyLib_Sizeof
 XLIB       OpenLibrary
 XLIB       CloseLibrary
 XLIB       FreeMem
 XLIB       Remove
 XLIB       Alert

Version        equ 1                 ;Version de la Library
Revision       equ 0                 ;Révision de la Library
Pri            equ 0                 ;Pri. de la Library (sans importance)

Start:
               moveq #0,d0
               rts
Resident:
               dc.w RTC_MATCHWORD    ;Code pour Resident
               dc.l Resident         ;Pointeur sur le début de la structure
               dc.l FinCode          ;Pointeur sur la fin de la structure
               dc.b RTF_AUTOINIT     ;Flag pour l'appel automatique
               dc.b Version          ;Version de la Library
               dc.b NT_LIBRARY       ;Type de la structure Resident=Library
               dc.b Pri              ;Priorité de la str.Resident
               dc.l LibName          ;Pointeur sur le nom de la Library
               dc.l idString         ;Chaîne d'id. pour la Library
               dc.l Init             ;Pointeur sur le tableau d'initialisation
LibName:
               dc.b 'aegSetup.library',0
idString:
               dc.b 'aegSetup.library Ver 0.1'
               dc.b '680x0 Version '
			         dc.b '(27 août 2021) ',13,10,0
DosName:
               dc.b 'dos.library',0
               ds.w 0
FinCode:
Init:
			dc.l	MyLib_Sizeof     ;Taille de la structure de librairie
			dc.l	FuncTable        ;Pointeur sur le tableau
                                     ;des fonctions Lib
			dc.l	DataTable        ;Pointeur sur tableau pour InitFonction
			dc.l	InitRoutine      ;Pointeur sur routine propre

; ************************************* 4. Functions Table (list of .Library functions)
FuncTable:
;----------- Routines système
			dc.l	Open
			dc.l	Close
			dc.l	Expunge
			dc.l	Zero
;----------- Routines personnelles
			dc.l	Constructor
			dc.l	Destructor
;----------- Marque de fin
               dc.l -1

;tableau transmis à la fonction InitStruct
DataTable:     INITBYTE  LH_TYPE,NT_LIBRARY
               INITLONG  LN_NAME,LibName
               INITBYTE  LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
               INITWORD  LIB_VERSION,Version
               INITWORD  LIB_REVISION,Revision
               INITLONG  LIB_IDSTRING,idString
               dc.l 0
;>= D0 = Pointeur sur la structure de librairie
;>= A0 = Pointeur sur la liste des segments de la Library chargée
;>= A6 = Pointeur sur Execbase
;=> D0 = Pointeur sur la structure de librairie
InitRoutine:
            move.l a5,-(a7)                     ;sauver A5
            move.l d0,a5                        ;Pointeur sur MyLib
            move.l a6,ml_SysLib(a5)             ;Pointeur sur ExecLib
            move.l a0,ml_SegList(a5)            ;introduit liste des segments
            lea DosName(pc),a1                  ;Pointeur sur le nom DOS
            move.l #Version,d0                  ;numéro de version= 0
            CALLSYS OpenLibrary
            move.l d0,ml_DosLib(a5)             ;Entrée de l'adresse
            bne.s s1                            ;Ok, Lib trouvé

;ALERT est une macro qui se trouve dans "exec/alerts.i"
            ALERT AG_OpenLib!AO_DOSLib          ;Sort Alert
s1:
;Vous placerez ici votre propre routine d'initialisation
            move.l a5,d0                        ;Pointeur sur Mylib
            move.l (a7)+,a5                     ;Recherche les registres
            rts                                 ;Retour
;La routine suivante est appelée par la fonction OpenLibrary()
;>= A6 = Pointeur sur la structure personelle de librairie
;>= D0 = Pointeur sur la structure personnelle de librairie
Open:
            addq.w #1,LIB_OPENCNT(a6)      ;Incrémente le compteur pour
                                           ;le nombre des accès à la Library
            bclr #LIBB_DELEXP,ml_Flags(a6) ;Flag pour supprimer
                                           ;la Library
            move.l a6,d0                   ;définir les paramètres de retour
            rts                            ;Retour
Close:
            clr.l d0                       ;Supprime le pointeur
                                           ;sur liste de  segments (important)
            subq.w #1,LIB_OPENCNT(a6)      ;compteur pour ouverture de la
                                           ;Library -1
            bne.s s2                       ;saut si Library
                                           ;encore utilisée
            btst #LIBB_DELEXP,ml_Flags(a5) ;est-ce que le flag
                                           ; LIBB_DELEXP est posé?
            beq.s s2                       ;Fin, s'il ne l'est pas
            bsr.b Expunge                    ;supprime Library
s2:         rts                            ;retour
;Routine pour supprimer la librairie de la mémoire.
;>= A6 = Pointeur sur Library
;=> D0 = Pointeur sur liste des segments de la Library chargée
Expunge:
            movem.l d1/a5-a6,-(a7)         ;sauver les registres
            move.l a6,a5                   ;Pointeur sur Library vers A5
            move.l ml_SysLib(a5),a6        ;ExecBase vers  A6
            tst.w LIB_OPENCNT(A5)          ;Library encore utilisée?
            beq.b s3                         ;Saut si non utilisée
            bset #LIBB_DELEXP,ml_Flags(a5) ;on souhaite supprimer
                                           ;la Library
            clr.l d0                       ;supprime le pointeur sur
                                           ;liste des segments
            bra.s Expunge_end              ;saut inconditionnel
s3:         move.l ml_SegList(a5),d2       ;Pointeur sur liste des segments
                                           ;vers D2
            move.l a5,a1                   ;Pointeur sur Library vers A1
            CALLSYS Remove                 ;supprimer Library
                                           ;de la liste Exec-Lib
            move.l ml_DosLib(a5),a1        ;Pointeur sur DOS-Library
            CALLSYS CloseLibrary           ;Fermer Library
            clr.l d0                       ;effacer D0
            move.l a5,a1                   ;Pointeur sur Library
            move.w LIB_NEGSIZE(a5),d0
            sub.l d0,a1                    ;cherche pointeur sur
                                           ;début de la mémoire
                                           ;occupée par la librairie
            add.w LIB_POSSIZE(a5),d0       ;obtenir longueur de la
                                           ;mémoire occupée
            CALLSYS FreeMem                ;libère la mémoire
            move.l d2,d0                   ;Pointeur sur liste des segments
                                           ;vers D0
Expunge_end:
            movem.l (a7)+,d2/a5-a6         ;restaurer les registres
            rts                            ;retour
;la fonction suivante peut être atteinte avec offset -24.
;Elle n'est pas utilisée dans la version Kickstart actuelle.
Zero:
            moveq #0,d0                    ;efface D0
            rts                            ;retour

; *************************************************************** Internal

;                                                                                                                      ************************
;                                                                                                                                        ***
;                                                                                                                                     ***
; *********************************************************************************************************************************************
;                                                                                           *                                                 *
;                                                                                           * AREA NAME :        *****                        *
;                                                                                           *                                                 *
;                                                                                           ***************************************************
;                                                                                                 ***
;                                                                                              ***
;                                                                                           ************************


;
; *****************************************************************************************************************************
; *************************************************************
; * Method Name : Constructor                                 *
; *-----------------------------------------------------------*
; * Description : Create the application InstanceID, StartGDK *
; *   by opening all dedicaced libraries, Return InstanceID in*
; *   D7 and return libraries pointers in a structure         *
; *                                                           *
; * Parameters : -                                            *
; *                                                           *
; * Return Value : D7=AppInstanceID, A5=Struture Pointer      *
; *************************************************************
;                                                    *******************************
; **** 1. Try to find a free instance slot in the available slots list
Constructor:

; **** 1.0 Check if there a free slot available
  Move.l    aegInstancesOpened(pc),d0
  cmp.l     #maxInstancesAmount,d0
  bge.s     .NoFreeSlot                    ; No Available free slot -> Jump .NoFreeSlot
; **** 1.1 Available free slot
.FreeSlotAvailable:
; **** 1.1.1 Reserve slot
  add.l     #1,d0                          ; OpenedInstancesAmount+1
  move.l    d0,aegInstancesOpened(pc)      ;   -> register to makes others instances know the exact free slots amount 
; **** 1.1.2 Found the slot in the list to push the ID inside it.
  lea       aegInstances(pc),a4
  movea     #maxInstancesAmount-1,d0       ; 'maxInstancesAmount' existing slots to scan
.cSearch:
  tst.l     (a4)                           ; is this slot used ?
  beq.s     .cFound
  add.l     #4,a4                          ; Next slot to read
  dbra      d0,.cSearch
; **** 1.2.1. No empty instance slot available. Simply quit with error -1 and not structure in a5.
.NoFreeSlot:
  Moveq     #-1,d0                         ; Error -1 = No Available Instance Slot
  rts
;                                                    *******************************
; **** 2. Empty instance slot available. Start the setup of the engine.
.cFound:
  Move.l    aegCurrentInstance(pc),d7      ; Load Last InstanceID
  add.l     #0080F473,d7                   ; Next Instance ID calculated using a static shift
  move.l    d7,(a4)                        ; Save new Instance ID in the current aegInstances slot
  move.l    d7,aegCurrentInstance(pc)      ; Save new instance in last ID backup

; **** 3. Create memory area to handle all the aeg libraries pointers if not yet created
  Move.l    aegSysStructure(pc),d0         ; d0 = aegSysStructure
  Tst.l     d0                             ; Is aegSysStructure already allocated and filled with informations/pointers ?
  bne.s     aegSetupAlreadyDone            ; Yes -> Jump .getSysStructPointer
.sysStructAllocation:
  move.l    #seSize,d0                     ; SizeRequired
  move.l    #Public|Clear,d1    Flags      ; Public (Fast & Chip) + Clear Memory
  ExeCall   AllocMem                       ; Call AllocMem
  Tst.l     d0                             ; No memory allocated ?
  Beq.w     QuitPrematurely                ; Yes -> Jump QuitPrematurely
  move.l    d0,aegSysStructure(pc)         ; Save Internal Structure pointer in case of.

; **** 4. Open All aeg Libraries with a5=Constant=InternalStructurePointer & d7 = aegCurrentInstanceID
  move.l aegCurrentInstance(pc),d7 ; d7 = Current AEG instance
  move.l aegSysStructure(pc),a5    ; a5 = InternalStructurePointer (global to aeg to avoid multiple libraries setup.)

; ** 4.1 Open aegHardwareDetector library
  initAegLibrary aegHardwareDetector_LibName,0,aegHardwareDetector,1 ; Save en aegHardwareDetector(a5)



aegSetupAlreadyDone:
  move.l    aegSysStructure(pc),a5         ; Load systemStructureWithAllPointer
  rts
;EndConstructor


; **** 5. Quit prematurely when there is not enough memory to start setup (allocate internal structure error)
QuitPrematurely:
  rts


;
; *****************************************************************************************************************************
; *************************************************************
; * Method Name : Destructor                                  *
; *-----------------------------------------------------------*
; * Description : If the provided Application Instance ID is  *
; *   found, it will release the Application Instance from the*
; *   GDK running libraries. If all instance are closed, all  *
; *   the libraries will be closed/released                   *
; *                                                           *
; * Parameters : D7 = AppInstanceID                           *
; *                                                           *
; * Return Value :                                            *
; *************************************************************
; ****************************************************************
Destructor:

; **** 1. Try to find the current instance sent in d0
  lea       aegInstances(pc),a4
  move.w    #(maxInstancesAmount-1),d0     ; 'maxInstancesAmount' existing slots
.dSearch:
  cmp.l     d7,(a4)                        ; is this slot is the one we are looking for ?
  beq.s     .dFound
  add.l     #4,a4                          ; Next slot to read
  dbra      d0,.dSearch

; **** 2. No empty instance slot available. Simply quit with error -1 and not structure in a5.
.dNotFound:
  move.l    #-2,d0                         ; Error -2 = Unknown Instance identifier.
  clr.l     (a5)                           ; No system Structure passed
  rts

.dFound:
  clr.l     (a5)                           ; Clear the instance identifier to release the slot.
  rts
;EndDestructor

; ****************************************************************

;
; *****************************************************************************************************************************
; *************************************************************
; * Method Name :                                             *
; *-----------------------------------------------------------*
; * Description :                                             *
; *                                                           *
; * Parameters :                                              *
; *                                                           *
; * Return Value :                                            *
; *************************************************************
; Create area to store the Unique Identifier for each running instance of the Amiga-E-Grimoire GDK.
aegSysStructure:
  dc.l      0                                  ; Pointer to the structure that will contains all the AEG libraries pointers for libCalls.
aegCurrentInstance:
  dc.l      $1405F8BA                          ; Backup of the Instance ID created during Constructor Setup
aegInstancesOpened:
  dc.l      0                                  ; Amount of instances that were opened by calling the aegSetup.library/Constructor method
aegInstances:
  REPT      maxInstancesAmount                 ; Repeat the dc.l 'maxInstancesAmount' times
  dc.l      0                                  ; insert a new instance slot (capability)
  ENDR                                         ; End of repeat
aegHardwareDetector_LibName:
  dc.b      "aegHardwareDetector.library",0
  EVEN
aegMemoryHandler_LibName:
  dc.b      "aegMemoryHandler",0
  EVEN




;
; *****************************************************************************************************************************
; *************************************************************
; * Method Name :                                             *
; *-----------------------------------------------------------*
; * Description :                                             *
; *                                                           *
; * Parameters :                                              *
; *                                                           *
; * Return Value :                                            *
; *************************************************************






