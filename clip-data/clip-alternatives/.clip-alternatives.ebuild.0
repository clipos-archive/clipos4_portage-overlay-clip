# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="CLIP basic alternative links + mailcap file"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	local alt="/usr/etc/alt"
	dodir "${alt}"

	dosym /usr/bin/firefox "${alt}/web-browser"
	dosym /usr/bin/thunderbird "${alt}/mail-client"
	dosym /usr/bin/thunderbird "/usr/bin/xdg-email-hook.sh"
	dosym /usr/bin/libreoffice "${alt}/office"

	dosym /usr/bin/gwenview "${alt}/image-viewer"
	dosym /usr/bin/okular "${alt}/pdf-viewer"
	dosym /usr/bin/okular "${alt}/ps-viewer"
	dosym /usr/bin/okular "${alt}/dvi-viewer"
	dosym /usr/bin/kwrite "${alt}/text-editor"
	dosym /usr/bin/ark "${alt}/archive-viewer"
	dosym /usr/bin/kgpg "${alt}/gpg-viewer"

	dosym /usr/bin/kaffeine "${alt}/audio-player"
	dosym /usr/bin/kaffeine "${alt}/video-player"

	insinto /usr/etc
	doins "${FILESDIR}/mailcap"
}
