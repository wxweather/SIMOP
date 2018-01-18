#!/bin/bash
#----------------------------------------------------------------------------------------------
# MODULO PARA BAIXAR DADOS DE CHUVA OBSERVADA EM GRADE 
#
#  
#
#---------------------------------------------------------------------------------------------

#function datagrads(ano,mes,dia,hora) 
function geradatagrads () 
{
case $2 in 
01) 
mesx="JAN"
;;
02)
mesx="FEB" 
;;
03)
mesx="MAR"
;;
04)
mesx="APR"
;;
05)
mesx="MAY"
;;
06)
mesx="JUN"
;;
07)
mesx="JUL"
;;
08)
mesx="AUG"
;;
09)
mesx="SEP"
;;
10)
mesx="OCT"
;;
11)
mesx="NOV"
;;
12)
mesx="DEC"
;;
esac 

datadograds=$4"Z"$3$mesx$1
echo $datadograds 
}




	
	
get_cpc_0p50()
{

## 
#
#-------------------------------------------------------------------------------
#                    CPC_GAUGE_0P50
#-------------------------------------------------------------------------------
#  baixa dados do CPC_GAUGE 0.50 graus 
#
#
# get_cpc_0p50 NDD 
#
# OPÇAÕ PARA RODAR PARA UMA DATA DIFERENTE DA DE HOJE
#






DATABASE="../../OBS"  
DATABASECPC=$DATABASE"/CPC_GAUGE_0P50"
mkdir $DATABASECPC     >>$LOG 2>&1
cd $DATABASECPC
echo "BAIXANDO CPC_GAUGE_0P50"
echo "          INICIO:"`date +"%Y%m%d %H:%M"`
echo "BAIXANDO CPC_GAUGE_0P50" >$LOG 2>&1 
echo "          INICIO:"`date +"%Y%m%d %H:%M"` >>$LOG 2>&1 
#
# atualiza banco de dados
#
#
# baixa as 63 ultimas chuvas. se jรก baixou passa adiante. 
#
for n in `seq --format=%02g 1 $1`
do
    download_data=`date -d "$n days ago" +"%Y%m%d"`
    ano=`date -d "$n days ago" +"%Y"`
	
    file="PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx."$download_data".RT"
    filenc="CHUVACPC_0P50_"$download_data".nc" 
	
	 if [ -f "$filenc" ] 
   then 
    echo " ja existe:"$filenc
    else 
	
    wget -nc ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/$ano/$file  >>$LOG 2>&1  
    #
    # cria data do grads para por no ctl
    # 
    #datagrads=`geradatagrads $ano $mes $dia $hora`
	datagrads=`date +"%HZ%d%h%Y" -d "$ndias hours ago"`
    #
    # cria o ctl 
    #
   
    echo "dset ^"$file > cpc.ctl 
    echo "options  little_endian ">> cpc.ctl
    echo "title global daily analysis (grid box mean, the grid shown is the center of the grid box)">> cpc.ctl
    echo "undef -999.0">> cpc.ctl
    echo "xdef 720 linear    0.25 0.50">> cpc.ctl  
    echo "ydef 360  linear -89.75 0.50">> cpc.ctl
    echo "zdef 1 linear 1 1">> cpc.ctl
    echo "tdef 1 linear "$datagrads" 1dy">> cpc.ctl
    echo "vars 2">> cpc.ctl  
    echo "rain     1  00 the grid analysis (0.1mm/day)">> cpc.ctl
    echo "gnum     1  00 the number of stn">> cpc.ctl
    echo "ENDVARS">> cpc.ctl
   #
   # cria o script do grads para criacao do netcdf
   #
  
   echo "'open cpc.ctl'"     > temp.gs
   echo "'set lon 280 330'"  >> temp.gs
   echo "'set lat -35 10'"   >> temp.gs
   echo "'lats4d -vars rain -o "$filenc" '"           >>temp.gs
   #echo "'lats4d -o "$filenc" -freq 1 hourly -func sum(@,t-1,t+1)'"           >>temp.gs
   echo "'quit'"                          >>temp.gs
  #
  #  executa o grads
  #
  grads -lbc "temp.gs"  >>$LOG 2>&1 
  rm $file 
  fi 
done 
echo "          FINAL:"`date +"%Y%m%d %H:%M"`
} 





get_merge()
{
#-------------------------------------------------------------------------------
#                    MERGE
#-------------------------------------------------------------------------------
DATABASE="../../OBS"  
DATABASEMERGE=$DATABASE"/MERGE_0P25"
mkdir $DATABASEMERGE  >$LOG 2>&1


echo "BAIXANDO MERGE"
echo "          INICIO:"`date +"%Y%m%d %H:%M"`

cd $DATABASEMERGE 
for n in `seq --format=%02g 0 $1`
do
download_data=`date +"%Y%m%d" -d "$n days ago"`
ano=`date +"%Y" -d "$n days ago"`
wget -nc ftp1.cptec.inpe.br/modelos/io/produtos/MERGE/$ano/prec_$download_data".bin" >>$LOG 2>&1 
done
echo "          FINAL:"`date +"%Y%m%d %H:%M"`


}



