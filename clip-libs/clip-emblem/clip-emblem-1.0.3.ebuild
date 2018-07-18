# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils autotools

DESCRIPTION="CLIP emblem library"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip clip-dev clip-rm"

src_compile() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}${CPREFIX:-/usr}"
}

src_install() {
	einstall DESTDIR="${D}" PREFIX="${EPREFIX}${CPREFIX:-/usr}"
}
