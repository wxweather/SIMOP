#!/bin/bash
#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------
#
#
# funçao bagen - baixa arquivo e gera netcdf 
#
# By Reginaldo Ventura de Sa (2017) 
#
#  bagen <MODEL> <SITE/PATH> filegrib filenc  
#  
#  ou 
#  
#  bagen <SITE/PATH> filegrib filenc   (qualuqer outro modelo) 
#
# 
#
#
#  MODEL (ate 30/11/2017)
#
#  ANAL - > processa analises do CFS e GFS. 
#  CFS   -> baixa e gera netcdf do CFS
#  CFSENS _> baixa e gera netcdf do CFS ensembles
#  
#  SITE/PATH ->  site com o caminho completo e arquivo a ser baixado
#  filegrib -> arquivo grib a ser baixado
#  filenc    _> arquivo saida netcdf 
# 
#--------------------------------------------------------------------

bagen()
{

case $1 in
	"ANAL")
		wget -nc $2
		./g2ctl.pl $3 > cfs.ctl 
		gribmap -i cfs.ctl
		echo "'open cfs.ctl'" > script.gs
		echo "'set lon 150 360'"  >>script.gs
		echo "'set lat -60 20' " >>script.gs
		echo "'lats4d -o "$4" '"           >>script.gs
		echo "'quit'" >>script.gs
		grads -lbc "script.gs" >>./LOG.prn 2>&1
		;;
	"CFS") 
		wget -nc $2
		./g2ctl.pl $3 > cfs.ctl 
		gribmap -i cfs.ctl
		echo "'open cfs.ctl'" > script.gs
		echo "'set lon 260 360'"  >>script.gs
		echo "'set lat -60 20' " >>script.gs
		echo "'lats4d -o "$4" '"           >>script.gs
		echo "'quit'" >>script.gs
		grads -lbc "script.gs" >>./LOG.prn 2>&1
		;;
	"CFSENS")
	         #

			./g2ctl.pl  $2 >cfs.ctl 
			 gribmap -i cfs.ctl   >>./LOG.prn 2>&1
			echo "'open cfs.ctl'" > script.gs
			echo "'set lon 260 360'"  >>script.gs
			echo "'set lat -60 20' " >>script.gs
			
			echo "'lats4d -levs "$levs" -vars "$vars" -o "$filenc" '"           >>script.gs
			echo "'quit'" >>script.gs
			grads -lbc "script.gs" >>./LOG.prn 2>&1
		    ;;
	*)
			wget -nc $1
		./g2ctl.pl $2 > cfs.ctl 
		gribmap -i cfs.ctl
		echo "'open cfs.ctl'" > script.gs
		echo "'set lon 280 360'"  >>script.gs
		echo "'set lat -35 10' " >>script.gs
		echo "'lats4d -o "$3" '"           >>script.gs
		echo "'quit'" >>script.gs
		grads -lbc "script.gs" >>./LOG.prn 2>&1
		;;
