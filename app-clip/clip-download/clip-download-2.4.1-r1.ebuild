# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
DESCRIPTION="clip-download : tool to download CLIP updates for clip distribution"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

inherit verictl2 eutils remove-other-perms

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="core-rm clip-hermes"

DEPEND=""
RDEPEND=">=sys-apps/apt-0.8.15.2
			>=app-arch/dpkg-1.14.7-r1
			>=sys-apps/busybox-update-1.12.0-r3
			>=dev-perl/CLIP-Pkg-Base-1.2.0
			>=dev-perl/CLIP-Pkg-Download-1.2.0
			>=dev-libs/openssl-1.0.0d-r1
			>=app-clip/clip-generic-net-2.4.1
			clip-libs/clip-lib"

CLIP_CONF_FILES="/etc/admin/clip_download/apt.conf.d/debug
				/etc/admin/clip_download/clip_download_clip.conf
				/etc/admin/clip_download/sources.list.clip"

if use core-rm; then
		CLIP_CONF_FILES="${CLIP_CONF_FILES}
				/etc/admin/clip_download/clip_download_rm_h.conf
				/etc/admin/clip_download/clip_download_rm_b.conf
				/etc/admin/clip_download/sources.list.rm_h
				/etc/admin/clip_download/sources.list.rm_b"
fi

src_prepare() {
	use clip-hermes && epatch "${FILESDIR}/disable-verify-host.patch"
}

src_compile() {
	if use core-rm; then
		econf --enable-corerm || die "could not configure"
	else
		econf || die "could not configure"
	fi
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"

	keepdir /var/pkg/cache/apt/clip_download/clip/archives/partial
	keepdir /var/pkg/cache/apt/clip_download/clip/lists/partial

	if use core-rm; then
		keepdir /var/pkg/rm_h
		keepdir /var/pkg/rm_b
	fi

	keepdir /update_root/etc/cron/crontab

	# Add the right for admin:admin
	chown -R 4000:4000 ${D}/etc/admin/clip_download

	mkdir -p "${D}/mounts/admin_root/${CPREFIX:-/usr}/bin"
	cp -p "${D}"{,/mounts/admin_root}"${CPREFIX:-/usr}"/bin/install_cert
	dodir /mounts/usr/var
}

pkg_predeb() {
	VERIEXEC_CTX=501 doverictld2 /usr/sbin/start-stop-daemon er - - - P
	doverictld2 /usr/sbin/start-stop-daemon er KILL KILL - P
}

