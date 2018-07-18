# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="USB keys management tools"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2 deb

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="core-deps clip-hermes core-rm"

DEPEND=">=clip-libs/clip-lib-1.2.3"
RDEPEND="
	>=sys-fs/lvm2-2.02.103
	>=dev-libs/openssl-1.0
	sys-fs/dosfstools
	>=sys-kernel/clip-kernel-2.6.32.12-r5
	>=clip-layout/baselayout-clip-1.8.4
	>=clip-libs/clip-sub-1.9.1
	!core-deps? (
		x11-misc/xdialog
		x11-misc/notification-daemon
	)
	sys-apps/coreutils
	>=sys-apps/util-linux-2.24
	sys-apps/pv
	>=app-clip/hotplug-clip-2.0
	>=app-clip/vsctl-1.1.2
"

pkg_setup() {
	CLIP_CONF_FILES_VIRTUAL="/etc/usbkeys.conf"
}

src_compile() {
	econf --sbindir=/sbin || die "econf failed"
	emake || "die emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_predeb() {
	# CAP_CONTEXT + CAP_SYS_ADMIN + CAP_MKNOD (device copy) inherit
	doverictld2 /sbin/usbadmin Ier - - 'CONTEXT|SYS_ADMIN|MKNOD' - ccsd

	local mnt_current="no"
	if use core-rm && use clip-hermes; then
		mnt_current="yes"
	fi
	init_maintainer "postinst"
	cat >> "${D}/DEBIAN/postinst" <<ENDSCRIPT
if [[ ! -f /etc/usbkeys.conf ]]; then
	echo "CDROM_DEVICE=\"/dev/sr0\'" >> /etc/usbkeys.conf
	echo "CLEARTEXT_LEVELS=\"rm_b clip\"" >> /etc/usbkeys.conf
fi
if ! grep -q "^USB_MOUNT_CURRENT_LEVEL=" /etc/usbkeys.conf; then
	echo "USB_MOUNT_CURRENT_LEVEL=\"${mnt_current}\"" >>/etc/usbkeys.conf
fi
if grep -q '=[^"]' /etc/usbkeys.conf; then
	sed -i -r 's/^([^=]+)=([^"].*)\$/\1="\2"/g' /etc/usbkeys.conf
fi
ENDSCRIPT
}
