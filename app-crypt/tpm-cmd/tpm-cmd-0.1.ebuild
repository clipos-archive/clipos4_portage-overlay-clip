# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="A lighthweight TPM commandline tool"
SRC_URI="mirror://clip/${P}.tar.xz"

USE=""
KEYWORDS="x86"
SLOT="0"
LICENSE="GPL-2"

inherit cmake-utils

DEPEND="
	dev-util/cmake
"
RDEPEND=""

src_install() {
	exeinto "/usr/sbin"
	doexe "${BUILD_DIR}/src/tpm_cmd"
}
