*********************************
***** OPEN INTUITION Window *****
*********************************

** APELLE EXEC
EXECBASE	=4
OPENLIBRARY	=-552
CLOSELIBRARY	=-414
WAITPORT	=-384
findtask	=-294
getmsg		=-372

** APPELLE DOS
DELAY		=-198

** APPELLE INTUITION
OPENWINDOW	=-204
CLOSEWINDOW	=-72
printitext	=-216


	move.l	execbase,a6	;c'est ma routine
	move.l	#0,a0		;de gestion
	jsr	findtask(a6)	;pour l'open
				;de programme
	move.l	d0,a4		;sous le Workbench
	tst.l	$ac(a4)		;** Je cherche la tache
	bne.l	fromcli		;je verifie le adr bit $ac
				;si pas ok alors ouvert par cli
				; goto cli	

	lea	$5c(a4),a0	;sinon	aller adr $5c de la tache
	jsr	waitport(a6)	;attendre le port du Wb

	lea	$5c(a4),a0	;des que port pret
	jsr	getmsg(a6)	;on recup le message
	move.l	d0,message	;on ne sait jamais
	
fromcli:
SCRIPT:
	jsr 	opendos		;ouvre dos
	cmp	#0,d0
	beq 	fin
	move.l	d0,dosbase
	
	jsr 	openintui	;ouvre intui
	cmp.l	#0,d0
	beq 	closedos
	move.l	d0,intuibase
	
	jsr 	openwin		; ouvre windows
	cmp	#0,d0
	beq 	closeintui
	move.l	d0,winhandle	;on recup Winhandle
	
	jsr 	print		;j'ecris dans intuition
	jsr 	attente		;j'attend gadjet close windows
	jmp 	closewin	;je ferme tout
	
****** OPEN LIBRARY ******
opendos:
	move.l	execbase,a6
	move.l	#dosname,a1
	move.l	#0,d0
	jsr 	openlibrary(a6)
	rts

openintui:
	move.l	execbase,a6
	move.l	#intuiname,a1
	move.l	#0,d0
	jsr	openlibrary(a6)
	rts
	
****** OPEN WINDOW ******
openwin:
	move.l	intuibase,a6
	lea 	newwindow,a0	;adr struct newWindow
	jsr 	openwindow(a6)	;GO retour de winhandle en d0
	rts

****** WAIT GADJET CLOSE PAR PORT ******
attente:
	move.l	winhandle,a0	;handle en a0
	move.l	86(a0),a0	;adr struct msgport
	move.l 	execbase,a6	;
	jsr 	waitport(a6)	;attendre un port ici $200
	move.l	d0,a1		;transfert en a1
	move.l	d0,d7
	move.l	20(a1),d1	;si 
	rts

***** printing ******
print:
	move.l	intuibase,a6	
	move.l	winhandle,a0	;handle window
	move.l	50(a0),a0	;adr rastport de window
	lea wintext,a1		;asdr struct text
	move.l	#20,d0		;x
	move.l	#20,d1		;y
	jsr printitext(a6)	;on ecrit
	rts
****** CLOSE WINDOW ******
closewin:
	move.l	winhandle,a0
	move.l	intuibase,a6
	jsr 	closewindow(a6)
	
******CLOSE LIBRARY ******
closeintui:
	move.l	execbase,a6
	move.l	intuibase,a1
	jsr 	closelibrary(a6)
	
closedos:
	move.l	execbase,a6
	move.l	dosbase,a1
	jsr 	closelibrary(a6)
	
******* END *******
fin:
	rts

********* MY WINDOW DATA *********
NEWWINDOW:
	dc.w 10			;x depart	
	dc.w 10			;y depart
	dc.w 600		;largeur
	dc.w 100		;hauteur
	dc.b 0			;ecriture
	dc.b 0			;fond noir
	dc.l $200		;drapeau idcmp(message:ferme fenetre)

	dc.l $1000!8!4!2!1		;activer fermer
	dc.l 0			;pas de premiere cellule
	dc.l 0			;
	dc.l Windowtitre	;titre
	dc.l 0			;adresse de l'ecran
	dc.l 0			;adresse bitmap
	dc.w 100		;largeur minimale
	dc.w 50			;hauteur minimale
	dc.w 640		;largeur maximale
	dc.w 250		;hauteur maximale
	dc.w 1			;type d'ecran toujours un sous WB

dosbase: 
	dc.l 0
intuibase:
	dc.l 0
winhandle:
	dc.l 0
message:
	dc.l 0
dosname:
	dc.b "dos.library",0
	even
intuiname:
	dc.b "intuition.library",0
	even
windowtitre:
	dc.b "Fenetre Example pour FLX_98",0
	even				
wintext:	
	dc.b	7	;Couleur Pen
	dc.b	3	;Couleur Fond
	dc.b 	1	;si =1 fait Mask du Fond
	dc.w	10	;Coord X en plus de celle par default
	dc.w	10	;Coord Y en plus de celle par default
	dc.l	0
	dc.l    textbuffer,wintext1
wintext1:	
	dc.b	7	;Couleur Pen
	dc.b	3	;Couleur Fond
	dc.b 	1	;si =1 fait Mask du Fond
	dc.w	20	;Coord X en plus de celle par default
	dc.w	20	;Coord Y en plus de celle par default
	dc.l	0
	dc.l    textbuffer,0


textbuffer:
	DC.B	"Coucou FREDDIX voici ta fenetre et ton texte",0


