#!/bin/bash -x
#########################################################################
# Script para verificacao de dados faltantes no Backup dos modelos ICON13KM, ICONLAM_SAM, ICONLAM_ANT, WRFMET e WRFANT#
# Adaptado pelo CC(T) GADELHA | 2SG-ME VANESSA VALENTIM e 2SG-ME CAROLINA ANDRIONI em 16MAI2025 para o backup#
#########################################################################

#!/bin/bash
set -x  # Ativa modo de depuração para mostrar execução linha a linha

if [ $# -lt 4 ]; then
    echo "Uso: $0 <HH> <modelo> <DATAINI (YYYYMMDD)> <DATAFIM (YYYYMMDD)>"
    exit 12
fi

HH=$1
MODEL=$2
DATAINI=${3}${HH}
DATAFIM=${4}${HH}
DATA=$DATAFIM

# Variáveis do modelo

SCRIPT_DIR="$(dirname "$0")"

case "$MODEL" in
    icon13)
        DIRBKP="/data2/backup/backup_icon/bkp_icon13km"
        EXT=bz2
        TAMREF=3900000
        ARQSAIDA="${SCRIPT_DIR}/lista_dados_faltantes_icon13_${HH}"
        ;;
    iconlam_sam)
        DIRBKP="/data2/backup/backup_icon/bkp_output_iconlam/sam"
        EXT=bz2
        TAMREF=4300000
        ARQSAIDA="${SCRIPT_DIR}/lista_dados_faltantes_iconlam_sam_${HH}"
        ;;
    icon4iconlam_sam)
        DIRBKP="/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
        EXT=bz2
        TAMREF=12900000
        ARQSAIDA="${SCRIPT_DIR}/lista_dados_faltantes_icon4iconlam_sam_${HH}"
        ;;
    iconlam_ant)
        DIRBKP="/data2/backup/backup_icon/bkp_output_iconlam/ant"
        EXT=bz2
        TAMREF=4300000
        ARQSAIDA="${SCRIPT_DIR}/lista_dados_faltantes_iconlam_ant_${HH}"
        ;;
    icon4iconlam_ant)
        DIRBKP="/data2/backup/backup_icon/bkp_input_icon4iconlam_ant"
        EXT=bz2
        TAMREF=12900000
        ARQSAIDA="${SCRIPT_DIR}/lista_dados_faltantes_icon4iconlam_ant_${HH}"
        ;;
    wrfmet)
        DIRBKP="/data2/backup/backup_wrf/bkp_output_wrf/met510km"
        EXT=bz2
        TAMREF=4300000
        ARQSAIDA="${SCRIPT_DIR}/lista_dados_faltantes_wrfmet_${HH}"
        ;;
    wrfant)
        DIRBKP="/data2/backup/backup_wrf/bkp_output_wrf/antartica"
        EXT=bz2
        TAMREF=12900000
        ARQSAIDA="${SCRIPT_DIR}/lista_dados_faltantes_wrfant_${HH}"
        ;;
    *)
        echo "Modelo inválido: $MODEL"
        exit 1
        ;;
esac

# Garante que a lista seja limpa antes de iniciar
> $ARQSAIDA

while [ $DATA -ge $DATAINI ]; do
    DATA_CORRENTE=$(echo $DATA | cut -c1-8)

    # Define nome do arquivo com base no modelo e data corrente
    case "$MODEL" in
        icon13)
            NOMARQ="icon_global_icosahedral_${DATA_CORRENTE}_${HH}.tar.${EXT}"
            ;;
        iconlam_sam)
            NOMARQ="iconlam_sam6.5_${HH}_${DATA_CORRENTE}.tar.${EXT}" 
            ;;
        icon4iconlam_sam)
            NOMARQ="icon4iconlamsam_${DATA_CORRENTE}${HH}.tar.${EXT}"
            ;;  
        iconlam_ant)
            NOMARQ="iconlam_ant6.5_${HH}_${DATA_CORRENTE}.tar.${EXT}" 
            ;;
        icon4iconlam_ant)
            NOMARQ="icon4iconlamant_${DATA_CORRENTE}${HH}.tar.${EXT}"
            ;;
        wrfmet)
            NOMARQ="wrf_met510km_${HH}_${DATA_CORRENTE}.tar.${EXT}"
            ;;
        wrfant)
            NOMARQ="wrf_antartica_${HH}_${DATA_CORRENTE}.tar.${EXT}"
        ;;
    esac

    CAMINHO="$DIRBKP/$NOMARQ"
    echo "Verificando: $CAMINHO"

    if [ ! -e "$CAMINHO" ]; then
        echo "$DATA AUSENTE" >> "$ARQSAIDA"
    else
        tam=$(du -s "$CAMINHO" | awk '{ print $1 }')
        echo "Tamanho: $tam (referência: $TAMREF)"
        if [ "$tam" -le "$TAMREF" ]; then
            echo "$DATA TAMANHO" >> "$ARQSAIDA"
        fi
    fi

    DATA=$(/home/admbackup/scripts/caldate "$DATA" - 24h 'yyyymmddhh')
done

echo "Finalizada a busca pelo dado do modelo $MODEL"

# echo " Isto é um e-mail de teste" | mail -s "Assunto: Dados faltantes do Backup do COSMO MET " thais.guilhon@marinha.mil.br 