esac		

}

		
#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------
get_cfs_vars()
{

#---------------------------------------------------------------------------------
# BAIXA DADOS DO CFS - VERSAO 5 MESES POR VARIAVEL  
# 
#
#
# VERSAO 2.0 DESENVOLVIDA POR REGINALDO VENTURA DE SA (regis@lamma.ufrj.br) 
# --------------------------------------------------------------------------------
# 20/11/2017 - VERSAO 2.0 
#
#---------------------------------------------------------------------------------
#
# Força ter saidas em lingua inglesa
#
export LANG=en_us_8859_1

for data in `seq 0 7`
do

	#
	# pega a data de hoje 
	#
	cfsdata=`date +"%Y%m%d" -d "$data days ago" `
	#
	# define as rodadas que seroa processadas 
	#
	rodadas="00 06 12 18"
	#
	# loop das rodadas	
	#
	for rodada in $rodadas 
	do
		#
		#  cria os diretorios 
		#
		CFSDIR="../../CICC/"$cfsdata$rodada"/CFS/4MESES/"
		mkdir ../../CICC/$cfsdata$rodada
		mkdir ../../CICC/$cfsdata$rodada"/CFS/"
		mkdir $CFSDIR
		# 
		# define as variaves que serao adquiridas
		# 	 
		vars="prate tmp2m  wnd10m wnd925 wnd850 wnd500 wnd250 wnd200"
		#
		# cria um direorio para cada variavel 
		# 
		for names in $vars
		do
			mkdir $CFSDIR$names
		done 
		echo "["`date`"] ADQUIRINDO DADOS CFS" 
		for names in $vars
		do
			for ens in `seq --format=%02g 1 4`
			do
				 if [ -f  $CFSDIR$names$filenc ]
				 then
					 echo "ja  existe"
				 else
					 filegrib=$names"."$ens"."$cfsdata$rodada".daily.grb2"
					 filenc="CFS_4MESES_"$names"_"$ens"_"$cfsdata$rodada".nc" 
					 wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/time_grib_"$ens"/"$filegrib >>./LOG.prn 2>&1
					 if [ -f $filegrib ]
					 then
						 ./g2ctl.pl  $filegrib >cfs.ctl 
						 gribmap -i cfs.ctl 
						 echo "'open cfs.ctl'" > script.gs
						 echo "'set lon 150 360'"  >>script.gs
						 echo "'set lat -35 20' " >>script.gs
						 echo "'lats4d  -mxtimes 1132 -o "$filenc" '"           >>script.gs
						 echo "'quit'" >>script.gs
						 grads -lbc "script.gs"
						 mv $filenc $CFSDIR$names
					fi
				fi	  
			done 
		done
	done
done










}



#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------
get_analises()
{

data=`date +"%Y%m%d"`
if [ "$1"="" ] 
then 
rodada="00"
else
rodada=$1
fi 
DIRW="../../CICC/"$data$rodada"/ANALISES/"
mkdir ../../CICC/$data$rodada
mkdir ../../CICC/$data$rodada/ANALISES
mkdir $DIRW 
ens="01"
#
# Analise CFS
#
for ens in `seq --format=%02g 1 4`
do

	site="http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$data"/"$rodada"/6hrly_grib_"$ens"/"
	filegrib="pgbanl."$ens"."$data$rodada".grb2"
	filenc="ANALISE_CFS_"$data$rodada"_"$ens".nc" 
	bagen ANAL $site$filegrib $filegrib $filenc 
	mv $filenc $DIRW
done
#
# Analise GFS
#

site="http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs."$data$rodada"/"
filegrib0p25="gfs.t"$rodada"z.pgrb2.0p25.anl"
filegrib0p50="gfs.t"$rodada"z.pgrb2.0p50.anl"
filegrib1p00="gfs.t"$rodada"z.pgrb2.1p00.anl"
filegrib0p25b="gfs.t"$rodada"z.pgrb2b.0p25.anl"
filegrib0p50b="gfs.t"$rodada"z.pgrb2b.0p50.anl"
filegrib1p00b="gfs.t"$rodada"z.pgrb2b.1p00.anl"
filenc0p25="ANALISE_GFS_"$data$rodada"_0p25.nc" 
filenc0p50="ANALISE_GFS_"$data$rodada"_0p50.nc" 
filenc1p00="ANALISE_GFS_"$data$rodada"_1p00.nc" 
filenc0p25b="ANALISE_GFS_"$data$rodada"_0p25b.nc" 
filenc0p50b="ANALISE_GFS_"$data$rodada"_0p50b.nc" 
filenc1p00b="ANALISE_GFS_"$data$rodada"_1p00b.nc" 

bagen ANAL  $site$filegrib0p25 $filegrib0p25 $filenc0p25
bagen ANAL $site$filegrib0p50 $filegrib0p50 $filenc0p50
bagen ANAL $site$filegrib1p00 $filegrib0p00 $filenc1p00
bagen ANAL $site$filegrib0p25 $filegrib0p25 $filenc0p25
bagen ANAL $site$filegrib0p50 $filegrib0p50 $filenc0p50
bagen ANAL $site$filegrib1p00 $filegrib1p00 $filenc1p00

mv ANALISE_GFS* $DIRW 








}


