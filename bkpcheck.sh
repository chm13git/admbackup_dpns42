#!/bin/bash -x
export LANG=pt_BR.utf8
#########################################################################
# Este script eh responsavel por VRF se os dados de backup
# foram realizados e envia uma planilha diariamente
# para os emails cadastrados
#
# Autor: CT(T) NERIS 
# Ultima ALT: Em 18JUL2023 feita pela 3SG-ME THAIS GUILHON
#########################################################################

if [ $# -ne 3 ] && [ $# -ne 4 ];then
        echo "Entre com o tipo execucao (ope/per), a rodada (00 ou 12), o dia (AAAAMMDD) ou os dias inicial e final e/ou 'n' para NAO enviar email."
	echo
        echo "Possibilidades:	./bkpcheck.sh ope 12 20230515"
        echo "			./bkpcheck.sh ope 00 20230515 n"
        echo "			./bkpcheck.sh per 12 20230515 n"
	exit 1
fi

RR=$1
HH=$2
DATA=$3
ML=$4

DATAVRF=`date`

# Diretorio de armazenamento dos backups
dirbkpserv="/data2/backup/backup_servidores"

# Definindo dia da semana
dia_semana=`/home/admbackup/scripts/caldate $DATA - 0d 'sd'`

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

echo "O script sera executado com os seguintes parametros:"
echo "HH=$HH"
echo "DATA=$DATA, $dia_semana"
echo "Data e hora da VRF: $DATAVRF"

#-----------------------------------------------------------------------#
# Verifica se os dados estao no diretorio                               #
#-----------------------------------------------------------------------#
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
# DPNS41                                                                #
if [ ${dia_semana} == "Segunda-feira" ];then
        DIRBKPDPNS41="${dirbkpserv}/dpns41"
        ULTBKPDPNS41=`ls -ltr $DIRBKPDPNS41/*tar* | tail -2 | head -1 | awk '{print $9}'`
        TAMREFDPNS41=`du -shb $ULTBKPDPNS41 | awk '{print $1}'`
        TAMMAXDPNS41=`echo $TAMREFDPNS41*1.1 | bc | cut -d. -f 1`
        TAMMINDPNS41=`echo $TAMREFDPNS41*0.9 | bc | cut -d. -f 1`
        TAMBKPDPNS41=`du -shb $DIRBKPDPNS41/dpns41_${DATA}.tar.gz | awk '{print $1}'`

        if [ -f $DIRBKPDPNS41/dpns41_${DATA}.tar.gz ];then
                vrf_dpns41="OK"
                if [ -f $DIRBKPDPNS41/dpns41_${DATA}.tar.gz ] && [ $TAMBKPDPNS41 -gt $TAMMAXDPNS41 ];then
                        vrf_dpns41="MAIOR"
                fi
                if [ -f $DIRBKPDPNS41/dpns41_${DATA}.tar.gz ] && [ $TAMBKPDPNS41 -lt $TAMMINDPNS41 ];then
                        vrf_dpns41="MENOR"
                fi
        else
                vrf_dpns41="ERRO"
        fi
else
        vrf_dpns41="NA"
fi

echo DPNS41: $vrf_dpns41

#########################################################################
# DPNS35                                                                #
if [ ${dia_semana} == "Quarta-feira" ];then
        DIRBKPDPNS35="${dirbkpserv}/dpns35"
        ULTBKPDPNS35=`ls -ltr $DIRBKPDPNS35/*tar* | tail -2 | head -1 | awk '{print $9}'`
        TAMREFDPNS35=`du -shb $ULTBKPDPNS35 | awk '{print $1}'`
        TAMMAXDPNS35=`echo $TAMREFDPNS35*1.1 | bc | cut -d. -f 1`
        TAMMINDPNS35=`echo $TAMREFDPNS35*0.9 | bc | cut -d. -f 1`
        TAMBKPDPNS35=`du -shb $DIRBKPDPNS35/dpns35_${DATA}.tar.gz | awk '{print $1}'`

        if [ -f $DIRBKPDPNS35/dpns35_${DATA}.tar.gz ];then
                vrf_dpns35="OK"
                if [ -f $DIRBKPDPNS35/dpns35_${DATA}.tar.gz ] && [ $TAMBKPDPNS35 -gt $TAMMAXDPNS35 ];then
                        vrf_dpns35="MAIOR"
                fi
                if [ -f $DIRBKPDPNS35/dpns35_${DATA}.tar.gz ] && [ $TAMBKPDPNS35 -lt $TAMMINDPNS35 ];then
                        vrf_dpns35="MENOR"
                fi
        else
                vrf_dpns35="ERRO"
        fi
else
        vrf_dpns35="NA"
fi

echo DPNS35: $vrf_dpns35


#########################################################################
# DPNS05d
if [ ${dia_semana} == "Domingo" ];then
	DIRBKPDPNS05d="${dirbkpserv}/dpns05d"
	ULTBKPDPNS05d=`ls -ltr $DIRBKPDPNS05d/*tar* | tail -2 | head -1 | awk '{print $9}'`
	TAMREFDPNS05d=`du -shb $ULTBKPDPNS05d | awk '{print $1}'`
	TAMMAXDPNS05d=`echo $TAMREFDPNS05d*1.1 | bc | cut -d. -f 1` # Margem de +10%
	TAMMINDPNS05d=`echo $TAMREFDPNS05d*0.9 | bc | cut -d. -f 1` # Margem de -10%
	TAMBKPDPNS05d=`du -shb ${DIRBKPDPNS05d}/dpns05d_${DATA}.tar.gz | awk '{print $1}'`

	if [ -f $DIRBKPDPNS05d/dpns05d_${DATA}.tar.gz ];then
		vrf_dpns05d="OK"
		if [ -f $DIRBKPDPNS05d/dpns05d_${DATA}.tar.gz ] && [ $TAMBKPDPNS05d -gt $TAMMAXDPNS05d ];then
			vrf_dpns05d="MAIOR"
		fi
		if [ -f $DIRBKPDPNS05d/dpns05d_${DATA}.tar.gz ] && [ $TAMBKPDPNS05d -lt $TAMMINDPNS05d ];then
			vrf_dpns05d="MENOR"
		fi
	else
		vrf_dpns05d="ERRO"
	fi
else
	vrf_dpns05d="NA"
fi

#########################################################################
# ICON13KM
DIRICON13KM="/data2/backup/backup_icon/bkp_icon13km"
TAMMAXICON13KM=9795263864
TAMMINICON13KM=8014306797
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
# ICON4ICONLAMSAM
DIRICON4ICONLAMSAM="/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
TAMMAXICON4ICONLAMSAM=15400000000
TAMMINICON4ICONLAMSAM=12600000000
TAMBKPICON4ICONLAMSAM=`du -shb $DIRICON4ICONLAMSAM/icon4iconlamsam_${DATA}${HH}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICON4ICONLAMSAM/icon4iconlamsam_${DATA}${HH}.tar.bz2 ];then

        vrf_icon4iconlamsam="OK"

        if [ -f $DIRICON4ICONLAMSAM/icon4iconlamsam_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICON4ICONLAMSAM -gt $TAMMAXICON4ICONLAMSAM ];then
                vrf_icon4iconlamsam="MAIOR"
        fi
        if [ -f $DIRICON4ICONLAMSAM/icon4iconlamsam_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICON4ICONLAMSAM -lt $TAMMINICON4ICONLAMSAM ];then
                vrf_icon4iconlamsam="MENOR"
        fi
else
        vrf_icon4iconlamsam="ERRO"
fi

echo ICON4ICONLAMSAM: $vrf_icon4iconlamsam

#########################################################################
# ICON4ICONLAMANT
DIRICON4ICONLAMANT="/data2/backup/backup_icon/bkp_input_icon4iconlam_ant"
TAMMAXICON4ICONLAMANT=4253654624
TAMMINICON4ICONLAMANT=3100000000
TAMBKPICON4ICONLAMANT=`du -shb $DIRICON4ICONLAMANT/icon4iconlamant_${DATA}${HH}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICON4ICONLAMANT/icon4iconlamant_${DATA}${HH}.tar.bz2 ];then

        vrf_icon4iconlamant="OK"

        if [ -f $DIRICON4ICONLAMANT/icon4iconlamant_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICON4ICONLAMANT -gt $TAMMAXICON4ICONLAMANT ];then
                vrf_icon4iconlamant="MAIOR"
        fi
        if [ -f $DIRICON4ICONLAMANT/icon4iconlamant_${DATA}${HH}.tar.bz2 ] && [ $TAMBKPICON4ICONLAMANT -lt $TAMMINICON4ICONLAMANT ];then
                vrf_icon4iconlamant="MENOR"
        fi
