# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Generic network initialization scripts for clip"
HOMEPAGE="https://www.ssi.gouv.fr"

inherit deb eutils

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip clip-rm clip-gtw clip-vpn core-rm"
VPN_PV="1.1.5"
VPN_P="clip-vpn-net-${VPN_PV}"
SRC_URI="mirror://clip/${P}.tar.xz
         clip-vpn? ( mirror://clip/${VPN_P}.tar.xz )"



DEPEND=">=sys-apps/portage-2.1.2.2-r12"

RDEPEND=">=clip-libs/clip-sub-1.9.8
		 >=app-clip/core-services-2.9.3
		 >=net-firewall/ipsec-tools-0.6.7
		 net-wireless/wireless-tools
		 >=net-misc/strongswan-4.2.10
		 >=clip-layout/baselayout-clip-1.8.5-r1
		 !clip? ( sys-apps/hwids )
		 sys-apps/iproute2
		 >=net-analyzer/arping-2
		 clip-rm? ( app-clip/clip-net )
		 clip-gtw? (
		 	!clip-vpn? ( app-clip/clip-gtw-net )
			)"

CLIP_CONF_FILES_VIRTUAL="/etc/admin/conf.d/net"

src_prepare() {
	if use clip-vpn; then
		cp -r "${WORKDIR}/${VPN_P}/"* "${S}"
	fi
}

src_install () {
	emake ${args} LIBDIR=$(get_libdir) DESTDIR=${D} install
	if use clip-vpn; then
		emake -f Makefile.clip-vpn ${args} LIBDIR=$(get_libdir) DESTDIR=${D} install
	fi

	keepdir /etc/admin/ike2/cert /etc/admin/ike2/crl /etc/ike2/cert
	chown 4000:4000 "${D}"/etc/admin/ike2/crl
	touch "${D}"/etc/admin/ike2/cert/lock
	touch "${D}"/etc/admin/ike2/crl/lock
	touch "${D}"/etc/ike2/cert/lock
}

pkg_predeb() {
	local list="netconf networking ipsec"
	init_maintainer "postinst"
	cat >> "${D}"/DEBIAN/postinst << ENDSCRIPT
/sbin/rc-update add netlocal nonetwork
/sbin/rc-update add netlocal default
for script in ${list} ; do
	/sbin/rc-update add \${script} default
done

ENDSCRIPT
	cat "${FILESDIR}/postinst.netconf" >> "${D}"/DEBIAN/postinst

	init_maintainer "prerm"
	cat >> "${D}"/DEBIAN/prerm << ENDSCRIPT
for script in ${list} ; do
	/sbin/rc-update del \${script} default
done
rc-update del netlocal default || true # might fail with older package
rc-update del netlocal nonetwork

ENDSCRIPT
}
