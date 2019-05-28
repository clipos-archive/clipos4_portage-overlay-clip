# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Thunderbird extension to support calendar synchronization against EWS"
DESCRIPTION_FR="Extension Thunderbird permettant de synchroniser l'agenda avec un serveur Exchange"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="http://github.com/ExchangeCalendar/exchangecalendar"
MY_PV="${PV/_/-}"
SRC_URI="mirror://clip/${PN}-v${MY_PV}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=mail-client/thunderbird-12.0"
DEPEND=""

S=${WORKDIR}/${PN}-v${MY_PV}

src_unpack() {
	xpi_unpack "${PN}-v${MY_PV}".xpi
}

src_install() {
	declare EMID="exchangecalendar@extensions.1st-setup.nl"
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}" #/"${P}"
}
