
; From There : https://wiki.amigaos.net/wiki/Intuition_Requesters
/*
** blockinput.c -- program to demonstrate how to block the input from a
** window using a minimal requester, and how to put up a busy pointer.
*/
#include <exec/types.h>
#include <intuition/intuition.h>
 
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
 
/* our function prototypes */
BOOL beginWait(struct Window *win, struct Requester *waitRequest);
VOID endWait(struct Window *win, struct Requester *waitRequest);
VOID processIDCMP(struct Window *win);
 
struct IntuitionIFace *IIntuition;
 
/* data for a busy pointer. */
uint16 waitPointer[] =
    {
    0x0000, 0x0000,     /* reserved, must be NULL */
 
    0x0400, 0x07C0,
    0x0000, 0x07C0,
    0x0100, 0x0380,
    0x0000, 0x07E0,
    0x07C0, 0x1FF8,
    0x1FF0, 0x3FEC,
    0x3FF8, 0x7FDE,
    0x3FF8, 0x7FBE,
    0x7FFC, 0xFF7F,
    0x7EFC, 0xFFFF,
    0x7FFC, 0xFFFF,
    0x3FF8, 0x7FFE,
    0x3FF8, 0x7FFE,
    0x1FF0, 0x3FFC,
    0x07C0, 0x1FF8,
    0x0000, 0x07E0,
 
    0x0000, 0x0000,     /* reserved, must be NULL */
    };
 
 
 
/*
** main()
**
** Open a window and display a busy-pointer for a short time then wait for
** the user to hit the close gadget (in processIDCMP()).  Normally, the
** application would bracket sections of code where it wishes to block window
** input with the beginWait() and endWait() functions.
*/
int main()
{
  struct Window *win;
 
  struct Library *IntuitionBase = IExec->OpenLibrary("intuition.library", 50);
  IIntuition = (struct IntuitionIFace*)IExec->GetInterface(IntuitionBase, "main", 1, NULL);
 
  if (IIntuition != NULL)
  {
    if (win = IIntuition->OpenWindowTags(NULL,
                        WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_INTUITICKS,
                        WA_Activate, TRUE,
                        WA_Width,  320,
                        WA_Height, 100,
                        WA_CloseGadget, TRUE,
                        WA_DragBar, TRUE,
                        WA_DepthGadget, TRUE,
                        WA_SizeGadget, TRUE,
                        WA_MaxWidth, ~0,
                        WA_MaxHeight, ~0,
                        TAG_END))
    {
      processIDCMP(win);
      IIntuition->CloseWindow(win);
    }
  }
 
   IExec->DropInterface((struct Interface*)IIntuition);
   IExec->CloseLibrary(IntuitionBase);
 
   return 0;
 }
 
 
 
/*
** beginWait()
**
** Clear the requester with InitRequester.  This makes a requester of
** width = 0, height = 0, left = 0, top = 0; in fact, everything is zero.
** This requester will simply block input to the window until
** EndRequest is called.
**
** The pointer is set to a reasonable 4-color busy pointer, with proper offsets.
*/
BOOL beginWait(struct Window *win, struct Requester *waitRequest)
{
  IIntuition->InitRequester(waitRequest);
  if (IIntuition->Request(waitRequest, win))
  {
    IIntuition->SetPointer(win, waitPointer, 16, 16, -6, 0);
    IIntuition->SetWindowTitles(win, "Busy - Input Blocked", (uint8 *)~0);
    return(TRUE);
  }
  else
    return(FALSE);
}
 
 
 
/*
** endWait()
**
** Routine to reset the pointer to the system default, and remove the
** requester installed with beginWait().
*/
VOID endWait(struct Window *win, struct Requester *waitRequest)
{
  IIntuition->ClearPointer(win);
  IIntuition->EndRequest(waitRequest, win);
  IIntuition->SetWindowTitles(win, "Not Busy", (uint8 *)~0);
}
 
 
/*
** processIDCMP()
**
** Wait for the user to close the window.
*/
VOID processIDCMP(struct Window *win)
{
  struct IntuiMessage *msg;
  struct Requester myreq;
  uint16 tick_count;
 
  BOOL done = FALSE;
 
  /* Put up a requester with no imagery (size zero). */
  if (beginWait(win, &myreq))
  {
    /*
    ** Insert code here for a window to act as the requester.
    */
 
    /* We'll count down INTUITICKS, which come about ten times
    ** a second.  We'll keep the busy state for about three seconds.
    */
    tick_count = 30;
  }
 
  while (!done)
  {
    IExec->Wait(1L << win->UserPort->mp_SigBit);
 
    while (NULL != (msg = (struct IntuiMessage *)IExec->GetMsg(win->UserPort)))
    {
      uint32 class = msg->Class;
      IExec->ReplyMsg((struct Message *)msg);
 
      switch (class)
      {
        case IDCMP_CLOSEWINDOW:
          done = TRUE;
          break;
 
        case IDCMP_INTUITICKS:
          if (tick_count > 0)
          {
            if (--tick_count == 0)
              endWait(win,&myreq);
          }
          break;
      }
    }
  }
}