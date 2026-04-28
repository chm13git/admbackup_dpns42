#!/bin/bash -x
export LANG=pt_BR.utf8
#########################################################################
# Este script eh responsavel por VRF se os dados de backup
# foram realizados e envia uma planilha diariamente
# para os emails cadastrados
#
# Autores: 1T(RM2-T)LUZ e CB-ME ALVES em 25mar2020.
# Alt1: Ten Neris em 15mai2020.
# Alt2: Ten Neris em 26jun2020.

# Pendencias:
# 1. Inserir opcao de verificar qualquer dia anterior.
# 
#########################################################################

if [ $# -ne 2 ] && [ $# -ne 3 ];then
        echo "Entre com o modo 'ope' e o dia (AAAAMMDD) ou o mes (AAAAMM), ex.:"
        echo
        echo "	./sheetgen.sh ope 20200911"
        echo "	ou"
        echo "	./sheetgen.sh ope 202012"
	echo
	echo "ou com o modo 'per' e os dias inicial e final (AAAAMMDD), ex.:"
        echo 
        echo "	./sheetgen.sh per 20201201 20210120"
	exit 1
fi

RR=$1
D1=$2
D2=$3

# Caminho para os arquivos de planilha de saida mensal
dirout=/home/admbackup/scripts/planilhas

# Define padrão da saida para o arquivo de texto
header="%29s %11s %6s %6s %6s %7s %8s %15s %15s %8s %10s %10s %12s %11s %11s %15s %11s %11s %15s %12s %12s %16s\n"

# Definindo variaveis para o dia corrente
# Datas. Exemplos para data=20200429
#	asis=`date +'%Y'`	# 2020
#	msis=`date +'%m'`	# 04
#	mmsis=`date +'%B'`	# abril
#	dsis=`date +'%d'`	# 29
#	hsis=`date +'%H'`	# Hora do sistema (11, para 11Z)
#	dtsis=$asis$msis$dsis	# 20200429
#	mesano=$mmsis$asis	# abril2020
#
#	DATA=`date +%Y%m%d`	# 20200429
#	dia_semana=`date +%A`	# segunda, terça etc
#	echo "Data de hoje $DATA, $dia_semana" 

# Verificando se a var D2 foi passada.
# Caso NEG, ele ira executar 
if [ $RR = ope ] && [ ${#D1} -eq 6 ];then
	DATA=$D1	# 20200429
	aaaamm=`date -d "$DATA -1 month" +%Y%m`
	plan="${dirout}/conf_bkp_ope_mensal_${aaaamm}.txt"
	echo "Foi passada uma data sem do dia ($DATA), logo vou rodar no modo OPERACIONAL MENSAL!"
	echo 
	echo "Data REF usada: $DATA"
	echo "Planilha: $plan"
	echo 
	
elif [ $RR = ope ] && [ ${#D1} -eq 8 ];then
	DATA=$D1        # 20200429
        aaaamm=`date -d "$DATA -0 month" +%Y%m`
        plan="${dirout}/conf_bkp_ope_${aaaamm}.txt"
	echo "Foi passada uma data completa ($DATA), logo vou rodar no modo OPERACIONAL DIARIO!"
        echo
        echo "Data REF usada: $DATA"
        echo "Planilha: $plan"
        echo

elif [ $RR = per ];then
	di=$D1
        df=$D2
        plan="${dirout}/conf_bkp_od_${di}_${df}.txt"
        echo "Foram passadas 02 datas no modo 'per', logo vou rodar no modo PERIODOS SOB DEMANDA!"
        echo
        echo "Datas usadas: $di ate $df "
        echo "Planilha: $plan"
        echo
else
	echo "ERRO! Opcao invalida!"
	echo "Dica: Reveja as datas e o modo de execucao do script!"
fi


# Cria um arq TXT, caso nao exista, e add um cabecalho para as colunas.
if [ -f $plan ];then
	echo 'Planilha ja existente! Os dados serao apendados...'
else
	# Inserir aqui os dados do HYCOM futuramente!
	printf "$header" "DATAVRF                     " "DATAHORA  " "DPNS31" "DPNS41" "DPNS35" "DPNS05d" "ICON13KM" "ICON4ICONLAMSAM" "ICON4ICONLAMANT" "COSMOMET" "ICONLAMSAM" "ICONLAMANT" "ICONLAMSSE21" "WW3ICONMET" "WW3ICONANT" "WW3ICONBRCOAST" "WW3GFSMET" "WW3GFSANT" "WW3GFSBRCOAST" "WW3ICLMMET" "WW3ICLMANT" "WW3ICLMBRCOAST" > $plan
fi

#########################################################################
# Escrevendo na planilha de conferencia
########################################################################

# Gravando linha de resultado da checagem na planilha.
cat bkpcheckout.txt
cat bkpcheckout.txt >> $plan

printf "\n" >> $plan

# Removendo o arquivo de checagem.
rm bkpcheckout.txt

exit
