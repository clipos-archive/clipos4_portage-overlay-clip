# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Thunderbird extension to add the Zimbra and Google contact sync feature"
DESCRIPTION_FR="Extension Thunderbird permettant la synchronisation du carnet d'adresses avec un compte Zimbra ou Google."
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://addons.mozilla.org/thunderbird/addon/6095"
MY_P="${PN/-/_}-${PV}-tb+sm+pb+sb"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip-hermes"

RDEPEND=">=mail-client/thunderbird-8.0"
DEPEND=""

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${MY_P}".xpi

	use clip-hermes && jar_epatch "${PN}.jar" \
		"${FILESDIR}/${PN}-0.8.24-hermes-nuc-r1.patch" \
		"${FILESDIR}/${PN}-0.8.24-hermes-fixrev.patch"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	export EMID='{ad7d8a66-253b-11dc-977c-000c29a3126e}'
	sed -i -e 's|<em:maxVersion>10.*</em:maxVersion>|<em:maxVersion>24.*</em:maxVersion>|' \
		"${WORKDIR}/${MY_P}/install.rdf" || die 
	xpi_install "${S}"/"${MY_P}"
}
