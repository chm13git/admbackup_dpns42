#!/bin/bash -x
#########################################################################
# Script para verificacao de dados faltantes no Backup do ICON 4 ICONLAM#
#########################################################################

if [ $# -lt 1 ];then
	echo "Entre com o horario da rodada"
	exit 12 
fi

HH=$1
DIRICON4ICONLAMKP="/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
EXT=bz2
TAMREF=12900000

# Setar as datas iniciais e finais para a consulta 
DATAINI=20240101${HH}
DATAFIM=20250101${HH}
DATA=$DATAFIM

# O programa fara duas buscas, ou seja, 2 (dois) IF's:
# 1) Saber se o arquivo esta no diretorio corrente; e
# 2) Busca pelo tamanho do arquivo (se o TAM for menor do que o de TAMREF)  

while [ $DATA -ge $DATAINI ]
do
	HH=`echo $DATA | cut -c9-10`
	echo "$HH"
	DATA_CORRENTE=`echo $DATA | cut -c1-8`

		if [ ! -e $DIRICON4ICONLAMKP/icon4iconlamsam_${DATA_CORRENTE}${HH}.tar.${EXT} ]; then
			echo "$DATA AUSENTE" >> lista_dados_faltantes_icon4iconlam_sam_${HH}
			else
			tam=`du -s $DIRICON4ICONLAMKP/icon4iconlamsam_${DATA_CORRENTE}${HH}.tar.${EXT} | awk '{ print $1 }'`

			if [ $tam -le $TAMREF ];then
				echo "$DATA TAMANHO">> lista_dados_faltantes_icon4iconlam_sam_${HH}
			fi
		fi
DATA=`/home/admbackup/scripts/caldate  $DATA - 24h  'yyyymmddhh'` 

done

#FIM 
 echo "Finalizada a busca pelo dado deste EXCELENTE MODELO"
# echo " Isto é um e-mail de teste" | mail -s "Assunto: Dados faltantes do Backup do ICON4ICONLAMSAM " thais.guilhon@marinha.mil.br 
