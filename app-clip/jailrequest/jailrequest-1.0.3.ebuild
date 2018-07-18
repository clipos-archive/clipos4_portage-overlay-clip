# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="jailrequest : poke a jail'ed jailmaster from outside the jail"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

src_compile () {
	econf || die "configure failed"
	emake || die "make failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}
