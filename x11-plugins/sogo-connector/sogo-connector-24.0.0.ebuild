# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Thunderbird extension to add CarDav support to the address book"
DESCRIPTION_FR="Extension Thunderbird apportant le support des carnets d'adresses CarDav"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="http://www.obm.org/doku.php?id=obmmozillacalendar"
SRC_URI="mirror://clip/${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=mail-client/thunderbird-24"
DEPEND=""

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}"/"${P}"
}
