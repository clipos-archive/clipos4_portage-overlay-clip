# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for private files of user view in CLIP core"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-devel clip-single"

RDEPEND=">=clip-layout/baselayout-clip-1.4-r1"

PROVIDE="virtual/baselayout"

src_install() {
	if [[ ! ${VERY_BRAVE_OR_VERY_DUMB} == "yes" ]] && [[ ${ROOT} == "/" ]] ; then
		ewarn "This should not be emerged to your root system..."
		die "silly options will destroy your system"
	fi
	
	keepdir /home /var /dev
	if use clip-single; then
		keepdir /home/common /home/user
		fperms 1777 /home/common
		fperms 0600 /home/user
	fi

	# basic var stuff
	keepdir /var/lib/misc /var/lock /var/log /var/run /var/spool /var/state 
	keepdir /var/run/authdir
	keepdir /var/run/smartcard
	keepdir /var/shared
	dosym ../tmp /var/tmp
	diropts -m0755

	# SSM
	keepdir /var/run/ssm_key
	keepdir /var/run/ssm_display

	#utmp, wtmp
	touch "${D}/var/run/utmp"
	fowners root:utmp /var/run/utmp
	fperms 664 /var/run/utmp
	touch "${D}/var/log/wtmp"
	fowners root:utmp /var/log/wtmp
	fperms 664 /var/log/wtmp

	# devices
	cd "${D}/dev"
	einfo "Creating generic devices in `pwd`"
	mknod -m 0666 null 		c 1 3
	mknod -m 0666 zero 		c 1 5
	mknod -m 0666 full 		c 1 7
	mknod -m 0666 urandom 	c 1 9
	ln -sf urandom random

	ln -sf /proc/self/fd fd
	ln -sf fd/0 stdin
	ln -sf fd/1 stdout
	ln -sf fd/2 stderr

	keepdir /dev/shm /dev/pts /dev/mapper

	einfo "Creating pts"	
	mknod -m 0666 tty 		c 5 0
	dosym pts/ptmx /dev/ptmx
	chown root:tty tty
	fperms 0755 /dev/pts
}
