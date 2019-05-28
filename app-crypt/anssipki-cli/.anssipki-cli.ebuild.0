# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1 script

DESCRIPTION="ANSSI-PKI command-line interface"
DESCRIPTION_FR="ANSSI-PKI (interface en ligne de commande)"
CATEGORY_FR="Utilitaires"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip"

DEPEND="
	dev-lang/swig
"

RDEPEND="
	>=app-crypt/libanssipki-client-1.0.0
"

python_install() {
	distutils-r1_python_install

	use clip && shebang_fix "${D}" 'python[\.0-9]*'
}
