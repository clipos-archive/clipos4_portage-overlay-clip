# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Freemind mind mapping software - binary version for CLIP"
DESCRIPTION_FR="Editeur de cartes mentales"
CATEGORY_FR="Bureautique"
HOMEPAGE="http://freemind.sourceforge.net"
SRC_URI="mirror:///sourceforge/${PN}-bin-max-${PV}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="virtual/jre"

src_install() {
	dodir "/usr/lib/${PN}"
	insinto "/usr/lib/${PN}"

	for f in plugins lib license patterns.xml doc accessories; do
		doins -r "${WORKDIR}"/${f}
	done
	doins "${FILESDIR}/${PN}.properties"

	exeinto "/usr/lib/${PN}"
	doexe "${WORKDIR}/${PN}.sh"

	dodir /usr/bin
	cat > "${D}${CPREFIX:-/usr}/bin/${PN}" <<EOF
#!/bin/sh

mkdir -p "\${HOME}/.${PN}"
if [[ ! -e "\${HOME}/.${PN}/auto.properties" ]]; then
	cp "${CPREFIX:-/usr}/lib/${PN}/${PN}.properties" "\${HOME}/.${PN}/auto.properties"
fi
exec "${CPREFIX:-/usr}/lib/${PN}/${PN}.sh" "\${@}"
EOF
	fperms 755 /usr/bin/${PN}

	domenu "${FILESDIR}/${PN}.desktop"
	doicon "${FILESDIR}/${PN}.png"
	insinto "/usr/share/mime/packages"
	doins "${FILESDIR}/${PN}.xml"

	dodir "/etc/alt"
	dosym "/usr/bin/freemind" "/etc/alt/freemind"
}
