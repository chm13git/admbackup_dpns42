#!/bin/bash -xv

HH=$1
dataini=$2
datafinal=$3
dirwork="/data2/backup/backup_icon/bkp_output_iconlam/ant/machineleaning-alana"
dirbkp="/data2/backup/backup_icon/bkp_output_iconlam/ant"

if [ $# -lt 3 ]; then
    echo "Entre com a hora HH, DATAINICIAL e DATAFINAL (YYYYMMDD)"
    exit 1
fi

data=$dataini
echo "Data inicial: $data"

# Carregando ambiente Conda (necessário no cron)
source /home/admbackup/miniconda3/etc/profile.d/conda.sh
conda activate cdo_env

while [ "$data" -le "$datafinal" ]; do
    ANOMES=$(date -d "${data}" +%Y%m)
    echo "Processando mês: $ANOMES"

    arquivo_bkp="${dirbkp}/iconlam_ant6.5_${HH}_${data}.tar.bz2"
    echo "Arquivo: $arquivo_bkp"

    if [ -e "$arquivo_bkp" ]; then
        echo "Arquivo de backup ${data}${HH} encontrado. Copiando..."
        cp "$arquivo_bkp" "$dirwork"
        cd "$dirwork" || exit 2
        tar -jxvf "iconlam_ant6.5_${HH}_${data}.tar.bz2"
    else
        echo "Arquivo ausente para ${data}${HH}. Pulando para o próximo."
        data=$(date -d "${data} +1 day" +%Y%m%d)
        continue
    fi

    cd "${dirwork}/home/opicon/operacional/ant6.5/data/outputdata${HH}" || exit 3

    # Gera lista dos arquivos GRIB
    ls iconlam_ant6.5_${HH}_${data}_*_ml.grb > lista.raw.txt

    # Loop sobre arquivos GRIB para extrair os dados e acumular no arquivo mensal
    for grib_file in $(cat lista.raw.txt); do
        echo "Processando arquivo $grib_file"
        cdo -outputtab,date,time,name,value -sellevidx,1 -remapnn,lon=-58.9867_lat=-62.1917 "$grib_file" >> "${dirwork}/ICONANT_dados_SCRM_${ANOMES}.csv"
    done

    # Limpeza (opcional)
    # rm "${dirwork}/iconlam_ant6.5_${HH}_${data}.tar.bz2"
    rm iconlam_ant6.5_${HH}_${data}_???_ml.grb iconlam_ant6.5_${HH}_${data}_???_pl.grb

    # Próximo dia
    data=$(date -d "${data} +1 day" +%Y%m%d)
    echo "Próxima data: $data"
done

echo "Finalizado!"
exit 0

