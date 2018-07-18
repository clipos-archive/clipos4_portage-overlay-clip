# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3

DESCRIPTION="cryptd black-side client"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/cryptd-${PV}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="doc clip-deps"

RDEPEND="!clip-deps? (
		>=clip-libs/clip-lib-1.2.9
		>=clip-libs/libacidfile-2.0.5
		>=clip-libs/libacidcrypt-3.0.11i
		)"
DEPEND="clip-dev/ccsd-headers:3.3
		doc? ( app-doc/doxygen )
		${RDEPEND}"

S="${WORKDIR}/cryptd-${PV}"

src_configure() {
	econf \
		--enable-black-client \
		--enable-diode \
		$(use_enable doc html-doc) \
		--with-ccsd-includes=/usr/include/ccsd-3.3 \
			|| die "configure failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}
