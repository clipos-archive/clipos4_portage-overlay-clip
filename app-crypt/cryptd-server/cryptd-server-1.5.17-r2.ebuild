# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=3

DESCRIPTION="cryptd: inter-jail encryption/decryption daemon"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/cryptd-${PV}.tar.xz"

inherit verictl2 linux-info

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="doc clip"

RDEPEND=">=clip-libs/clip-lib-1.2.9
	>=clip-libs/clip-libvserver-4.0.0
	>=clip-libs/libacidfile-2.0.16
	!clip? ( app-crypt/pinentry )
	>=clip-libs/libacidcrypt-3.0.11"
DEPEND="clip-dev/ccsd-headers:3.3
		doc? ( app-doc/doxygen )
		${RDEPEND}"

S="${WORKDIR}/cryptd-${PV}"

src_configure() {
	local kerninc=""
	[[ -n "${KERNEL_DIR}" ]] && kerninc="--with-kernel-src=${KERNEL_DIR}"
	econf --enable-server \
		--enable-vserver \
		--enable-diode \
		${kerninc} \
		$(use_enable doc html-doc) \
			|| die "configure failed"

	# Yeah, that's ugly. But passing -I /usr/src/linux/include
	# rather than -I/usr/src/linux would mean that other
	# kernel includes would get picked up on the way.
	local vserver_context_include="include\/linux\/vserver\/context.h"
	if kernel_is -ge 3 10 ; then
		vserver_context_include="include\/uapi\/vserver\/context.h"
	fi
	sed -i "s/@VSERVER_CONTEXT@/${vserver_context_include}/g" "${S}/src/server.c"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	if use clip; then
		exeinto /etc/local.d
		exeopts -m0700
		doexe "${FILESDIR}"/cryptd.{start,stop}
		local feats="pe"
		sed -i -e "s/@FEATURES@/${feats}/" "${D}/etc/local.d/cryptd.start" \
			|| die "sed failed"
	fi
}

pkg_predeb() {
	# CAP_CONTEXT + CAP_SYS_ADMIN + CAP_NET_ADMIN + CAP_SYS_CHROOT, straight
	# away
	doverictld2 /usr/sbin/cryptd er \
		'CONTEXT|SYS_ADMIN|NET_ADMIN|SYS_CHROOT' 'CONTEXT|SYS_ADMIN|NET_ADMIN|SYS_CHROOT' - - 
}
