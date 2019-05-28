# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

KEYWORDS="x86"

DESCRIPTION="Safer memory allocator from OpenBSD libc"
HOMEPAGE="http://openbsd.org"
SRC_URI="mirror://clip/${P}.tar.xz"
LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=""

src_compile() {
	emake
}

src_install() {
	dolib "lib${PN}.so"*
	doman openbsd-malloc.3
}
