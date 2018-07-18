# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CRX_ID="mlomiejdfkolichcflejclcbmpeaniij"
inherit chromium-extensions

DESCRIPTION="Chromium extension : Protect your privacy. See who's tracking your web browsing and block them."
DESCRIPTION_FR="Extension Chromium permettant de visualiser et bloquer les traceurs web"
CATEGORY_FR="Extensions Chromium"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=www-client/chromium-25.0"
DEPEND=""

src_prepare() {
		epatch "${FILESDIR}"/ghostery-5.2.1-no-content-script.patch || die "epatch failed"
}
