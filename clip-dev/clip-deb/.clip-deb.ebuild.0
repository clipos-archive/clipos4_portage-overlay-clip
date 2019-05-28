# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="clip-deb: utilities to generate .deb packages from portage"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"
IUSE=""

RDEPEND="dev-lang/perl
		 app-arch/dpkg
		 sys-apps/gawk"

src_install () {
	exeinto /usr/sbin
	doexe ${S}/src/gencontrol.pl
}
