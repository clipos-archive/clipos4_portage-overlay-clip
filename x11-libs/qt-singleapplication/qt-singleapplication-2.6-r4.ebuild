# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Qt Solution's single application"
HOMEPAGE="http://qt.nokia.com/products/appdev/add-on-products/catalog/4/Utilities/qtsingleapplication/"
MY_P="${P/-/}_1-opensource"
SRC_URI="mirror://clip/${MY_P}.tar.gz"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

RDEPEND="dev-qt/qtcore
		 dev-qt/qtgui"
DEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

setqtenv() {
	export V_QTLIBDIR="/usr/lib/qt4"
	export V_QTHEADERDIR="/usr/include/qt4"

	export QTLIBDIR="${CPREFIX:-/usr}/lib/qt4"
	export QTHEADERDIR="${CPREFIX:-/usr}/include/qt4"
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-2.6-getuid.patch"
}

src_configure() {
	setqtenv

	cd "${S}"/buildlib || die "cd buildlib failed"
	qmake -unix || die "qmake failed"

	if [[ -n "${CPREFIX}" ]]; then
		sed -i -e "s:^LFLAGS.*:& $LDFLAGS:g" Makefile \
			|| die "sed failed"
	fi
}

src_compile() {
	cd "${S}"/buildlib || die "cd buildlib failed"
	emake || die "make failed"
}

src_install() {
	setqtenv

	dodir "${V_QTLIBDIR}" "${V_QTHEADERDIR}/QtSolutions"
	cp -R "${S}/lib/"* "${D}/${QTLIBDIR}" || die "lib install failed"

	cp "${S}/src/"*.h "${S}/src/"QtSingleApplication "${S}/src/"QtLockedFile \
		"${D}/${QTHEADERDIR}/QtSolutions" || die "include install failed"
}
