# Based on baselayout-lite-1.0_pre1.ebuild, which is 
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Baselayout for user view"
HOMEPAGE="https://www.ssi.gouv.fr"

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

	keepdir /bin /etc /var /tmp /usr/local/share
	if use amd64; then
		keepdir /lib64 /usr/lib64 /usr/local/lib64
		dosym lib64 /lib
		dosym lib64 /usr/lib
		dosym lib64 /usr/local/lib
	else
		keepdir /lib /usr/lib /usr/local/lib
	fi
	keepdir /vserver/run /xauth
	keepdir /tmp/.X11-unix

	fperms 1777 /tmp
	fperms 1777 /xauth
}
