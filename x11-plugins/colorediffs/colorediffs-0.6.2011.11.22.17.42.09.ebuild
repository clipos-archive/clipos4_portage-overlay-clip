# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Thunderbird extension that colors diffs within SCM notifications"
DESCRIPTION_FR="Extension Thunderbird pour faciliter la lecture de patch"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://code.google.com/p/colorediffs/"
SRC_URI="mirror://clip/${P}.xpi"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="x86 arm amd64"
IUSE=""

RDEPEND=">=mail-client/thunderbird-3.1"
DEPEND=""

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${P}.xpi"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	sed -i -r 's,(<em:maxVersion>)8\.\*(</em:maxVersion>),\124.*\2,' "${WORKDIR}/${P}/install.rdf"
	xpi_install "${S}/${P}"
}
