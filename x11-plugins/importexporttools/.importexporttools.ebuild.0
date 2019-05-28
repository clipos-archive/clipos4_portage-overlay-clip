# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Add some tools to import and export folders and messages"
DESCRIPTION_FR="Extension Thunderbird permettant d'importer et d'exporter les courriels sous différents formats"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://addons.mozilla.org/en-US/thunderbird/addon/importexporttools/"
MY_P="${PN//-/_}-${PV}-sm+tb"
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
	declare EMID='{3ed8cc52-86fc-4613-9026-c1ef969da4c3}'
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}" #/"${MY_P}"
}
