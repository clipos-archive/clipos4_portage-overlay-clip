# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

MOZ_EXTENSION_TARGET="firefox"
inherit mozextension multilib

DESCRIPTION="Firefox FTP client plugin"
DESCRIPTION_FR="Client FTP sous forme d'extension Firefox"
CATEGORY_FR="Extensions Firefox"
HOMEPAGE="http://fireftp.mozdev.org"
MY_P="${P}-fx+sm"
SRC_URI="http://addons.mozilla.org/firefox/downloads/file/29826/${MY_P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=" >=www-client/firefox-24.0"
DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	xpi_unpack "${MY_P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/firefox"
	xpi_install "${S}"
}
