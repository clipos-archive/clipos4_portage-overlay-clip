# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Mass Mail and Personal Mail"
DESCRIPTION_FR="Extension Thunderbird facilitant l'envoi d'email à des destinataires multiples"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://addons.mozilla.org/en-US/thunderbird/addon/mail-merge/"
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
	declare EMID='mailmerge@example.net'
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}" #/"${MY_P}"
}
