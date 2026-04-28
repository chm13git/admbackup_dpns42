#!/bin/bash -x

if [ $# -ne 1 ] && [ $# -ne 3 ] && [ $# -ne 4 ];then
        echo "Entre com "ope" para rodar o script para 1 mes atras, ou com o dia inicial e final (AAAAMMDD) e/ou 'n' para NAO enviar email."
	echo
        echo "Opcoes:	./bkpcheck_periods.sh ope (fara a checagem de todo o mes anterior!)"
        echo "		ou"
        echo "		./bkpcheck_periods.sh per 20200515 20200910"
        echo "		ou"
        echo "		./bkpcheck_periods.sh per 20200515 20200910 n"
	exit 1
fi

# Lendo as INF passadas.
RR=$1
DI=$2
DF=$3
ML=$4

# Obtendo data atual, data inicial, num de dias entre a data corrente e a data inicial.
# Este procedimento eh NEC FIM PSB confeccao de tabelas para periodos interanuais.
if [ $RR = "ope" ];then
	mode="Operacional"
	di=`date -d "$(date +%Y-%m-1) -1 month" +%Y%m%d` ;echo "Data Inicial: $di"
	ndias=`cal $(date -d ${di} +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}'`;echo "Num dias do mes anterior: $ndias"
	aaaamm=`/home/admbackup/scripts/caldate $di - 0d 'yyyymm'`
        plan="/home/admbackup/scripts/planilhas/conf_bkp_ope_mensal_${aaaamm}.txt"

else
	mode="Sob Demanda"
	df=$DF;echo "Data Final: $df"
	dfa=`date -d $df +%s`
	di=$DI;echo "Data Inicial: $di"
	dia=`date -d $di +%s`
	ndias=`echo $(( ( $dfa - $dia ) / 86400 + 1 ))`;echo "Num dias a partir da data inicial: $ndias"
	plan="/home/admbackup/scripts/planilhas/conf_bkp_od_${di}_${df}.txt"

fi


# Criando string para ser utilizada no looping
rodada="00 12"

for hh in $rodada;do

	echo 
	echo Verificando as rodadas de $hh ...
	echo 

	dd=0
	while [ $dd -le $ndias ];do

		data=`/home/admbackup/scripts/caldate $di + ${dd}d 'yyyymmdd'`
		echo Rodando script para: $hh e $data
		echo Nao serao enviados emails para cada dia, apenas 1 unico com a planilha anexada.
		/home/admbackup/scripts/bkpcheck.sh per $hh $data n
		echo
		echo Anexando resultado na planilha.
		if [ $RR = ope ]; then

			/home/admbackup/scripts/sheetgen.sh $RR $aaaamm
		else
			/home/admbackup/scripts/sheetgen.sh $RR ${di} ${df}
		fi

		dd=$((dd+1))
	done

done

# Enviando email com Planilha em anexo, caso $ML seja string vazia
if [ -z $ML ];then
	cat ~/scripts/invariantes/legenda_per.txt > corpo
	cat corpo | mail -a $plan -s "Conferencia Backup DPN - Periodo $di a $df ($mode)" `cat /home/admbackup/scripts/invariantes/lista_emailsteste`
	echo "Enviei Relatorio Backup para emails cadastrados!!!"
fi

echo Gerei a seguinte planilha: $plan
echo Fim da Execucao!
echo `date`
