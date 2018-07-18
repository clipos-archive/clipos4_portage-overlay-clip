# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="CLIP user management tools"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86"
IUSE="core-deps core-rm"

DEPEND=">=clip-libs/clip-lib-1.2.3"
RDEPEND=">=sys-kernel/clip-kernel-2.6.22
		 >=sys-fs/device-mapper-1.02.07-r1
		 >=clip-layout/baselayout-clip-1.8.4
		 >=clip-libs/clip-sub-1.3.8
		 sys-auth/pam_exec_pwd
		 >=app-clip/clip-user-mount-1.0.9
		 !core-deps? ( x11-misc/xdialog )
		 sys-apps/coreutils
		 sys-apps/util-linux"

src_compile () {
	if use core-rm; then
		econf --sbindir=/sbin --enable-corerm || die "econf failed"
	else
		econf --sbindir=/sbin || die "econf failed"
	fi
	emake || "die emake failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_predeb () {
	# CAP_SYS_ADMIN + CAP_MKNOD inherit
	doverictld2 /sbin/usersrvadmin Ier - - 'SYS_ADMIN|MKNOD' - ccsd
}
