# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Extra firmwares (except wireless firmwares) for CLIP"
HOMEPAGE=""
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="Proprietary"
SLOT="0"
KEYWORDS="x86 ~amd64 ~arm"
IUSE=""

DEPEND=""
RDEPEND="!<sys-kernel/wireless-firmwares-2.0"

src_install() {
	dodir /lib/firmware
	insinto /lib/firmware
	cd ${S}
	doins -r *
}
