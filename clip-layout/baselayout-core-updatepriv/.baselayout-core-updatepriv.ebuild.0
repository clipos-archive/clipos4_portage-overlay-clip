# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for private files of update view in CLIP core"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-devel core-rm"

RDEPEND=">=clip-layout/baselayout-clip-1.4.15-r3"

PROVIDE="virtual/baselayout"

src_install() {
	if [[ ! ${VERY_BRAVE_OR_VERY_DUMB} == "yes" ]] && [[ ${ROOT} == "/" ]] ; then
		ewarn "This should not be emerged to your root system..."
		die "silly options will destroy your system"
	fi
	
	keepdir /root /var /dev /dev/mapper
	

	# basic var stuff
	keepdir /var/lib/misc /var/lock/subsys /var/log /var/run /var/spool /var/state 
	keepdir /var/shared
	diropts -m1777; keepdir /var/tmp
	diropts -m0755

	# apt stuff
	keepdir /var/pkg
	if use core-rm; then
		for j in rm_h rm_b; do
			keepdir /var/${j}/pkg/lib/dpkg
		done
	fi
	
	# tmp
	diropts -m1777; keepdir /tmp
	
	# cron stuff
	diropts -m0750 -o root -g 16; keepdir /var/spool/cron
	diropts -m0750; keepdir /var/spool/cron/lastrun
	diropts -m0750 -o root -g 16; keepdir /var/spool/cron/crontabs

	# devices
	cd "${D}/dev"
	einfo "Creating generic devices in `pwd`"
	mknod -m 0666 null 		c 1 3
	mknod -m 0666 zero 		c 1 5
	mknod -m 0666 full 		c 1 7
	mknod -m 0666 urandom 	c 1 9
	ln -sf urandom random
	mknod -m 0600 veriexec c 1 14
	mknod -m 0660 sr0	b 11 0

	ln -sf /proc/self/fd fd
	ln -sf fd/0 stdin
	ln -sf fd/1 stdout
	ln -sf fd/2 stderr

	mkdir pts
	chmod 0755 pts
	ln -s pts/ptmx ptmx
}
