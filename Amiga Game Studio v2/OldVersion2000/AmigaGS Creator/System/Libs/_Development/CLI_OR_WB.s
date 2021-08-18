ExecBase=4

GetMsg=-372
WaitPort=-384
FindTask=-294

; Cette routine doit être au debut de tous tes programmes 
; qui sont lancés à partir du Workbench.... Tzin tzin...
; et MAX est encore Là à la rescousse...

CLI_OR_WB:
 	move.l ExecBase,a6	;Exebase en A6
 	move.l #0,a1		;CLean A1
 	jsr    FindTask(a6)	;Quelle Tâche ???
 	move.l d0,a2		; sauve resultat en A2
 	tst.l  $ac(a2)		;verify Adr Message WB (Write)
 	bne    FromCLI		; si pas bon alors - OK CLI

 	lea    $5c(a2),a0    	;Sinon Il est ouvert du WB
 	jsr    WaitPort(a6)  	;Attendre le Port WB
 	lea    $5c(a2),a0	;Charge ADr Message WB (Read)
 	jsr    GetMsg(a6)	;recup le message ...
 				;on ne sauve pas car on ne s'en sert pas...
 				;si tu ne vide pas les messages
 				;Le buffer va se remplir et le Wb va planter

FromCLI:

;;; OK TU PEUX MAINTENANT FAIRE TON PETIT PROGRAMME