get_cmorph_25km()
{






#---------------------------------------------------------------------------------
#
#CMORPH 25 KM - versao arquivos diarios não real time 
# 
# versao 1.0 em 10/2017  
#
#----------------------------------------------------------------------------------
DATABASE="../../OBS"  

DATABASECMORPH=$DATABASE"/CMORPH"





mkdir $DATABASECMORPH   >>$LOG 2>&1

echo "BAIXANDO CMORPH"
echo "          INICIO:"`date +"%Y%m%d %H:%M"`
cd $DATABASECMORPH
for ndias in `seq $1 -1 1`
do
anomesdiahora=`date +"%Y%m%d" -d "$ndias days ago"`
ano=`date +"%Y" -d "$ndias days ago"`
mes=`date +"%m" -d "$ndias days ago"`
h=`date +"%H" -d "$ndias days ago"`


file="CMORPH_V0.x_RAW_0.25deg-DLY_00Z_"$anomesdiahora
filegz="CMORPH_V0.x_RAW_0.25deg-DLY_00Z_"$anomesdiahora".gz"
filenc="CHUVA25KM_DIARIO_"$anomesdiahora".nc"  
site="ftp://ftp.cpc.ncep.noaa.gov/precip/CMORPH_V0.x/RAW/0.25deg-DLY_00Z/"
ftppath=$site$ano"/"$ano$mes"/"$filegz


if [ -f "$filenc" ]
then
	echo "$filenc ja existe"
else
    if [  -f "$filegz" ]
	then
	    echo " Arquivo ainda nao disponivel"
	else
	 
    wget -nc $ftppath         >>$LOG 2>&1 
	gzip -d -f $filegz        >>$LOG 2>&1 
    #
    # cria data do grads para por no ctl
    # 
    #datagrads=`geradatagrads $ano $mes $dia $hora`
	datagrads=`date +"%HZ%d%h%Y" -d "$ndias hours ago"`
   #
   # cria o ctl 
   #
   
   echo "DSET ^"$file                     >temp.ctl 
   echo "OPTIONS little_endian"                                                              >>temp.ctl                        
   echo "UNDEF -999.0"                                                                       >>temp.ctl
   echo "TITLE CMORPH precipitation estimates"                                               >>temp.ctl
   echo "XDEF 1440 LINEAR   0.125 0.25"                                         >>temp.ctl
   echo "YDEF  480 LINEAR -59.875 0.25"                                         >>temp.ctl
   echo "ZDEF   01 LEVELS   1"                                                               >>temp.ctl
   echo "TDEF  1 LINEAR "$datagrads" 30mn"                                                    >>temp.ctl
   echo "VARS 1"                                                                             >>temp.ctl
   echo "cmorph   1   99   CMORPH precipitation estimates [mm/hr]"                           >>temp.ctl
   echo "ENDVARS"                                                                            >>temp.ctl
  #
  # cria o script do grads para criacao do netcdf
  #
  echo "'open temp.ctl'"     > temp.gs
  echo "'set lon 280 330'"  >> temp.gs
  echo "'set lat -35 10'"   >> temp.gs
  echo "'lats4d -o "$filenc" '"           >>temp.gs
  #echo "'lats4d -o "$filenc" -freq 1 hourly -func sum(@,t-1,t+1)'"           >>temp.gs
  echo "'quit'"                          >>temp.gs
  #
  #  executa o grads
  #
  grads -lbc "temp.gs"  >>$LOG 2>&1
  #
  # apaga arquivo dezipado
  #
  rm $file    >>$LOG 2>&1
  rm $filegz  >>$LOG 2>&1
  fi 

fi
done
echo "          FINAL:"`date +"%Y%m%d %H:%M"`
cd $WORK


}

