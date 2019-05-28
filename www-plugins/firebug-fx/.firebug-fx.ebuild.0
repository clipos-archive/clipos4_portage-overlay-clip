# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib eutils

DESCRIPTION="Firefox extension adds development tools"
DESCRIPTION_FR="Extension Firefox qui ajoute des outils de développement (en complément de l'outil déjà intégré à Firefox)"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="https://addons.mozilla.org/en/firefox/firebug"
MY_P="${PN%-fx}-${PV}-fx"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip"

RDEPEND=">=www-client/firefox-30.0"
DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}.xpi"
}

#src_prepare() {
#	use clip && epatch "${FILESDIR}/${PN}-2.1-nohomepage.patch"
#}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	xpi_install "${S}"
}
