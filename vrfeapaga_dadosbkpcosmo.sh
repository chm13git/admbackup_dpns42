#!/bin/bash

#### SCRIPT PARA VRF TAMANHO E APAGAR POR DATA ANTERIOR #########
#########################################################################
# Loop para mostrar dados menores que o tamanho normal e deletar dados 
# em datas anteriores a periodicidade necessaria do Backup da saida    
# para COSMOMET e COSMOANT na DPNS33
# Elaborado pela 1T(RM2-T) Luz em 24mar2020 - ALT 13abr2020
# ALT 03ago2021 - CT Neris						
#########################################################################

if [ $# -ne 2 ];then
        echo "Entre com o horario e o modelo"
        echo "Exemplo: ./apaga_tamanho_anteriores.sh 00/12 met/ant"
        exit 111
fi

HH=$1
GRID=$2


# Diretorios
D_FALT="/home/admbackup/scripts/dados_faltantes"


echo "Os seguintes parametros foram passados para o script:"
echo "HH=$HH"
echo "GRID=$GRID"

echo #Calcular a data inicial de busca (data atual)
DATA=`date +%Y%m%d`
echo "Data de hoje: $DATA"


if [ $GRID == 'met' ]; then

	################ PARA COSMOMET ###############
	# Apagando o arquivo de dados faltantes de 14 dias atras
	DATA14d=`/home/admbackup/scripts/caldate $DATA - 14d  'yyyymmdd'`
	echo
	echo "Data para apagar do Backup $DATA14d"
	echo
	rm ${D_FALT}/lista_faltantes_COSMOMET_${DATA14d}_${HH}.txt

	#definindo os diretorios de busca 
	DIRBKP="/data1/backup/backup_cosmo/metarea5/dados${HH}"

	#definindo o tamanho de referencia
	TAMREF=1900000

	# Definindo num dias anteriores que serao mantidos
	# 3 anos e 6 meses sao 42 meses ou aprox 1277 dias
	nmes=42

	DATABKP=`date -d "$DATA -${nmes} month" +%Y%m%d`
	echo  
	echo "Data inicial do Backup COSMOMET deve ser: $DATABKP"
	echo
	cd ${DIRBKP}

	# Colocar um valor maior que n para o while calcular o menor que
	faltantes=0
	DATAVRF=`date -d "$DATABKP +1 day" +%Y%m%d`
	while [ ${DATAVRF} -le ${DATA} ]; do

	        echo "Verificando dia ${DATAVRF}..."

		# Conferencia de tamanho dos arquivos a serem destacados para futuro RERUN
		echo "cosmomet_07km_${HH}_${DATAVRF}.tar.bz2"
		tam=`du -s $DIRBKP/cosmomet_07km_${HH}_${DATAVRF}.tar.bz2 | awk '{ print $1 }'`

		if [ -f ${DIRBKP}/cosmomet_07km_${HH}_${DATAVRF}.tar.bz2 ]; then	
			if [ $tam -lt $TAMREF ];then
    				echo "ERRO BACKUP $DIRBKP/cosmomet_07km_${HH}_${DATAVRF}.tar.bz2!!!"
				echo "Tamanho MENOR, vou destacar para /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOMET_'${DATA}'_'${HH}'.txt"
				echo TAMANHO_MENOR_cosmomet_07km_${HH}_${DATAVRF}.tar.bz2 >> /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOMET_'${DATA}'_'${HH}'.txt
				echo
				faltantes=`expr $faltantes + 1`
			else
				echo "Dado com tamanho normal"
	        		echo
			fi
		else
			faltantes=`expr $faltantes + 1`
    			echo "ERRO BACKUP $DIRBKP/cosmomet_07km_${HH}_${DATAVRF}.tar.bz2!!!"
			echo "Dado INEXISTENTE, vou destacar para /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOMET_'${DATA}'_'${HH}'.txt"
			echo FALHA_cosmomet_07km_${HH}_${DATAVRF}.tar.bz2 >> /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOMET_'${DATA}'_'${HH}'.txt
			echo
		fi
	        DATAVRF=`date -d "$DATAVRF +1 day" +%Y%m%d`

	done

	echo "##################################################################"
	echo "# APAGANDO dados anteriores ao limite de ${nmes} meses do COSMOMET"
	echo "##################################################################"
	echo

	echo "Deltando os 10 dias anteriores a primeira data do backup ($DATABKP)"
	ndiasdel=10
	while [ ${ndiasdel} -gt 0 ]; do

	        DATADEL=`date -d "$DATABKP -${ndiasdel} day" +%Y%m%d`
        	echo "Deletando cosmomet_07km_${HH}_${DATADEL}.tar.bz2..."

		if [ -f ${DIRBKP}/cosmomet_07km_${HH}_${DATADEL}.tar.bz2 ]; then
	                rm ${DIRBKP}/cosmomet_07km_${HH}_${DATADEL}.tar.bz2
        	        echo "Dado deletado."
			echo
        	else
	                echo "Dado ja nao existe."
			echo
        	fi

		ndiasdel=`expr ${ndiasdel} - 1`
	done

else

	############## PARA COSMOANT #################
        # Apagando o arquivo de dados faltantes de 14 dias atras
        DATA14d=`/home/admbackup/scripts/caldate $DATA - 14d  'yyyymmdd'`
        echo
        echo "Data para apagar do Backup $DATA14d"
        echo
        rm ${D_FALT}/lista_faltantes_COSMOANT_${DATA14d}_${HH}.txt

        #definindo os diretorios de busca
        DIRBKP="/data1/backup/backup_cosmo/antartica/dados${HH}"

        #definindo o tamanho de referencia
	TAMREF=495000

        # Definindo num dias anteriores que serao mantidos
        # 9 meses sao aprox 270 dias, deixei 10 para sobrar um pouco
        nmes=10

        DATABKP=`date -d "$DATA -${nmes} month" +%Y%m%d`
        echo
        echo "Data inicial do Backup COSMOANT deve ser: $DATABKP"
        echo
        cd ${DIRBKP}

        # Colocar um valor maior que n para o while calcular o menor que
        faltantes=0
	DATAVRF=`date -d "$DATABKP +1 day" +%Y%m%d`
        while [ ${DATAVRF} -le ${DATA} ]; do

                echo "Verificando dia ${DATAVRF}..."

                # Conferencia de tamanho dos arquivos a serem destacados para futuro RERUN
                echo "cosmoant_10km_${HH}_${DATAVRF}.tar.bz2"
                tam=`du -s $DIRBKP/cosmoant_10km_${HH}_${DATAVRF}.tar.bz2 | awk '{ print $1 }'`

                if [ -f ${DIRBKP}/cosmoant_10km_${HH}_${DATAVRF}.tar.bz2 ]; then
                        if [ $tam -lt $TAMREF ];then
                                echo "ERRO BACKUP $DIRBKP/cosmoant_10km_${HH}_${DATAVRF}.tar.bz2!!!"
                                echo "Tamanho MENOR, vou destacar para /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOANT_'${DATA}'_'${HH}'.txt"
                                echo TAMANHO_MENOR_cosmoant_10km_${HH}_${DATAVRF}.tar.bz2 >> /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOANT_'${DATA}'_'${HH}'.txt
                                echo
                                faltantes=`expr $faltantes + 1`
                        else
                                echo "Dado com tamanho normal"
                                echo
                        fi
                else
                        faltantes=`expr $faltantes + 1`
                        echo "ERRO BACKUP $DIRBKP/cosmoant_10km_${HH}_${DATAVRF}.tar.bz2!!!"
                        echo "Dado INEXISTENTE, vou destacar para /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOANT_'${DATA}'_'${HH}'.txt"
                        echo FALHA_cosmoant_10km_${HH}_${DATAVRF}.tar.bz2 >> /home/admbackup/scripts/dados_faltantes/lista_faltantes_COSMOANT_'${DATA}'_'${HH}'.txt
                        echo
                fi
                DATAVRF=`date -d "$DATAVRF +1 day" +%Y%m%d`

        done

        echo "##################################################################"
        echo "# APAGANDO dados anteriores ao limite de ${nmes} meses do COSMOANT"
        echo "##################################################################"
        echo

        echo "Deltando os 10 dias anteriores a primeira data do backup ($DATABKP)"
        ndiasdel=10
        while [ ${ndiasdel} -gt 0 ]; do

                DATADEL=`date -d "$DATABKP -${ndiasdel} day" +%Y%m%d`
                echo "Deletando cosmoant_10km_${HH}_${DATADEL}.tar.bz2..."

                if [ -f ${DIRBKP}/cosmoant_10km_${HH}_${DATADEL}.tar.bz2 ]; then
                        rm ${DIRBKP}/cosmoant_10km_${HH}_${DATADEL}.tar.bz2
                        echo "Dado deletado."
                        echo
                else
                        echo "Dado ja nao existe."
                        echo
                fi

                ndiasdel=`expr ${ndiasdel} - 1`
        done

fi
