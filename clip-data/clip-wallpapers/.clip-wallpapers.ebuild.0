# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Clip wallpaper set"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="Proprietary"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=""
RDEPEND="!<x11-apps/xinit-1.3.0-r5"

src_install() {
	insinto /usr/share/wallpapers
	doins "${S}/png/"*

	pushd "${D}${CPREFIX:-/usr}/share/wallpapers" >/dev/null
	popd >/dev/null
}
