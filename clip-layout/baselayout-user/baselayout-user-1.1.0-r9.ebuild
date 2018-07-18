# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for user view"
HOMEPAGE="https://www.ssi.gouv.fr"

inherit views

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

# Provide a virtual linux-sources as well here to fix
# some borken run depends checking
PROVIDE="virtual/baselayout virtual/linux-sources"

src_install() {
	if [[ ! ${VERY_BRAVE_OR_VERY_DUMB} == "yes" ]] && [[ ${ROOT} == "/" ]] ; then
		ewarn "This should not be emerged to your root system..."
		die "silly options will destroy your system"
	fi
	
	keepdir /bin /etc /home /sbin /usr /var /root 
	keepdir /proc /dev/pts /dev/shm /opt /tmp
	fperms 700 /root

	if use amd64; then
		keepdir /lib64
		dosym lib64 /lib
		keepdir /usr/lib64
		dosym lib64 /usr/lib
	else
		keepdir /lib
	fi

	keepdir /usr/local
	fperms 0700 /tmp

	keepdir /mnt/usb /mnt/cdrom

	insinto /etc
	doins "${FILESDIR}/mtab"

	views_create_etc_symlinks
	# Needed by e.g. acroread. Yuck.
	dosym /usr/local/etc/gre.d /etc/gre.d
	# kssl needs this for now
	dosym /usr/local/etc/ssl /etc/ssl
	# kde gives a periodical error unless we have this
	dosym /etc/mtab /etc/fstab
	# Similarly needed by e.g. flashplayer. Similarly yuck.
	dosym /usr/local/etc/adobe /etc/adobe
}
