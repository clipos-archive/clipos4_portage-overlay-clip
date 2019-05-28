# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3

inherit autotools

DESCRIPTION="Library regrouping all clip helper functions"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

src_prepare() {
	eautoreconf # Needed to fix $#?!&* Debian autotools :)
}

src_configure() {
	econf $(use_enable doc html-doc) || die "configure failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}
