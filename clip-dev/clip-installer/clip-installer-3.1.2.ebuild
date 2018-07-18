# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="3"
DESCRIPTION="Simple local installer for CLIP"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~arm ~amd64"
IUSE="clip-livecd clip-hermes"

DEPEND=""
RDEPEND="
	clip-livecd? (
		>=app-clip/clip-config-2.3.19-r1
		sys-apps/openrc
		clip-data/clip-hardware
		>=dev-perl/CLIP-Pkg-Download-1.2.6
		>=clip-dev/debootstrap-clip-2.0
		dev-util/debootstrap
		!<clip-dev/clip-install-gui-1.4.0
	)
	!clip-livecd? (
		app-clip/install-ccsd
	)
"

src_install() {
	if use clip-livecd; then
		dodir /usr/bin
		exeinto /usr/bin
		doexe "${S}/bin-livecd/"*
		rm -fr "${S}/bin-livecd"

		dodir /opt/${PN}
		cp -a "${S}"/* "${D}/opt/${PN}"
		dosym "/usr/share/clip-hardware/profiles" "/opt/${PN}/hw_conf"
		dosym "/usr/bin/clip-hardware-infos" "/opt/${PN}/get-hw-infos.sh"

		insinto /etc
		doins "${FILESDIR}/clip-installer.conf"
		if use clip-hermes; then
			ebegin "Enabling specific level config"
			sed -i -r 's/(CONFIG_RM_APPS_SPECIFIC_JAIL=)"no"/\1"yes"/' "${D}/etc/clip-installer.conf"
			eend $?
		fi
	else
		exeinto /usr/bin
		doexe "${S}/bin-clip/"*

		# Can't install in /lib/clip because of the external mount in the jail.
		insinto /usr/share/clip
		doins "${S}/config-admin.sub"
	fi
}

pkg_preinst() {
	local hwconf="/opt/${PN}/hw_conf"
	if [[ -d "${hwconf}" ]]; then
		mv "${hwconf}" "${hwconf}.bkp"
		ewarn "The ${hwconf} directory has been replaced by a symlink"
		ewarn "The old contents of ${hwconf} have been backed up to ${hwconf}.bkp"
	fi
}