#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------
get_cfs_ens()
{

#---------------------------------------------------------------------------------
# BAIXA DADOS DO CFS - VERSAO MENSAL  ENSEMBLES 
# 
# BAIXA CFS MENSAL E ARMAZENA POR ENSEMBLES 
#
#  
#
# VERSAO 2.0 DESENVOLVIDA POR REGINALDO VENTURA DE SA (regis@lamma.ufrj.br) 
# --------------------------------------------------------------------------------
# 20/11/2017 - VERSAO 2.0 
#
#---------------------------------------------------------------------------------
#
#
# força a libguagem ser inglês
#
export LANG=en_us_8859_1
#
# DEFINE AS VARIAVEIS A SEREM ADQUIRIDAS
#
# se vars e levs ="" entao pega todas as variaveis e todos os niveis (ainda não implementado. pode dar erro) 
#
export vars="-vars apcpsfc capesfc cinsfc cwatclm hgtprs gpa500mb hgttrop presmsl prestrop pwat30_0mb rhprs rh2m  rhclm spfhprs tmpprs tmptrop  ugrdprs vgrdprs ugrdtrop vgrdtrop vvelprs   "  
export levs="-levs 100000 92500 85000 70000 50000 25000 20000 1000 "

echo "["`date`"] ADQUIRINDO DADOS CFS" 
#
# VARRE OS ULTIMOS 7 DIAS 
#
for day in `seq 0 $1`
do
		#
		# TODAS AS RODADAS SAO ARMAZENADAS NO MESMO DIRETORIO FORMANDO ASSIM 28 MEMBROS DE ENSEBLES
		#
		cfsdata=`date +"%Y%m%d" -d "$day day ago" `
		# if [ "$1"="" ] 
        # then 
          rodada="00"
        # else
           # rodada=$1
        # fi 
		CFSDIR="../../CICC/"$cfsdata$rodada"/CFS/MENSAL/"
		mkdir ../../CICC/$cfsdata$rodada
		mkdir ../../CICC/$cfsdata$rodada/CFS 
		mkdir $CFSDIR
		#
		# DEFINE AS RODADAS QUE SERAO PROCESSADAS  
		# 
		# A RODADA 00 TEM 16 MEMBROS E AS DEMAIS 4
		# 
		rods="00 06 12 18"
		for nrod in $rods
		do
			#
			#  RODADA 00 TEM 16 MEMBROS
			#  E AS DEMAIS 4 
		    #
            if [ $nrod = "00" ] 
			then
			    nm=4
			    rodada=$nrod
			else
			   nm=1
			   rodada=$nrod
			  
			fi 
			 #
			 #  NUMERADOR DE ENSEMBLES 
			 # 
			case $nrod in
			 "00") 
			    incens=(0 4 8 12 )
				;;
			 "06")
			    incens=(16 17 18 19 )
				;;
			 "12")
			    incens=(20 21 22 23 )
				;;
			 "18")
				incens=(24 25 26 27 )
				;;
			esac 	
			 echo	
			 echo "============="$nrod" "$rodada" "$ens"  "$incens" "$nm
			 echo 	
			#
			# VARRE NUMERO DE MEBROS (00Z TEM 4 E DEMAIS TEM 1) 
			#
            for ens in `seq --format=%02g 1 $nm`
	        do 
			     #
				 #  VARRE AS 9 MESES DE PREVISAO 
				 #
			     for np in `seq 0 9`
			     do
	                #
				    # ARQUIVO RODADA $ROD  00Z 
				    #				    
				     let tmp=($ens + ${incens[0]}) 
				     ens00=`printf "%02g" "$tmp"`
				     prevdata=`date +"%Y%m" -d"$day day ago $np month "` 
		             filegrib="pgbf."$ens"."$cfsdata$rodada"."$prevdata".avrg.grib.00Z.grb2"
				     filenc="CFS_MENSAL_"$ens00"_"$cfsdata$rodada"_"$prevdata".nc" 
				     echo $filegrib" "$filenc" "$nrod
                     #
					 # VERIFICA SE O ARQUIVO FINAL JA EXISTE . SE NAO BAIXA O GRIB2 E GERA O NETCDF 
					 #
				
				    if [ -f $CFSDIR$filenc ]
				    then
					      echo "ja existe"
			 	    else
	                      wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/monthly_grib_"$ens"/"$filegrib >>./LOG.prn 2>&1
				          if [ -f $filegrib ]
				          then 
								# echo bagen CFSENS $filegrib $filenc "$vars$levs"
								 bagen CFSENS $filegrib $filenc 
								 

					       fi				 
				   fi
					 #
					 #  006Z	
				     #
				     let tmp=($ens + ${incens[1]}) 
				     ens06=`printf "%02g" "$tmp"`				
				     prevdata=`date +"%Y%m" -d"$day day ago $np month "` 
		             filegrib="pgbf."$ens"."$cfsdata$rodada"."$prevdata".avrg.grib.06Z.grb2"
				     filenc="CFS_MENSAL_"$ens06"_"$cfsdata$rodada"_"$prevdata".nc" 			
                     #
					 # VERIFICA SE O ARQUIVO FINAL JA EXISTE . SE NAO BAIXA O GRIB2 E GERA O NETCDF 
					 #				
					 echo $filegrib" "$filenc" "$nrod
					 if [ -f $CFSDIR$filenc ]
					 then
						  echo "ja existe"
					 else
	                
						 wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/monthly_grib_"$ens"/"$filegrib >>./LOG.prn 2>&1
						 if [ -f $filegrib ]
						 then 
							 bagen CFSENS $filegrib $filenc

						 fi				 
					 fi
					 #
					 #  012Z
					 #
					 let tmp=($ens + ${incens[2]}) 
					 ens12=`printf "%02g" "$tmp"` 				
					 prevdata=`date +"%Y%m" -d"$day day ago $np month "` 
					 filegrib="pgbf."$ens"."$cfsdata$rodada"."$prevdata".avrg.grib.12Z.grb2"
					 filenc="CFS_MENSAL_"$ens12"_"$cfsdata$rodada"_"$prevdata".nc" 						
					 echo $filegrib" "$filenc" "$nrod
                     #
					 # VERIFICA SE O ARQUIVO FINAL JA EXISTE . SE NAO BAIXA O GRIB2 E GERA O NETCDF 
					 #					 
					 if [ -f $CFSDIR$filenc ]
					 then
					 	echo "ja existe"
					 else
						 echo "wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/monthly_grib_"$ens"/"$filegrib "
						 wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/monthly_grib_"$ens"/"$filegrib >>./LOG.prn 2>&1
						 if [ -f $filegrib ]
						 then 
							 bagen CFSENS $filegrib $filenc
						
						 fi				 
					 fi
					 #
					 #  018Z
					 #
					 let tmp=($ens +  ${incens[3]})
					 ens18=`printf "%02g" "$tmp"`				
					 prevdata=`date +"%Y%m" -d"$day day ago $np month "` 
					 filegrib="pgbf."$ens"."$cfsdata$rodada"."$prevdata".avrg.grib.18Z.grb2"
					 filenc="CFS_MENSAL_"$ens18"_"$cfsdata$rodada"_"$prevdata".nc" 		
					 echo $filegrib" "$filenc" "$nrod				
					 #
					 # VERIFICA SE O ARQUIVO FINAL JA EXISTE . SE NAO BAIXA O GRIB2 E GERA O NETCDF 
					 #
					 if [ -f $CFSDIR$filenc ]
					 then
						echo "ja existe"
					 else
	                
						 wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/monthly_grib_"$ens"/"$filegrib >>./LOG.prn 2>&1
						 if [ -f $filegrib ]
						 then 
							 bagen CFSENS $filegrib $filenc 
						 fi				 
					 fi
					 #
					 #  media 
					 #
					 tmp="00" 
					 ens00=`printf "%02g" "$tmp"`				
					 prevdata=`date +"%Y%m" -d"$day day ago $np month "` 
					 filegrib="pgbf."$ens"."$cfsdata$rodada"."$prevdata".avrg.grib.grb2"
					 filenc="CFS_MENSAL_GCP_"$ens"_"$cfsdata$rodada"_"$prevdata".nc" 	
					 echo $filegrib" "$filenc" "$nrod				
					 if [ -f $CFSDIR$filenc ]
					 then
						echo "ja existe"
					 else
				     
	                 echo "wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/monthly_grib_"$ens"/"$filegrib "
	                 wget -nc "http://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."$cfsdata"/"$rodada"/monthly_grib_"$ens"/"$filegrib >>./LOG.prn 2>&1
				     if [ -f $filegrib ]
				     then 
							 bagen CFSENS $filegrib $filenc
					 fi				 
				 fi
				
			     mv CFS_MENSAL* $CFSDIR					
			 done   
			  	 
	     done 
	  
	  
	 done   
	  
