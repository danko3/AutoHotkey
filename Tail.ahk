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

file = %1%  ; first input parameter
k    = %2%  ; Second input parameter

;file= Mk5_3.log
if not %k%
   k =20

; Create the sub-menus for the menu bar:
Menu, FileMenu, Add, &Open..., FMGR
Menu, FileMenu, Add, E&xit, GuiClose
Menu, OptionsMenu, Add, &Text+, BigSize
Menu, OptionsMenu, Add, &Text-, SmallSize
Menu, HelpMenu, Add, &Help   F1, Help
Menu, HelpMenu, Add, &About, HelpAbout

; Create the menu bar by attaching the sub-menus to it:
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Options, :OptionsMenu
Menu, MyMenuBar, Add, &Help, :HelpMenu
Fontsize = 10

Gui:
Gui, +Resize
Gui, font, s%fontsize%, Lucida Console
Gui, Menu, MyMenuBar
Gui, Add, edit, x0 y0 r20 w600 vMyEdit
Gui, Add, StatusBar,,
Gui, Margin, 0, 0
anchor("h600")
anchor("")
SB_SetParts( 100, 140, 70, 200)
Gui, Show, w600 h290, Tail: %file%

#Persistent
Settimer FileCheck

FileCheck:
FileReadLine, line, %file%, 1  ; dummy read to open the file (Some applications don't seem to change the filesize continuesly)
   FileGetSize Size, %file%
  If Size0 >= %Size%
    Return

 FileContents := tail(k, file)
GuiControl,, MyEdit, %FileContents%
PostMessage, 0x115, 7, 0, edit1, Tail  ; 0=1line up, 1=1line down, 2=page up, 3=page down, 7=all down (0x115 = VScroll; Edit1 = main window)
Size0 = %Size%
SB_SetText(Round(Size0 / 1024, 1) . " kB", 1)
Return


Tail(k, file) {  ; Return the last k lines of file
   Loop Read, %file%
      i := Mod(A_Index,k), L%i% := A_LoopReadLine
   Loop % k
      i := Mod(i+1,k), L .= L%i% "`n"
   Return L
}
*/
GuiEscape:
GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
  ExitApp
return


GuiSize:
  Anchor("Edit1", "hw")
Return


;########################################################################
;###### Anchor   ########################################################
;########################################################################
/*
;Function: Anchor
;Defines how controls should be automatically positioned relative to the new dimensions of a window when resized.

;Parameters:
;cl - a control HWND, associated variable name or ClassNN to operate on
a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height),
optionally followed by a relative factor, e.g. "x h0.5"
r - (optional) true to redraw controls, recommended for GroupBox and Button types

;Examples:
;> "xy" ; bounds a control to the bottom-left edge of the window
;> "w0.5" ; any change in the width of the window will resize the width of the control on a 2:1 ratio
;> "h" ; similar to above but directly proportional to height

;Remarks:
;To assume the current window size for the new bounds of a control (i.e. resetting) simply omit the second and third parameters.
;However if the control had been created with DllCall() and has its own parent window,
;the container AutoHotkey created Gui must be made default with the +LastFound option prior to the call.
;For a complete example see anchor-example.ahk.

;License:
;- Version 4.60a <http://www.autohotkey.net/~Titan/#anchor>
- Simplified BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
Anchor(i, a = "", r = false) {
    static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
    If z = 0
        VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
    If (!WinExist("ahk_id" . i)) {
        GuiControlGet, t, Hwnd, %i%
        If ErrorLevel = 0
            i := t
        Else ControlGet, i, Hwnd, , %i%
      }
    VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
            , giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
    If (gp != gpi) {
        gpi := gp
        Loop, %gl%
            If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
                gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
                Break
              }
        If (!gf)
            NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
      }
    ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
    Loop, %cl%
        If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
            If a =
              {
                cf = 1
                Break
              }
            giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
                    , cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
            Loop, Parse, a, xywh
                If A_Index > 1
                    av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
                        , d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
            DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
                    , "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
            If r != 0
                DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
            Return
          }
    If cf != 1
        cb := cl, cl += cs
    bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
    If cf = 1
        dw -= giw - gw, dh -= gih - gh
    NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
            , NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
    Return, true
  }

;;;;;;;;;;;;;;;;;;;;;;;;;
; Buttons
;;;;;;;;;;;;;;;;;;;;;;;;;
~*F1::
Help:
  Run, %A_ScriptDir%\PN.chm
Return

HelpAbout:
  ;Gui, 2:+owner1  ; Make the main window (Gui #1) the owner of the "about box" (Gui #2).
  Gui +Disabled  ; Disable main window.
  Gui, 2:Add, Text,, Tail Version %Version%`n`nDate: April 2012`nAutoHotkeyL Version: %A_AhkVersion% `nAuthor: H. Tenkink
  Gui, 2:Add, Button, Default y70, OK
  Gui, 2:Show, h100
Return

2GuiClose:
2ButtonOK:
  Gui, 1:-Disabled
  Gui, 2:Destroy
Return

FMGR:
FileSelectFile, File
Gui, Show, w600 h290, Tail: %file%
return

Options:

return

BigSize:
fontsize++
Gui, font, s%fontsize%, Lucida Console
GuiControl, Font, Edit1
return

SmallSize:
EnvSub, fontsize, 1
Gui, font, s%fontsize%, Lucida Console
GuiControl, Font, Edit1
return