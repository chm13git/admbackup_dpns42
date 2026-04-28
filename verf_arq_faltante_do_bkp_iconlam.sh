#!/bin/bash -x
#########################################################################
# Script para verificacao de dados faltantes no Backup do ICONLAM       #
#########################################################################

if [ $# -lt 1 ];then
	echo "Entre com o horario da rodada"
	exit 12 
fi

HH=$1
DIRICONLAMBKP="/data2/backup/backup_icon/bkp_output_iconlam/sam"
EXT=bz2
TAMREF=4300000

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

		if [ ! -e $DIRICONLAMBKP/iconlam_sam6.5_${HH}_${DATA_CORRENTE}.tar.${EXT} ]; then
			echo "$DATA AUSENTE" >> lista_dados_faltantes_iconlam_sam_${HH}
			else
			tam=`du -s $DIRICONLAMBKP/iconlam_sam6.5_${HH}_${DATA_CORRENTE}.tar.${EXT} | awk '{ print $1 }'`

			if [ $tam -le $TAMREF ];then
				echo "$DATA TAMANHO">> lista_dados_faltantes_iconlam_sam_${HH}
			fi
		fi
DATA=`/home/admbackup/scripts/caldate  $DATA - 24h  'yyyymmddhh'` #tinha um caldate aqui para os scripts do rerun do cosmo no /data1 da 33.

done

#FIM 
 echo "Finalizada a busca pelo dado deste EXCELENTE MODELO"
# echo " Isto é um e-mail de teste" | mail -s "Assunto: Dados faltantes do Backup do ICONLAM SAM " thais.guilhon@marinha.mil.br 
