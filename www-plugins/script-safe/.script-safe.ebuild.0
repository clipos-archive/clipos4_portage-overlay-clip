# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CRX_ID="oiigbmnaadbkfbmpbfijlflahbdbdgdf"
inherit chromium-extensions

DESCRIPTION="Chromium extension : Regain control of the web and surf more securely"
DESCRIPTION_FR="Extension Chromium permettant d'interdire sélectivement les scripts dans les pages web"
CATEGORY_FR="Extensions Chromium"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=www-client/chromium-25.0"
DEPEND=""

src_prepare() {
	# Remove the synchronization popup
	epatch -p0 "${FILESDIR}/${PN}-no-sync-popup.patch"
}
