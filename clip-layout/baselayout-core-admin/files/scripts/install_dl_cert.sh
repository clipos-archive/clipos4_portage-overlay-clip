#!/bin/sh
# install_dl_cert.sh - Install a new HTTPS certificate for clip_download.
# Copyright (c) 2009 SGDN
# Author: Vincent Strubel <clipos@ssi.gouv.fr>
# Distributed under the terms of the GNU General Public License
# version 2.

error() {
	Xdialog --title "Installation du certificat HTTPS - Erreur" --no-cancel --wrap \
		--msgbox "Installation du certificat HTTPS.\nErreur dans le traitement :\n${1}" \
		0 0
	exit 1
}

DESTDIR="/etc/admin/clip_download/cert"
DEST="${DESTDIR}/cacert.pem"
SOURCE="$(Xdialog --center --stdout --title "Séléction du certificat HTTPS à installer" \
		--fselect /mnt/usb 0 0)"

[[ -n "${SOURCE}" ]] || exit 1

REMOVE="$(find /etc/admin/clip_download/cert -type l)"

# Not too clean...
for l in ${REMOVE}; do
	rm -f "${l}"
done

cp -f "${SOURCE}" "${DEST}"
[[ $? -eq 0 ]] || error "Impossible de copier ${SOURCE} sur ${DEST}."

install_cert -d "${DESTDIR}"
if [[ $? -ne 0 ]]; then
	error "Erreur install_cert."
else
	Xdialog --title "Installation du certificat HTTPS" --no-cancel \
		--msgbox "Le certificat ${SOURCE} a été correctement installé." 0 0
	exit 0
fi
