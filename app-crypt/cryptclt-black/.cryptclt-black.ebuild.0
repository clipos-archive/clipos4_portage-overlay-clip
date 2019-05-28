# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3

DESCRIPTION="cryptd black-side GUI client"
DESCRIPTION_FR="Client diode cryptograhique (côté noir) et diode montante (niveau bas)"
CATEGORY_FR="Utilitaires"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/cryptclt-${PV}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="doc clip clip-deps"

RDEPEND=">=app-crypt/cryptd-client-black-1.5.13
		!app-crypt/cryptclt-red
		app-crypt/acid7-utils
		clip? ( >=app-antivirus/clamav-0.96.3 )
		!clip-deps? ( clip-libs/clip-lib )
		dev-qt/qtcore
		dev-qt/qtgui
		clip-libs/clip-emblem"
DEPEND="${RDEPEND}
		app-crypt/cryptclt-red
		clip-dev/ccsd-headers:3.3
		>=app-crypt/cryptd-server-1.5.14"


# TODO: Quand il y aura une doc
#DEPEND="doc? ( app-doc/doxygen )
#		${RDEPEND}"

S="${WORKDIR}/cryptclt-${PV}"

src_configure() {
	if use clip; then
	  black_socket_path="/var/run/cryptd"
	else
	  black_socket_path="/var/run/cryptd-black"
	fi

	econf \
		--enable-black-client \
		--enable-diode \
		--with-black-socket=${black_socket_path} \
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

	for d in black down; do
		cp -a ${S}/${d}/share ${KDEDEST}
		cp -a ${S}/${d}/applications ${APPDEST}
		cp -a ${S}/${d}/icons ${APPDEST}
	done

	exeinto /usr/bin
	doexe "${FILESDIR}/cryptclt_decrypt_send"
	dosym "/usr/bin/cryptclt_decrypt_send" "/etc/alt/acid7-decrypt"
}
