# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Bugfix for D520 laptop's screenlid which does not wake the screen up"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86"
IUSE="clip-devstation"
RDEPEND="clip-devstation? (
	sys-power/acpid 
	sys-apps/vbetool
	)"
DEPEND="${RDEPEND}"
S="${WORKDIR}/${PN}-1.0"

src_install() {
	if use clip-devstation
	then
		dodir /etc/acpi
		insinto /etc/acpi/events
		doins "${FILESDIR}"/screenlid
		dodir /usr/local/bin
		exeinto /usr/local/bin
		doexe "${FILESDIR}"/handle-screenlid.sh
	fi
}
