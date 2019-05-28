# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Thunderbird extension providing advanced notifications for new mail"
DESCRIPTION_FR="Extension Thunderbird permettant de configurer de manière avancée la notification d'arrivée de nouveaux messages"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://addons.mozilla.org/en/thunderbird/addons/2610"
MY_P="${PN/-/_}-${PV}-tb+sm"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=mail-client/thunderbird-24.0"
DEPEND=""

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${MY_P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	sed -i -e 's|<em:maxVersion>17.*</em:maxVersion>|<em:maxVersion>24.*</em:maxVersion>|' \
		"${S}/${MY_P}/install.rdf" || die 
	xpi_install "${S}"/"${MY_P}"
}
