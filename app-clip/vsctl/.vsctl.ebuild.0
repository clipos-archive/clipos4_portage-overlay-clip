# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
DESCRIPTION="vsctl: start, stop and enter simple vservers"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 arm ~amd64"
IUSE="static debug core-rm clip-gtw clip clip-livecd clip-devstation"

DEPEND=">=clip-libs/clip-libvserver-4.1.7
		>=clip-libs/clip-lib-1.2.6
		>=sys-kernel/clip-kernel-3.14
		clip-devstation? ( ~sys-kernel/linux-headers-4.4 )
		clip-livecd? ( ~sys-kernel/linux-headers-4.4 )
"

RDEPEND="${DEPEND}
		 clip? ( >=clip-layout/baselayout-clip-1.5.2 )
"

src_compile () {
	econf --prefix=/usr  --exec-prefix=/ \
		$(use_enable static) $(use_enable debug) || die "Configure failed"
	emake || die "Make failed"
}

src_install () {
	emake DESTDIR="${D}" install
	doinitd "${FILESDIR}"/vprocunhide
	dodir /etc/vprocunhide
	insinto /etc/vprocunhide
	doins "${FILESDIR}"/watch
	doins "${FILESDIR}"/all
	doins "${FILESDIR}"/none

	# Show /proc/mdstat in ADMINclip in clip-gtw
	use clip-gtw && echo "/proc/mdstat" >> "${D}${CPREFIX}"/etc/vprocunhide/all
}

pkg_predeb () {
	# CAP_CONTEXT + CAP_SYS_ADMIN + CAP_NET_ADMIN + CAP_SYS_CHROOT, straight
	# away
	doverictld2 /sbin/vsctl Ier \
		'CONTEXT|SYS_ADMIN|NET_ADMIN|SYS_CHROOT' \
		'CONTEXT|SYS_ADMIN|NET_ADMIN|SYS_CHROOT' 'NET_ADMIN|SYS_ADMIN' N
	# CAP_CONTEXT + CAP_SYS_ADMIN, inheritable
	doverictld2 /sbin/nsmount er 'CONTEXT|SYS_ADMIN' - 'CONTEXT|SYS_ADMIN' -
	# CAP_CONTEXT + CAP_SYS_ADMIN, inheritable
	doverictld2 /sbin/vspace er 'CONTEXT|SYS_ADMIN' 'CONTEXT|SYS_ADMIN' - -
	doverictld2 /sbin/vsaddr er 'CONTEXT|SYS_ADMIN|NET_ADMIN' - \
			'CONTEXT|SYS_ADMIN|NET_ADMIN' -
	doverictld2 /sbin/vswatch er 'CONTEXT|SYS_ADMIN' 'CONTEXT|SYS_ADMIN' - -

	local dirs="/"
	use core-rm && dirs="$dirs /vservers"
	
	init_maintainer "postinst"
	cat >> "${D}"/DEBIAN/postinst << ENDSCRIPT
	/sbin/rc-update add vprocunhide boot

	for dir in $dirs; do
		test -d \$dir && /sbin/vsattr --barrier \$dir
	done
ENDSCRIPT
	init_maintainer "prerm"
	cat >> "${D}"/DEBIAN/prerm << ENDSCRIPT
	/sbin/rc-update del vprocunhide boot
ENDSCRIPT
}
