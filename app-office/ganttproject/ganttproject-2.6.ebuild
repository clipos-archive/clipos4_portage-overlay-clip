# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Graphical Java program for editing Gantt charts"
DESCRIPTION_FR="Gestionnaire de projet et éditeur de diagrammes de Gantt"
CATEGORY_FR="Bureautique"
HOMEPAGE="http://gantproject.biz"
MY_P="${P}-r1473"
SRC_URI="mirror://sourceforge/ganttproject/${MY_P}.zip"

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="virtual/jre"

S="${WORKDIR}/${MY_P}"

src_install() {
	dodir "/usr/lib/ganttproject"

	mv "${S}"/* "${D}${CPREFIX:-/usr}/lib/ganttproject/"
	rm "${D}${CPREFIX:-/usr}/lib/ganttproject/ganttproject"
	dobin "${FILESDIR}/gantt.sh"

	dodir "/usr/share/applications" "/usr/share/pixmaps"
	insinto "/usr/share/pixmaps"
	doins "${FILESDIR}/${PN}.png"
	insinto "/usr/share/applications"
	doins "${FILESDIR}/${PN}.desktop"
	insinto "/usr/share/mime/packages"
	doins "${FILESDIR}/${PN}.xml"

	dodir "/etc/alt"
	dosym "/usr/bin/gantt.sh" "/etc/alt/ganttproject"
}
