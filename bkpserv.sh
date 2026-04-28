#!/bin/bash -xv

########################################################################################
## Autor: 		CT(T) ALANA e 1T(RM2-T) LUZ	21fev2019 CH13
##
##      Descricao:
##      Script de backup para sincronizar os dados de maquinas sensiveis
##      ao SMM a fim de ser usado para 'subir' uma maquina que venha a
##      dar problema.
##
##      Uso:
##      ./bkp_hpc_alldpns.sh [maquina]
##
##      Exemplo:
##      ./bkp_hpc_alldpns.sh dpns31
##
##      Obs1.: O nome da maquina deve ser o mesmo que consta no arquivo /etc/hosts.
##	Caso se queira incluir um servidor na sincronizacao, inserir seu IP, email e 
##	apelido neste arquivo.
##
##      Dependencias:
##      A) Script 'caldate', que esta em /bin, para gerar a data de remocao dos
##      bkps antigos.
##
##      B) Arquivos /home/admbackup/scripts/direxc/exclusoes/exclude_me_[maquina].txt 
##	contendo os tipos de arquivos que NAO serao copiados. 
##
##      Resultado:
##      Arquivos: /data1/backup/backup_servidores/[maquina]/[maquina]_[yyyymmdd].tar.gz
##      Remove arquivos de 2 semanas atras: [maquina]_[yyyymmdd-14].tar.gz 
## 		
## 	O backup e realizado duas vezes: em dpns33:/data1/backup/backup_servidores e no dir montado /mnt/disco1/ automaticamente (este indisponivel em 03ago21)
##	
##      
##      INFORMACOES DOS PARAMETROS UTILIZADOS NO RSYNC
##      -a, --archive - modo arquivo; igual -rlptgoD (no -H,-A,-X)    
##      -u, --update - Nao sobrescreve arq no destino que possua uma data mais recente
##      -v, --verbose - modo verboso
##      -z, --compress - comprime durante transferência
##      -h, --exibe uma saída mais legível na saída de comando
##      -l, --links - cópia symlinks como symlinks
##      -b, --backup - Nao sobrescreve arquivos que já existam no destino, mas os renomeia 
##          adicionando um sufixo ~ aos seus nomes, antes de executar a transferência de novos arquivos
##
##      INFORMACOES IMPORTANTES SOBRE O EXCLUDE:
##       
##	incluir inf sobre os parametros do rsync
## 	This is some information on filter rules that may help:
##    /dir/ means exclude the root folder /dir (excluir a pasta raiz)
##    /dir/* means get the root folder /dir but not the contents (obter a pasta, mas nao o conteudo)
##     dir/ means exclude any folder anywhere where the name contains dir/ 
##          (excluir qualquer pagina em qualquer lugar que contenha o nome /dir)
##
########################################################################################

