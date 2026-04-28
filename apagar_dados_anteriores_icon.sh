#!/bin/bash
#########################################################################
# Loop de data para apagar dados anteriores no Backup                   #
# Elaborado pela 1T(RM2-T) Luz em 17jul2019                             #
# ALT 1T(RM2-T) Luz em 14abr2020                                        #
#########################################################################

# Se o backup for em funcao do horario, utilizar essa parte

if [ $# -ne 1 ];then
	echo "Entre com o horario da rodada"
	exit 12 
fi

HH=$1

#Pega a data atual
DATA=`date +%Y%m%d`
echo "$DATA"
# Extensao do arquivo
EXT=bz2

##################################################################################################
# APAGAR Icon CosmoMet5
#################################################################################################
DIRBKP="/data2/backup/backup_icon/bkp_input_icondata_met5"

echo "Apagando dados do ICON CosmoMet5"

#Setar o numero de dias que precisa estar no backup (igual o da data anterior)
#Backup de 1 anos e 6 meses para iconmet = 540 dias. Como alguns meses tem 31 dias, 549 parece um numero com margem aceitavel.
n=549

#Colocar um valor maior que n para o while calcular o menor que

while [ ${n} -le 650 ]
do

        DATAANTERIOR=`/home/admbackup/scripts/caldate $DATA - ${n}d  'yyyymmdd'`
        echo "$DATAANTERIOR"

        cd $DIRBKP
# O nome dos arquivos a serem apagados:
# Icon CosmoMet5: iconmet_* atencao que precisa mudar a extensao para .tar.
        
	if [ -f $DIRBKP/iconmet_${DATAANTERIOR}${HH}.tar.${EXT} ]; then

                echo "Vou apagar o dado: iconmet_${DATAANTERIOR}${HH}.tar.${EXT}..."
                rm iconmet_${DATAANTERIOR}${HH}.tar.${EXT}
        else
                echo "Dado inexistente."
        fi

n=`expr $n + 1`
done

##################################################################################################
# APAGAR Icon CosmoAnt
#################################################################################################
DIRBKP="/data2/backup/backup_icon/bkp_input_icondata_ant"

echo "Apagando dados do ICON CosmoAnt"

#Setar o numero de dias que precisa estar no backup (igual o da data anterior)
#Backup de 6 meses para iconant = 180 dias. Como alguns meses tem 31 dias, 183 parece um numero com margem aceitavel.
n=183

#Colocar um valor maior que n para o while calcular o menor que

while [ ${n} -le 290 ]
do

        DATAANTERIOR=`/home/admbackup/scripts/caldate $DATA - ${n}d  'yyyymmdd'`
        echo "$DATAANTERIOR"

        cd $DIRBKP
# O nome dos arquivos a serem apagados:
# Icon CosmoAnt: iconant_* atencao que precisa mudar a extensao para .tar.

        if [ -f $DIRBKP/iconant_${DATAANTERIOR}${HH}.tar.${EXT} ]; then

                echo "Vou apagar o dado: iconant_${DATAANTERIOR}${HH}.tar.${EXT}..."
                rm iconant_${DATAANTERIOR}${HH}.tar.${EXT}
        else
                echo "Dado inexistente."
        fi

n=`expr $n + 1`
done

##################################################################################################
# APAGAR Icon 13km
#################################################################################################
DIRBKP="/data2/backup/backup_icon/bkp_icon13km"

echo "Apagando dados do ICON 13km"

#Setar o numero de dias que precisa estar no backup (igual o da data anterior)
#Backup de 1 anos e 6 meses para icon13km = 540 dias. Como alguns meses tem 31 dias, 549 parece um numero com margem aceitavel. 
n=549

#Colocar um valor maior que n para o while calcular o menor que

while [ ${n} -le 650 ]
do

        DATAANTERIOR=`/home/admbackup/scripts/caldate $DATA - ${n}d  'yyyymmdd'`
        echo "$DATAANTERIOR"

        cd $DIRBKP
# O nome dos arquivos a serem apagados:
# Icon 13km: icon_global_icosahedral_YYYYMMDD_HH.tar.bz2 atencao que precisa mudar a extensao para .tar.

        if [ -f $DIRBKP/icon_global_icosahedral_${DATAANTERIOR}_${HH}.tar.${EXT} ]; then

                echo "Vou apagar o dado: icon_global_icosahedral_${DATAANTERIOR}_${HH}.tar.${EXT}..."
                rm icon_global_icosahedral_${DATAANTERIOR}_${HH}.tar.${EXT}
        else
                echo "Dado inexistente."
        fi

n=`expr $n + 1`
done

#FIM 
