# Copyright 2010 SGDSN/ANSSI
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: Baptiste Gourdin <clipos@ssi.gouv.fr>
# Purpose: manage chromium extensions
#
inherit multilib eutils

ECLASS="chromium-extensions"
INHERITED="$INHERITED $ECLASS"
SRC_URI="https://clients2.google.com/service/update2/crx/response=redirect&x=id%3D${CRX_ID}%26uc -> ${P}.crx"
HOMEPAGE="https://chrome.google.com/webstore/detail/${CRX_ID}"
CHROMIUM_EXT_DIR="/usr/$(get_libdir)/chromium-browser/extensions/"

if [ -z "${CRX_ID}" ]; then
	die "Need a CRX_ID variable";
fi

chromium-extensions_src_unpack() {
	einfo "Unpacking ${P}.crx to ${WORKDIR}/${PN}"

	crx_header_size="$(python -c "import struct; f=open(\"${DISTDIR}/${P}.crx\", \"r\"); f.seek(8); len=16+struct.unpack('<I', f.read(4))[0]; len+=struct.unpack('<I', f.read(4))[0]; print len;f.close()")"
	dd bs=1 skip="${crx_header_size}" if="${DISTDIR}/${P}.crx" of="${WORKDIR}/${P}.zip"  2> /dev/null

	unzip -qo "${WORKDIR}/${P}.zip" -d "${WORKDIR}/${P}" ||  die "failed to unpack ${P}"
}

chromium-extensions_src_configure() {
	:
}

chromium-extensions_src_compile() {
	:
}

chromium-extensions_src_install() {
	einfo "insert ${WORKDIR}/${PN} into ${CHROMIUM_EXT_DIR}"
	insinto "${CHROMIUM_EXT_DIR}/${PN}"
	doins -r "${WORKDIR}/${P}"/*
}

EXPORT_FUNCTIONS src_unpack src_configure src_compile src_install
