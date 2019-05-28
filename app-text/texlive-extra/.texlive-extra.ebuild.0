# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit deb

DESCRIPTION="Extra packages for texlive"
DESCRIPTION_FR="Paquetages supplémentaires (polices de caractères, etc) pour LaTeX"
CATEGORY_FR="Bureautique"
HOMEPAGE="http://tug.org/texlive/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=">=app-text/texlive-core-${PV}"
RDEPEND="${DEPEND}
	app-text/texlive
	>=dev-texlive/texlive-metapost-${PV}
	>=dev-texlive/texlive-fontsextra-${PV}
	>=dev-texlive/texlive-genericextra-${PV}
	>=dev-texlive/texlive-latexextra-${PV}
	>=dev-tex/glossaries-2.07
"
