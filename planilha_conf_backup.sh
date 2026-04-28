#!/bin/bash -x
#source ~/.bashrc
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

if [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 3 ];then
        echo "Entre com a rodada a ser VRF ou com a rodada (00 ou 12), o dia (AAAAMMDD) e/ou 'n' para NAO enviar email:"
        echo "Exemplo:	./planilha_conf_backup.sh 00"
        echo "		ou"
        echo "		./planilha_conf_backup.sh 00 20200515"
        echo "		ou"
        echo "		./planilha_conf_backup.sh 00 20200515 n"
	exit 1
fi

HH=$1
DATA=$2
MAIL=$3
dia_semana=`/home/admbackup/scripts/caldate $DATA - 0d 'sd'`
DATAVRF=`date`
DIAVRF=`date +%Y%m%d`

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

if [ $# -eq 1 ];then
	DATA=`date +%Y%m%d`			# 20200429
	dia_semana=`/home/admbackup/scripts/caldate $DATA - 0d 'sd'`	# Ex.: Domingo, Sabado, Segunda-feira, Terca-feira etc
	echo "Data de hoje $DATA, $dia_semana" 
fi

echo "Os seguintes parametros foram passados para o script:"
echo "HH=$HH"
echo "DATA=$DATA, $dia_semana"
echo "Data e hora da VRF: $DATAVRF"

# Escrevendo var aaaamm
aaaamm=`/home/admbackup/scripts/caldate $DATA - 0d 'yyyymm'`

# Caminho para os arquivos de planilha de saida mensal
dirout=$HOME/scripts/planilhas

# Diretorio de armazenamento dos backups
dirbkpserv="/data1/backup/backup_servidores"

# Define padrão da saida para o arquivo de texto
header="%-29s %-11s %-6s %-7s %-7s %-8s %-11s %-11s %-8s %-10s %-8s %-8s %-11s %-12s %-10s %-10s %-9s %-9s\n"
format="%29s %11s %6s %7s %7s %8s %11s %11s %8s %10s %8s %8s %11s %12s %10s %10s %9s %9s"

# Cria um arq TXT, caso nao exista, e add um cabecalho para as colunas.
if [ -f ${dirout}/Conf_Backup_${aaaamm}.txt ];then
	echo 'Arquivo mensal ja existente'
else
	# Inserir aqui os dados do HYCOM futuramente!
	printf "$header" "DATAVRF                     " "DATAHORA  " "DPNS31" "DPNS05d" "DPNS05e" "ICON13KM" "ICONDATAMET" "ICONDATAANT" "COSMOMET" "COSMOVENTO" "COSMOANT" "COSMOSSE" "WW3COSMOMET" "WW3COSMORJES" "WW3ICONMET" "WW3ICONANT" "WW3GFSMET" "WW3GFSANT" > $dirout/Conf_Backup_${aaaamm}.txt

fi

#-----------------------------------------------------------------------#
# Verifica se os dados estao no diretorio                               #
#-----------------------------------------------------------------------#
# INSERIR VERIFICACAO DO TAMANHO. VER COM ALANA SE 10% DE DIFERENCA E O SUFICIENTE!?
#
#-----------------------------------------------------------------------#
# LEGENDA
# OK - Arquivo no dir e dentro do tamanho esperado.
# MENOR - Arquivo no dir, mas e +d 10% menor que o tamanho esperado.
# MAIOR - Arquivo no dir, mas e +d 10% maior que o tamanho esperado.
# ERRO - Arquivo nao esta no dir.
# NA - Verificacao nao realizada, pois o dia nao e de backup.
#-----------------------------------------------------------------------#

#########################################################################
# DPNS31                                                                #
if [ ${dia_semana} == "Terca-feira" ];then
	#DATAANTDPNS31=`/home/admbackup/scripts/caldate $DATA - 7d  'yyyymmdd'`
	DIRBKPDPNS31="${dirbkpserv}/dpns31"
	ULTBKPDPNS31=`ls -ltr $DIRBKPDPNS31/*tar* | tail -2 | head -1 | awk '{print $9}'`
	TAMREFDPNS31=`du -shb $ULTBKPDPNS31 | awk '{print $1}'`
	TAMMAXDPNS31=`echo $TAMREFDPNS31*1.1 | bc | cut -d. -f 1`
	TAMMINDPNS31=`echo $TAMREFDPNS31*0.9 | bc | cut -d. -f 1`
	TAMBKPDPNS31=`du -shb $DIRBKPDPNS31/dpns31_${DATA}.tar.gz | awk '{print $1}'`

	if [ -f $DIRBKPDPNS31/dpns31_${DATA}.tar.gz ];then
		vrf_dpns31="OK"
		if [ -f $DIRBKPDPNS31/dpns31_${DATA}.tar.gz ] && [ $TAMBKPDPNS31 -gt $TAMMAXDPNS31 ];then
			vrf_dpns31="MAIOR"
		fi
		if [ -f $DIRBKPDPNS31/dpns31_${DATA}.tar.gz ] && [ $TAMBKPDPNS31 -lt $TAMMINDPNS31 ];then
			vrf_dpns31="MENOR"
		fi
	else
		vrf_dpns31="ERRO"
	fi
else
	vrf_dpns31="NA"
fi

echo DPNS31: $vrf_dpns31

#########################################################################
# DPNS05d
if [ ${dia_semana} == "Segunda-feira" ];then
	DIRBKPDPNS05d="${dirbkpserv}/dpns05d"
	ULTBKPDPNS05d=`ls -ltr $DIRBKPDPNS05d/*tar* | tail -2 | head -1 | awk '{print $9}'`
	TAMREFDPNS05d=`du -shb $ULTBKPDPNS05d | awk '{print $1}'`
	TAMMAXDPNS05d=`echo $TAMREFDPNS05d*1.1 | bc | cut -d. -f 1` # Margem de +10%
	TAMMINDPNS05d=`echo $TAMREFDPNS05d*0.9 | bc | cut -d. -f 1` # Margem de -10%
	TAMBKPDPNS05d=`du -shb $dirbkpserv/dpns05d/dpns05d_${DATA}.tar.gz | awk '{print $1}'`

	if [ -f $dirbkpserv/dpns05d/dpns05d_${DATA}.tar.gz ];then
		vrf_dpns05d="OK"
		if [ -f $dirbkpserv/dpns05d/dpns05d_${DATA}.tar.gz ] && [ $TAMBKPDPNS05d -gt $TAMMAXDPNS05d ];then
			vrf_dpns05d="MAIOR"
		fi
		if [ -f $dirbkpserv/dpns05d/dpns05d_${DATA}.tar.gz ] && [ $TAMBKPDPNS05d -lt $TAMMINDPNS05d ];then
			vrf_dpns05d="MENOR"
		fi
	else
		vrf_dpns05d="ERRO"
	fi
else
	vrf_dpns05d="NA"
fi

#########################################################################
# DPNS05e                                                                #
if [ ${dia_semana} == "Segunda-feira" ];then

	DIRBKPDPNS05e="${dirbkpserv}/dpns05e"
	ULTBKPDPNS05e=`ls -ltr $DIRBKPDPNS05e/*tar* | tail -2 | head -1 | awk '{print $9}'`
	TAMREFDPNS05e=`du -shb $ULTBKPDPNS05e | awk '{print $1}'`
	TAMMAXDPNS05e=`echo $TAMREFDPNS05e*1.1 | bc | cut -d. -f 1` # Margem de +10%
	TAMMINDPNS05e=`echo $TAMREFDPNS05e*0.9 | bc | cut -d. -f 1` # Margem de -10%
	TAMBKPDPNS05e=`du -shb $DIRBKPDPNS05e/dpns05e_${DATA}.tar.gz | awk '{print $1}'`

	if [ -f $DIRBKPDPNS05e/dpns05e_${DATA}.tar.gz ];then
		vrf_dpns05e="OK"
		if [ -f $DIRBKPDPNS05e/dpns05e_${DATA}.tar.gz ] && [ $TAMBKPDPNS05e -gt $TAMMAXDPNS05e ];then
			vrf_dpns05e="MAIOR"
		fi
		if [ -f $DIRBKPDPNS05e/dpns05e_${DATA}.tar.gz ] && [ $TAMBKPDPNS05e -lt $TAMMINDPNS05e ];then
			vrf_dpns05e="MENOR"
		fi
	else
		vrf_dpns05e="ERRO"
	fi
else
	vrf_dpns05e="NA"
fi

#########################################################################
# ICON13KM
DIRICON13KM="/data1/backup/backup_icon/backup_icon13km"
ULTBKPICON13KM=`ls -ltr $DIRICON13KM/*tar* | tail -2 | head -1 | awk '{print $9}'`
#TAMREFICON13KM=`du -shb $ULTBKPICON13KM | awk '{print $1}'`
TAMREFICON13KM=5600000000 # 5600000000 ~ 5.6GB
TAMMAXICON13KM=`echo $TAMREFICON13KM*1.1 | bc | cut -d. -f 1`
TAMMINICON13KM=`echo $TAMREFICON13KM*0.9 | bc | cut -d. -f 1`
TAMBKPICON13KM=`du -shb $DIRICON13KM/icon_global_icosahedral_${DATA}_${HH}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICON13KM/icon_global_icosahedral_${DATA}_${HH}.tar.bz2 ];then

	vrf_icon13km="OK"

	if [ -f $DIRICON13KM/icon_global_icosahedral_${DATA}_${HH}.tar.bz2 ] && [ $TAMBKPICON13KM -gt $TAMMAXICON13KM ];then
		vrf_icon13km="MAIOR"
	fi
	if [ -f $DIRICON13KM/icon_global_icosahedral_${DATA}_${HH}.tar.bz2 ] && [ $TAMBKPICON13KM -lt $TAMMINICON13KM ];then
		vrf_icon13km="MENOR"
	fi
else
	vrf_icon13km="ERRO"
fi

echo ICON13KM: $vrf_icon13km

#########################################################################
# ICONDATAMET
DIRICONDATAMET="/data1/backup/backup_icon/backup_icondata_met5"
ULTBKPICONDATAMET=`ls -ltr $DIRICONDATAMET/*tar.bz2 | tail -2 | head -1 | awk '{print $9}'`
TAMREFICONDATAMET=`du -shb $ULTBKPICONDATAMET | awk '{print $1}'`
TAMMAXICONDATAMET=`echo $TAMREFICONDATAMET*1.1 | bc | cut -d. -f 1`
TAMMINICONDATAMET=`echo $TAMREFICONDATAMET*0.9 | bc | cut -d. -f 1`
TAMBKPICONDATAMET=`du -shb $DIRICONDATAMET/iconmet_${DATA}${HH}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICONDATAMET/iconmet_${DATA}${HH}.tar.bz2 ];then

        vrf_iconmet="OK"

        if [ -f $DIRICONDATAMET/iconmet_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICONDATAMET -gt $TAMMAXICONDATAMET ];then
                vrf_iconmet="MAIOR"
        fi
        if [ -f $DIRICONDATAMET/iconmet_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICONDATAMET -lt $TAMMINICONDATAMET ];then
                vrf_iconmet="MENOR"
        fi
else
        vrf_iconmet="ERRO"
fi

echo ICONDATAMET: $vrf_iconmet

#########################################################################
# ICONDATAANT
DIRICONDATAANT="/data1/backup/backup_icon/backup_icondata_ant"
ULTBKPICONDATAANT=`ls -ltr $DIRICONDATAANT/*tar* | tail -2 | head -1 | awk '{print $9}'`
TAMREFICONDATAANT=`du -shb $ULTBKPICONDATAANT | awk '{print $1}'`
TAMMAXICONDATAANT=`echo $TAMREFICONDATAANT*1.1 | bc | cut -d. -f 1`
TAMMINICONDATAANT=`echo $TAMREFICONDATAANT*0.9 | bc | cut -d. -f 1`
TAMBKPICONDATAANT=`du -shb $DIRICONDATAANT/iconant_${DATA}${HH}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICONDATAANT/iconant_${DATA}${HH}.tar.bz2 ];then

        vrf_iconant="OK"

        if [ -f $DIRICONDATAANT/iconant_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICONDATAANT -gt $TAMMAXICONDATAANT ];then
                vrf_iconant="MAIOR"
        fi
        if [ -f $DIRICONDATAANT/iconant_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICONDATAANT -lt $TAMMINICONDATAANT ];then
                vrf_iconant="MENOR"
        fi
else
        vrf_iconant="ERRO"
fi

echo ICONDATAANT: $vrf_iconant

#########################################################################
# COSMOMET
DIRCOSMOMET="/data1/backup/backup_cosmo/metarea5/dados${HH}"
ULTBKPCOSMOMET=`ls -ltr $DIRCOSMOMET/*tar* | tail -2 | head -1 | awk '{print $9}'`
TAMREFCOSMOMET=`du -shb $ULTBKPCOSMOMET | awk '{print $1}'`
TAMMAXCOSMOMET=`echo $TAMREFCOSMOMET*1.1 | bc | cut -d. -f 1`
TAMMINCOSMOMET=`echo $TAMREFCOSMOMET*0.9 | bc | cut -d. -f 1`
TAMBKPCOSMOMET=`du -shb $DIRCOSMOMET/cosmomet_07km_${HH}_${DATA}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRCOSMOMET/cosmomet_07km_${HH}_${DATA}.tar.bz2 ];then

        vrf_cosmomet="OK"

        if [ -f $DIRCOSMOMET/cosmomet_07km_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPCOSMOMET -gt $TAMMAXCOSMOMET ];then
                vrf_cosmomet="MAIOR"
        fi
        if [ -f $DIRCOSMOMET/cosmomet_07km_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPCOSMOMET -lt $TAMMINCOSMOMET ];then
                vrf_cosmomet="MENOR"

        fi
else
        vrf_cosmomet="ERRO"
fi

echo COSMOMET: $vrf_cosmomet

#########################################################################
# COSMOANT
DIRCOSMOANT="/data1/backup/backup_cosmo/antartica/dados${HH}"
ULTBKPCOSMOANT=`ls -ltr $DIRCOSMOANT/*tar* | tail -2 | head -1 | awk '{print $9}'`
TAMREFCOSMOANT=`du -shb $ULTBKPCOSMOANT | awk '{print $1}'`
TAMMAXCOSMOANT=`echo $TAMREFCOSMOANT*1.1 | bc | cut -d. -f 1`
TAMMINCOSMOANT=`echo $TAMREFCOSMOANT*0.9 | bc | cut -d. -f 1`
TAMBKPCOSMOANT=`du -shb $DIRCOSMOANT/cosmoant_10km_${HH}_${DATA}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRCOSMOANT/cosmoant_10km_${HH}_${DATA}.tar.bz2 ];then

        vrf_cosmoant="OK"

        if [ -f $DIRCOSMOANT/cosmoant_10km_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPCOSMOANT -gt $TAMMAXCOSMOANT ];then
                vrf_cosmoant="MAIOR"
        fi
        if [ -f $DIRCOSMOANT/cosmoant_10km_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPCOSMOANT -lt $TAMMINCOSMOANT ];then
                vrf_cosmoant="MENOR"
        fi
else
        vrf_cosmoant="ERRO"
fi

echo COSMOANT: $vrf_cosmoant

#########################################################################
# COSMOVENTO
DIRCOSMOVENTO="/data1/CH131/WW3_bckup/cosmo_grib_wnd10m"
ULTBKPCOSMOVENTO=`ls -ltr $DIRCOSMOVENTO/*bz2 | tail -2 | head -1 | awk '{print $9}'`
TAMREFCOSMOVENTO=`du -shb $ULTBKPCOSMOVENTO | awk '{print $1}'`
TAMMAXCOSMOVENTO=`echo $TAMREFCOSMOVENTO*1.1 | bc | cut -d. -f 1`
TAMMINCOSMOVENTO=`echo $TAMREFCOSMOVENTO*0.9 | bc | cut -d. -f 1`
TAMBKPCOSMOVENTO=`du -shb $DIRCOSMOVENTO/cosmo.${DATA}${HH}.grb2.bz2 | awk '{print $1}'`

if [ -f $DIRCOSMOVENTO/cosmo.${DATA}${HH}.grb2.bz2 ];then

        vrf_cosmovento="OK"

        if [ -f $DIRCOSMOVENTO/cosmo.${DATA}${HH}.grb2.bz2 ] && [ $TAMBKPCOSMOVENTO -gt $TAMMAXCOSMOVENTO ];then
                vrf_cosmovento="MAIOR"
        fi
        if [ -f $DIRCOSMOVENTO/cosmo.${DATA}${HH}.grb2.bz2 ] && [ $TAMBKPCOSMOVENTO -lt $TAMMINCOSMOVENTO ];then
                vrf_cosmovento="MENOR"
        fi
else
        vrf_cosmovento="ERRO"
fi

echo COSMOVENTO: $vrf_cosmovento

#########################################################################
# COSMOSSE
#########################################################################
# A PERIODICIDADE DESSE BACKUP E SUA EXECUCAO E DE RESPONSABILIDADE DA REMO (RAQUEL)
# Atualmente, o backup fica armazenado num dir e todo o dia 01 de cada mes
# o script deles envia os dados REF ao mes anterior todo + o dia 01 do mes
# de execucao do script para o DIRCOSMOSSE. Portanto, a verificacao tem que ser adaptada.
# So faz a transferencia para o horario de 00!!

# Condicao para rodar somente quando o dia a ser verificado for REF a um mes =! do corrente
if ! [ `echo "${DATA:4:2}"` == `date +'%m'` ];then

	#DATALM=`/home/admbackup/scripts/caldate $DATA - 1m  'yyyymmdd'`
	DIRCOSMOSSE="/data1/CH131/HYCOM_bckup/DPNS31/preproc/cosmo/sse"
	ULTBKPCOSMOSSE=`ls -ltr $DIRCOSMOSSE/*bz2 | tail -2 | head -1 | awk '{print $9}'`
	TAMREFCOSMOSSE=`du -shb $ULTBKPCOSMOSSE | awk '{print $1}'`
	TAMMAXCOSMOSSE=`echo $TAMREFCOSMOSSE*1.1 | bc | cut -d. -f 1`
	TAMMINCOSMOSSE=`echo $TAMREFCOSMOSSE*0.9 | bc | cut -d. -f 1`
	TAMBKPCOSMOSSE=`du -shb $DIRCOSMOSSE/cosmo_sse_${HH}_${DATA}.tar.bz2 | awk '{print $1}'`

	if [ -f $DIRCOSMOSSE/cosmo_sse_${HH}_${DATA}.tar.bz2 ];then

	        vrf_cosmosse="OK"

        	if [ -f $DIRCOSMOSSE/cosmo_sse_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPCOSMOSSE -gt $TAMMAXCOSMOSSE ];then
                	vrf_cosmosse="MAIOR"
	        fi
        	if [ -f $DIRCOSMOSSE/cosmo_sse_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPCOSMOSSE -lt $TAMMINCOSMOSSE ];then
                	vrf_cosmosse="MENOR"
	        fi
	else
        	vrf_cosmosse="ERRO"
	fi

else
	vrf_cosmosse="NA"
fi

echo COSMOSSE: $vrf_cosmosse
#########################################################################
# WW3COSMOMET

DIRWW3COSMOMET="/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/ww3cosmo"
ULTBKPWW3COSMOMET=`ls -ltr $DIRWW3COSMOMET/ww3cosmo_met_*.nc | tail -2 | head -1 | awk '{print $9}'`
TAMREFWW3COSMOMET=`du -shb $ULTBKPWW3COSMOMET | awk '{print $1}'`
TAMMAXWW3COSMOMET=`echo $TAMREFWW3COSMOMET*1.1 | bc | cut -d. -f 1`
TAMMINWW3COSMOMET=`echo $TAMREFWW3COSMOMET*0.9 | bc | cut -d. -f 1`
TAMBKPWW3COSMOMET=`du -shb $DIRWW3COSMOMET/ww3cosmo_met_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3COSMOMET/ww3cosmo_met_${DATA}${HH}.nc ];then

        vrf_ww3cosmomet="OK"

        if [ -f $DIRWW3COSMOMET/ww3cosmo_met_${DATA}${HH}.nc ] && [ $TAMBKPWW3COSMOMET -gt $TAMMAXWW3COSMOMET ];then
                vrf_ww3cosmomet="MAIOR"
        fi
        if [ -f $DIRWW3COSMOMET/ww3cosmo_met_${DATA}${HH}.nc ] && [ $TAMBKPWW3COSMOMET -lt $TAMMINWW3COSMOMET ];then
                vrf_ww3cosmomet="MENOR"
        fi
else
        vrf_ww3cosmomet="ERRO"
fi

echo WW3COSMOMET: $vrf_ww3cosmomet

#########################################################################
# WW3COSMORJES

DIRWW3COSMORJES="/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/ww3cosmo"
ULTBKPWW3COSMORJES=`ls -ltr $DIRWW3COSMORJES/ww3cosmo_rjes_*.nc | tail -2 | head -1 | awk '{print $9}'`
TAMREFWW3COSMORJES=`du -shb $ULTBKPWW3COSMORJES | awk '{print $1}'`
TAMMAXWW3COSMORJES=`echo $TAMREFWW3COSMORJES*1.1 | bc | cut -d. -f 1`
TAMMINWW3COSMORJES=`echo $TAMREFWW3COSMORJES*0.9 | bc | cut -d. -f 1`
TAMBKPWW3COSMORJES=`du -shb $DIRWW3COSMORJES/ww3cosmo_rjes_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3COSMORJES/ww3cosmo_rjes_${DATA}${HH}.nc ];then

        vrf_ww3cosmorjes="OK"

        if [ -f $DIRWW3COSMORJES/ww3cosmo_rjes_${DATA}${HH}.nc ] && [ $TAMBKPWW3COSMORJES -gt $TAMMAXWW3COSMORJES ];then
                vrf_ww3cosmorjes="MAIOR"
        fi
        if [ -f $DIRWW3COSMORJES/ww3cosmo_rjes_${DATA}${HH}.nc ] && [ $TAMBKPWW3COSMORJES -lt $TAMMINWW3COSMORJES ];then
                vrf_ww3cosmorjes="MENOR"
        fi
else
        vrf_ww3cosmorjes="ERRO"
fi

echo WW3COSMORJES: $vrf_ww3cosmorjes
#########################################################################
# WW3ICONMET

DIRWW3ICONMET="/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/ww3icon"
ULTBKPWW3ICONMET=`ls -ltr $DIRWW3ICONMET/ww3icon_met_*.nc | tail -2 | head -1 | awk '{print $9}'`
TAMREFWW3ICONMET=`du -shb $ULTBKPWW3ICONMET | awk '{print $1}'`
TAMMAXWW3ICONMET=`echo $TAMREFWW3ICONMET*1.1 | bc | cut -d. -f 1`
TAMMINWW3ICONMET=`echo $TAMREFWW3ICONMET*0.9 | bc | cut -d. -f 1`
TAMBKPWW3ICONMET=`du -shb $DIRWW3ICONMET/ww3icon_met_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3ICONMET/ww3icon_met_${DATA}${HH}.nc ];then

        vrf_ww3iconmet="OK"

        if [ -f $DIRWW3ICONMET/ww3icon_met_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONMET -gt $TAMMAXWW3ICONMET ];then
                vrf_ww3iconmet="MAIOR"
        fi
        if [ -f $DIRWW3ICONMET/ww3icon_met_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONMET -lt $TAMMINWW3ICONMET ];then
                vrf_ww3iconmet="MENOR"
        fi
else
        vrf_ww3iconmet="ERRO"
fi

echo WW3ICONMET: $vrf_ww3iconmet

#########################################################################
# WW3ICONANT

DIRWW3ICONANT="/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/ww3icon"
ULTBKPWW3ICONANT=`ls -ltr $DIRWW3ICONANT/ww3icon_ant_*.nc | tail -2 | head -1 | awk '{print $9}'`
TAMREFWW3ICONANT=`du -shb $ULTBKPWW3ICONANT | awk '{print $1}'`
TAMMAXWW3ICONANT=`echo $TAMREFWW3ICONANT*1.1 | bc | cut -d. -f 1`
TAMMINWW3ICONANT=`echo $TAMREFWW3ICONANT*0.9 | bc | cut -d. -f 1`
TAMBKPWW3ICONANT=`du -shb $DIRWW3ICONANT/ww3icon_ant_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3ICONANT/ww3icon_ant_${DATA}${HH}.nc ];then

        vrf_ww3iconant="OK"

        if [ -f $DIRWW3ICONANT/ww3icon_ant_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONANT -gt $TAMMAXWW3ICONANT ];then
                vrf_ww3iconant="MAIOR"
        fi
        if [ -f $DIRWW3ICONANT/ww3icon_ant_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONANT -lt $TAMMINWW3ICONANT ];then
                vrf_ww3iconant="MENOR"
        fi
else
        vrf_ww3iconant="ERRO"
fi

echo WW3ICONANT: $vrf_ww3iconant

#########################################################################
# WW3GFSMET

DIRWW3GFSMET="/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/ww3gfs"
ULTBKPWW3GFSMET=`ls -ltr $DIRWW3GFSMET/ww3gfs_met_*.nc | tail -2 | head -1 | awk '{print $9}'`
TAMREFWW3GFSMET=`du -shb $ULTBKPWW3GFSMET | awk '{print $1}'`
TAMMAXWW3GFSMET=`echo $TAMREFWW3GFSMET*1.1 | bc | cut -d. -f 1`
TAMMINWW3GFSMET=`echo $TAMREFWW3GFSMET*0.9 | bc | cut -d. -f 1`
TAMBKPWW3GFSMET=`du -shb $DIRWW3GFSMET/ww3gfs_met_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3GFSMET/ww3gfs_met_${DATA}${HH}.nc ];then

        vrf_ww3gfsmet="OK"

        if [ -f $DIRWW3GFSMET/ww3gfs_met_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSMET -gt $TAMMAXWW3GFSMET ];then
                vrf_ww3gfsmet="MAIOR"
        fi
        if [ -f $DIRWW3GFSMET/ww3gfs_met_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSMET -lt $TAMMINWW3GFSMET ];then
                vrf_ww3gfsmet="MENOR"
        fi
else
        vrf_ww3gfsmet="ERRO"
fi

echo WW3GFSMET: $vrf_ww3gfsmet

#########################################################################
# WW3GFSANT

DIRWW3GFSANT="/data1/CH131/WW3_bckup/bckup_ww3_saidas_nc/ww3gfs"
ULTBKPWW3GFSANT=`ls -ltr $DIRWW3GFSANT/ww3gfs_ant_*.nc | tail -2 | head -1 | awk '{print $9}'`
TAMREFWW3GFSANT=`du -shb $ULTBKPWW3GFSANT | awk '{print $1}'`
TAMMAXWW3GFSANT=`echo $TAMREFWW3GFSANT*1.1 | bc | cut -d. -f 1`
TAMMINWW3GFSANT=`echo $TAMREFWW3GFSANT*0.9 | bc | cut -d. -f 1`
TAMBKPWW3GFSANT=`du -shb $DIRWW3GFSANT/ww3gfs_ant_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3GFSANT/ww3gfs_ant_${DATA}${HH}.nc ];then

        vrf_ww3gfsant="OK"

        if [ -f $DIRWW3GFSANT/ww3gfs_ant_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSANT -gt $TAMMAXWW3GFSANT ];then
                vrf_ww3gfsant="MAIOR"
        fi
        if [ -f $DIRWW3GFSANT/ww3gfs_ant_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSANT -lt $TAMMINWW3GFSANT ];then
                vrf_ww3gfsant="MENOR"
        fi
else
        vrf_ww3gfsant="ERRO"
fi

echo WW3GFSANT: $vrf_ww3gfsant

#########################################################################
# Escrevendo na planilha de conferencia mensal
########################################################################
# Ordem da planilha:
# "DATAVRF" "DATAHORA" "DPNS31" "DPNS05d" "DPNS05e" "ICON13KM" "ICONDATAMET" "ICONDATAANT" "COSMOMET" "COSMOVENTO" "COSMOANT" "COSMOSSE" "WW3COSMOMET" "WW3COSMORJES" "WW3ICONMET" "WW3ICONANT" "WW3GFSMET" "WW3GFSANT"

printf "$format" "$DATAVRF" "$DATA$HH" "$vrf_dpns31" "$vrf_dpns05d" "$vrf_dpns05e" "$vrf_icon13km" "$vrf_iconmet" "$vrf_iconant" "$vrf_cosmomet" "$vrf_cosmovento" "$vrf_cosmoant" "$vrf_cosmosse" "$vrf_ww3cosmomet" "$vrf_ww3cosmorjes" "$vrf_ww3iconmet" "$vrf_ww3iconant" "$vrf_ww3gfsmet" "$vrf_ww3gfsant" >> $dirout/Conf_Backup_${aaaamm}.txt

printf "\n" >> $dirout/Conf_Backup_${aaaamm}.txt

# Escrevendo email com resumo da verificacao

echo -e "DATAVRF: $DATAVRF\nDATAHORA: $DATA$HH\nDPNS31: $vrf_dpns31\nDPNS05d: $vrf_dpns05d\nDPNS05e: $vrf_dpns05e\nICON13KM: $vrf_icon13km\nICONDATAMET: $vrf_iconmet\nICONDATAANT: $vrf_iconant\nCOSMOMET: $vrf_cosmomet\nCOSMOVENTO: $vrf_cosmovento\nCOSMOANT: $vrf_cosmoant\nCOSMOSSE: $vrf_cosmosse\nWW3COSMOMET: $vrf_ww3cosmomet\nWW3COSMORJES: $vrf_ww3cosmorjes\nWW3ICONMET: $vrf_ww3iconmet\nWW3ICONANT: $vrf_ww3iconant\nWW3GFSMET: $vrf_ww3gfsmet\nWW3GFSANT: $vrf_ww3gfsant" > check
cat check

if [ -z $MAIL ];then
	cat check ~/scripts/invariantes/legenda.txt > corpo
	cat corpo | mail -s "Conferencia Backup DPN (DPNS33) - $DATA$HH" felipenc2@gmail.com thaisguilhon@gmail.com tatyanecss@gmail.com supervisorch13@gmail.com alana@marinha.mil.br damiao.andre@marinha.mil.br liana.bittencourt@marinha.mil.br victor.vinicius@marinha.mil.br chm.supervisordpn@marinha.mil.br
	echo "Enviei Relatorio Backup para emails cadastrados!!!"
	rm corpo
fi

rm check

exit
