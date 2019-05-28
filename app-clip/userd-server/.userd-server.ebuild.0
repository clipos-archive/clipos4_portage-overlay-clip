# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
DESCRIPTION="userd: daemon handling user management tasks"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/userd-${PV}.tar.xz"

inherit pam verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip"

RDEPEND=">=clip-libs/clip-lib-1.2.9
		!app-clip/clip-useradmin
		sys-libs/pam
		>=dev-libs/libp11-0.2"
DEPEND="${RDEPEND}"

S="${WORKDIR}/userd-${PV}"

CLIP_CONF_FILES="/etc/conf.d/user-ssh"

src_configure() {
	econf --enable-server || die
}

src_install() {
	emake DESTDIR="${D}" install || die ""

	if use clip; then
		exeinto /etc/local.d
		exeopts -m0700
		doexe "${FILESDIR}"/userd.{start,stop}

		insinto /etc/conf.d
		doins "${FILESDIR}"/user-ssh

		dopamd "${FILESDIR}"/pam.d/*
	fi
}

pkg_predeb() {
	# CAP_SYS_ADMIN + CAP_MKNOD, forced inheritable + effective SYS_ADMIN
	# away
	doverictld2 /usr/sbin/userd Ier \
		'MKNOD|SYS_ADMIN' 'SYS_ADMIN' 'MKNOD|SYS_ADMIN' -
}	