done









}


#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------

get_gfs()
{
#-----------------------------------------------------------
#
# MODELO: GFS  (1.0 0.50 e 0.25 graus)
# TIPO DE DADO: GRIB2
# pOR rEGIS. regis@lamma.ufrj.br 
#
#---- featuretes
# ele baixa via nomads com grib filter
# só baixa chuva, temp 
# Regiao de corte: 280 230 longitude -35 10 latitude
# 
# em 31/08/2017  
# Updates
#
#--------------------------------------------------------
#
# inicio do processo
# 
#
# força o ingles
#
export LANG=en_us_8859_1
#
# inicio
#
echo "["`date`"] INICIO DO LOG GFS1P00 "  >./LOGGFS1P00.prn 2>&1 
echo "["`date`"] INICIO DO LOG GFS1P00 "  >./LOGGFS0P50.prn 2>&1 
echo "["`date`"] INICIO DO LOG GFS1P00 "  >./LOGGFS0P25.prn 2>&1 
echo "["`date`"] INICIO DO PROCESSO BAIXAR GFS - CHUVA E TEMP " 
#
# pega data
#
if [ $1 ="" ];then
   data=`date +"%Y%m%d"`
else
   data=$1
fi 
#
# pega rodada (00z, 06Z, 12Z ou 18Z)
#
if  [ $2 ="" ];then
rodada="00"
else
rodada=$2 
fi 
echo $data
echo $rodada
#
# cria os diretorios onde ficarao os dados
#
# 1P00
#
LOCAL="../../CICC/" 
LOCALFILE1=$LOCAL/$data$rodada"/GFS1P00/"
mkdir $LOCAL                                     >>./LOGGFS1P00.prn 2>&1 
mkdir $LOCAL/$data$rodada                                     >>./LOGGFS1P00.prn 2>&1 
mkdir $LOCALFILE1                                  >>./LOGGFS1P00.prn 2>&1 
#
# 0P50
#
LOCAL="../../CICC/" 
LOCALFILE2=$LOCAL/$data$rodada"/GFS0P50/"
mkdir $LOCAL                                     >>./LOGGFS0P50.prn 2>&1 
mkdir $LOCAL/$data$rodada                                     >>./LOGGFS0P50.prn 2>&1 
mkdir $LOCALFILE2                                    >>./LOGGFS0P50.prn 2>&1 
#
# 0P25
#
LOCAL="../../CICC/" 
LOCALFILE3=$LOCAL/$data$rodada"/GFS0P25/"
mkdir $LOCAL                                                  >>./LOGGFS0P25.prn 2>&1 
mkdir $LOCAL/$data$rodada                                     >>./LOGGFS0P25.prn 2>&1 
mkdir $LOCALFILE3                                             >>./LOGGFS0P25.prn 2>&1 
# nome do arquivo de saida 
#
#filegrib=$tipoens"_"$rodada"_"$data"_BR.grb2"
filegrib1="GFS_"$rodada"_"$data"_BR_1P00.grb2"
filegrib2="GFS_"$rodada"_"$data"_BR_0P50.grb2"
filegrib3="GFS_"$rodada"_"$data"_BR_0P25.grb2"
#
# Baixa todos os arquivos 16 dias de previsão 
#
for n in `seq --format=%03g 0 6 384`
do
#
# manter compatibilidade
#
hora=$n
#
# nome do arquivo temporario 
#
file1="tmpfilegrib1.grb2"
file2="tmpfilegrib2.grb2"
file3="tmpfilegrib3.grb2"
#
#
# link do gribfilter (altere com cuidado!!!!!!!!!!!!!!!!!)
# veja no site do nomads como gerar um outro de sua preferencia
#
#
####link01="http://nomads.ncep.noaa.gov/cgi-bin/filter_gens.pl?file="$tipoens".t"$rodada"z.pgrb2f"$hora"&lev_surface=on&var_APCP=on&var_PRATE=on&var_TMAX=on&var_TMIN=on&var_TMP=on&subregion=&leftlon=280&rightlon=330&toplat=10&bottomlat=-35&dir=%2Fgefs."$data"%2F00%2Fpgrb2"
link01="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_1p00.pl?file=gfs.t"$rodada"z.pgrb2.1p00.f"$hora"&lev_surface=on&var_APCP=on&var_PRATE=on&var_RH=on&var_TMAX=on&var_TMIN=on&var_TMP=on&subregion=&leftlon=280&rightlon=330&toplat=10&bottomlat=-35&dir=%2Fgfs."$data$rodada
link02="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p50.pl?file=gfs.t"$rodada"z.pgrb2full.0p50.f"$hora"&lev_surface=on&var_APCP=on&var_PRATE=on&var_RH=on&var_TMAX=on&var_TMIN=on&var_TMP=on&subregion=&leftlon=280&rightlon=330&toplat=10&bottomlat=-35&dir=%2Fgfs."$data$rodada
link03="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t"$rodada"z.pgrb2.0p25.f"$hora"&lev_surface=on&var_APCP=on&var_PRATE=on&var_RH=on&var_TMAX=on&var_TMIN=on&var_TMP=on&subregion=&leftlon=280&rightlon=330&toplat=10&bottomlat=-35&dir=%2Fgfs."$data$rodada
#
#  baixo arquivo 1P00
#
file=$LOCALFILE1/$filegrib1
if [ -e  $file ];then 
echo "GFS 1P00 JA BAIXADO:"$n
else
wget  -O $file1 $link01  >>./LOGGFS1P00.prn 2>&1 
#
#  junta tudo num so arquivo 
#
wgrib2 -append -grib $filegrib1 $file1  >>./LOGGFS1P00.prn 2>&1 
fi
#  baixo arquivo 0P50
file=$LOCALFILE2/$filegrib2
if [ -e  $file ];then 
echo "GFS 0P50 JA BAIXADO"
else
wget  -O $file2 $link02  >>./LOGGFS0P50.prn 2>&1 
#
#  junta tudo num so arquivo 
#
wgrib2 -append -grib $filegrib2 $file2  >>./LOGGFS0P50.prn 2>&1 
fi
#  baixo arquivo 0P25
file=$LOCALFILE3/$filegrib3
if [ -e  $file ];then 
echo "GFS 0P25 JA BAIXADO"
else
wget  -O $file3 $link03  >>./LOGGFS0P25.prn 2>&1 
#  junta tudo num so arquivo 
wgrib2 -append -grib $filegrib3 $file3  >>./LOGGFS0P25.prn 2>&1 
fi
done
#
# copia arquivos para diretorios finais
#
mv $filegrib1 $LOCALFILE1 >>./LOGGFS1P00.prn 2>&1
mv $filegrib2 $LOCALFILE2 >>./LOGGFS0P50.prn 2>&1
mv $filegrib3 $LOCALFILE3 >>./LOGGFS0P25.prn 2>&1
}





