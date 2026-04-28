#!/bin/bash -xv
dirwork


HH=$1
dataini=$2
datafinal=$3
dirwork="/home/admbackup/retrieve_data"
dirbkp="/data2/backup_cosmo/metarea5/dados${HH}"

if [ $# -lt 3 ]
   then
   echo "+------------------Utilização-------------------------------------+"
   echo " Script criated by CT(T) Alana  e 1T(RM2-T) Rambo data from Backup "
   echo "    Entre com o horario inicial HH (00 ou 12)			    "
   echo "    Entre com a DATAINICIAL Exemplo: 20200220                      "
   echo "    Entre com a DATAFINAL   Exemplo: 20200305                      "
   echo "+-----------------------------------------------------------------+"
exit 4444 
fi


data=$dataini

while [ $data -le $datafinal ];do
	
	if [ -e ${dirbkp}/cosmomet_07km_${HH}_${data}.tar.bz2 ];then

		echo " O arquivo de backup do dia/hora ${data}${HH} está no diretório de backup"

		echo  "Copiando o arquivo para diretório de trabalho"
		cp ${dirbkp}/cosmomet_*${data}.tar.bz2 ${dirwork}/cosmomet.${data}${HH}.tar.bz2

		echo  "Descompactando arquivo..."
		cd ${dirwork}
		tar -jxvf cosmomet.${data}${HH}.tar.bz2
 
	else 

		echo "Não tem o arquivo deste dia $data no backup, to saindo"
		exit 444 	
	fi 

	
 	echo " Fazendo uma lista de grib para o dia $data de 000 a 009 a partir do nivel de modelo, tbm temos a opção de fazer em nivel de pressao"
        echo " Pois depois temos o prognóstico de 012 a partir do próxima rodada de 12h com o prog 0 da mesmo"  
	
	ls -ltr cosmo_met5_${HH}_${data}00* | awk '{print $9}' | grep -v 00[0-9]p | grep -v 00[0-9]c > lista.raw.txt

	rm ${dirwork}/cosmo_met5_${HH}_${data}0[1-9]*
	rm ${dirwork}/cosmo_met5_${HH}_${data}000c
	rm ${dirwork}/cosmo_met5_${HH}_${data}00[0-9]p
#############################################################################################
##### Só pra lembrar copiei o arquivo do wgrib e wgrib2 para ~/fontes/bin ###################
	for grib_file in `cat lista.raw.txt`; do
		new_grib=`ls -ltr ${grib_file} | awk '{print $9}' | cut -c1-5,11-25`
  
		/home/admbackup/fontes/bin/wgrib ${grib_file} | egrep "(kpds5=11:kpds6=105|:PMSL:|:U:|:V:)" | /home/admbackup/fontes/bin/wgrib -i -grib ${grib_file} -o raw_${new_grib}.grb
		####### ISSO AQUI EMBAIXO PRECISA SER ALTERADO A LAT E LON [LONW,LONE,LATS,LATN] 
		#/data1/dpns31_old/usr/local/bin/cdo -sellonlatbox,-60,-30,-40,-10 raw_${new_grib}.grb ${new_grib}.grb
		cp raw_${new_grib}.grb ${new_grib}.grb
	 	### Até aqui eu consegui gerar um arquivo com uma latlon qualquer lugar do modelo cosmo #######
		rm raw_${new_grib}.grb
		rm ${grib_file}
	done 

	rm ${dirwork}/lista.raw.txt
	rm ${dirwork}/cosmomet.${data}${HH}.tar.bz2

	data=`caldate $data + 1d 'YYYYmmdd'`
	echo "$data"
done 
exit 4444 
#### A partir daqui vou terq trabalhar com dado .grib nas máquinas de pos-processamento
#### Tive que pegar o arquivo grib2ctl.pl da internet e jogar para a 05e (Na delta ja tinha, fui burro) 
### Transformando agora ele em um ctl para gerar as figuras na 05d /home/operador/bin/grib2ctl.pl e 05e /opt/opengrads/Contents/grib2ctl.pl
/opt/opengrads/Contents/grib2ctl.pl ${grib_file}.grb > ${grib_file}.ctl

/opt/opengrads/Contents/gribmap -i ${grib_file}.ctl 
