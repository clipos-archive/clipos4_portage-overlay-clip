# Based on gentoo's sys-apps/baselayout, which is
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit flag-o-matic eutils toolchain-funcs 


DESCRIPTION="Devices to be mounted in rm compartments"
#SRC_URI="mirror://clip/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-devel"

RDEPEND="clip-layout/baselayout-clip"


# ${PATH} should include where to get MAKEDEV when calling this
# function
create_generic_dev_nodes() {
	local root="${1}"
	local log="${2}"
	
	[[ -z "${log}" ]] && log="../log"
	
	einfo "Creating generic devices in $root"
	mknod -m 0666 null 		c 1 3
	mknod -m 0666 zero 		c 1 5
	mknod -m 0666 full 		c 1 7
	mknod -m 0666 urandom 	c 1 9
	# Let's not expose the real random dev to an entropy exhaustion threat
	ln -sf urandom random
	
	keepdir ${root}/shm
	fperms 0755 ${root}/shm
	
	ln -sf /proc/self/fd fd
	ln -sf fd/0 stdin
	ln -sf fd/1 stdout
	ln -sf fd/2 stderr

	# syslog cannot create a socket in /dev since it is read-only
	# => the socket is created in /var/run => this helps loggers
	# find it...
	ln -sf "${log}" log
}

create_pts() {
	local root=$1
	einfo "Creating pts in $root"	
	mknod -m 0666 tty 		c 5 0

	keepdir ${root}/pts
	fperms 0755 ${root}/pts
	dosym pts/ptmx "${root}/ptmx"
}

create_veriexec() {
	local root=$1
	einfo "Creating veriexec device in $root"
	mknod -m 0600 veriexec c 1 14
}

src_install() {
	cd ${D}
	dodir /user_devs /update_devs /jail_devs /audit_devs

	einfo "Creating user devices"
	cd ${D}/user_devs 
	create_generic_dev_nodes /user_devs
	create_pts /user_devs

	einfo "Creating update devices"
	cd ${D}/update_devs
	create_generic_dev_nodes /update_devs
	create_veriexec /update_devs
	create_pts /update_devs

	einfo "Creating audit devices"
	cd ${D}/audit_devs
	create_generic_dev_nodes /audit_devs

	einfo "Creating jail devices"
	cd ${D}/jail_devs
	create_generic_dev_nodes /jail_devs ../update/log
	create_pts /jail_devs
	dodir /jail_devs/mapper
}
