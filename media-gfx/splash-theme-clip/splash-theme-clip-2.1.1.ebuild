# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Boot-time splash theme for clip"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="Proprietary"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

RDEPEND=">=media-gfx/splashutils-1.1.9.5"

src_install() {
	dodir /etc/splash/clip
	cp -pR ${S}/clip ${D}/etc/splash

	if [ ! -e ${ROOT}/etc/splash/default ]; then
		dosym /etc/splash/clip /etc/splash/default
	fi
}
