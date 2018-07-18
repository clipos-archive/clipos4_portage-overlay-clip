# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib eutils

MOZ_EXTENSION_TARGET="firefox"

DESCRIPTION="Firefox extension to delete non-deletable cookies"
DESCRIPTION_FR="Extension Firefox permettant l'effacement des cookies de longue durée"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/6623"
MY_P="${P}-fx"
SRC_URI="https://addons.mozilla.org/firefox/addon/6623/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=www-client/firefox-24.0"
DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	EMID='{d40f5e7b-d2cf-4856-b441-cc613eeffbe3}'
	xpi_install "${S}"
}
