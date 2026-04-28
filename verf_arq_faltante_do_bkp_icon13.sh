#!/bin/bash -x
#########################################################################
# Script para verificacao de dados faltantes no Backup do ICON13KM      #
#########################################################################

if [ $# -lt 1 ];then
	echo "Entre com o horario da rodada"
	exit 12 
fi

HH=$1
DIRICON13BKP="/data2/backup/backup_icon/bkp_icon13km"
EXT=bz2
TAMREF=3900000

# Setar as datas iniciais e finais para a consulta 
DATAINI=20250101${HH}
DATAFIM=20250507${HH}
DATA=$DATAFIM

# O programa fara duas buscas, ou seja, 3 (dois) IF's:
# 1) Saber se o arquivo esta no diretorio corrente; e
# 2) Busca pelo tamanho do arquivo (se o TAM for menor do que o de TAMREF  

while [ $DATA -ge $DATAINI ]
do
	HH=`echo $DATA | cut -c9-10`
	echo "$HH"
	DATA_CORRENTE=`echo $DATA | cut -c1-8`

		if [ ! -e $DIRICON13BKP/icon_global_icosahedral_${DATA_CORRENTE}_${HH}.tar.${EXT} ]; then
			echo "$DATA AUSENTE" >> lista_faltante_dados_icon13_${HH}
			else
			tam=`du -s $DIRICON13BKP/icon_global_icosahedral_${DATA_CORRENTE}_${HH}.tar.${EXT} | awk '{ print $1 }'`

			if [ $tam -le $TAMREF ];then
				echo "$DATA TAMANHO">> lista_faltante_dados_icon13_${HH}
			fi
		fi
DATA=`/home/admbackup/scripts/caldate $DATA - 24h  'yyyymmddhh'`

done

#FIM 
 echo "Finalizada a busca pelo dado deste EXCELENTE MODELO"
# echo " Isto é um e-mail de teste" | mail -s "Assunto: Dados faltantes do Backup do ICON13KM " thais.guilhon@marinha.mil.br 
