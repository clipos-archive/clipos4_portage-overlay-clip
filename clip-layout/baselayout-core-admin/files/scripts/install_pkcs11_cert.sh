#!/bin/sh
# install_pkcs11_cert.sh - Install a new CA certificate for pam_pkcs11
# Copyright (c) 2009 SGDN/DCSSI
# Copyright (c) 2011 SGDSN/ANSSI
# Author: Vincent Strubel <clipos@ssi.gouv.fr>
# Distributed under the terms of the GNU General Public License
# version 2.

error() {
	Xdialog --title "Installation du certificat PKCS11 - Erreur" --no-cancel --wrap \
		--msgbox "Installation du certificat PKCS11.\nErreur dans le traitement :\n${1}" \
		0 0
	exit 1
}

DESTDIR="/etc/admin/pkcs11/cacerts"
SOURCE="$(Xdialog --center --stdout --title "Séléction du certificat PKCS11 à installer" \
		--fselect /mnt/usb 0 0)"

[[ -n "${SOURCE}" ]] || exit 1
DEST="$(basename "${SOURCE}")"

REMOVE="$(find /etc/admin/pkcs11/cacerts -type l)"

# Not too clean...
for l in ${REMOVE}; do
	rm -f "${l}"
done

save_umask=$(umask)
umask 0133 && cp -f "${SOURCE}" "${DESTDIR}/${DEST}" && chmod 644 "${DESTDIR}/${DEST}"
ret=$?
umask ${save_umask}
[[ $ret -eq 0 ]] || error "Impossible de copier ${SOURCE} sur ${DESTDIR}/${DEST}."

install_cert -d "${DESTDIR}"
if [[ $? -ne 0 ]]; then
	error "Erreur install_cert."
else
	Xdialog --title "Installation du certificat PKCS11" --no-cancel \
		--msgbox "Le certificat ${SOURCE} a été correctement installé." 0 0
	exit 0
fi
