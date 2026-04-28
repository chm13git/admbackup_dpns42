#!/bin/bash

if [ $# -eq 1 ];then
        echo "Entre com o horario"
        echo "Exemplo: ./conferir_dados_rerun.sh 00 ou 12"
        HH=$1
fi

echo "O seguinte parametro foi passado para o script"
echo "HH=$HH"

#entrar com a data inicial de busca
AMD=20170101

#definindo os diretorios de busca
DIRBCK="/data2/backup_cosmo/metarea5/dados${HH}"
DIRRERUN="/data1/cosmo_rerun2/metarea5/data/backup${HH}"

#definindo o tamanho de referencia
TAMREF=1900000
EXT=bz2

#definindo o numero de dias para frente da data inicial que serao buscados
numero_dias=920

#Definido a data

n=0
while [ ${n} -le ${numero_dias} ]
do
yy=$(/bin/date --date='+'$n'day'${AMD} +%Y)
mm=$(/bin/date --date='+'$n'day'${AMD} +%m)
di=$(/bin/date --date='+'$n'day'${AMD} +%d)

echo
echo "Data ${yy}${mm}${di}"

cd ${DIRRERUN}

#buscando rodada do rerun
if [ -f ${DIRRERUN}/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.bz2 ]; then

	arq1="`stat -c "%n" cosmomet_07km_${HH}_${yy}${mm}${di}.tar.bz2`"

	cd ${DIRBCK}

	if [ -f ${DIRBCK}/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.bz2 ]; then
	arq2="`stat -c "%n" cosmomet_07km_${HH}_${yy}${mm}${di}.tar.bz2`"
#verificando se existe no rerun e no backup 
		if [ $arq1 == $arq2 ] 
		then
		echo "Existe o arquivo ${yy}${mm}${di} no rerun e backup";
		tam1=`du -s $DIRRERUN/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.${EXT} | awk '{ print $1 }'`
                 
#verificando tamanho dos aqruivos
			if [ $tam1 -le $TAMREF ];then
                        echo "$DATA RERUN com tamanho ERRADO"
			else
			echo "$DATA RERUN com tamanho ok"
			fi
		tam2=`du -s $DIRBCK/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.${EXT} | awk '{ print $1 }'`
                        if [ $tam2 -le $TAMREF ];then
                        echo "$DATA BACKUP com tamanho ERRADO"
#                        scp $DIRRERUN/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.${EXT} $DIRBCK/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.${EXT}
			else
                        echo "$DATA BACKUP com tamanho ok"
                        fi
		else 
		echo "Existe, mas não são iguais ${yy}${mm}${di}";
		fi

	else
	echo "O arquivo ${yy}${mm}${di} EXISTE NO RERUN E NAO EXISTE NO BACKUP"
#	scp $DIRRERUN/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.${EXT} $DIRBCK/cosmomet_07km_${HH}_${yy}${mm}${di}.tar.${EXT}
	echo "O arquivo ${yy}${mm}${di} FOI COPIADO PARA O BACKUP"
	fi

else
echo "Nao existe rodada de rerun"
fi
  
n=`expr $n + 1`
 
done 

