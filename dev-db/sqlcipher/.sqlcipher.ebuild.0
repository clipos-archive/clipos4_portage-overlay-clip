# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils flag-o-matic

DESCRIPTION="Open source extension to SQLite that provides transparent 256-bit AES encryption of database files"
HOMEPAGE="http://sqlcipher.net"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="core-deps clip clip-devstation"
LICENSE="sqlcipher"

RDEPEND="
	!core-deps? (
		dev-libs/openssl
		sys-libs/glibc
		sys-libs/ncurses
		sys-libs/readline
		sys-libs/zlib
	)
	dev-lang/tcl
	clip? ( app-clip/fdp )
"
DEPEND="${RDEPEND}
	clip-devstation? ( app-clip/fdp )"

#export LDFLAGS="-lfdp-client"

src_configure() {
	append-cflags -DSQLITE_HAS_CODEC

	if use clip; then
		epatch "${FILESDIR}/${PN}-2.2.1-clip-fdp.patch"
		append-ldflags -lfdp-client
	fi

	econf --enable-tempstore=yes
}
