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
make color scales, contourplot?
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


PlotFile = volcano1.txt

graph = grapher1.ahk

If not FileExist(Plotfile)
  {
    MsgBox, Datafile %Plotfile% missing
    ExitApp
  }
If not FileExist(graph)
  {
    MsgBox, File %graph% missing
    ExitApp
  }
;write to the array
Array := Object()
Loop, Read, %PlotFile%
  {
    Array.Insert(A_LoopReadLine) ; Append this line to the array.
    xw := A_Index
  }

ymax = 0
ymin = 100000
;read from array
for index, element in Array ; Recommended approach in most cases.
{
  Loop, Parse, element , CSV
    {
      yl := A_Loopfield
      yh := A_Index
      {
        If (ymax < yl)
            ymax := yl
        If (ymin > yl)
            ymin := yl
      }
}
}

ydif :=Ymax-ymin
;MsgBox, xw=%xw% yh=%yh%ymin=%ymin% ydif=%ydif%
; sanety check
If Ydif not Between 0.0005 and 2500.0
  {
    MsgBox,16,Error message, Data of file %PlotFile% out of Range`n`n Min = %Ymin%`n`n Max= %Ymax%
    ExitApp
  }

; Plot window size (real estate)
StartHeight  := 500
StartWidth   := 500
If xw>500
    StartWidth   := xw
If yh>500
    StartHeight  := yh

TopMargin     = 20
BottomMargin  = 60
LeftMargin    = 60
RightMargin  := 30
WindowWidth  := StartWidth+LeftMargin+RightMargin
WindowHeight := StartHeight+TopMargin+BottomMargin
LegendaPos   := StartHeight+TopMargin+0
;ylabel       := Round(ydif/StartHeight,4)
Y_Pos_top_X_Label           := TopMargin-20
Y_Pos_Bottom_X_Label        := TopMargin+StartHeight+5
X_Pos_Left_Y_Label          := LeftMargin-35
xSpace:=Round(xw/10)

#Include grapher4.ahk

DetectHiddenWindows On
OnExit GuiClose
Gui Add,Progress, h0
Process Exist
WinGet ScriptID,ID,ahk_pid %ErrorLevel%
Gui, +Resize

; the dummy characters are used to wipe the edges of the plot window
Gui, font, s900 Cd4d0c8 ; make the characters 'dummy' inVisible
Gui Add,text, x-30, dummy
Gui, font


; X_labels initialize
;Gui Add,text, x-30 vxlab0, 0
Loop, %xw%
  {
    If !Mod(A_Index,xSpace) ; Label every 10 units
        Gui Add,text, x-30 vxlab%A_Index%, ^%A_Index%
  }

; Y_labels initialize
Gui Add,text, x-60 w30 +Right vylab0, 0  ; x-60 is left off Screen
Loop, %yh%
  {
    If !Mod(A_Index,xSpace) ; Label every 10 units
        Gui Add,text, x-60 vylab%A_Index% w30 +Right, %A_Index% >  ; x-60 is left off Screen
  }

Gui Show, W%WindowWidth% h%WindowHeight%,Results
Return

GuiSize:  ; Launched when the window is resized, minimized, maximized, or restored.
  If A_EventInfo = 1  ; The window has been Minimized.  No action needed.
      Return
  GraphDestroy()

  Plotwidth := A_GuiWidth - LeftMargin-RightMargin
  Plotheight := A_GuiHeight-TopMargin-BottomMargin
  LabelposX := A_GuiWidth/2
  LabelposY := A_GuiHeight-50

  ;dummy labels
  dummxpos := A_GuiWidth-RightMargin
  dummypos := A_GuiHeight-BottomMargin
  GuiControl, move, dummy, x0 y%DummyPos% w%A_ScreenWidth% ; the Bottom dummy
  GuiControl, move, dummy, x%DummxPos% y%TopMargin% h%A_ScreenHeight% ; the Right dummy

  ; X_labels (Bottom)
  ypos := dummypos+5
  lw_1 := PlotWidth/xw
  lw_2 := LeftMargin-lw_1/2
  Loop, %Plotwidth%
    {
      xpos := lw_1*A_Index+lw_2
      GuiControlGet, name,,xlab%A_Index%
      If name
          GuiControl, move, %name%, x%xPos% y%yPos%
    }
  ; Y-labels
  lh_1 := PlotHeight/yh
  lh_2 := TopMargin-lh_1/2-7
  Loop, %PlotHeight%
    {
      pos := lh_1*A_Index +lh_2
      GuiControlGet, name,,ylab%A_Index%
      If name
          GuiControl, movedraw, %name%, x%X_Pos_Left_Y_Label% y%Pos%
    }

  GraphCreate(ScriptID,LeftMargin,TopMargin,PlotWidth,PlotHeight,"GraphOpt_")

  for index, element in Array
  {
    x := A_Index *__graph_lineWidth*plotWidth/StartWidth
    xleft := x-__graph_lineWidth*plotWidth/StartWidth-1
    Y_value := __graph_lineWidth*plotHeight/StartHeight

    SetFormat, IntegerFast, H ; We're talking Hex now.
    Loop, Parse, element , CSV
      {
        y := A_Index /xw*plotHeight
        ytop := y-Y_value-1
        z :=  Round(255/ydif*(A_Loopfield-ymin)) ; Autoscale the Z values
        z += 0  ; Sets A_Loopfield (which previously contained e.g. 11) to be 0xB.
        z := SubStr(z, 3) ;  This removes 0x.
        z := SubStr("0" . z, -1) ;This pads the Number with a 0.
        Color := "0x" . z . z . z  ; make a greyscale plot
        Pen := DllCall("CreatePen", UInt,0, UInt,0, UInt, Color)
        DllCall("SelectObject", UInt,__graph_MemoryDC, UInt,Pen)
        Brush := DllCall("CreateSolidBrush", UInt, Color) ; a pen AND a brush is needed to prevent Screendoor effect.
        DllCall("SelectObject", UInt,__graph_MemoryDC, UInt,Brush)
        DllCall("Rectangle", UInt,__graph_MemoryDC, UInt, xleft, UInt, ytop, UInt, x, UInt, y)
        DllCall("DeleteObject", UInt,Pen)
        DllCall("DeleteObject", UInt,Brush)
      }
  }
GraphDraw() ;

SetFormat, IntegerFast, d ; We're talking decimal now.
;MsgBox, x= %x% xleft= %xleft% linewidth=%__graph_lineWidth%
duration := A_TickCount - Start ; timer
Return

; terminate script
quit:

GuiEscape:
  GraphClear()
  ;return

  MsgBox, That took %duration% mSeconds
GuiClose:
  GraphDestroy()
  ExitApp
