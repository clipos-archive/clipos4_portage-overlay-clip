# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for audit view in CLIP core"
HOMEPAGE="https://www.ssi.gouv.fr"

inherit views

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip-deps"

RDEPEND="!clip-deps? ( >=clip-layout/baselayout-clip-1.4.9 )"

src_install() {
	if [[ ! ${VERY_BRAVE_OR_VERY_DUMB} == "yes" ]] && [[ ${ROOT} == "/" ]] ; then
		ewarn "This should not be emerged to your root system..."
		die "silly options will destroy your system"
	fi
	
	keepdir /bin /sbin /etc /usr /var /root 
	if [[ "${ARCH}" =~ ^.*64$ ]] ; then
		keepdir /lib64
		dosym lib64 /lib
	else
		keepdir /lib
	fi
	keepdir /proc /dev /tmp 
	keepdir /log
	fperms 700 /root

	keepdir /home
	if [[ "${ARCH}" =~ ^.*64$ ]] ; then
		keepdir /usr/lib64 /usr/local/lib64
		dosym lib64 /usr/lib
		dosym lib64 /usr/local/lib
	else
		keepdir /usr/lib /usr/local/lib
	fi
	keepdir /mnt/usb /mnt/cdrom
	keepdir /etc/audit

	views_create_etc_symlinks 
	insinto /etc
	doins "${FILESDIR}/mtab"
}
