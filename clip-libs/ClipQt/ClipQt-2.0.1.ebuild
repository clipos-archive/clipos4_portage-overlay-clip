# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Generic Qt code for CLIP"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit autotools

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

RDEPEND="dev-qt/qtcore
		 dev-qt/qtgui"
DEPEND="${RDEPEND}
		=sys-devel/automake-1.10*
"

src_prepare() {
	eautoreconf
}
