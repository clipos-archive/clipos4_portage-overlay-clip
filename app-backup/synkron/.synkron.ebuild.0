# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils qt4

MY_P="Synkron-${PV}-src"
DESCRIPTION="QT4 backup utility"
HOMEPAGE="http://synkron.sourceforge.net/"
SRC_URI="mirror:///sourceforge/${MY_P}.tar.gz"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 x86"
IUSE="debug"

RDEPEND="dev-qt/qtgui"
DEPEND="$RDEPEND"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.6.2-fr-only.patch
}

src_configure() {
	lrelease Synkron.pro || die "lrelease failed"
	eqmake4 Synkron.pro PREFIX=${CPREFIX:-/usr}
}

src_compile() {
	emake || die "make failed"
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die 'make install failed'
	dodir /usr/bin
	dobin "${S}"/synkron || die "synkron not found"

	insinto /usr/share/pixmaps
	newins "${S}/images/Synkron48.png" synkron.png
	insinto /usr/share/applications
	doins "${FILESDIR}/synkron.desktop"
}
