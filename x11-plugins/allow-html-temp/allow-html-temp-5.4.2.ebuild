# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Allow to have HTML temporarily allowed in the currently displayed message by only one click"
DESCRIPTION_FR="Extension Thunderbird permettant de basculer entre la visualisation texte brut and HMTL en un clic"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://addons.mozilla.org/en-US/thunderbird/addon/allow-html-temp/"
MY_P="${PN//-/_}-${PV}-tb"
SRC_URI="mirror:///clip/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=mail-client/thunderbird-8.0"
DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}".xpi
}

src_install() {
	declare EMID='{532269cf-a10e-4396-8613-b5d9a9a516d4}'
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}" #/"${MY_P}"
}
