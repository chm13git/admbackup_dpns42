#!/bin/bash -x
#########################################################################
# Script para verificacao de dados faltantes no Backup dos modelos ICON13KM, ICONLAM_SAM, ICONLAM_ANT, WRFMET e WRFANT#
# Adaptado pela 2SG-ME VANESSA VALENTIM em 03MAR2026 para o backup dos produtos de modelagem#
#########################################################################

BASE="/data2/backup/backup_supervisor"
DESTINO="/home/admbackup/scripts/dados faltantes - produtos de modelagem"

ANO="$1"
MES="$2"
DATA_INI="$3"
DATA_FIM="$4"

# ---------------- VALIDAÇÕES ----------------

if [ -z "$ANO" ] || [ -z "$MES" ] || [ -z "$DATA_INI" ] || [ -z "$DATA_FIM" ]; then
    echo "Uso: $0 ANO MES YYYYMMDD YYYYMMDD"
    exit 1
fi

DIR="$BASE/$ANO/$MES"

if [ ! -d "$DIR" ]; then
    echo "Diretório inexistente: $DIR"
    exit 1
fi

# Converte datas para epoch
EPOCH_INI=$(date -d "$DATA_INI" +%s 2>/dev/null)
EPOCH_FIM=$(date -d "$DATA_FIM" +%s 2>/dev/null)

if [ -z "$EPOCH_INI" ] || [ -z "$EPOCH_FIM" ]; then
    echo "Erro na conversão das datas. Use formato YYYYMMDD."
    exit 1
fi

if [ "$EPOCH_INI" -gt "$EPOCH_FIM" ]; then
    echo "DATAINICIAL maior que DATAFINAL."
    exit 1
fi

# ---------------- CONFIGURAÇÃO ----------------

# 1.1 GB em bytes (1.1 * 1024^3)
LIMITE=1181116006

# Garante diretório destino
mkdir -p "$DESTINO"

RELATORIO="$DESTINO/Relatorio_dados_faltantes_${MES}.txt"

# ---------------- INÍCIO RELATÓRIO ----------------

echo "RELATÓRIO DE VERIFICAÇÃO" > "$RELATORIO"
echo "Ano: $ANO" >> "$RELATORIO"
echo "Mês: $MES" >> "$RELATORIO"
echo "Período: $DATA_INI até $DATA_FIM" >> "$RELATORIO"
echo "Execução: $(date)" >> "$RELATORIO"
echo "--------------------------------------------------" >> "$RELATORIO"

# ---------------- PROCESSAMENTO ----------------

EPOCH_ATUAL="$EPOCH_INI"

TOTAL_OK=0
TOTAL_AUSENTE=0
TOTAL_INCOMPLETO=0

while [ "$EPOCH_ATUAL" -le "$EPOCH_FIM" ]; do

    DATA_ATUAL=$(date -d "@$EPOCH_ATUAL" +%Y%m%d)
    PASTA="$DIR/$DATA_ATUAL"

    if [ ! -d "$PASTA" ]; then
        echo "$DATA_ATUAL - DADOS AUSENTES" >> "$RELATORIO"
        TOTAL_AUSENTE=$((TOTAL_AUSENTE + 1))
    else
        TAM=$(du -sb "$PASTA" 2>/dev/null | awk '{print $1}')
        if [ "$TAM" -lt "$LIMITE" ]; then
            echo "$DATA_ATUAL - DADOS INCOMPLETOS" >> "$RELATORIO"
            TOTAL_INCOMPLETO=$((TOTAL_INCOMPLETO + 1))
        else
            echo "$DATA_ATUAL - OK" >> "$RELATORIO"
            TOTAL_OK=$((TOTAL_OK + 1))
        fi
    fi

    EPOCH_ATUAL=$((EPOCH_ATUAL + 86400))

done

# ---------------- RESUMO FINAL ----------------

{
echo "--------------------------------------------------"
echo "Resumo:"
echo "OK: $TOTAL_OK"
echo "AUSENTE: $TOTAL_AUSENTE"
echo "DADOS INCOMPLETOS: $TOTAL_INCOMPLETO"
echo "--------------------------------------------------"
} >> "$RELATORIO"

echo "Relatório gerado em: $RELATORIO"



 echo "Finalizada a busca pelos dados deste mês"
# echo " Isto é um e-mail de teste" | mail -s "Assunto: Dados faltantes do Backup do COSMO MET " thais.guilhon@marinha.mil.br 
