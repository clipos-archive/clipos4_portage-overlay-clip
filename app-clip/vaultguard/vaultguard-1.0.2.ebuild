# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Virtual vault to keep user's secrets"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86"
IUSE="debug clip-deps"

DEPEND="
	!clip-deps? (
		clip-libs/clip-lib
		dev-libs/glib
		sys-libs/glibc
	)
"
RDEPEND="${DEPEND}"

# user _vault
MY_VAULT_UID=6000
# group vault_import
MY_VAULT_GID_IMPORT=6000
# group vault_guard
MY_VAULT_GID_GUARD=6001

src_compile() {
	emake VAULT_UID="${MY_VAULT_UID}" VAULT_GID_IMPORT="${MY_VAULT_GID_IMPORT}" \
		VAULT_GID_GUARD="${MY_VAULT_GID_GUARD}" PREFIX_ETC="${EPREFIX}${CPREFIX}" \
		DEBUG="$(use debug && echo 1 || echo 0)"
}

src_install() {
	einstall VAULT_UID="${MY_VAULT_UID}" VAULT_GID_IMPORT="${MY_VAULT_GID_IMPORT}" \
		VAULT_GID_GUARD="${MY_VAULT_GID_GUARD}" DESTDIR="${D}" \
		PREFIX="${EPREFIX}${CPREFIX:-/usr}" PREFIX_ETC="${EPREFIX}${CPREFIX}"
}

pkg_predeb() {
	# Need to override initial directory permissions
	doverictld2 "${CPREFIX:-/usr}/bin/vault" e DAC_OVERRIDE DAC_OVERRIDE - -
}
