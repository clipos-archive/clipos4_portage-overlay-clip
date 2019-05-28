# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib eutils

DESCRIPTION="Firefox extension to change user agent"
DESCRIPTION_FR="Extension Firefox permettant de modifier le user agent"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="http://www.chrispederick.com/work/user-agent-switcher"
MY_P="user_agent_switcher-${PV}-fx+sm"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip"

RDEPEND=">=www-client/firefox-5.0"
DEPEND="app-arch/zip"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}".xpi

	if use clip; then 
		jar_epatch "${PN//-/}.jar" "${FILESDIR}/${PN}-0.7.2-nohomepage.patch"
	fi
	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.7.3-fxversion.patch"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	sed -i -e 's|<em:maxVersion>8.0.*</em:maxVersion>|<em:maxVersion>24*</em:maxVersion>|' \
		"${S}/install.rdf" || die 
	xpi_install "${S}"
}
