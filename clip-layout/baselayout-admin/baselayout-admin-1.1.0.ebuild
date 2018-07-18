# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for admin view"
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
	
	keepdir /bin /etc /home /lib /sbin /usr /var /root 
	keepdir /proc /dev/pts /dev/shm /tmp

	keepdir /usr/etc/ssh

	fperms 700 /root
	fperms 1777 /tmp

	keepdir /usr/lib /usr/sbin /var/empty

	views_create_etc_symlinks
}
