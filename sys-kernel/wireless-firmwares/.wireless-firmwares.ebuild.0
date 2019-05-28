# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
DESCRIPTION="Wireless NIC firmwares for CLIP"
HOMEPAGE=""
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="Proprietary"
SLOT="0"
KEYWORDS="x86 ~arm ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	dodir /lib/firmware
	cp -rd "${S}/firmware/"* "${D}/lib/firmware/" || die
}
