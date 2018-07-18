# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit autotools

DESCRIPTION="Library regrouping all clip vserver helper functions"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="doc"

RDEPEND=">=sys-kernel/clip-kernel-2.6.28"
DEPEND="doc? ( app-doc/doxygen )"

src_prepare() {
	eautoreconf
}

src_configure() {
	local kerndir=""
	if [[ -n "${KERNEL_DIR}" ]]; then
		kerndir="--with-kernel-includes=${KERNEL_DIR}/include/uapi/"
	fi
	econf \
		--enable-net-ns \
		$(use_enable doc html-doc) \
		$kerndir \
			|| die "configure failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}
