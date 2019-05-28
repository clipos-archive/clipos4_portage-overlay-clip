# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

inherit pam

DESCRIPTION="Pam userpass module from OWL"
HOMEPAGE="http://www.openwall.com/"
SRC_URI="http://www.openwall.com/pam/modules/pam_userpass/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="x86 ~amd64"

DEPEND="virtual/pam"

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dopammod pam_userpass.so
	insinto /usr/include/security
	doins ${S}/include/security/{_,}pam_userpass.h

	insinto /usr/lib
	doins ${S}/libpam_userpass.so{,.1.0}

	doman pam_userpass.8
	dodoc README
}