#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------

get_gfs_ens()
{
#-----------------------------------------------------------
#
# MODELO: GES   ENSEMBLE DO GFS
# TIPO DE DADO: GRIB2
# pOR rEGIS. regis@lamma.ufrj.br 
#
#---- featuretes
# ele baixa via nomads com grib filter
# só baixa chuva, temp 
# Regiao de corte: 280 230 longitude -35 10 latitude
# baixa o controle e os essembles e junta tudo num arquivo so
# em 31/08/2017  
# Updates
#
#--------------------------------------------------------
#
# inicio do processo
# 
#
# força o ingles
#
export LANG=en_us_8859_1
#
# pega data
#
if [ $1 ="" ];then
   data=`date +"%Y%m%d"`
else
   data=$1
fi 
#
# pega rodada (00z, 06Z, 12Z ou 18Z)
#
if  [ $2 ="" ];then
rodada="00"
else
rodada=$2 
fi 
echo $data
echo $rodada


LOCAL="../../CICC/" 
LOCALFILE=$LOCAL/$data$rodada"/GEFS1P00/"
mkdir $LOCAL                                     >./LOGGFSENS.prn 2>&1 
mkdir $LOCAL/$data$rodada                                     >>./LOGGFSENS.prn 2>&1
mkdir $LOCALFILE                                    >>./LOGGFSENS.prn 2>&1 


mkdir $LOCAL                   >>./LOGGFSENS.prn 2>&1
mkdir $LOCALFILE               >>./LOGGFSENS.prn 2>&1
# nome do arquivo de saida 
#
#filegrib=$tipoens"_"$rodada"_"$data"_BR.grb2"
filegrib="GEFS_"$rodada"_"$data"_BR_1P00.grb2"

file=$LOCALFILE/$filegrib
if [ -e  $file ];then 
echo "Ja tem"
return 

else


#
# baixa os 20 membros e membro controle 
#
for ens in `seq --format=%02g 0 20`
do
#
# define o label tipoens :gec00 controle demais ensembles gep
#
if [ $ens = 00 ];then 
tipoens="gec00" 
else
tipoens="gep"$ens
fi 
#
# baixar
#
echo "Baixando :"$tipoens
#
# Baixa todos os arquivos 16 dias de previsão 
#
for n in `seq --format=%02g 0 6 384`
do
#
# manter compatibilidade
#
hora=$n
#
# nome do arquivo temporario 
#
file="tmpfilegrib.grb2"
#

#
# link do gribfilter (altere com cuidado!!!!!!!!!!!!!!!!!)
# veja no site do nomads como gerar um outro de sua preferencia
#
#
link01="http://nomads.ncep.noaa.gov/cgi-bin/filter_gens.pl?file="$tipoens".t"$rodada"z.pgrb2f"$hora"&lev_surface=on&var_APCP=on&var_PRATE=on&var_TMAX=on&var_TMIN=on&var_TMP=on&subregion=&leftlon=280&rightlon=330&toplat=10&bottomlat=-35&dir=%2Fgefs."$data"%2F00%2Fpgrb2"
#
#  baixo arquivo 
#
wget  -O $file $link01  >>./LOGGFSENS.prn 2>&1 
#
#  junta tudo num so arquivo 
#
wgrib2 -append -grib $filegrib $file  >>./LOGGFSENS.prn 2>&1 
done
done 


mv $filegrib $LOCALFILE   >>./LOGGFSENS.prn 2>&1
fi

}




