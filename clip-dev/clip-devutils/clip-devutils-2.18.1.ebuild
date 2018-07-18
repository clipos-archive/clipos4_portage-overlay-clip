# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
DESCRIPTION="Misc devel utilities for CLIP"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 arm amd64"
IUSE="clip-sdk-bootstrap"

DEPEND=""
RDEPEND="
	app-crypt/gen-crypt
	app-crypt/gnupg
	>=app-portage/gentoolkit-0.3
	>=clip-dev/clip-build-2.0.9
	dev-perl/CLIP-Pkg-Base
	>=dev-perl/CLIP-Pkg-Download-1.2.6
	>=dev-perl/CLIP-Pkg-QA-1.0.2
	dev-perl/Sort-Versions
	media-gfx/imagemagick
	sys-apps/fakeroot
	!clip-sdk-bootstrap? ( clip-dev/clip-pkgdb )
"

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	ewarn "If you are upgrading from clip-devutils-1.*, you might"
	ewarn "want to read man 7 clip-devutils, to discover all the"
	ewarn "new scripts in this package."
	ewarn "And don't forget to edit /etc/clip-build.conf if you"
	ewarn "haven't done it yet..."
	ewarn
	ewarn "You should import /usr/share/clip-devutils/pubkeys/*.asc to verify"
	ewarn "Internet archives"
}
