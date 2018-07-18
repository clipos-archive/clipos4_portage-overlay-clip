# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="clip-install-rm: tool to install CLIP updates for rm distribution"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

DEPEND="" 
RDEPEND=">=app-clip/clip-install-common-2.0 
		>=sys-apps/busybox-update-1.12.0-r3"

CLIP_CONF_FILES="/etc/admin/clip_install/preferences.rm
				/etc/admin/clip_install/clip_install_rm_core.conf
				/etc/admin/clip_install/clip_install_rm_apps.conf
				/etc/admin/clip_install/optional.conf.rm"

src_compile() {
	econf || die "could not configure"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"

	keepdir /var/pkg/cache/apt/clip_install/rm/apps/archives/partial
	keepdir /var/pkg/cache/apt/clip_install/rm/apps/lists/partial
	keepdir /var/pkg/cache/apt/clip_install/rm/core/archives/partial
	keepdir /var/pkg/cache/apt/clip_install/rm/core/lists/partial
	keepdir /var/pkg/cache/apt/clip_download/rm/archives/partial
	keepdir /var/pkg/cache/apt/clip_download/rm/lists/partial

	keepdir /var/log

	keepdir /etc/cron/crontab
	cp ${FILESDIR}/root_clip_install_rm	${D}/etc/cron/crontab/root_clip_install_rm

	chown -R 4000:4000 ${D}/etc/admin/clip_install
}

