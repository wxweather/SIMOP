


'quit'

function sstcalc(t0,tf,arqout) 

t=t0
while (t<=tf)
'set t 't

'q time'
var=subwrd(result,3)
ano=substr(var,9,4)
mes=substr(var,6,3) 
dia=substr(var,4,2) 
*Time = 00Z01MAY2001 to 00Z01MAY2001  Tue to Tue


*say var 
ninoregions(1)
'd aave(tmpsfc-273.16,lon='_x1',lon='_x0',lat='_y0',lat='_y1')'
tsm1=subwrd(result,4) 


ninoregions(1.2)
'd aave(tmpsfc-273.16,lon='_x1',lon='_x0',lat='_y0',lat='_y1')'
tsm12=subwrd(result,4) 


ninoregions(2)
'd aave(tmpsfc-273.16,lon='_x1',lon='_x0',lat='_y0',lat='_y1')'
tsm2=subwrd(result,4) 

 
ninoregions(3)
'd aave(tmpsfc-273.16,lon='_x1',lon='_x0',lat='_y0',lat='_y1')'
tsm3=subwrd(result,4) 

ninoregions(4)
'd aave(tmpsfc-273.16,lon='_x1',lon='_x0',lat='_y0',lat='_y1')'
tsm4=subwrd(result,4) 

ninoregions(3.4)
'd aave(tmpsfc-273.16,lon='_x1',lon='_x0',lat='_y0',lat='_y1')'
tsm3.4=subwrd(result,4) 




ninoregions(cbm) 
'd aave(tmpsfc-273.16,lon='_x1',lon='_x0',lat='_y0',lat='_y1')'
tsmcbm=subwrd(result,4) 


if (mes = "JAN" ) ; mesx=1; endif 
if (mes = "FEB" ) ; mesx=2; endif 
if (mes = "MAR" ) ; mesx=3; endif 
if (mes = "APR" ) ; mesx=4; endif 
if (mes = "MAY" ) ; mesx=5; endif 
if (mes = "JUN" ) ; mesx=6; endif 
if (mes = "JUL" ) ; mesx=7; endif 
if (mes = "AUG" ) ; mesx=8; endif 
if (mes = "SEP" ) ; mesx=9; endif 
if (mes = "OCT" ) ; mesx=10; endif 
if (mes = "NOV" ) ; mesx=11; endif 
if (mes = "DEC" ) ; mesx=12; endif 

pi=write(arqout,ano' 'mesx' 'dia' 'tsm1' 'tsm2' 'tsm12' 'tsm3' 'tsm4' 'tsm3.4' 'tsmcbm) 

t=t+1
endwhile 
return 










function ninoregions( nino) 


if (nino =1 ) then 
*nino1
_x0=-80
_x1=-90
_y0=-10
_y1=-5
endif
if (nino =1.2 ) then 
*nino1
_x0=-80
_x1=-90
_y0=-10
_y1=0
endif


if(nino=2) then 
*nino2
_x0=-80
_x1=-90
_y0=-5
_y1=0
endif

if (nino=3) 
*nino3
_x0=-90
_x1=-150
_y0=-5
_y1=5
endif

if (nino=4)
*nino4
_x0=-150
_x1=-160
_y0=-5
_y1=5
endif 

if (nino=3.4)
*Nino3.4
_x0=-120
_x1=-170
_y0=-5
_y1=5
endif 

if (nino=cbm) 
_x1=-63
_x0=-43
_y0=-43
_y1=-33
endif 


return