#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MODULO ADQURE MODEL 
#
#-----------------------------------------------------------------------------------
get_eta_40 ()
{
#ETA40------------------------------------------------------------------------
#
#
#  SCRIPT PARA ADQUIRIR PREVISOES DO ETA 10 DIAS DO CPTEC E 
#  CALCULAR CHUVA ACUMULADA POR BACIA DO SIN 
#
#  VERSAO 2.0 
#
#
#  bY regis  reginaldo.venturadesa@gmail.com 
#  uso:
#      adquire  [00/12]
#    
# ----------------------------------------------------------------------
# Necessita de um arquivo contendo informaçoes sonre as bacias. 
#  (ver como documentar isso aqui)
#
#
#
#------------------------------------------------------------------------- 
# essa versao é feita pela conta regisgrundig e nao pela lAMOC
#
#--------------------------------------------------------------------------
#
# Existem duas rodadas do modelo ao dia. Uma as 00Z e outra as 12Z
# se nada for informada na linha de comando assume-se 00z
#
#
export LANG=en_us_8859_1
echo "["`date`"] INICIO DO LOG ETA40KM "  >./LOGETA40.prn 2>&1
#
# Se opcao for vazia pega a data do momento
# se não tiver vazia opçoes $1 e $2 sao argumentos
# se $1 = - então $2 dias para trás que sera pego os dados 
if [ -z $1  ] 
then
data=`date +"%Y%m%d"`
datagrads=`date +"%d%b%Y" -d "1 days"` 
rodada="00"
else
data=$1
datagrads=$2
rodada=$3
fi
#
# caso $1="-"
#
if [ "$1" == "-" ]
then
let b="$2-1"
data=`date +"%Y%m%d" -d "$2 days ago"`
datagrads=`date +"%d%b%Y" -d "$b  days ago"` 
rodada="00"
fi
#
# define o local onde sera feito as coisas
#
LOCAL="../../CICC/" 
LOCALFILE=$LOCAL/$data$rodada"/ETA40/"
file=$LOCALFILE"/"$data$rodada".bin"
mkdir $LOCAL                           >>./LOGETA40.prn 2>&1
mkdir $LOCAL$data$rodada                           >>./LOGETA40.prn 2>&1
mkdir $LOCALFILE                      >>./LOGETA40.prn 2>&1
echo $data      
echo $datagrads 

#
#  arquivo de saida
#
filebin=$data$rodada".bin" 
if [ ! -e $file ];then 
#
# Adquire os dados no site do CPTEC. 
# Atençao:  
# Verifique pois o CPTEC altera os caminhos sem avisar!!!
#
echo "["`date`"] BAIXANDO DADOS ETA 40KM " 
echo "["`date`"] BAIXANDO DADOS ETA 40KM "  >>./LOGETA40.prn 2>&1
wget -nc ftp://ftp1.cptec.inpe.br/modelos/io/tempo/regional/Eta40km_ENS/prec24/$data$rodada/* >>./LOGETA40.prn 2>&1
#
# existem 10 arquivos .bin
# separados fica dificil de trabalhar com os arquivos
# por isso vou juntar todos os .bin num único do arquivo
#
echo "["`date`"] CRIANDO ARQUIVOS PARA O GRADS" 
rm $data$rodada".bin" >>./LOGETA40.prn 2>&1
rm *.ctl            >>./LOGETA40.prn 2>&1
for file in `ls -1 *.bin`
do
cat $file >>  $filebin     
rm $file                            
done
file=`echo $filebin".bin"`
mv $filebin $LOCALFILE 
else
echo "ETA 40 KM JA BAIXADO"
fi


}

