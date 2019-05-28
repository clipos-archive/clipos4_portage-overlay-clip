# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib

DESCRIPTION="Firefox extension to analyse the DOM representation of a web page"
DESCRIPTION_FR="Extension Firefox permettant d'analyser la représentation d'une page web"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="https://addons.mozilla.org/en/thunderbird/addons/6622"
MY_P="${PN/-/_}-${PV}-sm+fn+tb+fx"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
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
	xpi_install "${S}"
}
