#!/bin/bash

#set -euo pipefail

# Função de Ajuda/Manual
show_help() {
    cat << EOF
USO:
    $(basename "$0") [HORARIO] [DOMINIO] [DATA_OPCIONAL]

DESCRIÇÃO:
    Realiza o backup e sincronização de dados ICONLAM para os domínios SAM ou ANT.
    O script valida a data dos arquivos e o número de variáveis (GRIB) antes de
    compactar e enviar via rsync.

ARGUMENTOS:
    HORARIO         Horário de referência da rodada (00 ou 12).
    DOMINIO         Domínio de processamento (sam ou ant).
    DATA_OPCIONAL   Data no formato AAAAMMDD. 
                    Se omitida, utiliza a data de 3 horas atrás.

VALIDAÇÕES:
    - Verifica existência de icon_new.bz2
    - Valida dataDate via grib_ls
    - Valida número de variáveis (Ref: 917) via grib_count
    - Timeout: 6 horas (720 tentativas de 30s)

EXEMPLOS:
    $0 00 sam
    $0 12 ant 20231027

SAÍDA:
    0  - Sucesso
    12 - Erro de argumentos
    13 - Domínio inválido
    2  - Erro fatal (dados inconsistentes ou timeout)
EOF
}

# Verificação de argumentos
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    show_help
    exit 12
fi

HH="$1"
DOM="$2"

if [ $# -eq 2 ];then
  datacorrente=$(date -d "3 hours ago" +%Y%m%d)
else
  datacorrente="$3"
fi

case "$DOM" in
    ant)
        domBaseName="ant"
        min_file_size=3453258880  # Ref: 3483258880
        ;;
    sam)
        domBaseName="sam"
        min_file_size=24792825600 # Ref: 24892825600
        ;;
    *)
        echo "Domínio inválido: $DOM"
        exit 13
        ;;
esac

numVarsRef="917"
srcDir="/data2/opicon_data/${domBaseName}_dwdinput${HH}"
srcDir_bkp="/home/admbackup/scripts/workdir/${domBaseName}"
rsyncdir42="/data2/backup/backup_icon/bkp_input_icon4iconlam_${domBaseName}"
filename="icon4iconlam${domBaseName}_"
ndaystokeep=1

nmax=720
sleeptime=30
ntent=1

echo "Iniciando backup ICONLAM $HH $DOM"
echo "Data corrente esperada: $datacorrente"
echo "Hora: `date`"

echo "Limpando dir ${srcDir_bkp}..."
rm -f ${srcDir_bkp}/*bz2 ${srcDir_bkp}/igfff*

while (( ntent <= nmax )); do

    echo "Tentativa ${ntent}/${nmax}"

    # Verifica se arquivo existe antes de copiar
    if [[ ! -f "${srcDir}/icon_new.bz2" ]]; then
        echo "icon_new.bz2 ainda não disponível."
        sleep "$sleeptime"
        ((ntent++))
        continue
    fi

    # Extrai data sem descompactar para disco
    cd "$srcDir_bkp"
    data=$(bzcat "${srcDir}/icon_new.bz2" | head -1)
    
    cp -v "${srcDir}"/igfff05000000.bz2 "${srcDir_bkp}/"
    bunzip2 "${srcDir_bkp}"/igfff05000000.bz2
    numVars=$(grib_count "${srcDir_bkp}"/igfff05000000)
    dataLast=$(grib_ls -p dataDate "${srcDir_bkp}"/igfff05000000 | head -3 | tail -1 | xargs)

    if [[ "$data" == "$datacorrente" ]] && \
       [[ "$dataLast" == "$datacorrente" ]] && \
       [[ "$numVars" == "$numVarsRef" ]]; then
        echo "Data correta encontrada para icon_new.bz2 e igfff05000000."
        echo "Copiando dados de ${srcDir}/i* para ${srcDir_bkp}/..."
        cp -v "${srcDir}"/i* "${srcDir_bkp}/"

        tarfile="${filename}${datacorrente}${HH}.tar.bz2"
        echo "Compactando arquivos icon_new.bz2 ig?ff0???0000.bz2 em $tarfile..."
        tar -cvf "$tarfile" icon_new.bz2 ig?ff0???0000.bz2

        echo "Backup criado: $tarfile"
        break
    else
	echo "Data ($data|$dataLast =! Ref: $datacorrente) e/ou numero de vars incorreto ($numVars =! Ref: $numVarsRef). Esperando..."
	rm -f ${srcDir_bkp}/*bz2 ${srcDir_bkp}/igfff*
        sleep "$sleeptime"
        ((ntent++))
    fi
done

if (( ntent > nmax )); then
    echo "FATAL: Dados corretos não chegaram após 6h."
    exit 2
fi

echo "Enviando para dpns42..."
rsync -av --progress --size-only ${srcDir_bkp}/*.tar.bz2 $rsyncdir42/ && echo Limpando dir ${srcDir_bkp}... && rm -f ${srcDir_bkp}/*bz2 ${srcDir_bkp}/igfff*

echo "Hora: `date`"
echo "Fim do backup."
