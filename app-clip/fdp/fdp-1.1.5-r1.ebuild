# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="File Descriptor Passing helpers and library"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip clip-deps clip-rm core-rm"

DEPEND="
	!clip-deps? (
		!clip-rm? (
			>=clip-libs/clip-lib-1.2.17
		)
	)
	core-rm? ( >=sys-auth/pam_exec_pwd-1.0.3 )
"
RDEPEND="${DEPEND}"

if use clip; then
	if use clip-rm; then
		export EXTRA_EMAKE="BIN_FILES=fdp-server LIB_FILES= LIB_LINKS="
		export CLIP_CTX='rm'
	else
		export EXTRA_EMAKE="BIN_FILES=fdp-server"
		export CLIP_CTX='clip'
	fi
fi

src_install () {
	einstall DESTDIR=${D} PREFIX=${EPREFIX}${CPREFIX:-/usr}
	if use core-rm; then
		insinto /etc/security/exec.conf.d
		doins "${FILESDIR}"/110-ssm-start.conf
	fi
}
