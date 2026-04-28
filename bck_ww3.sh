#!/bin/bash

## ---------------------------------------
# Script que limpa o diretorio e subdiretorios de backup
# O backup é realizado pelo script "pos_proc.py" na DPNS-31
# Autor: 1°T(RMS-T) Ferreira
# Data: 19/10/2021
## ________________________________________

function limpa(){
        diretorio=$1
	dias=$2
        # Apagando todos os arquivos antigos (Exemplo: mais de 720 dias = 2 anos):
        for i in `find ${diretorio} -mtime +${dias} -type f`; do rm -fv $i; done
}

dir='/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/'
dias='720'
limpa $dir $dias


