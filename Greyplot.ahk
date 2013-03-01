/*
Greyplot v1.0
 by danko

Greyplot makes grayscale plots of a CSV file
the file is an array of X . Y points where the values
are the intensities (Z values)
Needs Grapher.ahk by jonny, hacked by me
to get tics and renamed to grapher2.ahk
It started as a simple plotting routine for real-time
plots of data from my Velleman k8055 board
Written to prove that you can make a plotting program
in Autohotkey without external libraries or programs.
In fact jonny did that already, but now not to plot functions
but 'real' data from a file.
*/

/*
To Do:
¯¯¯¯¯¯
make color scales, resizing?
*/

/*
Revision History
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# v[#].[#] ([yyyy]-[mm]-[dd])
* initial release
*/

/*
********** Settings, Variable Declarations **********
*/

#SingleInstance Force
#NoEnv
OnExit, quit

Start := A_TickCount  ; timer


PlotFile = sinc16.csv
if not FileExist(Plotfile)
{
  MsgBox, Datafile %Plotfile% missing
ExitApp
}
;write to the array
Array := Object()
Loop, read, %PlotFile%  
{
	Array.Insert(A_LoopReadLine) ; Append this line to the array.
}
ymax = 0
ymin = 100000
;read from array
for index, element in Array ; Recommended approach in most cases.
{
	xw := A_Index
	Loop, parse, element , CSV
	{
	  yl := A_Loopfield
	  yh := A_Index
	{
		if (ymax < yl)
		ymax := yl 
		if (ymin > yl)
		ymin := yl
	 } 
	}
}

ydif :=Ymax-ymin
; sanety check
if Ydif not between 0.0005 and 2500.0
{
	MsgBox,16,Error message, Data of file %PlotFile% out of range`n`n Min = %Ymin%`n`n Max= %Ymax%
	ExitApp
}

; Plot window size (real estate)
Height   := 600
Width    := 600  ;round(x + x/10,-2)

;linewidth of graphs
__graph_lineWidth := Height/(yh-1)

#include grapher2.ahk

DetectHiddenWindows On
OnExit GuiClose
Process Exist
WinGet ScriptID,ID,ahk_pid %ErrorLevel%
Gui Show, W%WindowWidth% h%WindowHeight%,Results
GraphCreate(ScriptID,LeftMargin,TopMargin,Width,Height,"GraphOpt_")

for index, element in Array
{
  x := A_Index *__graph_lineWidth
  xleft := x-__graph_lineWidth-1
  SetFormat, IntegerFast, H ; We're talking Hex now.
  Loop, parse, element , CSV
	{
		y := A_Index *__graph_lineWidth
		ytop := y-__graph_lineWidth-1
		z :=  round(255/ydif*(A_Loopfield-ymin)) ; Autoscale the Z values
        z += 0  ; Sets A_Loopfield (which previously contained e.g. 11) to be 0xB.
        z := SubStr(z, 3) ;  This removes 0x.
        z := SubStr("0" . z, -1) ;This pads the number with a 0.
		color := "0x" . z . z . z  ; make a greyscale plot
    
   Pen := DllCall("CreatePen", UInt,0, UInt,0, UInt, Color)
   DllCall("SelectObject", UInt,__graph_MemoryDC, UInt,Pen)
   Brush := DllCall("CreateSolidBrush", UInt, Color) ; a pen AND a brush is needed to prevent screendoor effect.
   DllCall("SelectObject", UInt,__graph_MemoryDC, UInt,Brush)
   DllCall("Rectangle", UInt,__graph_MemoryDC, UInt, xleft, UInt, ytop
      , UInt, x, UInt, y)
   DllCall("DeleteObject", UInt,Pen)
   DllCall("DeleteObject", UInt,Brush)
	}		
}
SetFormat, IntegerFast, d ; We're talking decimal now.
GraphDraw()
duration := A_TickCount - Start ; timer
return

; terminate script
quit:
 
GuiEscape:
GraphClear()
;return

MsgBox, That took %duration% mseconds
GuiClose:
GraphDestroy()
ExitApp