# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

DESCRIPTION="ANSSI-PKI client library"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip clip-ssm"

DEPEND="
	dev-lang/swig
"

RDEPEND="
	app-crypt/pkcs11-proxy
	!clip-ssm? ( dev-libs/softhsm )
"

python_prepare() {
	if ! use clip-ssm; then
		einfo 'Setting default config to work without SSM'
		cp -v ${FILESDIR}/nossm-config/* cfg/
	fi
	distutils-r1_python_prepare
}
