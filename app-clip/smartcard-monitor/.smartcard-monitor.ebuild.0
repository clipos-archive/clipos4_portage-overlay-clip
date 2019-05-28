# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit multilib eutils verictl2

DESCRIPTION="Smartcard events monitor"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~alpha ~amd64 arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc x86"
IUSE="clip"

RDEPEND="sys-apps/pcsc-lite
	!<sys-auth/pam_pkcs11-0.6.3-r1
	clip? ( clip-libs/clip-libvserver )"
DEPEND="${RDEPEND}"

CLIP_CONF_FILES="/etc/admin/conf.d/smartcards"

src_compile() {
	ADDCFLAGS=""
	ADDLDFLAGS=""
	if use clip ; then
		ADDCFLAGS="${ADDCFLAGS} -DCLIP"
		ADDLDFLAGS="${ADDLDFLAGS} -lclip -lclipvserver"
	fi
	CFLAGS="${ADDCFLAGS} ${CFLAGS}" LDFLAGS="${ADDLDFLAGS} ${LDFLAGS}" emake || die "emake failed"
}


src_install() {
	insinto /etc/conf.d/
	doins "${S}"/conf/smartcard-monitor

	doinitd "${S}"/init/smartcard-monitor

	exeinto /usr/sbin/
	doexe ${S}/smartcard_monitor
	doexe ${S}/smartcard_notifier
	doexe ${S}/smartcard_list

	exeinto /usr/bin/
	newexe ${S}/clip_xcardlock.sh xcardlock.sh
	newexe ${S}/clip_xcardactions.sh xcardactions.sh

	insinto /etc/admin/conf.d
	insopts -o 4000 -g 4000
	newins "${FILESDIR}"/smartcards.conf smartcards
}


pkg_predeb() {
	if use clip; then
		doverictld2 /usr/sbin/smartcard_monitor er \
			'CONTEXT|SYS_ADMIN' 'CONTEXT|SYS_ADMIN' - -
	fi
}
