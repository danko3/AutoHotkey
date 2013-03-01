; quick and dirty testfile creator
size = 50   ; <---- edit!  50 x 50 array
xmin  = -20  ; <---- edit!  function range
xmax  =  20  ; <---- edit!  function range
func = sinc  ; <---- edit!  'sinc' or 'normal'

sd = 0.3  ;  standard deviation
pi = 3.14159265
xdif := xmax - xmin
xstep := xdif/size

; filename is [func][size].csv
file := func . size . .csv
FileDelete, %file%

loop, %size%
{
  y := A_Index
	yg := A_Index*xstep+xmin
loop, %size%
{
	x := A_Index
	xg := A_Index*xstep+xmin
	q := sqrt(xg**2+yg**2)
	
	if func = sinc
      z := sinc(q)
	if func = normal
	   normal(q)	
FileAppend, %z%`, , %file%
}
FileAppend, %z%`n , %file%
}
return


;
; Math Functions
; 
normal(q)
{
    z := (1/sqrt(2*pi*sd))*exp(-0.5*((q/sd)**2))  ;  create a normal distribution
	return, z
}

sinc(q)
{
	if q<>0
	z:= sin(q)/q  ; create a sinc function
	else
	z = 1
	return, z
}