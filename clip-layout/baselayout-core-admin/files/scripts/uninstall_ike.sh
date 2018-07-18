#!/bin/sh
# uninstall_ike.sh - uninstall a CCSD key for CLIP IKE
# Copyright (c) 2009 SGDN
# Author: Vincent Strubel <clipos@ssi.gouv.fr>
# Distributed under the terms of the GNU General Public License
# version 2.

error() {
	Xdialog --title "Suppression de clé IPsec - Erreur" --no-cancel \
		--msgbox "Suppression de clé IKE.\nErreur dans le traitement :\n${1}" \
		0 0
	exit 1
}

SOURCE="$(Xdialog --center --stdout --title "Séléction de la clé IPsec à supprimer" --fselect \
		/etc/admin/ike2/cert 0 0)"

[[ -n "${SOURCE}" ]] || exit 1

SOURCE_BN="$(basename "${SOURCE}")"

Xdialog --center --wrap --title "Confirmation de la suppression de clé IPsec" \
	--yesno "Confirmer vous la suppression de la clé IPsec suivante ?\n${SOURCE_BN}" 0 0

[[ $? -eq 0 ]] || exit 0

install_ccsd -u "${SOURCE_BN}"
if [[ $? -ne 0 ]]; then
	error "Erreur install_ccsd."
else
	Xdialog --title "Suppression de clé IPsec" --no-cancel \
		--msgbox "Le fichier ${SOURCE_BN} a été supprimé." 0 0
	exit 0
fi
