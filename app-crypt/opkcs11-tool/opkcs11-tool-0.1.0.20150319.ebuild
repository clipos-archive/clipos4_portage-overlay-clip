# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit virtualx eutils autotools libtool deb pax-utils

DESCRIPTION="opkcs11-tool: managing and operating PKCS#11 security tokens in OCaml"
DESCRIPTION_FR="opkcs11-tool: outils de gestion de tokens PKCS11 en OCaml"
HOMEPAGE="https://github.com/caml-pkcs11/opkcs11-tool"
SRC_URI="mirror://clip/${P}.tar.gz"

LICENSE="CeCILL B"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ~mips ~ppc ~ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="dev-ml/camlidl
		dev-util/coccinelle
		${RDEPEND}"

src_configure() {
	econf \
		--with-caml-crush=caml-crush
}

src_prepare() {
	./autogen.sh
}

src_compile() {
	emake -j1 || die
}

src_install() {
	exeinto ${CPREFIX:-/usr}/bin
	doexe "${S}"/opkcs11-tool
}

