# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

MY_P="${P/_rc/rc}"

DESCRIPTION="USB printer devices for RM jails"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=">=app-clip/hotplug-clip-2
		>=clip-libs/clip-sub-1.6.0"

src_compile() {
	emake || die "emake failed"
}

src_install() {
	into /
	dobin usb_printerid

	exeinto /lib/devices.d
	doexe "${S}/devices.d/printer"
	exeinto /lib/hotplug.d
	doexe "${S}/hotplug.d/printer"
	exeinto /lib/clip
	doexe "${S}/sub/printer.sub"

	dodir /usr/share/hpfirmwares
	insinto /usr/share/hpfirmwares
	doins hpfirmwares/*.dl
	doins hpfirmwares/printermodels
}
