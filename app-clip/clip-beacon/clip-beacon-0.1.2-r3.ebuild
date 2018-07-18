# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Sends information to device management system"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2 deb

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86"
IUSE="clip-deps"

DEPEND="
	!clip-deps? (
		net-misc/curl
	)
"
RDEPEND="${DEPEND}"

SCRIPTS_DIR=/lib/beacon
ETC_DIR=/etc/admin/beacon

src_compile() {
	emake \
		BEACON_URL_FILE=${ETC_DIR}/url \
		BEACON_REPORT_DIR=/var/run/beacon/ \
		BEACON_CERT_FILE=${ETC_DIR}/cert \
		BEACON_KEY_FILE=${ETC_DIR}/key \
		BEACON_CA_PATH=${ETC_DIR}/ca/ \
		BEACON_SCRIPTS="${SCRIPTS_DIR}" \
		BEACON_SEND_BIN=${CPREFIX:-/usr}/bin/clip-beacon-send
}

src_install() {
	exeinto "${CPREFIX:-/usr}/bin"
	doexe "${S}/clip-beacon"
	doexe "${S}/clip-beacon-send"
	exeinto "${SCRIPTS_DIR}"
	doexe "${FILESDIR}/scripts"/*
	keepdir "${ETC_DIR}"
}

pkg_predeb() {
	doverictld2 "${CPREFIX:-/usr}/bin/clip-beacon-send" e - - - c
}
