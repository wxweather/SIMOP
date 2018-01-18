#!/bin/bash 
#--------------------------------------------------------------------
#
#  Gera produtos com os dados de SST 
#


#./sst_opera.sh 

if [ "$1" = "" ];then 
	nb=1500
	nm=500
	else
	nb=$1
	nm=$2 
fi
	

echo "dset ../../../OBS/OISST/OISST_%y4%m2%d2.nc" > sst2.ctl
echo "title xxxxxx" >>sst2.ctl 
echo "options template " >>sst2.ctl 
echo "undef 9.999e+20 " >>sst2.ctl 
echo "dtype netcdf" >>sst2.ctl 
echo "xdef 360 linear -0.5 1" >>sst2.ctl 
echo "ydef 180 linear -89.5 1" >>sst2.ctl 
echo "zdef 1 linear 0 1" >>sst2.ctl 
echo "tdef 427 linear 00Z01NOV1981 7dy" >>sst2.ctl 
echo "vars 1" >>sst2.ctl 
echo "tmpsfc=>tmpsfc  0  t,y,x  ** surface Temp. [K]" >>sst2.ctl 
echo "endvars" >>sst2.ctl 
echo "'open sst2.ctl'" > script2.gs
echo 'pi=sstcalc( 1,427,"sst_semanal_anos80.prn")'  >>script2.gs
echo "'close 1'" >>script2.gs
cat sst_opera.gs >>script2.gs 
grads -lbc "script2.gs"
	
echo "dset ../../../OBS/OISST/OISST_%y4%m2%d2.nc" > sst1.ctl
echo "title xxxx" >>sst1.ctl 
echo "options template " >>sst1.ctl
echo "undef 9.999e+20 " >>sst1.ctl 
echo "dtype netcdf" >>sst1.ctl 
echo "xdef 360 linear -0.5 1" >>sst1.ctl 
echo "ydef 180 linear -89.5 1" >>sst1.ctl 
echo "zdef 1 linear 0 1" >>sst1.ctl 
echo "tdef $nb linear 00Z03JAN1990 7dy" >>sst1.ctl 
echo "vars 1" >>sst1.ctl 
echo "tmpsfc=>tmpsfc  0  t,y,x  ** surface Temp. [K]" >>sst1.ctl 
echo "endvars" >>sst1.ctl 
echo "'open sst1.ctl'" > script1.gs
echo 'pi=sstcalc( 1,'$nb',"sst_semanal_anos90.prn")'  >>script1.gs
echo "'close 1'" >>script1.gs
cat sst_opera.gs >>script1.gs 
grads -lbc "script1.gs"



echo "dset ../../../OBS/OISST/OISST_MENSAL_%y4%m2.nc" > sst.ctl
echo "title " >>sst.ctl 
echo "options template " >>sst.ctl 
echo "undef 9.999e+20 " >>sst.ctl 
echo "dtype netcdf" >>sst.ctl 
echo "xdef 360 linear -0.5 1" >>sst.ctl 
echo "ydef 180 linear -89.5 1" >>sst.ctl 
echo "zdef 1 linear 0 1" >>sst.ctl 
echo "tdef $nm linear 00Z01NOV1981 1mo" >>sst.ctl 
echo "vars 1" >>sst.ctl 
echo "tmpsfc=>tmpsfc  0  t,y,x  ** surface Temp. [K]" >>sst.ctl 
echo "endvars" >>sst.ctl 
echo "'open sst.ctl'" > script
echo 'pi=sstcalc( 1,'$nm',"sst_mensal.prn")'  >>script.gs
echo "'close 1'" >>script.gs

cat sst_opera.gs >>script.gs 
grads -lbc "script.gs"



cat sst_semanal_anos80.prn sst_semanal_anos90.prn > sst_semanal.prn 
grads -lbc "regioes_nino_clima.gs" 
matlab -nodisplay -nodesktop -r "run toexcel.m" 
