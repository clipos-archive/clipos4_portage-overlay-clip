# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

# Include copyright

EAPI=5

inherit findlib eutils

IUSE=""

DESCRIPTION="config-file : Parsing library"
HOMEPAGE="http://config-file.forge.ocamlcore.org"
DOWNLOAD_ID="845"
SRC_URI="https://forge.ocamlcore.org/frs/download.php/${DOWNLOAD_ID}/${P}.tar.gz"

DEPEND=">=dev-ml/findlib-1.0
	>=dev-lang/ocaml-3.10"
RDEPEND="${DEPEND}"

SLOT="0/${PV}"
LICENSE="LGPL-2.1"
KEYWORDS="x86 ~amd64"

src_compile() {
	emake -j1
}

src_install() {
	findlib_src_preinst
	emake install
}
