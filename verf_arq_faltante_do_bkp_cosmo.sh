#!/bin/bash -x
#########################################################################
# Script para verificacao de dados faltantes no Backup do COSMO METAREAV#
# Adaptado pela CC(T) ALANA em 15MAR2019 para o backup e ATU pela 3SG-ME#
# THAÍS GUILHON                                                         #
#########################################################################

if [ $# -lt 1 ];then
	echo "Entre com o horario da rodada"
	exit 12 
fi

HH=$1
DIRCOSMOBKP="/data2/backup/backup_cosmo/metarea5/dados${HH}"
EXT=bz2
TAMREF=1928788

# Setar as datas iniciais e finais para a consulta 
DATAINI=20220612${HH} #Tinha 00 no final de cada data e eu tirei, porque a rodada já entra como parâmetro
DATAFIM=20240612${HH}
DATA=$DATAFIM

# O programa fara duas buscas, ou seja, 2 (dois) IF's:
# 1) Saber se o arquivo esta no diretorio corrente; e
# 2) Busca pelo tamanho do arquivo (se o TAM for menor do que o de TAMREF)  

while [ $DATA -ge $DATAINI ]
do
	HH=`echo $DATA | cut -c9-10`
	echo "$HH"
	DATA_CORRENTE=`echo $DATA | cut -c1-8`

		if [ ! -e $DIRCOSMOBKP/cosmomet_07km_${HH}_${DATA_CORRENTE}.tar.${EXT} ]; then
			echo "$DATA AUSENTE" >> lista_faltante_dados${HH}
			else
			tam=`du -s $DIRCOSMOBKP/cosmomet_07km_${HH}_${DATA_CORRENTE}.tar.${EXT} | awk '{ print $1 }'`

			if [ $tam -le $TAMREF ];then
				echo "$DATA TAMANHO">> lista_faltante_dados${HH}
			fi
		fi
DATA=`/home/admbackup/scripts/caldate  $DATA - 24h  'yyyymmddhh'` #tinha um caldate aqui para os scripts do rerun do cosmo no /data1 da 33.

done

#FIM 
 echo "Finalizada a busca pelo dado deste EXCELENTE MODELO"
# echo " Isto é um e-mail de teste" | mail -s "Assunto: Dados faltantes do Backup do COSMO MET " thais.guilhon@marinha.mil.br 
