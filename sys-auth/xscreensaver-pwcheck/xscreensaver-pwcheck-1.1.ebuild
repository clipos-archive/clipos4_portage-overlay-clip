# Copyright 2007 SGDN
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="xscreensaver-pwcheck: authenticate xscreensaver users through
pwcheckd" 
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit pam

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}
