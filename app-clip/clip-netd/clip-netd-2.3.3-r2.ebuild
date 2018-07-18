# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Networking config restarter daemon"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-hermes core-rm"

RDEPEND=">=clip-libs/clip-lib-1.2.3"
DEPEND="=sys-devel/automake-1.10*
		${RDEPEND}"

src_compile () {
	# Note /etc/init.d/netconf stop will stop all networking script, 
	# while /etc/init.d/netup start will start all of them, due to
	# dependencies
	econf --sbindir=/sbin \
		--with-stop-script="/etc/init.d/netconf" \
		--with-start-script="/etc/init.d/netup" \
			|| die "econf failed"
	emake || "die emake failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
	doinitd "${FILESDIR}"/netup

	dodir /mounts/admin_root/bin
	cp -a "${D}/usr/bin/netd-client" "${D}/mounts/admin_root/bin/netd-client"

	exeinto /mounts/admin_root/bin
	doexe "${FILESDIR}/net-change-profile"

	if use clip-hermes && use core-rm; then 
		sed -i -e 's/need ipsec/need ipsec stunnel/' "${D}/etc/init.d/netup" \
			|| die "sed failed"
	fi
}

pkg_predeb() {
	init_maintainer "postinst"
	cat >> "${D}/DEBIAN/postinst" <<ENDSCRIPT
rc-update add netup default
ENDSCRIPT
	init_maintainer "prerm"
	cat >> "${D}/DEBIAN/prerm" <<ENDSCRIPT
rc-update del netup default
ENDSCRIPT
	doverictld2 /sbin/netd Ier - - 'NET_ADMIN|NET_BIND_SERVICE|NET_RAW' -
	doverictld2 /sbin/ipsec-updownd Ier - - 'CONTEXT|SYS_ADMIN|NET_ADMIN' -
}