else
        vrf_icon4iconlamant="ERRO"
fi

echo ICON4ICONLAMANT: $vrf_icon4iconlamant

#########################################################################
# COSMOMET
DIRCOSMOMET="/data2/backup/backup_cosmo/metarea5/dados${HH}"
TAMMAXCOSMOMET=2100000000
TAMMINCOSMOMET=1800000000
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
# ICONLAMSAM
DIRICONLAMSAM="/data2/backup/backup_icon/bkp_output_iconlam/sam"
TAMMAXICONLAMSAM=10015625858
TAMMINICONLAMSAM=8194602975
TAMBKPICONLAMSAM=`du -shb $DIRICONLAMSAM/iconlam_sam6.5_${HH}_${DATA}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICONLAMSAM/iconlam_sam6.5_${HH}_${DATA}.tar.bz2 ];then

        vrf_iconlamsam="OK"

        if [ -f $DIRICONLAMSAM/iconlam_sam6.5_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPICONLAMSAM -gt $TAMMAXICONLAMSAM ];then
                vrf_iconlamsam="MAIOR"
        fi
        if [ -f $DIRICONLAMSAM/iconlam_sam6.5_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPICONLAMSAM -lt $TAMMINICONLAMSAM ];then
                vrf_iconlamsam="MENOR"
        fi
else
        vrf_iconlamsam="ERRO"
fi

echo ICONLAMSAM: $vrf_iconlamsam

#########################################################################
# ICONLAMANT
DIRICONLAMANT="/data2/backup/backup_icon/bkp_output_iconlam/ant"
TAMMAXICONLAMANT=4301108787
TAMMINICONLAMANT=3519089008
TAMBKPICONLAMANT=`du -shb $DIRICONLAMANT/iconlam_ant6.5_${HH}_${DATA}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICONLAMANT/iconlam_ant6.5_${HH}_${DATA}.tar.bz2 ];then

        vrf_iconlamant="OK"

        if [ -f $DIRICONLAMANT/iconlam_ant6.5_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPICONLAMANT -gt $TAMMAXICONLAMANT ];then
                vrf_iconlamant="MAIOR"
        fi
        if [ -f $DIRICONLAMANT/iconlam_ant6.5_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPICONLAMANT -lt $TAMMINICONLAMANT ];then
                vrf_iconlamant="MENOR"
        fi
