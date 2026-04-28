#!/bin/bash -xv

HH=$1
dataini=$2
datafinal=$3
dirwork="/data2/backup/backup_icon/bkp_output_iconlam/ant/machineleaning-alana"
dirbkp="/data2/backup/backup_icon/bkp_output_iconlam/ant"
dirout="/home/opicon/operacional/ant6.5/data/outputdata${HH}"

if [ $# -lt 3 ];then
	echo "Entre com a hora HH, DATAINICIAL e DATAFINAL (YYYYMMDD)"
fi

data=$dataini
echo $data
ANOMES=$(date -d "${data} +1 day" +%Y%m)
echo $ANOMES

while [ "$data" -le "$datafinal" ]; do

    arquivo_bkp="${dirbkp}/iconlam_ant6.5_${HH}_${data}.tar.bz2"
    
    echo $arquivo_bkp

    if [ -e "$arquivo_bkp" ]; then
        echo "Arquivo de backup ${data}${HH} encontrado. Copiando..."
        cp "$arquivo_bkp" "$dirwork/$dirout"
        cd "${dirwork}/home/opicon/operacional/ant6.5/data/outputdata${HH}" || exit 2
        #cd "${dirwork}" || exit 2
        tar -jxvf "iconlam_ant6.5_${HH}_${data}.tar.bz2"
    else
        echo "Arquivo ausente para ${data}${HH}. Pulando para o próximo."
    fi
        
    cd ${dirwork}${dirout}	
    ls iconlam_ant6.5_${HH}_${data}_*_ml.grb > lista.raw.txt

# Carregando ambiente conda para funcionar o CDO
#eval "$(conda shell.bash hook)"
source /home/admbackup/miniconda3/etc/profile.d/conda.sh
conda activate cdo_env

for grib_file in `cat lista.raw.txt`; do
	cdo -outputtab,date,time,name,value -sellevidx,1 -remapnn,lon=-58.9867_lat=-62.1917 ${grib_file} >> ICONANT_dados_SCRM_${ANOMES}.csv
done 

cd ${dirwork}${dirout}
rm  iconlam_ant6.5_${HH}_${data}.tar.bz2 iconlam_ant6.5_${HH}_${data}_???_ml.grb iconlam_ant6.5_${HH}_${data}_???_pl.grb 

data=$(date -d "${data} +1 day" +%Y%m%d)
echo "$data"
done 
exit 4444 
