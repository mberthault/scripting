#!/usr/bin/bash
#________________________________________________________________________
# ENTREPRISE
# Objet       : 
# Auteur      : xxx xxx
# Fait le     : //
# Demand� par : 
  DESCRIPTION_SCRIPT="" 
  NOM_SCRIPT=""
#������������������������������������������������������������������������
#______________________________________________
#    _____________________________________
# --| D�finition des Fonctions de Base -- |
#    �������������������������������������
controle_code_retour(){
  #echo $ETAPE " - Code Retour : "$MaxRet # DECOMMENTER POUR MODE DEBUG
  if (( $MaxRet != 0 ))
  then
    echo $ETAPE " - Code Retour : "$MaxRet # COMMENTER POUR MODE DEBUG
    exit $MaxRet
  fi
}
# -----------------------------------------
initialisation_SCRIPT(){
  ETAPE="INITIALISATION DU SCRIPT"
  (( MaxRet = 0 ))
  controle_code_retour
  DATE_DEBUT=$(date +%d"-"%m"-"%Y"_"%H"."%M"."%S) 
  echo "------------------------------"
  echo "D�but de traitement : "$DATE_DEBUT
  echo "------------------------------"
  echo $DESCRIPTION_SCRIPT
  echo "------------------------------"
}
# -----------------------------------------
sortie_SCRIPT(){
  ETAPE="FIN DU SCRIPT"
  DATE_FIN=$(date +%d"-"%m"-"%Y"_"%H"."%M"."%S)
  echo "------------------------------"
  echo "Fin de traitement : "$DATE_FIN
  echo "------------------------------"
  controle_code_retour
  exit $MaxRet
}
# -----------------------------------------
show_etape(){
echo ""
echo "_____________________________________________________________________"
echo " " $ETAPE
echo "���������������������������������������������������������������������"
echo ""
}
#______________________________________________
#    _____________________________________
# --| D�finition Fonctions et Proc�dures  |
#    �������������������������������������





#����������������������������������������������
initialisation_SCRIPT
#_________________________________________________
set +x
#    _____________________________________
# --| D�finition des variables ---------- |
#    �������������������������������������


#__________________________________________________
#������������������\_[MAIN]_/��������������������� \
ETAPE=$DESCRIPTION_SCRIPT
show_etape
#����������������������������������������������



#______________________________________________
(( MaxRet = $MaxRet + $? ))
controle_code_retour
#_________________________________________________ /
#��������������������������������������������������
sortie_SCRIPT
