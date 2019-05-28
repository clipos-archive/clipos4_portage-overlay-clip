# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib eutils

DESCRIPTION="Firefox extension to block Flash/Java/Javascript"
DESCRIPTION_FR="Extension Firefox permettant d'interdire sélectivement Flash / Java ou Javascript dans les pages web pour plus de sécurité"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="https://addons.mozilla.org/en/thunderbird/addons/70"
MY_P="noscript_security_suite-${PV}-fx+sm"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip"

RDEPEND=">=www-client/firefox-24.0"
DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}.xpi"
}

src_prepare() {
	use clip && jar_epatch noscript.jar "${FILESDIR}/${P}-nohomepage.patch"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	xpi_install "${S}"
}
