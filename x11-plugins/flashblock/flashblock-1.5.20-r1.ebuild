# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib

DESCRIPTION="Firefox plugin to disable flash content"
HOMEPAGE="http://flashblock.mozdev.org"
MY_P="${P}-fx"
SRC_URI="http://downloads.mozdev.org/flashblock/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=www-client/firefox-24.0"
DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	#sed -i -e 's|<em:maxVersion>23.0</em:maxVersion>|<em:maxVersion>24.*</em:maxVersion>|' \
	#	"${S}/install.rdf" || die 
	
	xpi_install "${S}"
}