else
        vrf_iconlamant="ERRO"
fi

echo ICONLAMANT: $vrf_iconlamant

#########################################################################
# ICONLAMSSE21
DIRICONLAMSSE21="/data2/backup/backup_icon/bkp_output_iconlam/sse"
TAMMAXICONLAMSSE21=5301459537
TAMMINICONLAMSSE21=4337557803
TAMBKPICONLAMSSE21=`du -shb $DIRICONLAMSSE21/iconlam_sse2.1_${HH}_${DATA}.tar.bz2 | awk '{print $1}'`

if [ -f $DIRICONLAMSSE21/iconlam_sse2.1_${HH}_${DATA}.tar.bz2 ];then

        vrf_iconlamsse21="OK"

        if [ -f $DIRICONLAMSSE21/iconlam_sse2.1_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPICONLAMSSE21 -gt $TAMMAXICONLAMSSE21 ];then
                vrf_iconlamsse21="MAIOR"
        fi
        if [ -f $DIRICONLAMSSE21/iconlam_sse2.1_${HH}_${DATA}.tar.bz2 ] && [ $TAMBKPICONLAMSSE21 -lt $TAMMINICONLAMSSE21 ];then
                vrf_iconlamsse21="MENOR"
        fi
else
        vrf_iconlamsse21="ERRO"
fi

echo ICONLAMSSE21: $vrf_iconlamsse21

#########################################################################
# WW3ICONMET

