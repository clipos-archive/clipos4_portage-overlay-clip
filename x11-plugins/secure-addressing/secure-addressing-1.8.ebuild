# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

inherit mozextension multilib

DESCRIPTION="Thunderbird extension to avoid sending emails to wrong addresses"
DESCRIPTION_FR="Extension Thunderbird permettant controler les adresses destination"
CATEGORY_FR="Extensions Thunderbird"
HOMEPAGE="https://addons.mozilla.org/en-US/thunderbird/addon/secure-addressing"
MY_P="secure_addressing-${PV}-tb"
SRC_URI="mirror://clip/${MY_P}.xpi"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND=">=mail-client/thunderbird-24.0"
DEPEND=""

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${MY_P}".xpi
}

src_install() {
	declare EMID="secure-addressing@matsuba.net"
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	xpi_install "${S}"/"${MY_P}"
}
