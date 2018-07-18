# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Keyboard shortcuts to change folder, move/copy messages, with folder name auto-completion"
DESCRIPTION_FR="Raccourcis clavier pour changer de répertoire, déplacer/copier des messages, avec auto-complétion"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://addons.mozilla.org/en-US/thunderbird/addon/nostalgy/"
MY_P="${PN}-${PV}-sm+tb"
SRC_URI="mirror://clip/${MY_P}.xpi"

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
	declare EMID='nostalgy@alain.frisch'
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}" #/"${MY_P}"
}
