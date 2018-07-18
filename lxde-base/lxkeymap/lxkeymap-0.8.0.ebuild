# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_5,2_6,2_7} pypy{1_9,2_0} )

inherit distutils-r1 script

DESCRIPTION="A simple PyGTK GUI to configure X11 keymaps"
HOMEPAGE="http://packages.ubuntu.com/natty/lxkeymap"
SRC_URI="mirror://clip/${P}.tar.bz2"
LICENSE="GPL-3"
IUSE="clip"
SLOT="0"
KEYWORDS="x86 amd64"

RDEPEND=">=dev-python/pygtk-2.10
		dev-python/dbus-python
		dev-python/python-xklavier"
DEPEND="${RDEPEND}
		dev-python/setuptools
		dev-python/python-distutils-extra
		>=dev-python/docutils-0.6[glep]"


python_prepare_all() {
	distutils-r1_python_prepare_all

	use clip && epatch "${FILESDIR}/${P}-clip.patch"

	sed -i -e \
		"s:../data/:${CPREFIX:-/usr}/share/lxkeymap/:" \
		"lxkeymap/lxkeymapconfig.py" \
		|| die
}


python_install_all() {
	distutils-r1_python_install_all

	shebang_fix "${ED}${CPREFIX:-/usr}"/bin
}
