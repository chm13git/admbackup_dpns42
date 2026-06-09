#!/bin/bash

########################################################################
#  Script para verificação dos dados do backup dos ICON's na DPNS42    #
########################################################################

if [ $# -ne 2 ];then
        echo "Entre com a rodada (00 ou 12) e o dia (AAAAMMDD)."
        echo "Exemplo:	$0 <HH> <DATA>"
        echo "Exemplo:	$0 12 20240923"
	exit 1
fi

HH=$1
DATA=$2

#########################################################################
# Common definitions
bkp_dir='/data2/backup'
defaultSuffix='.tar.bz2'
#########################################################################
# Helper interno para validação com margem de 10%
validar_arquivo() {
    local arquivo=$1
    local esperado=$2

    if [ -f "$arquivo" ]; then
        local atual=$(du -shb "$arquivo" | awk '{print $1}')
	
	# Cálculo de margens (Aritmética inteira do Bash)
        local max=$(( esperado * 110 / 100 ))
        local min=$(( esperado * 90 / 100 ))

        if [ "$atual" -gt "$max" ]; then echo "MAIOR"
        elif [ "$atual" -lt "$min" ]; then echo "MENOR"
        else echo "OK"; fi
    else
        echo "ERRO"
    fi
}
#########################################################################
function verificar_iconlam() {
    # 1. Parâmetros de entrada
    local HH=$1
    local DATA=$2
    local bkpModelDir=$3
    local modelBaseName=$4
    local expectedMain=$5   # Tamanho esperado arquivo Principal
    local expectedWave=$6   # Tamanho esperado Wave 1
    local expectedWavePS=$7 # Tamanho esperado Wave 2

    # 2. Definição dos caminhos
    local fMain="$bkpModelDir/${modelBaseName}_${HH}_${DATA}${defaultSuffix}"
    local fWave="$bkpModelDir/${modelBaseName}_${HH}_wave_${DATA}${defaultSuffix}"
    local fPS="$bkpModelDir/${modelBaseName}_${HH}_wave_ps_${DATA}${defaultSuffix}"

    # 3. Execução e Retorno
    local resMain=$(validar_arquivo "$fMain" "$expectedMain")
    local resWave=$(validar_arquivo "$fWave" "$expectedWave")
    local resPS=$(validar_arquivo "$fPS" "$expectedWavePS")

    # 4. Definindo print
    if [[ $modelBaseName == "iconlam_sam6.5" ]]; then
      echo "ICONLAMSAM (main|wave|wave_ps):     $resMain | $resWave | $resPS"
    elif [[ $modelBaseName == "iconlam_ant6.5" ]]; then
      echo "ICONLAMANT (main|wave):             $resMain | $resWave"
    elif [[ $modelBaseName == "iconlam_sse2.1" ]]; then
      echo "ICONLAMSSE (main):                  $resMain"
    elif [[ $modelBaseName == "iconlam_pen2.1" ]]; then
      echo "ICONLAMPEN (main):                  $resMain"
    else
      echo "ERROR! Nome base não encontrado!"
      echo "Entre com iconlam_sam6.5, iconlam_ant6.5, iconlam_sse2.1 ou iconlam_pen2.1."
      exit 2
    fi
}
#########################################################################
function verificar_icon13km() {
    # 1. Parâmetros de entrada
    local HH=$1
    local DATA=$2
    local bkpModelDir=$3
    local modelBaseName=$4
    local expectedMain=$5   # Tamanho esperado arquivo Principal

    # 2. Definição dos caminhos
    local fMain="$bkpModelDir/${modelBaseName}_${DATA}_${HH}${defaultSuffix}"

    # 3. Execução e Retorno
    local resMain=$(validar_arquivo "$fMain" "$expectedMain")

    # 4. Definindo print
    if [[ $modelBaseName == "icon_global_icosahedral" ]]; then
      echo "ICON13KM:                           $resMain"
    else
      echo "ERROR! Nome base não encontrado!"
      echo "Entre com icon_global_icosahedral."
      exit 2
    fi
}
#########################################################################
function verificar_dwdinput() {
    # 1. Parâmetros de entrada
    local HH=$1
    local DATA=$2
    local bkpModelDir=$3
    local modelBaseName=$4
    local expectedMain=$5   # Tamanho esperado arquivo Principal

    # 2. Definição dos caminhos
    local fMain="$bkpModelDir/${modelBaseName}_${DATA}${HH}${defaultSuffix}"

    # 3. Execução e Retorno
    local resMain=$(validar_arquivo "$fMain" "$expectedMain")

    # 4. Definindo print
    if [[ $modelBaseName == "icon4iconlamsam" ]]; then
      echo "ICON4ICONLAMSAM:                    $resMain"
    elif [[ $modelBaseName == "icon4iconlamant" ]]; then
      echo "ICON4ICONLAMANT:                    $resMain"
    else
      echo "ERROR! Nome base não encontrado!"
      echo "Entre com icon4iconlamsam ou icon4iconlamant."
      exit 2
    fi
}
#########################################################################
echo "
#########################################################################
#    RESUMO DA VERIFICAÇÃO DOS DADOS DO BACKUP DOS ICON'S NA DPNS42:    #
#                           - $DATA/$HH -                             #
#########################################################################"

echo ""

#################################
# ICON13KM
DIRICON13KM="$bkp_dir/backup_icon/bkp_icon13km"
REFSIZEICON13KM=11100000000
MODELBASENAMEICON13KM='icon_global_icosahedral'

verificar_icon13km $HH $DATA $DIRICON13KM $MODELBASENAMEICON13KM $REFSIZEICON13KM

#################################
# ICON4ICONLAMSAM
DIRICON4ICONLAMSAM="$bkp_dir/backup_icon/bkp_input_icon4iconlam_sam"
REFSIZEICON4ICONLAMSAM=24500000000
MODELBASENAMEICON4ICONLAMSAM='icon4iconlamsam'

verificar_dwdinput $HH $DATA $DIRICON4ICONLAMSAM $MODELBASENAMEICON4ICONLAMSAM $REFSIZEICON4ICONLAMSAM

#################################
# ICON4ICONLAMANT
DIRICON4ICONLAMANT="$bkp_dir/backup_icon/bkp_input_icon4iconlam_ant"
REFSIZEICON4ICONLAMANT=3700000000
MODELBASENAMEICON4ICONLAMANT='icon4iconlamant'

verificar_dwdinput $HH $DATA $DIRICON4ICONLAMANT $MODELBASENAMEICON4ICONLAMANT $REFSIZEICON4ICONLAMANT

#################################
# ICONLAMSAM
DIRICONLAMSAM="$bkp_dir/backup_icon/bkp_output_iconlam/sam"
REFSIZEICONLAMSAM=9289158069
REFSIZEICONLAMSAMWAVE=240000000
REFSIZEICONLAMSAMWAVEPS=430000
MODELBASENAMEICONLAMSAM='iconlam_sam6.5'

verificar_iconlam $HH $DATA $DIRICONLAMSAM $MODELBASENAMEICONLAMSAM $REFSIZEICONLAMSAM $REFSIZEICONLAMSAMWAVE $REFSIZEICONLAMSAMWAVEPS

#################################
# ICONLAMANT
DIRICONLAMANT="$bkp_dir/backup_icon/bkp_output_iconlam/ant"
REFSIZEICONLAMANT=3910098897
REFSIZEICONLAMANTWAVE=21250637
MODELBASENAMEICONLAMANT='iconlam_ant6.5'

verificar_iconlam $HH $DATA $DIRICONLAMANT $MODELBASENAMEICONLAMANT $REFSIZEICONLAMANT $REFSIZEICONLAMANTWAVE

#################################
# ICONLAMSSE
DIRICONLAMSSE="$bkp_dir/backup_icon/bkp_output_iconlam/sse"
REFSIZEICONLAMSSE=4819508670
MODELBASENAMEICONLAMSSE='iconlam_sse2.1'

verificar_iconlam $HH $DATA $DIRICONLAMSSE $MODELBASENAMEICONLAMSSE $REFSIZEICONLAMSSE

#################################
# ICONLAMPEN
DIRICONLAMPEN="$bkp_dir/backup_icon/bkp_output_iconlam/pen"
REFSIZEICONLAMPEN=2000000000 # 2046296890
MODELBASENAMEICONLAMPEN='iconlam_pen2.1'

verificar_iconlam $HH $DATA $DIRICONLAMPEN $MODELBASENAMEICONLAMPEN $REFSIZEICONLAMPEN

#########################################################################
echo "
#-----------------------------------------------------------------------#
#                                LEGENDA                                #
#-----------------------------------------------------------------------#

# OK - Arquivo está no diretório e dentro do tamanho esperado.
# MENOR - Arquivo no diretório, mas é 10% menor que o tamanho esperado.
# MAIOR - Arquivo no diretório, mas é 10% maior que o tamanho esperado.
# ERRO - Arquivo não está no diretório.
#########################################################################"
