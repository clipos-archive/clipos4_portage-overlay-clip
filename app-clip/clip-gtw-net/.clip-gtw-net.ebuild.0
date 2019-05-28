# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Network initialization scripts and conf files for clip gateways"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit deb eutils

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-ccsd"

RDEPEND=">=app-clip/clip-generic-net-3.1.0
		 >=clip-libs/clip-sub-1.9.0
		 >=net-misc/strongswan-4.6.2-r1
		 !virtual/clip-netbase"

PROVIDE="virtual/clip-netbase"

pkg_setup() {
	use !clip-ccsd && CLIP_CONF_FILES_VIRTUAL="/etc/conf.d/ipsec"
}

src_install () {
	local etc="etc-default"
	use !clip-ccsd && etc="etc-noccsd"
	einstall LIBDIR=$(get_libdir) DESTDIR="${D}" ETC_PROFILE="${etc}"
}

pkg_predeb() {
	if use clip-ccsd; then
		init_maintainer postinst
		cat "${FILESDIR}/postinst.mvppr" >>"${D}/DEBIAN/postinst"
	fi
}
