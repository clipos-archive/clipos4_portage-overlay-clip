# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="graphical configuration tool for RMH services"
DESCRIPTION_FR="Utilitaire de gestion des services RM_H"
CATEGORY_FR="Utilitaires"

HOMEPAGE="https://www.ssi.gouv.fr"
SPLASH_THEME="ksplash-RMH_ANSSI-1.0"
SRC_URI="mirror://clip/${P}.tar.xz
			mirror://clip/${SPLASH_THEME}.tar.bz2"

inherit verictl2 eutils

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="doc clip clip-rmh-admin clip-anssi"

RDEPEND="dev-qt/qtcore
	 dev-qt/qtgui
	 x11-libs/qt-singleapplication
	 dev-libs/openssl
	 !clip-rmh-admin? ( !app-clip/ldap-light-client )
	 net-nds/openldap"
DEPEND="${RDEPEND}"
CLIP_SRC="${WORKDIR}/${PN}-clip-${CLIP_PVR}"

src_configure() {
	export PATH=${QTDIR}/bin:${PATH}
	CONF_STR=""
	if use clip-rmh-admin; then
		CONF_STR="--enable-admin"
	fi
	econf $CONF_STR || die "configure failed"
}

src_install() {
	export PATH=${QTDIR}/bin:${PATH}
	sed -i -e 's/Icon=password/Icon=rmh-config/' \
		"${S}"/rmh-config.desktop
	if use clip-rmh-admin; then
		domenu "${S}"/rmh-config-admin.desktop
	else
		domenu "${S}"/rmh-config.desktop
	fi
	insinto /usr/share/icons
	doins "${FILESDIR}"/rmh-config.png
	make DESTDIR="${D}" install || die "make install failed"
	exeinto /usr/bin/clip-user-data-update-scripts
	doexe "${FILESDIR}"/splash

	if use clip-anssi; then
		# KDE 4
		insinto /usr/share/apps/ksplash/Themes/RMH_ANSSI
		doins -r "${WORKDIR}/${SPLASH_THEME}"/*

		# Thunderbird
		#insinto /usr/lib/thunderbird/isp
	fi
}

pkg_predeb() {
	if ! use clip-rmh-admin; then
		mkdir -p ${D}/${CPREFIX:-/usr}/bin/clip-user-data-update-scripts
		ln -s ../session-init-certs.sh ${D}/${CPREFIX:-/usr}/bin/clip-user-data-update-scripts/rmh-config
	fi

	if use clip-rmh-admin; then
		doverictld2  "${CPREFIX:-/usr}/bin/rmh-config-admin" e - - - c ccsd
	else
		doverictld2  "${CPREFIX:-/usr}/bin/rmh-config" e - - - c ccsd
	fi
}

