# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit verictl2 eutils

DESCRIPTION="Hotplug event handler for CLIP"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="GPL-2 LGPL-3"
SLOT="0"
KEYWORDS="x86 arm ~amd64"
IUSE="debug clip"

DEPEND=""
RDEPEND=">=app-clip/verictl-2.0.0-r3
		>=sys-kernel/clip-kernel-2.6.29.4-r2
		sys-apps/ozerocdoff
		!<app-clip/clip-usb-keys-2.4.0"

src_compile() {
	econf \
		--exec-prefix=/ \
		--bindir=/usr/bin \
		$(use_enable debug) \
			|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodir "/mounts/admin_root/usr/bin"
	mv "${D}/usr/bin/clip-device-request" "${D}/mounts/admin_root/usr/bin" || die

	dodir "/lib/devices.d"
}

pkg_predeb() {
	doverictld2 /sbin/hotplug Iker - - 'CONTEXT|SYS_ADMIN|NET_ADMIN|MKNOD|KILL' F
	doverictld2 /sbin/eventd Ier - - 'NET_ADMIN|NET_BIND_SERVICE|NET_RAW|MKNOD' s
	doverictld2 /sbin/device-admind Ier - - 'SYS_ADMIN' -
}
