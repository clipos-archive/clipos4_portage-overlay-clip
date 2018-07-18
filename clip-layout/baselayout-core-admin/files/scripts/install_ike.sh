#!/bin/sh
# install_ike.sh - Install a CCSD key for CLIP IKE.
# Copyright (c) 2009 SGDN
# Author: Vincent Strubel <clipos@ssi.gouv.fr>
# Distributed under the terms of the GNU General Public License
# version 2.

error() {
	Xdialog --title "Installation de clé IPsec - Erreur" --wrap --no-cancel \
		--msgbox "Installation de clé IKE.\nErreur dans le traitement :\n${1}" \
		0 0 
	exit 1
}

SOURCE="$(Xdialog --center --stdout --title "Sélection de la clé IPsec à installer" --fselect \
		/mnt/usb 0 0)"

[[ -n "${SOURCE}" ]] || exit 1

install_ccsd "${SOURCE}"
if [[ $? -ne 0 ]]; then
	error "Erreur install_ccsd."
else
	Xdialog --title "Installation de clé IPsec" --no-cancel \
		--msgbox "Le fichier ${SOURCE} a été correctement installé." 0 0
	exit 0
fi
