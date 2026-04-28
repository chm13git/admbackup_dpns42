#!/bin/bash -x
#########################################################################
# Script para verificacao de dados faltantes no Backup dos modelos ICON13KM, ICONLAM_SAM, ICONLAM_ANT, WRFMET e WRFANT#
# Adaptado pelo CC(T) GADELHA | 2SG-ME VANESSA VALENTIM e 2SG-ME CAROLINA ANDRIONI em 16MAI2025 para o backup#
#########################################################################

if [ $# -lt 4 ];then
	echo "1 - Entre com o horario da rodada;"
	echo "2 - o modelo a ser avaliado (icon13, iconlam_sam, icon4iconlam_sam, iconlam_ant e icon4iconlam_an);"
	echo "3 - o horario inicial no formato YYYYMMDD; e"
	echo "4 - o horario final no formato YYYYMMDD."
	exit 12 
fi

HH=$1
MODEL=$2
DATAINI=$3
DATAFIM=$4

# Setar as datas iniciais e finais para a consulta 
DATAINI=${DATAINI}${HH} #Tinha 00 no final de cada data e eu tirei, porque a rodada já entra como parâmetro
DATAFIM=${DATAFIM}${HH}
DATA=$DATAFIM

DATA_CORRENTE=`echo $DATA | cut -c1-8`

case "$MODEL" in
	icon13)
		DIRBKP="/data2/backup/backup_icon/bkp_icon13km"
		EXT=bz2
		TAMREF=3900000
		NOMARQ="icon_global_icosahedral_${DATA_CORRENTE}_${HH}.tar.${EXT}"
		NOMARQ2="lista_dados_faltantes_icon13_${HH}"
	;;
	iconlam_sam)
		DIRBKP="/data2/backup/backup_icon/bkp_output_iconlam/sam"
		EXT=bz2
		TAMREF=4300000
		NOMARQ="iconlam_sam6.5_${HH}_${DATA_CORRENTE}.tar.${EXT}"
		NOMARQ2="lista_dados_faltantes_iconlam_sam_${HH}"

	;;
	icon4iconlam_sam)
		DIRBKP="/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
		EXT=bz2
		TAMREF=12900000
		NOMARQ="icon4iconlamsam_${DATA_CORRENTE}${HH}.tar.${EXT}"
		NOMARQ2="lista_dados_faltantes_icon4iconlam_sam_${HH}"
	;;
	*)
    		echo "Opção inválida"
    	;;
esac

# O programa fara duas buscas, ou seja, 2 (dois) IF's:
# 1) Saber se o arquivo esta no diretorio corrente; e
# 2) Busca pelo tamanho do arquivo (se o TAM for menor do que o de TAMREF)  

while [ $DATA -ge $DATAINI ];do

	if [ ! -e $DIRBKP/${NOMARQ} ]; then
		echo "$DATA AUSENTE" >> ./${NOMARQ2}
	else
		tam=`du -s $DIRBKP/${NOMARQ} | awk '{ print $1 }'`

		if [ $tam -le $TAMREF ];then
			echo "$DATA TAMANHO" >> ${NOMARQ2}
		fi
	fi
	DATA=`/home/admbackup/scripts/caldate  $DATA - 24h  'yyyymmddhh'` #tinha um caldate aqui para os scripts do rerun do cosmo no /data1 da 33.

done

#FIM 
 echo "Finalizada a busca pelo dado deste EXCELENTE MODELO"
# echo " Isto é um e-mail de teste" | mail -s "Assunto: Dados faltantes do Backup do COSMO MET " thais.guilhon@marinha.mil.br 
