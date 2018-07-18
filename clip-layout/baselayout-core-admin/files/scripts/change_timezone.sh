#!/bin/sh
# change_timezone.sh - change time zone
# Author: Florent Chabaud
# Distributed under the terms of the GNU General Public License
# version 2.

ZDIR="/usr/share/zoneinfo"

TREELIST="$(cd "${ZDIR}"; find * | sort | awk -F/ '{printf " " $0 " " $NF " on " NF-1}')"
DEPTH="$(cd "${ZDIR}"; find * | awk -F/ 'BEGIN{MAX=0}{if(NF-1>MAX)MAX=NF-1;}END{print MAX}')"

TZ=.

while [[ ! -f "${ZDIR}/${TZ}" ]]; do
  TZ="$(Xdialog --stdout --title "Fuseau horaire" --ok-label "Appliquer" --cancel-label "Annuler" --treeview "Sélection du fuseau horaire" 30 80 $DEPTH$TREELIST)"
  [[ $? -ne 0 ]] && exit 1
done

cat "${ZDIR}/${TZ}" > "/etc/core/localtime"
if [[ $? -ne 0 ]]; then
	Xdialog --title "Fuseau horaire : erreur" --no-cancel \
		--msgbox "Echec d'installation du fuseau horaire ${TZ}." 0 0
else
	Xdialog --title "Fuseau horaire" --no-cancel \
		--msgbox "Nouveau fuseau horaire : ${TZ}." 0 0
	exit 0
fi