DIRWW3ICONMET="/data/opww3/backup/ww3icon"
TAMMAXWW3ICONMET=935
TAMMINWW3ICONMET=765
TAMBKPWW3ICONMET=`du -shm $DIRWW3ICONMET/ww3icon_met5_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3ICONMET/ww3icon_met5_${DATA}${HH}.nc ];then

        vrf_ww3iconmet="OK"

        if [ -f $DIRWW3ICONMET/ww3icon_met5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONMET -gt $TAMMAXWW3ICONMET ];then
                vrf_ww3iconmet="MAIOR"
        fi
        if [ -f $DIRWW3ICONMET/ww3icon_met5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONMET -lt $TAMMINWW3ICONMET ];then
                vrf_ww3iconmet="MENOR"
        fi
else
        vrf_ww3iconmet="ERRO"
fi

echo WW3ICONMET: $vrf_ww3iconmet

#########################################################################
# WW3ICONANT

DIRWW3ICONANT="/data/opww3/backup/ww3icon"
TAMMAXWW3ICONANT=440
TAMMINWW3ICONANT=360
TAMBKPWW3ICONANT=`du -shm $DIRWW3ICONANT/ww3icon_ant5_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3ICONANT/ww3icon_ant5_${DATA}${HH}.nc ];then

        vrf_ww3iconant="OK"

        if [ -f $DIRWW3ICONANT/ww3icon_ant5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONANT -gt $TAMMAXWW3ICONANT ];then
                vrf_ww3iconant="MAIOR"
        fi
        if [ -f $DIRWW3ICONANT/ww3icon_ant5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONANT -lt $TAMMINWW3ICONANT ];then
                vrf_ww3iconant="MENOR"
        fi
else
        vrf_ww3iconant="ERRO"
fi

echo WW3ICONANT: $vrf_ww3iconant

#########################################################################
# WW3ICONBRCOAST

DIRWW3ICONBRCOAST="/data/opww3/backup/ww3icon"
TAMMAXWW3ICONBRCOAST=374
TAMMINWW3ICONBRCOAST=306
TAMBKPWW3ICONBRCOAST=`du -shm $DIRWW3ICONBRCOAST/ww3icon_brcoast_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3ICONBRCOAST/ww3icon_brcoast_${DATA}${HH}.nc ];then

        vrf_ww3iconbrcoast="OK"

        if [ -f $DIRWW3ICONBRCOAST/ww3icon_brcoast_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONBRCOAST -gt $TAMMAXWW3ICONBRCOAST ];then
                vrf_ww3iconbrcoast="MAIOR"
        fi
        if [ -f $DIRWW3ICONBRCOST/ww3icon_brcoast_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICONBRCOAST -lt $TAMMINWW3ICONBRCOAST ];then
                vrf_ww3iconbrcoast="MENOR"
        fi
else
        vrf_ww3iconbrcoast="ERRO"
fi

echo WW3ICONBRCOAST: $vrf_ww3iconbrcoast


#########################################################################
# WW3GFSMET

DIRWW3GFSMET="/data/opww3/backup/ww3gfs"
TAMMAXWW3GFSMET=935
TAMMINWW3GFSMET=765
TAMBKPWW3GFSMET=`du -shm $DIRWW3GFSMET/ww3gfs_met5_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3GFSMET/ww3gfs_met5_${DATA}${HH}.nc ];then

        vrf_ww3gfsmet="OK"

        if [ -f $DIRWW3GFSMET/ww3gfs_met5_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSMET -gt $TAMMAXWW3GFSMET ];then
                vrf_ww3gfsmet="MAIOR"
        fi
        if [ -f $DIRWW3GFSMET/ww3gfs_met5_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSMET -lt $TAMMINWW3GFSMET ];then
                vrf_ww3gfsmet="MENOR"
        fi
else
        vrf_ww3gfsmet="ERRO"
fi

echo WW3GFSMET: $vrf_ww3gfsmet

#########################################################################
# WW3GFSANT

DIRWW3GFSANT="/data/opww3/backup/ww3gfs"
TAMMAXWW3GFSANT=440
TAMMINWW3GFSANT=360
TAMBKPWW3GFSANT=`du -shm $DIRWW3GFSANT/ww3gfs_ant5_${DATA}${HH}.nc | awk '{print $1}'`


if [ -f $DIRWW3GFSANT/ww3gfs_ant5_${DATA}${HH}.nc ];then

        vrf_ww3gfsant="OK"

        if [ -f $DIRWW3GFSANT/ww3gfs_ant5_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSANT -gt $TAMMAXWW3GFSANT ];then
                vrf_ww3gfsant="MAIOR"
        fi
        if [ -f $DIRWW3GFSANT/ww3gfs_ant5_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSANT -lt $TAMMINWW3GFSANT ];then
                vrf_ww3gfsant="MENOR"
        fi
