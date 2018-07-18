# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Display client and daemon for CLIP SSM"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} app-crypt/pinentry >=dev-lang/python-2.6.0"

src_install () {
	einstall DESTDIR=${D} PREFIX=${EPREFIX}${CPREFIX:-/usr}
}
