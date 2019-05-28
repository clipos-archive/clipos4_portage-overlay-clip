# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3
DESCRIPTION="Graphical installer for CLIP"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 arm ~amd64"
IUSE="doc clip"

CDEPEND=">=clip-libs/ClipQt-1.0.1
		 >=app-clip/clip-config-2.1.4
		 >=clip-data/clip-icons-1.0.8
		 >=clip-dev/clip-installer-2.15.0
		 x11-misc/xdialog
		 dev-qt/qtcore
		 dev-qt/qtgui
		 x11-libs/qt-singleapplication"
RDEPEND="${CDEPEND}
		 >=clip-dev/clip-livecd-2.4.10"
DEPEND="${CDEPEND}"

src_configure() {
	econf || die "configure failed"
}

src_compile() {
	emake || die "make failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}