else
        vrf_ww3gfsant="ERRO"
fi

echo WW3GFSANT: $vrf_ww3gfsant

#########################################################################
# WW3GFSBRCOAST

DIRWW3GFSBRCOAST="/data/opww3/backup/ww3gfs"
TAMMAXWW3GFSBRCOAST=374
TAMMINWW3GFSBRCOAST=306
TAMBKPWW3GFSBRCOAST=`du -shm $DIRWW3GFSBRCOAST/ww3gfs_brcoast_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3GFSBRCOAST/ww3gfs_brcoast_${DATA}${HH}.nc ];then

        vrf_ww3gfsbrcoast="OK"

        if [ -f $DIRWW3GFSBRCOAST/ww3gfs_brcoast_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSBRCOAST -gt $TAMMAXWW3GFSBRCOAST ];then
                vrf_ww3gfsbrcoast="MAIOR"
        fi
        if [ -f $DIRWW3GFSBRCOST/ww3gfs_brcoast_${DATA}${HH}.nc ] && [ $TAMBKPWW3GFSBRCOAST -lt $TAMMINWW3GFSBRCOAST ];then
                vrf_ww3gfsbrcoast="MENOR"
        fi
else
        vrf_ww3gfsbrcoast="ERRO"
fi

echo WW3GFSBRCOAST: $vrf_ww3gfsbrcoast

#########################################################################
# WW3ICLMMET

DIRWW3ICLMMET="/data/opww3/backup/ww3iclm"
TAMMAXWW3ICLMMET=1025
TAMMINWW3ICLMMET=839
TAMBKPWW3ICLMMET=`du -shm $DIRWW3ICLMMET/ww3iclm_met5_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3ICLMMET/ww3iclm_met5_${DATA}${HH}.nc ];then

        vrf_ww3iclmmet="OK"

        if [ -f $DIRWW3ICLMMET/ww3iclm_met5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICLMMET -gt $TAMMAXWW3ICLMMET ];then
                vrf_ww3iclmmet="MAIOR"
        fi
        if [ -f $DIRWW3ICLMMET/ww3iclm_met5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICLMMET -lt $TAMMINWW3ICLMMET ];then
                vrf_ww3iclmmet="MENOR"
        fi
else
        vrf_ww3iclmmet="ERRO"
fi

echo WW3ICLMMET: $vrf_ww3iclmmet

#########################################################################
# WW3ICLMANT

DIRWW3ICLMANT="/data/opww3/backup/ww3iclm"
TAMMAXWW3ICLMANT=484
TAMMINWW3ICLMANT=396
TAMBKPWW3ICLMANT=`du -shm $DIRWW3ICLMANT/ww3iclm_ant5_${DATA}${HH}.nc | awk '{print $1}'`


if [ -f $DIRWW3ICLMANT/ww3iclm_ant5_${DATA}${HH}.nc ];then

        vrf_ww3iclmant="OK"

        if [ -f $DIRWW3ICLMANT/ww3iclm_ant5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICLMANT -gt $TAMMAXWW3ICLMANT ];then
                vrf_ww3iclmant="MAIOR"
        fi
        if [ -f $DIRWW3ICLMANT/ww3iclm_ant5_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICLMANT -lt $TAMMINWW3ICLMANT ];then
                vrf_ww3iclmant="MENOR"
        fi
else
        vrf_ww3iclmant="ERRO"
fi

echo WW3ICLMANT: $vrf_ww3iclmant

#########################################################################
# WW3ICLMBRCOAST

DIRWW3ICLMBRCOAST="/data/opww3/backup/ww3iclm"
TAMMAXWW3ICLMBRCOAST=398
TAMMINWW3ICLMBRCOAST=326
TAMBKPWW3ICLMBRCOAST=`du -shm $DIRWW3ICLMBRCOAST/ww3iclm_brcoast_${DATA}${HH}.nc | awk '{print $1}'`

