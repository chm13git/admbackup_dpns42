#!/bin/bash -xv

########################################################################################
##      Autora: 1T(RM2-T) LUZ     22jan2020 CH13
##      ALT 1T(RM2-T) LUZ     14abr2020 CH13
##      Descricao:
##      Script para duplicar o backup do modelo ICON no storage 10.13.99.102 
##      e apagar os dados anteriores no storage
########################################################################################

# Fazendo o ponto de montagem no disco2


if ! [ $# -eq 1 ];then
        echo "Entre com o horario"
        echo "Exemplo: ./script.sh 00 ou 12"
	exit 1
fi

HH=$1

echo "O seguinte parametro foi passado para o script"
echo "HH=$HH"

data=`date +%Y%m%d`

# Montando disco2
ssh -i /home/admbackup/.ssh/id_rsa32 root@10.13.100.32 "mount 10.13.200.12:/mnt/dados /mnt/disco2"


# Duplicar ICON 13km
echo "Duplicando ICON 13km"
cp /data2/backup_icon/backup_icon13km/icon_global_icosahedral_${data}_${HH}.tar.bz2 /mnt/disco2/backup_modelos/backup_icon/backup_icon13km/

# Duplicar ICONDATA ANT
echo "Duplicando ICONDATA ANT"
cp /data2/backup_icon/backup_icondata_ant/iconant_${data}${HH}.tar.bz2 /mnt/disco2/backup_modelos/backup_icon/backup_icondata_ant/

# Duplicar ICONDATA MET
echo "Duplicando ICONDATA MET"
cp /data2/backup_icon/backup_icondata_met5/iconmet_${data}${HH}.tar.bz2 /mnt/disco2/backup_modelos/backup_icon/backup_icondata_met5/

##########################################################
# Apagando dados anteriores no disco
#########################################################
echo "Apagando dados anteriores no disco"

#Pega a data atual
DATA=`date +%Y%m%d`
echo "$DATA"
# Extensao do arquivo
EXT=bz2


##################################################################################################
# APAGAR Icon CosmoMet5
#################################################################################################
DIRBKP="/mnt/disco2/backup_modelos/backup_icon/backup_icondata_met5"

echo "Apagando dados do ICON CosmoMet5"

#Setar o numero de dias que precisa estar no backup (igual o da data anterior)
#Backup de 2 anos e 6 meses para iconmet = 912 dias
n=912

#Colocar um valor maior que n para o while calcular o menor que

while [ ${n} -le 950 ]
do

        DATAANTERIOR=`/home/admbackup/scripts/caldate $DATA - ${n}d  'yyyymmdd'`
        echo "$DATAANTERIOR"

        cd $DIRBKP
# O nome dos arquivos a serem apagados:
# Icon CosmoMet5: iconmet_* atencao que precisa mudar a extensao para .tar.

        if [ -f $DIRBKP/iconmet_${DATAANTERIOR}${HH}.tar.${EXT} ]; then
                echo "iconmet_${DATAANTERIOR}${HH}.tar.${EXT}"
                echo "vou apagar o dado"
                rm iconmet_${DATAANTERIOR}${HH}.tar.${EXT}
        else
                echo "nao existe o dado"
        fi

n=`expr $n + 1`
done


##################################################################################################
# APAGAR Icon CosmoAnt
#################################################################################################
DIRBKP="/mnt/disco2/backup_modelos/backup_icon/backup_icondata_ant"

echo "Apagando dados do ICON CosmoAnt"

#Setar o numero de dias que precisa estar no backup (igual o da data anterior)
#Backup de 6 meses e 6 meses para iconant = 365 dias
n=365

#Colocar um valor maior que n para o while calcular o menor que

while [ ${n} -le 380 ]
do

        DATAANTERIOR=`/home/admbackup/scripts/caldate $DATA - ${n}d  'yyyymmdd'`
        echo "$DATAANTERIOR"

        cd $DIRBKP
# O nome dos arquivos a serem apagados:
# Icon CosmoAnt: iconant_* atencao que precisa mudar a extensao para .tar.

        if [ -f $DIRBKP/iconant_${DATAANTERIOR}${HH}.tar.${EXT} ]; then
                echo "iconant_${DATAANTERIOR}${HH}.tar.${EXT}"
                echo "vou apagar o dado"
                rm iconant_${DATAANTERIOR}${HH}.tar.${EXT}
        else
                echo "nao existe o dado"
        fi

n=`expr $n + 1`
done

##################################################################################################
# APAGAR Icon 13km
#################################################################################################
DIRBKP="/mnt/disco2/backup_modelos/backup_icon/backup_icon13km"

echo "Apagando dados do ICON 13km"

#Setar o numero de dias que precisa estar no backup (igual o da data anterior)
#Backup de 3 anos e 6 meses para icon13km = 1277 dias
n=1277

#Colocar um valor maior que n para o while calcular o menor que

while [ ${n} -le 1300 ]
do

        DATAANTERIOR=`/home/admbackup/scripts/caldate $DATA - ${n}d  'yyyymmdd'`
        echo "$DATAANTERIOR"

        cd $DIRBKP
# O nome dos arquivos a serem apagados:
# Icon 13km: icon_global_icosahedral_YYYYMMDD_HH.tar.bz2 atencao que precisa mudar a extensao para .tar.

        if [ -f $DIRBKP/icon_global_icosahedral_${DATAANTERIOR}_${HH}.tar.${EXT} ]; then
                echo "icon_global_icosahedral_${DATAANTERIOR}_${HH}.tar.${EXT}"
                echo "vou apagar o dado"
                rm icon_global_icosahedral_${DATAANTERIOR}_${HH}.tar.${EXT}
        else
                echo "nao existe o dado"
        fi

n=`expr $n + 1`
done

                     
# Desfazendo o ponto de montagem do disco2
ssh -i /home/admbackup/.ssh/id_rsa32 root@10.13.100.32 "umount /mnt/disco2"

echo "*******************************"
echo " Fim da duplicacao do  backup  "
echo "*******************************"

