# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for private files of admin view in CLIP core"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="core-rm"

RDEPEND=">=clip-layout/baselayout-clip-1.3.6"

PROVIDE="virtual/baselayout"

CLIP_CONF_FILES="/etc.admin/issue"

src_install() {
	if [[ ! ${VERY_BRAVE_OR_VERY_DUMB} == "yes" ]] && [[ ${ROOT} == "/" ]] ; then
		ewarn "This should not be emerged to your root system..."
		die "silly options will destroy your system"
	fi
	
	keepdir /home /dev 
	keepdir /var/log /var/empty /var/run /var/lock /var/pkg /var/shared
	
	touch ${D}/var/{log/wtmp,log/lastlog,run/utmp}
	fowners root:utmp /var/run/utmp
	fowners root:utmp /var/log/wtmp
	fperms 664 /var/run/utmp
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

	mknod -m 0666 tty 		c 5 0
	dosym pts/ptmx /dev/ptmx
	chown root:tty tty
	mkdir pts
	chmod 0755 pts

	keepdir /etc.admin 
	if use core-rm; then
		keepdir /etc.admin/rm_h
		keepdir /etc.admin/rm_b
	fi
	touch "${D}/etc.admin/issue"
	chown -R 4000:4000 "${D}"/etc.admin/*
	keepdir /etc.admin/ike2 /etc.ike2
	chown 4000:4000 "${D}/etc.ike2"
	keepdir /etc.admin/netconf.d
	chown 4000:4000 "${D}/etc.admin/netconf.d"

	keepdir /dev/mapper

	keepdir /home/admin
}