if [ -f $DIRWW3ICLMBRCOAST/ww3iclm_brcoast_${DATA}${HH}.nc ];then

        vrf_ww3iclmbrcoast="OK"

        if [ -f $DIRWW3ICLMBRCOAST/ww3iclm_brcoast_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICLMBRCOAST -gt $TAMMAXWW3ICLMBRCOAST ];then
                vrf_ww3iclmbrcoast="MAIOR"
        fi
        if [ -f $DIRWW3ICLMBRCOST/ww3iclm_brcoast_${DATA}${HH}.nc ] && [ $TAMBKPWW3ICLMBRCOAST -lt $TAMMINWW3ICLMBRCOAST ];then
                vrf_ww3iclmbrcoast="MENOR"
        fi
else
        vrf_ww3iclmbrcoast="ERRO"
fi

echo WW3ICLMBRCOAST: $vrf_ww3iclmbrcoast

#########################################################################
# Escrevendo na planilha de conferencia mensal
########################################################################
# Ordem da planilha:
# "DATAVRF" "DATAHORA" "DPNS31" "DPNS41" "DPNS35" "DPNS05d" "ICON13KM" "ICON4ICONLAMSAM" "ICON4ICONLAMANT" "COSMOMET" "ICONLAMSAM" "ICONLAMANT" "ICONLAMSSE21" "WW3ICONMET" "WW3ICONANT" "WW3ICONBRCOAST" "WW3GFSMET" "WW3GFSANT" "WW3GFSBRCOAST" "WW3ICLMMET" "WW3ICLMANT" "WW3ICLMBRCOAST"

# Define padrão da saida para o arquivo de texto
format="%29s %11s %6s %6s %6s %7s %8s %15s %15s %8s %10s %10s %12s %11s %11s %15s %11s %11s %15s %12s %12s %16s"

printf "$format" "$DATAVRF" "$DATA$HH" "$vrf_dpns31" "$vrf_dpns41" "$vrf_dpns35" "$vrf_dpns05d" "$vrf_icon13km" "$vrf_icon4iconlamsam" "$vrf_icon4iconlamant" "$vrf_cosmomet" "$vrf_iconlamsam" "$vrf_iconlamant" "$vrf_iconlamsse21" "$vrf_ww3iconmet" "$vrf_ww3iconant" "$vrf_ww3iconbrcoast" "$vrf_ww3gfsmet" "$vrf_ww3gfsant" "$vrf_ww3gfsbrcoast" "$vrf_ww3iclmmet" "$vrf_ww3iclmant" "$vrf_ww3iclmbrcoast" > bkpcheckout.txt

# Este arq e usado pelo script sheetgen.sh para alimentar as planilhas corretamente.
# Ele e sobrescrito a cada rodada do bkpcheck.sh.
printf "\n" >> bkpcheckout.txt

# Rodando script para gerar planilha com o conteudo de bkpcheckout.txt.
if [ $RR = ope ];then
	/home/admbackup/scripts/sheetgen.sh ope $DATA
fi

# Escrevendo email com resumo da verificacao

echo -e "DATAVRF: $DATAVRF\nDATAHORA: $DATA$HH\nDPNS31: $vrf_dpns31\nDPNS41: $vrf_dpns41\nDPNS35: $vrf_dpns35\nDPNS05d: $vrf_dpns05d\nICON13KM: $vrf_icon13km\nICON4ICONLAMSAM: $vrf_icon4iconlamsam\nICON4ICONLAMANT: $vrf_icon4iconlamant\nCOSMOMET: $vrf_cosmomet\nICONLAMSAM: $vrf_iconlamsam\nICONLAMANT: $vrf_iconlamant\nICONLAMSSE21: $vrf_iconlamsse21\nWW3ICONMET: $vrf_ww3iconmet\nWW3ICONANT: $vrf_ww3iconant\nWW3ICONBRCOAST: $vrf_ww3iconbrcoast\nWW3GFSMET: $vrf_ww3gfsmet\nWW3GFSANT: $vrf_ww3gfsant\nWW3GFSBRCOAST: $vrf_ww3gfsbrcoast\nWW3ICLMMET: $vrf_ww3iclmmet\nWW3ICLMANT: $vrf_ww3iclmant\nWW3ICLMBRCOAST: $vrf_ww3iclmbrcoast" > check
cat check

if [ -z $ML ];then
	cat check ~/scripts/invariantes/legenda.txt > corpo
	cat corpo | mail -s "Conferencia Backup DPN (DPNS42) - $DATA$HH" `cat ~/scripts/invariantes/lista_emails`
	echo "Enviei Relatorio Backup para emails cadastrados!!!"
	rm corpo
fi

rm check

exit
