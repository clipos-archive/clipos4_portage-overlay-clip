# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

MY_P="${P/_rc/rc}"

inherit deb

DESCRIPTION="USB smartcard readers devices creation scripts (hotplug)"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	into /

	dosbin "${S}/scarddev.ADD.sh"
	dosbin "${S}/scarddev.DEL.sh"

	newinitd "${S}/sccreatedev.sh" sccreatedev
}

pkg_predeb() {
	     init_maintainer "postinst"
	     cat >> "${D}"/DEBIAN/postinst << ENDSCRIPT
	     /sbin/rc-update -a sccreatedev default
ENDSCRIPT
}
