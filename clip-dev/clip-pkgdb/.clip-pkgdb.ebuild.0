# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python{2_5,2_6,2_7} )

inherit distutils-r1

DESCRIPTION="Tool to manage packages metadata for CLIP"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 arm amd64"
IUSE=""

DEPEND=""
RDEPEND="
	dev-python/ipython
	dev-python/jinja
	dev-python/lxml
	dev-python/python-dateutil
"

src_prepare() {
	sed -i "s/@VERSION@/${PV}/g" "${S}/python/setup.py" || die "Failed to set version"
	head -n 1 "${S}/debian/changelog" | grep -qF "${PN} (${PV}-" || \
		ewarn "Debian package version not synchronized"
}

python_compile() {
	pushd python > /dev/null
	distutils-r1_python_compile
	popd > /dev/null
}

python_install() {
	pushd python > /dev/null
	distutils-r1_python_install
	popd > /dev/null
}

python_install_all() {
	distutils-r1_python_install_all

	dobin "${S}/bin/clip-pkgdb"
	local name
	for name in ressources templates; do
		insinto "/usr/share/${PN}/${name}"
		doins "${S}/${name}"/*
	done
}
