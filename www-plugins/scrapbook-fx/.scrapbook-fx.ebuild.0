# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib eutils

DESCRIPTION="Firefox extension to help you save Webpages and organize the collection"
DESCRIPTION_FR="Extension Firefox pour sauvegarder des pages web et les organiser"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="https://addons.mozilla.org/en/firefox/scrapbook"
MY_P="${PN%-fx}-${PV}-fx"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip"

RDEPEND=">=www-client/firefox-31.0"
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
