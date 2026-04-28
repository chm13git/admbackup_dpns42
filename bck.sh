#!/bin/bash

## ---------------------------------------
# Script que limpa o diretorio de backup
# Autor: 1T(RMS-T) Ferreira
# Data: 19/10/2021
## ________________________________________

function limpa(){
        diretorio=$1
	dias=$2
        # Apagando todos os arquivos antigos (mais de 720 dias = 2 anos):
        for i in `find ${diretorio} -mtime +${dias} -type f`; do echo $i; done #substituir "echo" por: rm -fv
}

dir='/mnt/nfs/dpns33/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/'
dias='720'
limpa $dir $dias


