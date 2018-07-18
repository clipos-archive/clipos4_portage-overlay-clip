# Copyright 2007 SGDN
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="pwcheckd: authenticate users sending their password over a UNIX
socket"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit pam verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip clip-tcb"

RDEPEND=">=clip-libs/clip-lib-1.2.9
		sys-libs/pam
		sys-apps/shadow
		clip-tcb? ( sys-apps/tcb )"

DEPEND="${RDEPEND}"

src_compile() {
	local conf="--enable-syslog"
	econf ${conf} `use_enable clip-tcb tcb` || die "Configure failed"
	emake || die "Make failed"
}

src_install() {
	emake DESTDIR="${D}" install

	use clip && newpamd "${FILESDIR}"/pwcheckd.pam pwcheckd

}

