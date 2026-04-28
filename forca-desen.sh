#!/bin/bash -xv

HH=$1
DATAINI=$2
DATAFIM=$3
dirwork="/data3/CH131/WW3_bckup/cosmo_grib_wnd10m/vento-ago-set/dados_oleo_cosmo7km"
dirbkp="/data2/backup_cosmo/metarea5/dados${HH}"
tamref=600000

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização-------------------------------------+"
   echo " Script criated by CT(T) Alana to retrieve COSMO data from Backup  "
   echo "       ex: ./retrieve_data.sh 00                                      "
   echo "+-----------------------------------------------------------------+"
fi


#DATAS="2017040412 2017040612 2017040700 2017050500 2017062100 2017062112 2017071512 2017071600 2017100200  2017101200 2017101212 2017122700 2018022400 2018022500 2018022600 2018022700 2018022800
#2018030100 2018030200 2018030300 2018030400 2018030500 2018030600 2018030700 2018030800 2018030900 2018031000 2018031100 2018031200 2018031300 2018031400 2018031612"

#for DATA in `echo $DATAS`
#do

#DATA=$DATAINI

#        while [ $DATA -le $DATAFIM ]
#        do
#        HH=`echo $DATA | cut -c9-10`
#        cur_date=`echo $DATA | cut -c1-8`
#        ${RAIZ}/datas/ledata_corr.sh ${HH} ${cur_date}

#if [ -e $DIRICONBKP/iconmet_${DATA}.tar.${EXT} ] &&  [ ! -f ${RAIZ}/metarea5/data/vento${HH}/cosmo_vento_${HH}_${cur_date}.tar.bz2 ]; then
#if [ -e $DIRICONBKP/iconmet_${DATA}.tar.${EXT} ]; then

#        tam=`du -s $DIRICONBKP/iconmet_${DATA}.tar.${EXT} | awk '{ print $1 }'`

 #               if [ $tam -ge $TAMREF ]; then
 #               sleep 1
 #                       /usr/bin/input_status.py COSMO-RERUN-1 99 Teste yellow "Iniciando a rodada de $DATA"
 #                       /usr/bin/input_status.py VERIF-RERUN-1 99 Teste yellow "Iniciando a rodada de $DATA"
 #                       rm ${DIRDPNS24}_${HH}/icon_new.${EXT}

#cd ${DIRDPNS24}_${HH}
#cp $DIRICONBKP/iconmet_${DATA}.tar.${EXT} ${DIRDPNS24}_${HH}
#tar -xvf ${DIRDPNS24}_${HH}/iconmet_${DATA}.tar.${EXT}
#                if [ -e icon_new ]; then
#                   bzip2 -z icon_new
#                fi

#rm ${DIRDPNS24}_${HH}/iconmet_${DATA}.tar.${EXT}

 #               if [ $HH -ne $HANTERIOR ]; then
  #                 sleep 2
   #             else

    #    while [ ! -f ${RAIZ}/metarea5/data/vento${HH}/cosmo_vento_${HH}_${DATAANTERIOR}.tar.bz2 ]
    #    do
    #            echo FUNCIONOU
    #            sleep 600
    #    done

     #   fi

#'echo $HH > ${RAIZ}/metarea5/cosmo/HH.txt

#scp admcosmo@10.13.100.32:/data2/backup_cosmo/metarea5/dados${HH}

#  1)
#  How to retrieve data from number of records? 
#  This part will retrieve from 1 to 24 records

	#/usr/bin/bunzip2 cosmo.20190*.grb2.bz2 
	#ls cosmo.20190*grb2 > lista.raw
	#for grib_file in `cat lista.raw`; do
	#echo $grib_file
	#/data1/home_dpns31/operador/bin/wgrib2 ${grib_file} -for_n 1:24 -grib new_${grib_file}
	#bzip2 new_${grib_file}.grb2
	#done

#  2)
# How to tranform to NETCDF and replace name from the data?

	#for grib_file in `cat lista.raw1`; do
	#/data1/home_dpns31/operador/bin/wgrib2 ${grib_file} -netcdf ${grib_file}.nc 
	#grib_file2=`echo ${grib_file}.nc | sed 's/grb2\.nc/nc/'`
	#mv ${grib_file}.nc ${grib_file2}
	#done

# 3)

for file in `ls *.bz2`; do
	/usr/bin/bunzip2 $file
done
#for file in `ls *.tar`; do 
#	tar -xvf $file
#	mv $file.tar arqtar
#done
date
	ls *000* > lista.raw.txt | ls `cat lista.raw.txt` | grep -v p > 000.txt

for grib_file in `cat 000.txt`; do
	wgrib $grib_file | egrep "(kpds5=11:kpds6=105|:PMSL:|:U:|:V:)" | wgrib -i -grib $grib_file -o new_$grib_file.grib
done

date
	ls new_*.grib > lista.new.grib.txt

for grib_file in `cat lista.new.grib.txt`; do
/usr/local/lib/.pyenv/shims/cdo -f nc copy ${grib_file} ${grib_file}.nc
grib_file2=`echo ${grib_file}.nc | sed 's/\.grib\.nc/.nc/'`
mv ${grib_file}.nc ${grib_file2}
done
#
