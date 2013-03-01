/*
LinePlot.ahk v1.0
 by danko

Simple plotting program.
Makes an XY line plot from CSV file
Needs Grapher.ahk by jonny, hacked by me
to get labels and tics and renamed to grapher1.ahk
It started as a simple plotting routine for real-time
plots of data from my Velleman k8055 board
Written to prove that you can make a plotting program
in Autohotkey without external libraries or programs.
In fact jonny did that already, but now not to plot functions
but 'real' data from a file.
Feel free to improve and comment.
 
 needs:
 ������
 - Grapher1.ahk
 - An ASCII datafile. (now 8055.log (line 49))
 
*/

/*
To Do:
������
Improve code!!! (learn to program)
more testing more general,
resizing, zooming, you name it
See also GreyPlot.ahk
*/

/*
Revision History
����������������
# v[#].[#] ([yyyy]-[mm]-[dd])
* initial release
*/

/*
********** Settings, Variable Declarations **********
*/

#SingleInstance Force
#NoEnv
OnExit, quit

; k8055.log added as a real world example
PlotFile = k8055.log ; real values
Graph = grapher1.ahk
if not FileExist(Plotfile)
{
  MsgBox,16,Error, Datafile %Plotfile% missing
ExitApp
}
; The plotfile is assumed to be a CSV file with three columns:
; The first are timestamps the second and third are measured values.
; The values are between 0 and 255

chan=2  ; the channel to plot
chan += 1 ; the column to plot
ymax = 0
ymin = 100000

if not FileExist(graph)
{
  MsgBox,16,Error, File %graph% missing
ExitApp
}
; First read the file to see the size and the values
Array := Object()
Loop, read, %PlotFile%
{
	Array.Insert(A_LoopReadLine) ; Append this line to the array.
}
for index, element in Array
{
	x_A := A_Index ; used in Grapher1 to determine the plotwidth
	Loop, parse, element , CSV
	{
	  yl := A_Loopfield
	  if A_Index = %chan%
	 {
		if (ymax < yl)
		ymax := yl 
		if (ymin > yl)
		ymin := yl
	 }
	}		 
}

Ydif := Ymax-Ymin
; sanety check
if Ydif not between 0.0005 and 2500.0
{
	MsgBox,16,Error message, Data of file %PlotFile% out of range`n`n Min = %Ymin%`n`n Max= %Ymax%
	ExitApp
}
; Try to make some decent scaling.
; We don't want e.g. 4.327 units/tic
; But only 2.5, 5 or 10
y5 := 500, y10 := 1000, y25 := 2500
;MsgBox, ymin=%ymin% ymax=%ymax% ydif=%ydif% 

if (Ydif < y25/10)  ; 2500
	y5  := y5/10,   Y10 := Y10/10,	Y25 := Y25/10,	round := 1 ; (round is just a guess)
if (Ydif < y25/10)  ; 250
	y5  := y5/10,	Y10 := Y10/10,	Y25 := Y25/10,	round := 10
if (Ydif < y25/10)  ; 25
	y5  := y5/10,	Y10 := Y10/10,	Y25 := Y25/10,	round := 10
if (Ydif < y25/10)  ; 2.5
	y5  := y5/10,	Y10 := Y10/10,	Y25 := Y25/10,	round := 100
if (Ydif < y25/10)   ; 0.25
	y5  := y5/10,	Y10 := Y10/10,	Y25 := Y25/10,	round := 100
if (Ydif < y25/10)  ; 0.025
	y5  := y5/10,	Y10 := Y10/10,	Y25 := Y25/10,	round := 1000
;MsgBox, y5= %y5%
if (Ydif < Y5)
	Ydif := Y5
else if (Ydif < Y10)
	Ydif := Y10
else
	Ydif := Y25


; ymin = bottom of plot area
; ydif = top of plotarea - ymin
Ymin := floor(ymin*round)/round

#include grapher1.ahk ; include jonny's modified grapher

DetectHiddenWindows On
Process Exist
WinGet ScriptID,ID,ahk_pid %ErrorLevel%
Gui Show, W%WindowWidth% h%WindowHeight%,Results of %PlotFile% ;dimensions from Grapher1
GraphCreate(ScriptID,LeftMargin,TopMargin,PlotWidth,PlotHeight,"GraphOpt_")

if chan = 2 ; create a red pen
Pen := DllCall("CreatePen", UInt,0, UInt,__graph_lineWidth, UInt,0x0000FF)
if chan = 3  ; create a green pen
Pen := DllCall("CreatePen", UInt,0, UInt,__graph_lineWidth, UInt,0x00AA00)
DllCall("SelectObject", UInt,__graph_MemoryDC, UInt,Pen)
py := round(Plotheight/ydif,0)

; read the array to plot
for index, element in Array
{
  x := A_Index
  Loop, parse, element , CSV
	{
	if A_Index = 1   ; The first column (timestamps)
	 {       ; write timestamps @ bottom X-axis
		time := A_Loopfield
		if x = 1 ; the first time label
		    Gui Add,text, x%LeftMargin% y%Y_Pos_bottom_X_label% +Center, %time%
		if !mod(x,100) ; the rest of the time labels
		 {
			pos := x+LeftMargin
		    Gui Add,text, x%pos%  y%Y_Pos_bottom_X_label% +Center, %time% 
	     }
	 }
	  if A_Index = %chan%
	   {
	    Y := PlotHeight-(A_Loopfield-ymin)*Py  ; autoscaling Y
		if (x = 1)
        DllCall("MoveToEx", UInt,__graph_MemoryDC, UInt, X, UInt, Y, UInt, 0)
        else
		DllCall("LineTo", UInt,__graph_MemoryDC, UInt, X, UInt, Y)
	   }
	   ;GraphDraw() ; draw every single point
	}		
}
GraphDraw() ; draw the plot in one time
return

; terminate script
quit:
 
GuiEscape:
GraphClear()
;return

GuiClose:
GraphDestroy()
ExitApp

/*
; part of 8055.log as example
14:47:24,054.51,018.18
14:47:34,054.50,018.17
14:47:44,054.50,018.17
14:47:53,054.51,018.16
14:48:03,054.50,018.15
14:48:12,054.49,018.13
14:48:22,054.52,018.07
14:48:32,054.50,017.96
14:48:41,054.50,017.72
14:48:51,054.50,017.54
14:49:00,054.50,017.36
14:49:10,054.48,017.28
14:49:20,054.50,017.23
14:49:29,054.49,017.21
14:49:39,054.50,017.19
14:49:48,054.50,017.17
14:49:58,054.48,017.15
14:50:08,054.51,017.12
14:50:17,054.50,017.09
14:50:27,054.49,017.03
*/
