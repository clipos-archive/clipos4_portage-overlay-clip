# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib verictl2 remove-other-perms

DESCRIPTION="clip-install-common: tool to install CLIP updates"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-devel clip-core clip-rm"

DEPEND=""
RDEPEND="
	>=dev-perl/CLIP-Pkg-Base-1.2.0
	>=dev-perl/CLIP-Pkg-Install-1.1.9
	sys-apps/apt
	app-arch/dpkg"

src_unpack() {
	unpack ${A}
	cd "${S}" || die "Could not cd to ${S}"
}

src_compile() {
	econf || die "could not configure"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodir /usr/share/clip-install
	insinto /usr/share/clip-install
	doins "${FILESDIR}/features"

	remove-other-perms
}

pkg_predeb() {
	doverictld2 "${CPREFIX:-/usr}/bin/clip_install" Ier \
		'FSETID' - 'FSETID' -
	if use clip-core; then
		VERIEXEC_CTX=501 doverictld2 "${CPREFIX:-/usr}/bin/clip_install" Ier \
								'FSETID' - 'FSETID' -
	fi

	if use clip-rm; then
		cat >>  "${D}/DEBIAN/postinst" <<EOF
if [[ "\${1}" == "configure" ]]; then
	rm -f /var/pkg/mirrors/flags/rm_core || true
fi
EOF
	fi
}
