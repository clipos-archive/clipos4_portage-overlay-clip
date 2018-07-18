# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

KEYWORDS="x86"

DESCRIPTION="Safer memory allocator from Android's bionic libc"
HOMEPAGE="https://github.com/android/platform_bionic/"
SRC_URI="mirror://clip/${P}.tar.xz"
LICENSE="BSD"
SLOT="0"
IUSE="+debug +mmap-only mallinfo"

DEPEND=""
RDEPEND=""

src_compile() {
	local myconf=""
	use debug && myconf="${myconf} DEBUG=1"
	use mmap-only && myconf="${myconf} MMAP_ONLY=1"
	use mmap-only && myconf="${myconf} MALLINFO=1"

	emake "${myconf}" || die "emake failed"
}

src_install() {
	dolib "lib${PN}.so"*
}
