# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for update view in CLIP core"
HOMEPAGE="https://www.ssi.gouv.fr"

inherit views

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="core-rm"

RDEPEND=">=clip-layout/baselayout-clip-1.4.15-r1"

src_install() {
	if [[ ! ${VERY_BRAVE_OR_VERY_DUMB} == "yes" ]] && [[ ${ROOT} == "/" ]] ; then
		ewarn "This should not be emerged to your root system..."
		die "silly options will destroy your system"
	fi
	
	keepdir /bin /sbin /etc /usr /var /root 
	if use amd64; then
		keepdir /lib64
		dosym lib64 /lib
	else
		keepdir /lib
	fi
	keepdir /proc /dev /tmp 
	keepdir /viewers
	keepdir /var
	fperms 700 /root

	# etc stuff
	keepdir /etc/core
	keepdir /etc/apt

	# mount points
	keepdir /mnt/cdrom
	keepdir /mnt/usb

	keepdir /mounts/audit_root /mounts/admin_root /mounts/user_root

	views_create_etc_symlinks 
	dosym ../usr/local/etc/X11 /etc/X11
}
