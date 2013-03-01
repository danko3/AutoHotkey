/*
Example for using the Velleman K8055 USB experiment board.
https://en.wikipedia.org/wiki/Velleman
I wanted to use the analog inputs for monitoring purposes.
But I could not find a program who could fill my needs:
just writing the values to a file.
*/

#NoEnv
SetWorkingDir, %A_ScriptDir%

LogFile = K8055.log ; not elegant but it works


; all levels between 0-255
AnalogOutput1 = 12
AnalogOutput2 = 125
DigitalOut    = 16


hModule := DllCall("LoadLibrary", "str", "k8055d.dll")
if !hModule
{
MsgBox, 4112, Error, k8055d.dll not found
ExitApp
}

; General procedures
;DllCall("k8055d\Version")
dev := DllCall("k8055d\SearchDevices")
;MsgBox,  Found %dev% P8055
if !dev
{
	MsgBox, 4112, Error, No P8055 board found!
	ExitApp
}

Gui:
  Gui, font, s12, Courier New Bold
  gui, Add, text,, Meetpunt
  gui, Add, text,x+50, Maximum
  Gui, Add, Edit, x15 w130 vMax ,%Amount%
  Gui, Add, Edit, x+10 w130 ,%Amount%
  gui, Add, text, x15, chan1   chan2
  Gui, Add, Edit , w80 %Chan1%
  Gui, Add, Edit , w80 x+10 %Chan2%
  gui, Add, text,x15 , delay
  gui, Add, text,x+35 , Average
  Gui, add, Edit, x15 w80 vDelay, %delay%
  Gui, add, Edit, x+10 w80, %Average%
  Gui, Add, Button,x15, OK
  Gui, Add, Button, x+10, End
  Gui, Show, w300 h300, P8055-1 Velleman board
  GuiControl, Focus, Edit2
Return

ButtonOK:

chanA = 0
chanB = 0
ControlGetText, Max, edit2
ControlGetText, Average, edit6
if !Average
Average = 1
ControlGetText, Delay, edit5
if !Delay
Delay = 0

DllCall("k8055d\OpenDevice", "int", 0)
FormatTime, timestamp, A_Now, dd-MM-yyyy
FileAppend, [%timestamp%]  Chan1    Chan2    Average: %Average%  Delay: %Delay%`n, %LogFile%
Loop, %Max%
{
FormatTime, timestamp, A_Now, HH:mm:ss
Chan1 := DllCall("k8055d\ReadAnalogChannel", "int", 1)
Chan2 := DllCall("k8055d\ReadAnalogChannel", "int", 2)
 
; average the reults.

if Mod(A_Index, Average)
{
  chanA := chanA + chan1
  chanB := chanB + chan2
  }
else
{
  chanA := chanA + chan1  
  chanB := chanB + chan2
  if not Average = 1 ; No averaging so chanA/B=0
  {
  chan1 := round(chanA / (average),2)
  chan2 := round(chanB / (average),2)
}
else
{ 
  chan1 := round(chan1,2)
  chan2 := round(chan2,2)
  }
; format the output somewhat 
Chan1 := SubStr("000" . Chan1, -5) ; This pads the number with enough 00 to make its total width 5 characters.
Chan2 := SubStr("000" . Chan2, -5)

amount++  ; keep track of the numer of measurements
FileAppend, [%timestamp%]    %Chan1%   %Chan2%`n, %LogFile%
chanA = 0 ; reset the averages.
chanB = 0
ControlSetText, Edit1, %Amount%
ControlSetText, Edit3, %Chan1%
ControlSetText, Edit4, %Chan2%
ControlSetText, Edit5, %Delay%
ControlSetText, Edit6, %Average%
}
Sleep, %delay%

}


ButtonEnd:
DllCall("k8055d\CloseDevice", "int", 0)


GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
FileAppend, Total measurements: %Amount% `n, %LogFile%
MsgBox, Finished 
ExitApp