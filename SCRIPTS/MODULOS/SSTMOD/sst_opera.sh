#!/bin/bash 

#
# SIMOP 3.0 
# MODULO SSTMOD
# 



#
# inicio 
#
export LANG=en_us_8859_1
#
# onde tudo acontece 
#
cd ../../WORKDISK/
LOG="LOG_"`date +"%Y%m%d_%H"`
#
# LOCAL DO BANCO DE DADOS
#
DATABASE="../../OBS"  
DATABASESST=$DATABASE"/OISST"
mkdir $DATABASESST   >>$LOG 2>&1
WORK=`pwd`
cd $DATABASESST
cp ../../SCRIPTS/MODULOS/COMMOM_STUFF/grib2ctl.pl . 




#-----------------------------------------------------------------------------------
#
# OI SST  semanal 
#-----------------------------------------------------------------------------------





site="ftp://ftp.emc.ncep.noaa.gov/cmb/sst/oisst_v2/GRIB/"

####ftp://ftp.emc.ncep.noaa.gov/cmb/sst/oisst_v2/GRIB/oisst.20171101.grb

for ndias in `seq  90 -1 1`
do
   anomesdia=`date +"%Y%m%d" -d "$ndias days ago"`
   ano=`date +"%Y" -d "$ndias days ago"`
   mes=`date +"%m" -d "$ndias days ago"`
   h=`date +"%H" -d "$ndias days ago"`
   diadasemana=`date +"%A" -d "$ndias days ago" ` 
   filegrib="oisst."$anomesdia".grb"
   filenc="OISST_"$anomesdia".nc"   
   echo $diadasemana 
   
   if [[ ($ano -lt 1990  &&  $diadasemana = "Sunday")  || ( $ano -ge 1990  && $diadasemana = "Wednesday") ]]
   then 
	   if [ -f $filenc ] 
       then 
       echo "ja existe"$filenc
        else 	   
          wget $site$filegrib
		  if [ -f $filegrib ] 
		  then 
		  
		     grib2ctl.pl $filegrib > sst.ctl 
             gribmap -i sst.ctl 
             echo "'open sst.ctl'" > sst.gs 
             echo "'set lon 0 358'" >>sst.gs 
             echo "'lats4d -vars tmpsfc -o "$filenc" '" >>sst.gs  
             echo "'quit'" >>sst.gs 	  
		     grads -lbc "sst.gs"   
		     rm $filegrib 
             rm *.idx
             rm *.tmp 
             rm *.grb    	
           fi 			 
		  
		fi
    fi 
done	
       
#-----------------------------------------------------------------------------------
#
# OI SST  mensal 
#-----------------------------------------------------------------------------------



site="ftp://ftp.emc.ncep.noaa.gov/cmb/sst/oimonth_v2/GRIB/"

####ftp://ftp.emc.ncep.noaa.gov/cmb/sst/oisst_v2/GRIB/oisst.20171101.grb

for ndias in `seq  12 -1 1`
do
   anomes=`date +"%Y%m" -d "$ndias months ago"`
   ano=`date +"%Y" -d "$ndias months ago"`
   mes=`date +"%m" -d "$ndias months ago"`
   h=`date +"%H" -d "$ndias hours ago"`
   diadasemana=`date +"%A" -d "$ndias days ago" ` 
   filegrib="oiv2mon."$anomes".grb"
   filenc="OISST_MENSAL_"$anomes".nc"   
   if [  -f $filenc ] 
   then 
   echo "ja existe"$filenc
   else 
  	   
          wget $site$filegrib
		  grib2ctl.pl $filegrib > sst.ctl 
          gribmap -i sst.ctl 
          echo "'open sst.ctl'" > sst.gs 
          echo "'set lon 0 358'" >>sst.gs 
          echo "'lats4d -vars tmpsfc -o "$filenc" '" >>sst.gs  
          echo "'quit'" >>sst.gs 	  
		  grads -lbc "sst.gs"   
		  rm $filegrib 
          rm *.idx
          rm *.tmp 
          rm *.grb    		  
		  
   fi

done	
       


