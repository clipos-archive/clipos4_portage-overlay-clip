# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3
DESCRIPTION="graphical configuration tool for clip-installer profiles"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="doc clip"

RDEPEND=">=clip-libs/ClipQt-1.0.1
		 dev-qt/qtcore
		 dev-qt/qtgui
		 x11-libs/qt-singleapplication
		 sys-apps/apt
		 >=dev-perl/CLIP-Pkg-Base-1.1.16
		 >=app-clip/clip-config-2.3.9
		 dev-perl/CLIP-Conf-Base"
DEPEND="${RDEPEND}"

src_configure() {
	econf || die "configure failed"
}

src_compile() {
	emake || die "make failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}

