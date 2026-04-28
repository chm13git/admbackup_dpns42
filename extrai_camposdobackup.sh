#!/bin/bash

## CB - LILIAN ACIOLY - 30/07/2019
#################

mes=(agosto setembro)
mesn=(08 09)
ano=2019
HH=12

caminho='/home/admbackup/backup_supervisor'
jogadados='/home/admbackup/backup_supervisor/retrieve_data'
	q=0
	while [ $q -le 2 ]; do
		if [ ${mesn[q]} -eq 08 ] || [ ${mesn[q]} -eq 09 ]; then
		dia=1
			while [ $dia -le 31 ]; do
			  if [ $dia -le 9 ]; then
                                        cd ${jogadados} ; mkdir 0$dia${mesn[q]}$ano
cp ${caminho}/$ano/${mes[q]}/0$dia${mesn[q]}$ano/cosmomet_${HH}/ventmax_003.gif /home/admbackup/backup_supervisor/retrieve_data/ventmax003_$ano${mesn[q]}0$dia${HH}Z.gif
                                        dia=$((dia+1))
                                else
                                        cd ${jogadados} ; mkdir $dia${mesn[q]}$ano
                                      #  cp ${caminho}/$ano/${mes[q]}/$dia${mesn[q]}$ano/cosmomet_00/ventmax_???.gif  ${jogadados}/$dia${mesn[q]}$ano
cp ${caminho}/$ano/${mes[q]}/$dia${mesn[q]}$ano/cosmomet_${HH}/ventmax_003.gif /home/admbackup/backup_supervisor/retrieve_data/ventmax003_$ano${mesn[q]}$dia${HH}Z.gif
					 dia=$((dia+1))
                                fi

			done
		fi
	q=$((q+1))
	done
exit
