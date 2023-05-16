


; http://amigacoding.com/images/b/b3/Howtocode5.txt

	include "exec/exec.i"
	include "libraries/dosextens.i"

cliOrWbStartup:
    movem.l     d0/a0,-(sp)                            ; Save registers that are trashed by exec.
    clr.l       returnMsg
    move.l      #0,a1
    exeCall     FindTask
    move.l      d0,a4                                  ; a4 = pointer to the current prog task
    tst.l       pr_CLI(a4)
    bne.s       startedFromCli
startedFromWB:
    lea         pr_MsgPort(a4),a0
    exeCall     WaitPort
    lea         pr_MsgPort(a4),a0
    exeCall     GetMsg
    move.l      d0,returnMsg
startedFromCli:
    movem.l     (sp)+,d0/a0
    rts

cliOrWbFinish:
    move.l      d0,-(sp)
    tst.l       returnMsg
    beq.s       exitToDos
    exeCall     Forbid
    move.l      returnMsg,a1
    exeCall     ReplyMsg
exitToDos:
    move.l      (sp)+,d0
    rts

returnMsg:      dc.l     0
                even