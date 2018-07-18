# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

MY_P="${P/_rc/rc}"

DESCRIPTION="USB scanner devices for RM jails"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=""
RDEPEND=">=app-clip/hotplug-clip-2"

src_install() {
	exeinto /lib/hotplug.d
	doexe "${S}/hotplug.d/scanner"
	exeinto /lib/clip
	doexe "${S}/sub/scanner.sub"
}
