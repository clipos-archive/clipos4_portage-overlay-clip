# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Clip eraser"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip-livecd"

src_install () {
	var_path_to_lib="/usr/lib/${PN}"
	dodir ${var_path_to_lib}
	exeinto ${var_path_to_lib}

	doexe "${WORKDIR}"/"${P}"/hdparm_discard_file.py
	doexe "${WORKDIR}"/"${P}"/list_home_files_to_delete.sh

	# --------------------------------------------------------------------------------------
	# set the path to hdparm_discard_file.py in clip-fast-eraser.sh
	sed -i -e 's~path_to_lib=\"~path_to_lib=\"'"${var_path_to_lib}"'~g'	"${WORKDIR}"/"${P}"/clip-fast-eraser.sh

	dodir "/usr/bin"
	exeinto "/usr/bin"

	doexe "${WORKDIR}"/"${P}"/clip-full-eraser.sh
	doexe "${WORKDIR}"/"${P}"/clip-fast-eraser.sh
}