get_cmorph_08km()
{




#---------------------------------------------------------------------------------
#
# CMORPH 8 KM  - versao baixar ultinos n dias.
#----------------------------------------------------------------------------------

DATABASE="../../OBS"  
DATABASECMORPH8km=$DATABASE"/CMORPH8km"
mkdir $DATABASECMORPH8km   >>$LOG 2>&1
echo "BAIXANDO CMORPH 8km"
echo "          INICIO:"`date +"%Y%m%d %H:%M"`
cd $DATABASECMORPH8km


for ndias in `seq $1 -1 1 `
do

anomesdiahora=`date +"%Y%m%d%H" -d "$ndias hours ago"`
ano=`date +"%Y" -d "$ndias hours ago"`
mes=`date +"%m" -d "$ndias hours ago"`
h=`date +"%H" -d "$ndias hours ago"`


file="CMORPH_V0.x_RAW_8km-30min_"$anomesdiahora
filegz="CMORPH_V0.x_RAW_8km-30min_"$anomesdiahora".gz"
filenc="CHUVA08KM_"$anomesdiahora".nc"  
site="ftp://ftp.cpc.ncep.noaa.gov/precip/CMORPH_V0.x/RAW/8km-30min/"
ftppath=$site$ano"/"$ano$mes"/"$filegz
echo $ftppath >> debugao 

if [ -f "$filenc" ]
then
	echo "$filenc ja existe"
else
    
    wget -nc $ftppath         >>$LOG 2>&1 
	gzip -d -f  $filegz     >>$LOG 2>&1
    #
    # cria data do grads para por no ctl
    # 
    #datagrads=`geradatagrads $ano $mes $dia $hora`
	datagrads=`date +"%HZ%d%h%Y" -d "$ndias hours ago"`
   #
   # cria o ctl 
   #
   echo "DSET ./"$file                                                                         >temp.ctl 
   echo "OPTIONS little_endian"                                                              >>temp.ctl                        
   echo "UNDEF -999.0"                                                                       >>temp.ctl
   echo "TITLE CMORPH precipitation estimates"                                               >>temp.ctl
   echo "XDEF 4948 LINEAR   0.036378335 0.072756669"                                         >>temp.ctl
   echo "YDEF 1649 LINEAR -59.963614    0.072771377"                                         >>temp.ctl
   echo "ZDEF   01 LEVELS   1"                                                               >>temp.ctl
   echo "TDEF 2 LINEAR "$datagrads" 30mn"                                                    >>temp.ctl
   echo "VARS 1"                                                                             >>temp.ctl
   echo "cmorph   1   99   CMORPH precipitation estimates [mm/hr]"                           >>temp.ctl
   echo "ENDVARS"                                                                            >>temp.ctl
  #
  # cria o script do grads para criacao do netcdf
  #
  echo "'open temp.ctl'"     > temp.gs
  echo "'set lon 280 330'"  >> temp.gs
  echo "'set lat -35 10'"   >> temp.gs
  echo "'lats4d -o "$filenc" '"           >>temp.gs
  #echo "'lats4d -o "$filenc" -freq 1 hourly -func sum(@,t-1,t+1)'"           >>temp.gs
  echo "'quit'"                          >>temp.gs
  #
  #  executa o grads
  #
 #if [ -f "$filegz" ]
  #then
 grads -lbc "temp.gs"   >>$LOG 2>&1
  #fi 
  #
  # apaga arquivo dezipado
  #
  rm $file       >>$LOG 2>&1
  rm $filegz     >>$LOG 2>&1
  
fi
done
echo "          FINAL:"`date +"%Y%m%d %H:%M"`
cd $WORK


}

get_chirps()
{
DATABASE="../../OBS"  
DATABASECHIRPS=$DATABASE"/CHIRPS_05"
mkdir $DATABASECHIRPS  >>$LOG 2>&1
echo "BAIXANDO CHIRPS 5km"
echo "          INICIO:"`date +"%Y%m%d %H:%M"`
cd $DATABASECHIRPS


#ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRPS-2.0/global_daily/netcdf/p05/
#ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRPS-2.0/global_daily/netcdf/p05/chirps-v2.0.2017.days_p05.nc


site="ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRPS-2.0/global_daily/netcdf/p05/" 
filenc="chirps-v2.0."$1".days_p05.nc" 
if [ -f $filenc ]
then
	  rm filenc 
      wget $site$filenc 
else
      wget $site$filenc 
fi 
cd $WORK


DATABASE="../../OBS"  
DATABASECHIRPS=$DATABASE"/CHIRPS_25"
mkdir $DATABASECHIRPS  >>$LOG 2>&1
echo "BAIXANDO CHIRPS 25km"
echo "          INICIO:"`date +"%Y%m%d %H:%M"`
cd $DATABASECHIRPS

#ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRPS-2.0/global_daily/netcdf/p25/chirps-v2.0.2017.days_p25.nc


site="ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRPS-2.0/global_daily/netcdf/p25/" 
filenc="chirps-v2.0."$1".days_p25.nc" 
if [ -f $filenc ]
then
	  rm filenc 
      wget $site$filenc 
else
      wget $site$filenc 
fi 
cd $WORK

	  
}



#------------------------------------------------------------------
#  COMMON STUFF
#------------------------------------------------------------------
#
# inicio 
#
export LANG=en_us_8859_1
#
# onde tudo acontece 
#
cd ../../WORKDISK/
LOG="LOG_"`date +"%Y%m%d_%H"`
export WORK=`pwd`

case "$1" in 
           cpc)
           get_cpc_0p50 30  		  
           ;; 
           merge)
           get_merge 30 		  
           ;; 
           cmorph25)
           get_cmorph_25km 30		  
           ;;
		   cmorph08)
		   get_cmorph_08km 720 
		   ;;
		   chirps)
		   get_chirps 2017
		   ;;
		   *)
			get_cpc_0p50 30 
			get_merge 30
			get_cmorph_25km 30
			get_cmorph_08km 720 
			get_chirps 2017 				
		   ;;
esac 





