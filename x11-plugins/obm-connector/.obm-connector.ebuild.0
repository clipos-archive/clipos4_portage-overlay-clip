# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Thunderbird extension to support calendar synchronization against OBM"
DESCRIPTION_FR="Extension Thunderbird permettant de synchroniser l'agenda avec un serveur OBM"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="http://www.obm.org/doku.php?id=obmmozillacalendar"
SRC_URI="mirror://clip/${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=mail-client/thunderbird-8.0"
DEPEND=""

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	sed -i -e 's|<maxVersion>10.*</maxVersion>|<maxVersion>17.*</maxVersion>|' \
		"${WORKDIR}/${P}/install.rdf" || die 
	xpi_install "${S}"/"${P}"
}