if [ $# -ne 1 ];then
        echo "Entre com o nome do servidor a ser sincronizado"
        echo "Exemplo: ./bkpserv.sh dpns41, dpns35c, dpns05d"
        echo " O servidor deve estar listado em /etc/hosts"
	exit 1
fi

MAQ=$1
echo "O seguinte parametro foi passado para o script"
echo "MAQ=$MAQ"
echo
echo "***************************"
echo " Inicio do backup da ${MAQ} - `date`"
echo "***************************"

### Definindo local de salvamento de bkp, direxc e as datas corrente e antiga.

#dirbkp1="/mnt/disco1/backup_hpc_alldpns/${MAQ}"
dirbkp="/data2/backup/backup_servidores/${MAQ}"
direxc="/home/admbackup/scripts/invariantes/exclusoes"
dirinc="/home/admbackup/scripts/invariantes/inclusoes"
data=`date +%Y%m%d`
dataold28d=`/home/admbackup/scripts/caldate ${data} - 28d 'yyyymmdd'`
dataold21d=`/home/admbackup/scripts/caldate ${data} - 21d 'yyyymmdd'`

#for diretorio in $dirbkp1 $dirbkp;do
for diretorio in $dirbkp;do

	echo "Iniciando sincronizacao no dir: ${diretorio}..."
	echo 

        if [ "${MAQ}" = "dpns35c" ];then

                echo ============================================================
                echo " Sincronizando o crontab e os diretorios /home/afdop e /home/operador do servidor ${MAQ}"
                echo Iniciando rsync ${MAQ}... > $diretorio/newfiles_${MAQ}_${data}
                echo `date` >> $diretorio/newfiles_${MAQ}_${data}

                echo Sincronizando afdop@${MAQ}:/home/afdop >> $diretorio/newfiles_${MAQ}_${data}
                echo >> $diretorio/newfiles_${MAQ}_${data}
                rsync -abvzh --out-format="%t %f %'''b" --exclude-from ${direxc}'/exclude_me_'$MAQ'.txt' afdop@${MAQ}:/home/afdop $diretorio/home/ >> $diretorio/newfiles_${MAQ}_${data}

		echo Sincronizando operador@${MAQ}:/home/operador >> $diretorio/newfiles_${MAQ}_${data}
                echo >> $diretorio/newfiles_${MAQ}_${data}
                rsync -abvzh --out-format="%t %f %'''b" --exclude-from ${direxc}'/exclude_me_'$MAQ'.txt' operador@${MAQ}:/home/operador $diretorio/home/ >> $diretorio/newfiles_${MAQ}_${data}
                #rsync -abvzh --out-format="%t %f %'''b" --exclude-from='/home/operador/.cache/' operador@${MAQ}:/home/operador $diretorio/home/ >> $diretorio/newfiles_${MAQ}_${data}

                echo Sincronizando root@${MAQ}:/var/spool/cron/crontabs >> $diretorio/newfiles_${MAQ}_${data}
                rsync -abvzh --out-format="%t %f %'''b" root@${MAQ}:/var/spool/cron/crontabs $diretorio/home/ >> $diretorio/newfiles_${MAQ}_${data}

                echo >> $diretorio/newfiles_${MAQ}_${data}
                echo Fim rsync $MAQ >> $diretorio/newfiles_${MAQ}_${data}
                echo `date` >> $diretorio/newfiles_${MAQ}_${data}


        elif [ "${MAQ}" = "dpns41" ];then


                echo ============================================================
                echo " Sincronizando o crontab e os diretorios do /home/opicon do servidor dpns41"
                echo Iniciando rsync ${MAQ}... > $diretorio/newfiles_${MAQ}_${data}
                echo `date` >> $diretorio/newfiles_${MAQ}_${data}

                echo Sincronizando opicon@${MAQ}:/home/opicon >> $diretorio/newfiles_${MAQ}_${data}
                echo >> $diretorio/newfiles_${MAQ}_${data}
                rsync -abvzh --out-format="%t %f %'''b" --exclude-from ${direxc}'/exclude_me_'$MAQ'.txt' opicon@${MAQ}:/home/opicon $diretorio/home/ >> $diretorio/newfiles_${MAQ}_${data}
		#rsync -abvzh --out-format="%t %f %'''b" --exclude-from=${direxc}'/exclude_me_'$MAQ'.txt' opwrf@${MAQ}:/home/opwrf $diretorio/home/ >> $diretorio/newfiles_${MAQ}_${data}

                echo Sincronizando root@${MAQ}:/var/spool/cron/tabs >> $diretorio/newfiles_${MAQ}_${data}
                rsync -abvzh --out-format="%t %f %'''b" root@${MAQ}:/var/spool/cron/tabs $diretorio/home/cron >> $diretorio/newfiles_${MAQ}_${data}

                echo >> $diretorio/newfiles_${MAQ}_${data}
                echo Fim rsync $MAQ >> $diretorio/newfiles_${MAQ}_${data}
                echo `date` >> $diretorio/newfiles_${MAQ}_${data}


	elif [ "${MAQ}" = "dpns05d" ] || [ "${MAQ}" = "dpns05e" ];then


		echo ============================================================
		echo " Sincronizando os crontabs e diretorios do /home/operador das maquinas de pos-proc"
		echo Iniciando rsync ${MAQ}... > $diretorio/newfiles_${MAQ}_${data}
		echo `date` >> $diretorio/newfiles_${MAQ}_${data}

		echo Sincronizando admcosmo@${MAQ}:/home >> $diretorio/newfiles_${MAQ}_${data}
		echo Sincronizando operador@${MAQ}:/home/operador >> $diretorio/newfiles_${MAQ}_${data}
		echo >> $diretorio/newfiles_${MAQ}_${data} 
	        rsync -abvzh --out-format="%t %f %'''b" --exclude-from ${direxc}'/exclude_me_'$MAQ'.txt' operador@${MAQ}:/home/operador $diretorio/ >> $diretorio/newfiles_${MAQ}_${data}

		echo >> $diretorio/newfiles_${MAQ}_${data}
		echo Sincronizando operador@${MAQ}:/home/operador/grads/ >> $diretorio/newfiles_${MAQ}_${data}
		echo >> $diretorio/newfiles_${MAQ}_${data}
		rsync -abvzh --out-format="%t %f %'''b" --exclude-from ${direxc}'/exclude_me_'$MAQ'.txt' operador@${MAQ}:/home/operador/grads/ $diretorio/operador/grads/ >> $diretorio/newfiles_${MAQ}_${data}

		echo >> $diretorio/newfiles_${MAQ}_${data}
		echo Sincronizando operador@${MAQ}:/home/operador/ftpscript/ >> $diretorio/newfiles_${MAQ}_${data} >> $diretorio/newfiles_${MAQ}_${data}
		echo >> $diretorio/newfiles_${MAQ}_${data}
		rsync -abvzh --out-format="%t %f %'''b" --exclude-from ${direxc}'/exclude_me_'$MAQ'.txt' operador@${MAQ}:/home/operador/ftpscript/ $diretorio/operador/ftpscript/ >> $diretorio/newfiles_${MAQ}_${data}

		echo >> $diretorio/newfiles_${MAQ}_${data}
		echo Sincronizando operador@${MAQ}:/home/operador/ftp_comissoes/ >> $diretorio/newfiles_${MAQ}_${data}
		echo >> $diretorio/newfiles_${MAQ}_${data}
		rsync -abvzh --out-format="%t %f %'''b" --exclude-from ${direxc}'/exclude_me_'$MAQ'.txt' operador@${MAQ}:/home/operador/ftp_comissoes/ $diretorio/operador/ftp_comissoes/ >> $diretorio/newfiles_${MAQ}_${data}

		echo Sincronizando root@${MAQ}:/var/spool/cron/crontabs >> $diretorio/newfiles_${MAQ}_${data}
		rsync -abvzh --out-format="%t %f %'''b" root@${MAQ}:/var/spool/cron/crontabs $diretorio/operador >> $diretorio/newfiles_${MAQ}_${data}

		echo >> $diretorio/newfiles_${MAQ}_${data} 
		echo Fim rsync $MAQ >> $diretorio/newfiles_${MAQ}_${data}
		echo `date` >> $diretorio/newfiles_${MAQ}_${data}
	else
		echo ERRO! Maquina nao cadastrada. 
		echo Dica: VRF se o nome dela esta salvo no /etc/hosts.
       	fi

	echo ============================================================
	echo " Iniciando compactacao dos backups e removendo os anteriores"
	echo `date`

	if [ "${MAQ}" = "dpns35c" ];then
                cd $diretorio
                tar -cvzf ${MAQ}_${data}.tar.gz home newfiles_${MAQ}_${data}
                echo 
                echo " Removendo Backup antigo: ${MAQ}_${dataold28d}.tar.gz..."
                rm -f ${MAQ}_${dataold28d}.tar.gz
                echo 
                echo " Removendo lista de arqs backup antigo: newfiles_${MAQ}_${dataold28d}..."
                rm -f newfiles_${MAQ}_${dataold28d}

        elif [ "${MAQ}" = "dpns41" ];then
                cd $diretorio
                tar -cvzf ${MAQ}_${data}.tar.gz home newfiles_${MAQ}_${data}
                echo 
                echo " Removendo Backup antigo: ${MAQ}_${dataold21d}.tar.gz..."
                rm -f ${MAQ}_${dataold21d}.tar.gz
                echo 
                echo " Removendo lista de arqs backup antigo: newfiles_${MAQ}_${dataold21d}..."
                rm -f newfiles_${MAQ}_${dataold21d}

	elif [ "${MAQ}" = "dpns05d" ] || [ "${MAQ}" = "dpns05e" ];then
		cd $diretorio
       		tar -cvzf ${MAQ}_${data}.tar.gz operador newfiles_${MAQ}_${data}
		echo 
       		echo " Removendo Backup antigo: ${MAQ}_${dataold28d}.tar.gz..."
       		rm -f ${MAQ}_${dataold28d}.tar.gz
		echo 
		echo " Removendo lista de arqs backup antigo: newfiles_${MAQ}_${dataold28d}..."
		rm -f newfiles_${MAQ}_${dataold28d}
	fi

	echo
	echo " Fim da compactacao dos backups e remocao dos anteriores"
	echo `date`

done

echo "Backup ${MAQ} feito" | mail -s "Backup Servidor ${MAQ} (DPNS42)" vanessa.valentim@marinha.mil.br carolina.andrioni@marinha.mil.br lopes.raquel@marinha.mil.br neris@marinha.mil.br alana@marinha.mil.br

echo 
echo "***************************"
echo " Fim do backup da ${MAQ} - `date`"
echo "***************************"
