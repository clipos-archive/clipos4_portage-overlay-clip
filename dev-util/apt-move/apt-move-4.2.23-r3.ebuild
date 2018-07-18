# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Utility to move a collection of .deb files into a proper mirror"
HOMEPAGE="http://packages.debian.org/unstable/admin/apt-move/"
SRC_URI="http://ftp.debian.org/debian/pool/main/a/apt-move/${PN}_${PV}.tar.gz"

inherit eutils

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86"
IUSE=""

DEPEND="sys-apps/apt"
RDEPEND="sys-apps/apt"

src_unpack() {
	unpack "${A}" || die "Failed to unpack"

	cd "${S}" && epatch "${FILESDIR}/${P}-mawk-awk.patch"
	cd "${S}" && epatch "${FILESDIR}/${PN}-noash-nodash.patch"

}

src_install() {
	dodir /usr/bin
	dodir /usr/lib/apt-move
	dodir /usr/share/apt-move
	dodir /etc
	dodir /usr/share/man/man8
	emake DESTDIR=${D} install
	dodir /etc/apt-move
	insinto /etc/apt-move
	doins ${FILESDIR}/apt-move.conf.clip
	doins ${FILESDIR}/apt-move.conf.clip-single
	doins ${FILESDIR}/apt-move.conf.rm
}
