# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="verictl: configure veriexec"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip clip-devel static clip-core core-rm veriexec-guest"

DEPEND=">=sys-kernel/clip-kernel-3.2.26-r1"

RDEPEND="clip? ( clip-core? ( 
			>=clip-layout/baselayout-clip-1.6.2 
			>=sys-kernel/clip-kernel-3.2.19-r1
			>=app-clip/core-services-2.9.0
			core-rm? ( >=app-clip/clip-vserver-3.4.4 )
		) )"


src_compile () {
	local conf="--prefix=/usr --exec-prefix=/"
	if ! use veriexec-guest; then
		conf="${conf} --enable-devctl"
		use clip-devel && conf="${conf} --enable-veribypass"
	fi
	[[ -n "${KERNEL_DIR}" ]] && conf="${conf} --with-kernel-includes=${KERNEL_DIR}/include"
	econf ${conf} $(use_enable static) || die "econf failed"
	emake || die "emake failed"
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	into /
	if use clip-core && ! use veriexec-guest ; then
		doinitd "${FILESDIR}"/veriexec
		doinitd "${FILESDIR}"/reducecap
		doinitd "${FILESDIR}"/devctl
	fi
}

pkg_predeb () {
	if use clip-core && ! use veriexec-guest; then
		doverictld2 /sbin/verictl er \
			'CONTEXT|SYS_ADMIN' CONTEXT 'CONTEXT|SYS_ADMIN' V
		if use clip-devel; then
			doverictld2 /sbin/devctl er SYS_ADMIN - SYS_ADMIN -
		fi
	else # veriexec-guest
		doverictld2_vroots /sbin/verictl er - - - V
	fi # veriexec-guest

	if use clip-core && ! use veriexec-guest ; then
		init_maintainer "postinst"
		cat >> "${D}"/DEBIAN/postinst << ENDSCRIPT
/sbin/rc-update add reducecap default
/sbin/rc-update add veriexec nonetwork
/sbin/rc-update add devctl boot

ENDSCRIPT

		init_maintainer "prerm"
		cat >> "${D}"/DEBIAN/prerm << ENDSCRIPT
/sbin/rc-update del reducecap default
/sbin/rc-update del veriexec nonetwork
/sbin/rc-update del devctl boot

ENDSCRIPT

	fi # clip-core
}
