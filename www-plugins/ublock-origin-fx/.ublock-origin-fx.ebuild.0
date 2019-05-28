# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib eutils

DESCRIPTION="Firefox extension to block ads (that aims to be leaner than the alternatives)"
DESCRIPTION_FR="Extension Firefox pour bloquer les pubs (prévue plus légers que les autres extensions de blocage de pub"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="https://addons.mozilla.org/en/firefox/ublock"
MY_P="ublock_origin-${PV/-/_/}-sm+tb+fx+an"
# retrieved through mozilla's website
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip"

RDEPEND=">=www-client/firefox-29.0"
DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}.xpi"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	xpi_install "${S}"
}
