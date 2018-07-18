# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils gnome2 deb verictl2

DESCRIPTION="Kerberos 5 authentication dialog"
DESCRIPTION_FR="Outil graphique d'authentification par Kerberos"
CATEGORY_FR="Utilitaires"
HOMEPAGE="https://honk.sigxcpu.org/piki/projects/krb5-auth-dialog/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="+caps"

RDEPEND="virtual/krb5
	caps? ( sys-libs/libcap )"
DEPEND="${RDEPEND}
	app-text/gnome-doc-utils"

src_prepare() {
	epatch "${FILESDIR}"/krb5-auth-dialog-3.12.0-clip-stay-systray.patch
	epatch "${FILESDIR}"/krb5-auth-dialog-3.12.0-clip-i18n.patch
	epatch "${FILESDIR}"/krb5-auth-dialog-3.12.0-clip-fix-looping-grab-creds.patch
	epatch "${FILESDIR}"/krb5-auth-dialog-3.12.0-clip-fix-useless-cred-copy.patch
	epatch "${FILESDIR}"/krb5-auth-dialog-3.12.0-clip-threaded-grab-cred.patch
}

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-scrollkeeper
		$(use_with caps libcap)"
}

pkg_predeb() {
	einfo "Creating postinst"
	init_maintainer "postinst"
	cat >> "${ED}/DEBIAN/postinst" <<-EOF
		/usr/bin/glib-compile-schemas ${CPREFIX:-/usr}/share/glib-2.0/schemas
	EOF

	doverictld2 "${CPREFIX:-/usr}/bin/krb5-auth-dialog" e - - - c
}
