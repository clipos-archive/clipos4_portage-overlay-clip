# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for user view in CLIP core"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI=""

inherit views

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip-single clip-deps"

RDEPEND="!clip-deps? ( >=clip-layout/baselayout-clip-1.3.4 )"

PROVIDE="virtual/baselayout"

src_install() {
	if [[ ! ${VERY_BRAVE_OR_VERY_DUMB} == "yes" ]] && [[ ${ROOT} == "/" ]] ; then
		ewarn "This should not be emerged to your root system..."
		die "silly options will destroy your system"
	fi
	
	keepdir /bin /etc /home/user /usr /var /root 
	if [[ "${ARCH}" =~ ^.*64$ ]] ; then
		keepdir /lib64
		dosym lib64 /lib
	else
		keepdir /lib
	fi
	keepdir /proc /dev /opt /tmp 
	keepdir /mnt/usb /mnt/cdrom
	use clip-single || keepdir /xauth /viewers
	keepdir /var/run/authdir
	fperms 700 /root

	# etc stuff
	views_create_etc_symlinks 
	dosym /usr/local/etc/X11 /etc/X11
	# Needed by e.g. acroread. Yuck.
	dosym /usr/local/etc/gre.d /etc/gre.d
}
