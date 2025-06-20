#!/usr/bin/bash
#________________________________________________________________________
# ASTEK
# Objet       : Extractions Métier
# Auteur      : xxx
# Fait le     : JJ/MM/AAAA
# Demandé par : ENTREPRISE/CLIENT
  DESCRIPTION_SCRIPT="Extractions Métier"
  NOM_SCRIPT=$(basename $0)
  FIC_LOG=$(dirname $0)"/logs/"${0%.*}.log
#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#______________________________________________
#    _____________________________________
# --| Définition des Fonctions de Base -- |
#    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
controle_code_retour(){
  #echo $ETAPE " - Code Retour : "$MaxRet | tee -a $FIC_LOG # DECOMMENTER POUR MODE DEBUG
  if (( $MaxRet != 0 ))
  then
    echo $ETAPE " - Code Retour : "$MaxRet | tee -a $FIC_LOG # COMMENTER POUR MODE DEBUG
    exit $MaxRet
  fi
}
# -----------------------------------------
initialisation_SCRIPT(){
  ETAPE="INITIALISATION DU SCRIPT"
  (( MaxRet = 0 ))
  controle_code_retour
  touch $FIC_LOG 
  DATE_DEBUT=$(date +%d"-"%m"-"%Y"_"%H"."%M"."%S)
  echo "------------------------------" | tee -a $FIC_LOG
  echo "Début de traitement : "$DATE_DEBUT | tee -a $FIC_LOG
  echo "------------------------------" | tee -a $FIC_LOG
  echo $DESCRIPTION_SCRIPT | tee -a $FIC_LOG
  echo "------------------------------" | tee -a $FIC_LOG
}
# -----------------------------------------
sortie_SCRIPT(){
  ETAPE="FIN DU SCRIPT"
  DATE_FIN=$(date +%d"-"%m"-"%Y"_"%H"."%M"."%S)
  echo "------------------------------" | tee -a $FIC_LOG
  echo "Fin de traitement : "$DATE_FIN | tee -a $FIC_LOG
  echo "------------------------------" | tee -a $FIC_LOG
  controle_code_retour
  exit $MaxRet
}
# -----------------------------------------
show_etape(){
echo "" | tee -a $FIC_LOG
echo "_____________________________________________________________________" | tee -a $FIC_LOG
echo " " $ETAPE | tee -a $FIC_LOG
echo "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯" | tee -a $FIC_LOG
echo "" | tee -a $FIC_LOG
}
#______________________________________________
#    _____________________________________
# --| Définition Fonctions et Procédures  |
#    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

lancement_Export(){
ETAPE=$1
show_etape
sqlplus -s toto/pwdtoto@BDDOracle @$Rep_travail/$2.sql
(( MaxRet = $MaxRet + $? ))
echo "Nombre de lignes ($2.csv): "$(wc -l $Rep_result/$2.csv | awk '{ print $1 }') | tee -a $FIC_LOG
controle_code_retour
}

#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
initialisation_SCRIPT
#_________________________________________________
set +x
#    _____________________________________
# --| Définition des variables ---------- |
#    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Rep_travail="/home/toto/extractions"
Rep_result=$Rep_travail"/result/"
Rep_log=$Rep_travail"/logs"
#__________________________________________________
#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\_[MAIN]_/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \
ETAPE=$DESCRIPTION_SCRIPT
show_etape
#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Positionnement dans le répertoire de travail
cd $Rep_travail
##################################
# Export des donnees A1-5
##################################
lancement_Export "Export des donnees A1" donnees_a1
lancement_Export "Export des donnees A2" donnees_a2
lancement_Export "Export des donnees A3" donnees_a3
lancement_Export "Export des donnees A4" donnees_a4
lancement_Export "Export des donnees A5" donnees_a5
##################################
# Export des donnees B1-5
##################################
lancement_Export "Export des donnees B1" donnees_b1
lancement_Export "Export des donnees B2" donnees_b2
lancement_Export "Export des donnees B3" donnees_b3
lancement_Export "Export des donnees B4" donnees_b4
lancement_Export "Export des donnees B5" donnees_b5
##################################
# Export des donnees C
##################################
lancement_Export "Export des donnees C1" donnees_c1
lancement_Export "Export des donnees C2" donnees_c1

##################################
# Export des donnees D
##################################
lancement_Export "Export des donnees D" donnees_d

#______________________________________________
(( MaxRet = $MaxRet + $? ))
controle_code_retour
#_________________________________________________ /
#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
sortie_SCRIPT