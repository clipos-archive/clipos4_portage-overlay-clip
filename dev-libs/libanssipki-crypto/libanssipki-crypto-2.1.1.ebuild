# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools

DESCRIPTION="Library regrouping all ANSSI PKI cryptographic functions"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-deps"

DEPEND="
	dev-libs/gmp
	!clip-deps? ( sys-libs/zlib )
"

RDEPEND="${DEPEND}"
