;
; AutoHotkey Version: 1.1
; Language:       English
; Platform:       Win9x/NT/XP
; Author:         H. Tenkink <tenkink@jive.nl>
;


#SingleInstance force ; If it is alReady Running it will be restarted.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode,2 ; string somewhere in titel is ok.
SetTitleMatchMode,fast  ; makes window recognition more reliable
DetectHiddenWindows, On
SetKeyDelay,0

file = MkV12

Gui:
Gui, Add, edit, x0 y0 r24 w400 vMyEdit
Gui, Add, StatusBar,,
Gui, Margin, 0, 0
SB_SetParts( 100, 100, 70, 200)
Gui, Show,,Tail: %file%

#Persistent
Settimer FileCheck

FileCheck:
   FileGetSize Size, %file%
   If Size0 >= %Size%
      Return

 FileContents := tail(20, file)
GuiControl,, MyEdit, %FileContents%
PostMessage, 0x115, 7, 0, edit1, Tail  ; 0=1line up, 1=1line down, 2=page up, 3=page down, 7=all down (0x115 = VScroll; Edit1 = main window)
Size0 = %Size%
;GuiControl, +Redraw, Tail
SB_SetText(Round(Size0 / 1024, 1) . " KB", 1)
Return


Tail(k, file) {  ; Return the last k lines of file
   Loop Read, %file%
      i := Mod(A_Index,k), L%i% := A_LoopReadLine
   Loop % k
      i := Mod(i+1,k), L .= L%i% "`n"
   Return L
}

GuiEscape:
GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
  ExitApp
return