#-------------------------------------------------------------------------------------
#  SIMOP 3.0 - SISTEMA DE APOIO A PREVISAO 
#
#  Sistema que adquire dados observados, rodadas de modelos, calcula medias e afins e 
#  gera figuras. 
#
#  By ReginaldoVentura de sa (regis@lamma.ufrj.br) 
#
#------------------------------------------------------------------------------------  
# 
#
#     MAIN 
#
#-----------------------------------------------------------------------------------
#
#
# 
#
#######  MAIN 
# ETA40 
# get_eta_40   (pega dado de hoje)
# get_eta_40  - n    (pega dados de -n dias para trás)
# get_eta_40  AAAAMMDD HHZDDMMMAAAA    ( pega para a data AAAA MM DD; MM= 0 a 12  MMM= mes escrito ingles
#
#GFS
#
# get_gfs_ens AAAAMMDD HH 
#
#  Baixa os gfs  de 1 grau, meio gru  e 0.25 
#
# LOCAL ONDE TUDO ACONTECE
#
mkdir ../../WORKDISK

cp g2ctl.pl  ../../WORKDISK
cd ../../WORKDISK

echo "MODELO SENDO UTILIZADO:"$1

get_analises
#
# SEM PARAMETROS , aciona tudo!!
#
case "$1" in 
           eta40)
           get_eta_40 $2 $3 $4 		  
           ;; 
           gefs)
           get_gfs_ens $2 $3 $4 		  
           ;; 
           gfs)
           get_gfs $2 $3 $4 		  
           ;;
		   analises)
		   get_analises $2   ###### $2 é  rodada (00,06,12,18) 
		   ;;
		   cfs)
		   get_cfs_vars  
           ;;
           cfsens) 
           get_cfs_ens $2 	  #### NDD 	   
		   *)
		   get_eta_40   $2 $3 $4 		  
		   get_gfs  $2 $3 $4 		  
           get_gfs_ens $2 $3 $4 	
           get_cfs_ens $2  
           get_cfs_vars 				
		   ;;
esac 
