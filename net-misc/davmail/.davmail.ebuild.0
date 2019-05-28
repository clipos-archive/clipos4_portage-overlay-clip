# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit eutils java-pkg-2 java-ant-2

EXTRA_REV="2066"
MY_P="${PN}-src-${PV}-${EXTRA_REV}"

DESCRIPTION="Local Gateway to enable MS Exchange e-mail/calendar access"
DESCRIPTION_FR="Passerelle locale de connection à un serveur MS Exchange, permettant un accès à la messagerie et au calendrier depuis Thunderbird"
CATEGORY_FR="Réseau"
HOMEPAGE="http://sourceforge.net/projects/davmail"
SRC_URI="mirror://sourceforge/davmail/${MY_P}.tgz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip"

RDEPEND="virtual/jre
		>=dev-java/swt-3.6"

DEPEND=">=virtual/jdk-1.6
	>=dev-java/ant-core-1.8.2"

ANT_TASKS="all"

pkg_setup() {
	DISTNAME="davmail-linux-x86-${PV}"
	if use amd64; then
		DISTNAME="davmail-linux-x86_64-${PV}"
	fi

	DIST="${WORKDIR}/${MY_P}/dist/${DISTNAME}-trunk.tgz"
	S="${WORKDIR}/${MY_P}"
}

#src_prepare() {
	#use clip && epatch "${FILESDIR}/${PN}-3.8.8-clip-useragent.patch"
#}

src_compile() {
	# Grr, stupid ant thinks it can connect to X, and fails when it can't...
	unset DISPLAY XAUTHORITY
	export ANT_OPTS=-Dfile.encoding=UTF-8
	eant 
}

src_install() {
	mkdir "${T}/dist"
	tar -C "${T}/dist" -xzvpf "${DIST}"
	
	dodir /usr/lib/davmail

	mv "${T}/dist/${DISTNAME}"/* "${D}${CPREFIX:-/usr}/lib/davmail/"
	rm "${D}${CPREFIX:-/usr}/lib/davmail/davmail.sh"
	exeinto /usr/lib/davmail
	doexe "${FILESDIR}/davmail.sh"

	doicon "${S}/dist/"/${PN}.png
	domenu "${FILESDIR}"/${PN}.desktop
}
