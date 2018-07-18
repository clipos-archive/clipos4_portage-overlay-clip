# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3

inherit eutils

DESCRIPTION="cryptd red-side GUI client"
DESCRIPTION_FR="Client diode cryptograhique (côté rouge) et diode montante (niveau haut)"
CATEGORY_FR="Utilitaires"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/cryptclt-${PV}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="doc clip clip-deps"

RDEPEND=">=app-crypt/cryptd-client-red-1.5.14
		app-crypt/acid7-utils
		!clip-deps? ( clip-libs/clip-lib )
		dev-qt/qtcore
		dev-qt/qtgui
		clip-libs/clip-emblem"
DEPEND="${RDEPEND}
		clip-dev/ccsd-headers:3.3
		>=app-crypt/cryptd-server-1.5.14"

# TODO: Quand il y aura une doc
#DEPEND="doc? ( app-doc/doxygen )
#		${RDEPEND}"

S="${WORKDIR}/cryptclt-${PV}"

src_configure() {
	if use clip; then
	  red_socket_path="/var/run/cryptd"
	else
	  red_socket_path="/var/run/cryptd-red"
	fi

	econf \
		--enable-red-client \
		--enable-diode \
		--with-red-socket=${red_socket_path} \
		--with-ccsd-includes=/usr/include/ccsd-3.3 \
			|| die "configure failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"

	cd ${S} || die "Cannot cd to ${S}"
	if use clip; then 
	  KDEDEST=${D}${CPREFIX:-/usr}/etc/kde
	else
	  KDEDEST=${D}/usr
	fi
	APPDEST="${D}${CPREFIX:-/usr}/share"
	mkdir -p ${KDEDEST} ${APPDEST}

	for d in red up; do
		cp -a ${S}/${d}/share ${KDEDEST}
		cp -a ${S}/${d}/applications ${APPDEST}
		cp -a ${S}/${d}/icons ${APPDEST}
	done

	dosym /usr/bin/cryptclt_decrypt /etc/alt/acid7-decrypt
}
