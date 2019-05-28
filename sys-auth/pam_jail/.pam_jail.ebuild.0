# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit pam

DESCRIPTION="PAM module to jail users based on their groups"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm ~amd64"
IUSE="clip"

RDEPEND="
	sys-libs/pam
	clip-libs/clip-libvserver
"

src_compile () {
	emake || die "emake failed"
}

src_install () {
	emake DESTDIR="${D}" \
		  PAMDIR="${D}/$(getpam_mod_dir)" \
		  MANDIR="${D}/${CPREFIX:-/usr}/share/man" \
		  install || die "emake install failed"

	if use clip ; then
		insinto /etc/security
		newins "${FILESDIR}"/pam_jail.conf pam_jail.conf
	fi
}
