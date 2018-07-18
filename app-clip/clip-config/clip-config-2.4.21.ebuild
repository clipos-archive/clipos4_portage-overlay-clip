# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="graphical configuration tool"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="doc clip core-deps clip-deps clip-livecd"

RDEPEND=">=clip-libs/ClipQt-2.0.0
		 dev-qt/qtcore
		 dev-qt/qtgui
		 x11-libs/qt-singleapplication
		 !core-deps? ( clip-libs/clip-lib )
		 >=app-clip/userd-client-1.2.0
		 >=clip-data/clip-icons-1.0.15
		 !clip-deps? (
		 	 dev-perl/CLIP-Conf-Base
			 dev-perl/CLIP-Logger
			 >=dev-perl/CLIP-Pkg-Base-1.1.15
		)"
DEPEND="${RDEPEND}
		app-clip/userd-server"

src_compile () {
	econf || die "configure failed"
	emake || die "make failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	local confdir="confs"
	use clip-livecd && confdir="confs-livecd"
	doins "${FILESDIR}/${confdir}/"*
}

pkg_predeb() {
	VERIEXEC_CTX=503 doverictld2  ${CPREFIX:-/usr}/bin/clip-audit-config e - - - c
	VERIEXEC_CTX=504 doverictld2  ${CPREFIX:-/usr}/bin/clip-config e - - - c
}

