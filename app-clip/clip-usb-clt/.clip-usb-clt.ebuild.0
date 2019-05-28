# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Usb keys client tool"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="core-deps"

DEPEND=""
RDEPEND="!core-deps? ( >=clip-layout/baselayout-user-1.1.0-r1 )
		 !core-deps? ( >=app-clip/clip-usb-keys-2.10.0 )"

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}
