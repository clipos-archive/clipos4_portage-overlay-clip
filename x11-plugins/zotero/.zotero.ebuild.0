# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib

DESCRIPTION="Firefox extension to collect and manage research sources"
DESCRIPTION_FR="Extension Firefox permettant de créer et gérer une bibliographie"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="http://www.zotero.org"
MY_P="${PN}-${PV/_/}"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=www-client/firefox-24.0"
DEPEND=""

src_unpack() {
	xpi_unpack "${MY_P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	#sed -i -e 's|<em:maxVersion>8.*</em:maxVersion>|<em:maxVersion>10.*</em:maxVersion>|' \
	#	"${WORKDIR}/${MY_P}/install.rdf" || die 
	xpi_install "${WORKDIR}/${MY_P}"
}
