#!/bin/bash -x

if [ $# -ne 1 ] && [ $# -ne 3 ] && [ $# -ne 4 ];then
        echo "Entre com "ope" para rodar o script para 1 mes atras, ou com o dia inicial e final (AAAAMMDD) e/ou 'n' para NAO enviar email:"
        echo "Exemplo:	./planilha_conf_backupmensal.sh ope"
        echo "		ou"
        echo "		./planilha_conf_backupmensal.sh nope 20200515 20200910"
        echo "		ou"
        echo "		./planilha_conf_backupmensal.sh nope 20200515 20200910 n"
	exit 1
fi

# Lendo as INF passadas.
RR=$1
DI=$2
DF=$3
ML=$4

# Obtendo data atual, data inicial, num de dias entre a data corrente e a data inicial.
# Este procedimento eh NEC FIM possibilitar fazer tabelas para periodos interanuais.
if [ $RR = "ope" ];then
	df=`date +%Y%m%d`;echo "Data Final:	$df"
	dfa=`date +%s`
	di=`/home/admbackup/scripts/caldate $df - 1m 'yyyymmdd'`;echo "Data Inicial:	$di"
	dia=`date -d $di +%s`
	ndias=`echo " ($dfa-$dia) / 86400 " | bc`;echo "Num dias:	$ndias"
else
	df=$DF;echo "Data Final:	$df"
	dfa=`date -d $df +%s`
	di=$DI;echo "Data Inicial:	$di"
	dia=`date -d $di +%s`
	ndias=`echo $(( (( $(date -d $dfa +%s) - $(date -d $dia +%s) ) / 86400) + 1 ))`;echo "Num dias a partir da data inicial:	$ndias"

fi

# Criando string para ser utilizada no looping
rodada="00 12"

for HH in $rodada;do

	echo 
	echo Verificando as rodadas de $HH ...
	echo 

	d=0
	while [ $d -le $ndias ];do
		DATA=`/home/admbackup/scripts/caldate $di + ${d}d 'yyyymmdd'`
		echo Rodando script para: $HH e $DATA
		/home/admbackup/scripts/planilha_conf_backup.sh $HH $DATA n
		d=$((d+1))
	done

done

# Enviando email com Planilha em anexo
echo Segue Planilha de Conferencia de Backup consolidada do mes anterior em anexo. | mail -a ~/scripts/planilha/Conf_Backup_`echo "${DATA:0:6}"`.txt -s "Conferencia Backup DPN - $DATA$HH" felipenc2@gmail.com thaisguilhon@gmail.com acarol.meteoro@gmail.com supervisorch13@gmail.com alana@marinha.mil.br damiao.andre@marinha.mil.br liana.bittencourt@marinha.mil.br
echo "Enviei Relatorio Backup Mensal para emails cadastrados!!!"
