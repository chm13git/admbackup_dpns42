#!/bin/bash -x
#source ~/.bashrc
export LANG=pt_BR.utf8
#########################################################################
# Este script eh responsavel por VRF o tamanho dos diretorios de backup
# e envia uma planilha diariamente para os emails cadastrados
#
# Autora: 3SG-ME THAIS GUILHON.
# 
#########################################################################

if [ $# -ne 1 ] && [ $# -ne 2 ];then
        echo "Entre com o dia a ser VRF (AAAAMMDD) e/ou 'n' para NAO enviar email:"
        echo "Exemplo:	./planilha_conf_dirbackup.sh 20211216"
        echo "		ou"
        echo "		./planilha_conf_dirbackup.sh 20211216 n"
	exit 2
fi

DATA=$1
MAIL=$2
DATAVRF=`date`
DIAVRF=`date +%Y%m%d`

# Definindo variaveis para o dia corrente
# Datas. Exemplos para data=20211216
#	asis=`date +'%Y'`	# 2021
#	msis=`date +'%m'`	# 12
#	mmsis=`date +'%B'`	# dezembro
#	dsis=`date +'%d'`	# 16
#	hsis=`date +'%H'`	# Hora do sistema (11, para 11Z)
#	dtsis=$asis$msis$dsis	# 20211216
#	mesano=$mmsis$asis	# dezembro2021
#
#	DATA=`date +%Y%m%d`	# 20211216
#	dia_semana=`date +%A`	# segunda, terça etc
#	echo "Data de hoje $DATA, $dia_semana" 

if [ $# -eq 2 ];then
	DATA=`date +%Y%m%d`			# 20211216
	echo "Data de hoje $DATA, $dia_semana" 
fi

echo "Os seguintes parametros foram passados para o script:"
echo "DATA=$DATA, $dia_semana"
echo "Data e hora da VRF: $DATAVRF"

# Escrevendo var aaaamm
aaaamm=`/home/admbackup/scripts/caldate $DATA - 0d 'yyyymm'`

#########################################################################
# DPNS31                                                                #
DIRBKPDPNS31_DPNS42="/data2/backup/backup_servidores/dpns31"
TAMDIRDPNS31_DPNS42=`du -mshc * $DIRBKPDPNS31_DPNS42 | tail -1 | awk '{print $1}'`

########################################################################
# DPNS41                                                                #
DIRBKPDPNS41_DPNS42="/data2/backup/backup_servidores/dpns41"
TAMDIRDPNS41_DPNS42=`du -mshc * $DIRBKPDPNS41_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# DPNS05d

DIRBKPDPNS05d_DPNS42="/data2/backup/backup_servidores/dpns05d"
TAMDIRDPNS05d_DPNS42=`du -mshc * $DIRBKPDPNS05d_DPNS42 | tail -1 | awk '{print $1}'`

##########################################################################
# DPNS35                                                                #

DIRBKPDPNS35_DPNS42="/data2/backup/backup_servidores/dpns35"
TAMDIRDPNS35_DPNS42=`du -mshc * $DIRBKPDPNS35_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICON13KM
DIRICON13KM_DPNS42="/data2/backup/backup_icon/bkp_icon13km"
TAMDIRICON13KM_DPNS42=`du -mshc * $DIRICON13KM_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICONDATAMET
DIRICONDATAMET_DPNS42="/data2/backup/backup_icon/bkp_input_icondata_met5"
TAMDIRICONDATAMET_DPNS42=`du -mshc * $DIRICONDATAMET_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICONDATAANT
DIRICONDATAANT_DPNS42="/data2/backup/backup_icon/bkp_input_icondata_ant"
TAMDIRICONDATAANT_DPNS42=`du -mshc * $DIRICONDATAANT_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICON PARA ICON-LAM SAM
DIRICON4ICONLAMSAM_DPNS42="/data2/backup/backup_icon/bkp_input_icon4iconlam_sam"
TAMDIRICON4ICONLAMSAM_DPNS42=`du -mshc * $DIRICON4ICONLAMSAM_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICON PARA ICON-LAM ANT
DIRICON4ICONLAMANT_DPNS42="/data2/backup/backup_icon/bkp_input_icon4iconlam_ant"
TAMDIRICON4ICONLAMANT_DPNS42=`du -mshc * $DIRICON4ICONLAMANT_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICON-LAM SAM
DIRICONLAMSAM_DPNS42="/data2/backup/backup_icon/bkp_output_iconlam/sam"
TAMDIRICONLAMSAM_DPNS42=`du -mshc * $DIRICONLAMSAM_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICON-LAM ANT
DIRICONLAMANT_DPNS42="/data2/backup/backup_icon/bkp_output_iconlam/ant"
TAMDIRICONLAMANT_DPNS42=`du -mshc * $DIRICONLAMANT_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICON-LAM PEN (ANT2.1)
DIRICONLAMPEN_DPNS42="/data2/backup/backup_icon/bkp_output_iconlam/pen"
TAMDIRICONLAMPEN_DPNS42=`du -mshc * $DIRICONLAMPEN_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# ICON-LAM SSE (2.1)
DIRICONLAMSSE_DPNS42="/data2/backup/backup_icon/bkp_output_iconlam/sse"
TAMDIRICONLAMSSE_DPNS42=`du -mshc * $DIRICONLAMSSE_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# COSMOMET
DIRCOSMOMET_DPNS42="/data2/backup/backup_cosmo/metarea5"
TAMDIRCOSMOMET_DPNS42=`du -mshc * $DIRCOSMOMET_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# COSMOANT
DIRCOSMOANT_DPNS42="/data2/backup/backup_cosmo/antartica"
TAMDIRCOSMOANT_DPNS42=`du -mshc * $DIRCOSMOANT_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# HYCOM FORCANTES GFS

DIRFORGFS="/data/ophycom/previsao/hycom_2_2/preproc/gfs/grib_0.25"
TAMDIRFORGFS=`du -mshc * $DIRFORGFS | tail -1 | awk '{print $1}'`

#DIRFORGFS="/home/ophycom/previsao/hycom_2_2/preproc/gfs/grib"
#TAMDIRFORGFS=`ssh ophycom@10.13.100.41 "du -mshc * ${DIRFORGFS} | tail -1"`
#TAMDIRFORGFS=`echo $TAMDIRFORGFS | cut -d' ' -f1`

########################################################################
# HYCOM FORCANTES ICON

DIRFORICON="/data/ophycom/previsao/hycom_2_2/preproc/icon/grib"
TAMDIRFORICON=`du -mshc * $DIRFORICON | tail -1 | awk '{print $1}'`

#DIRFORICON="/home/ophycom/previsao/hycom_2_2/preproc/icon/grib"
#TAMDIRFORICON=`ssh ophycom@10.13.100.41 "du -mshc * ${DIRFORICON} | tail -1"`
#TAMDIRFORICON=`echo $TAMDIRFORICON | cut -d' ' -f1`

#########################################################################
# HYCOM OUTPUT 1/4

DIRHYCOM_1_4="/data/ophycom/previsao/hycom_2_2/output/Previsao_1_4/ab"
TAMDIRHYCOM_1_4=`du -mshc * $DIRHYCOM_1_4 | tail -1 | awk '{print $1}'`

#########################################################################
# HYCOM OUTPUT 1/12

DIRHYCOM_1_12="/data/ophycom/previsao/hycom_2_2/output/Previsao_1_12/ab"
TAMDIRHYCOM_1_12=`du -mshc * $DIRHYCOM_1_12 | tail -1 | awk '{print $1}'`

#########################################################################
# HYCOM OUTPUT 1/24

DIRHYCOM_1_24="/data/ophycom/previsao/hycom_2_2/output/Previsao_1_24/ab"
TAMDIRHYCOM_1_24=`du -mshc * $DIRHYCOM_1_24 | tail -1 | awk '{print $1}'`

#########################################################################
# HYCOM OUTPUT 1/12 GRADE NOVA

DIRHYCOM_1_12_GN="/data/ophycom/previsao/hycom_2_2/output/Previsao_1_12_nova/ab"
TAMDIRHYCOM_1_12_GN=`du -mshc * $DIRHYCOM_1_12_GN | tail -1 | awk '{print $1}'`

#########################################################################
# HYCOM OUTPUT 1/24 GRADE NOVA

DIRHYCOM_1_24_GN="/data/ophycom/previsao/hycom_2_2/output/Previsao_1_24_nova/ab"
TAMDIRHYCOM_1_24_GN=`du -mshc * $DIRHYCOM_1_24_GN | tail -1 | awk '{print $1}'`

#########################################################################
# WW3ICON

DIRWW3ICON_DPNS42="/data/opww3/backup/ww3icon"
TAMDIRWW3ICON_DPNS42=`du -mshc * $DIRWW3ICON_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# WW3ICLM

DIRWW3ICLM_DPNS42="/data/opww3/backup/ww3iclm"
TAMDIRWW3ICLM_DPNS42=`du -mshc * $DIRWW3ICLM_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################
# WW3GFS

DIRWW3GFS_DPNS42="/data/opww3/backup/ww3gfs"
TAMDIRWW3GFS_DPNS42=`du -mshc * $DIRWW3GFS_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################

# IMAGENS (BKP DO SUPERVISOR)

DIRIMAGENS_DPNS42="/data2/backup/backup_supervisor"
TAMDIRIMAGENS_DPNS42=`du -mshc * $DIRIMAGENS_DPNS42 | tail -1 | awk '{print $1}'`

#########################################################################

#########################################################################
# Escrevendo email com resumo da verificacao
#########################################################################

echo -e "DATAVRF: $DATAVRF\nDPNS31: $TAMDIRDPNS31_DPNS42\nDPNS41: $TAMDIRDPNS41_DPNS42\nDPNS05d: $TAMDIRDPNS05d_DPNS42\nDPNS35: $TAMDIRDPNS35_DPNS42\nICON13KM: $TAMDIRICON13KM_DPNS42\nICONDATAMET: $TAMDIRICONDATAMET_DPNS42\nICONDATAANT: $TAMDIRICONDATAANT_DPNS42\nICON4ICONLAMSAM: $TAMDIRICON4ICONLAMSAM_DPNS42\nICON4ICONLAMANT: $TAMDIRICON4ICONLAMANT_DPNS42\nICONLAMSAM: $TAMDIRICONLAMSAM_DPNS42\nICONLAMANT: $TAMDIRICONLAMANT_DPNS42\nICONLAMPEN: $TAMDIRICONLAMPEN_DPNS42\nICONLAMSSE: $TAMDIRICONLAMSSE_DPNS42\nCOSMOMET: $TAMDIRCOSMOMET_DPNS42\nCOSMOANT: $TAMDIRCOSMOANT_DPNS42\nFORCANTES_GFS: $TAMDIRFORGFS\nFORCANTES_ICON: $TAMDIRFORICON\nHYCOM_1_4: $TAMDIRHYCOM_1_4\nHYCOM_1_12: $TAMDIRHYCOM_1_12\nHYCOM_1_24: $TAMDIRHYCOM_1_24\nHYCOM_1_12_GN: $TAMDIRHYCOM_1_12_GN\nHYCOM_1_24_GN: $TAMDIRHYCOM_1_24_GN\nWW3ICON: $TAMDIRWW3ICON_DPNS42\nWW3GFS: $TAMDIRWW3GFS_DPNS42\nWW3ICLM: $TAMDIRWW3ICLM_DPNS42\nIMAGENS: $TAMDIRIMAGENS_DPNS42" > check
cat check

if [ -z $MAIL ];then
	cat check ~/scripts/invariantes/legendatamdir.txt > corpo
	cat corpo | mail -s "Conferencia do Tamanho dos Diretorios de Backup da DPNS42 - $DATA" vanessa.valentim@marinha.mil.br carolina.andrioni@marinha.mil.br lopes.raquel@marinha.mil.br	
	echo "Enviei Relatorio do Tamanho dos Diretorios de Backup para emails cadastrados!!!"
	rm corpo
fi

rm check

exit
