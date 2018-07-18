# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit python-utils-r1 deb eutils script

GNOME_COLORS_PV="5.5.1"

DESCRIPTION="ADeskBar is a Python/Gtk Application Launcher"
HOMEPAGE="http://www.ad-comp.be/index.php?category/ADesk-Bar"
SRC_URI="http://www.ad-comp.be/public/deb/archives/${PN}.${PV}-all.deb
	http://gnome-colors.googlecode.com/files/gnome-colors-${GNOME_COLORS_PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip clip-livecd clip-hermes clip-devel"

DEPEND="
	!clip? ( dev-lang/python )
	clip? ( >=dev-lang/python-2.7 )"
RDEPEND="${DEPEND}
	dev-python/pygtk
	gnome-base/gnome-menus[python]
	dev-python/pyxdg
	dev-python/pyinotify
	x11-libs/gdk-pixbuf
	!clip? ( x11-libs/vte[python] )
	clip? (
		!x11-misc/fbpanel
		>=x11-misc/clip-menu-xdg-1.4.6
		>=x11-misc/xdialog-2.3.1-r5
		>=x11-wm/openbox-3.4.11.2-r8
	)
	clip-livecd? (
		>=x11-misc/clip-menu-xdg-1.4.7
		x11-misc/xvkbd
	)
"

S="${WORKDIR}"

src_unpack() {
	default
	unpack ./data.tar.gz
}

src_prepare() {
	epatch "${FILESDIR}/adeskbar-0.4.3-fix-tasklist.patch"
	epatch "${FILESDIR}/adeskbar-0.4.3-fix-battery.patch"
	epatch "${FILESDIR}/adeskbar-0.4.3-auto-resize.patch"

	# Add missing icons (from gnome-colors)
	local batplug="${WORKDIR}/usr/share/${PN}/images/plugins/battery"
	mkdir -p "${batplug}"
	mv "${WORKDIR}/gnome-colors-common/scalable/notifications"/notification-battery-* "${batplug}" || die "Missing battery icons"

	if use clip ; then
		epatch "${FILESDIR}/adeskbar-0.4.3-exitcode.patch"
		epatch "${FILESDIR}/adeskbar-0.4.3-nested-menu.patch"
	fi
	if use clip || use clip-livecd; then
		epatch "${FILESDIR}/adeskbar-0.4.3-plugins.patch"
		epatch "${FILESDIR}/adeskbar-0.4.3-tooltip.patch"
		epatch "${FILESDIR}/adeskbar-0.4.3-maxsize.patch"
		epatch "${FILESDIR}/adeskbar-0.4.3-digiclock-exec.patch"
		! use clip-devel && epatch "${FILESDIR}/adeskbar-0.4.3-no-user-conf.patch"
	fi
}

src_compile() {
	true
}

src_install() {
	sed -i -r "s,/usr/,${CPREFIX:-/usr}/,g" "${WORKDIR}"/usr/bin/*
	if use clip; then
		dodir /usr/bin
		ln -s "${CPREFIX:-/usr}/share/adeskbar/main.py" "${ED}${CPREFIX:-/usr}/bin/adeskbar"
	else
		exeinto /usr/bin
		doexe "${WORKDIR}"/usr/bin/*
	fi
	rm -r "${WORKDIR}"/usr/share/adeskbar/po
	cp -r "${WORKDIR}"/usr/share "${ED}${CPREFIX:-/usr}/"
	find "${ED}${CPREFIX:-/usr}/share" -type f -exec chmod a-x {} \;
	find "${ED}${CPREFIX:-/usr}/share" -name '*.py' -exec chmod +x {} \;

	if use clip || use clip-livecd; then
		shebang_fix "${D}${CPREFIX:-/usr}"/share

		exeinto /usr/share/adeskbar/plugins
		doexe "${FILESDIR}"/plugins/*.py
		ebegin "sed PREFIX"
		sed -i -r "s,^(PREFIX_USR\s+=\s+).*,\1'${CPREFIX:-/usr}',g" "${ED}${CPREFIX:-/usr}"/share/adeskbar/plugins/*.py &&
		sed -i -r "s,^(PREFIX_ROOT\s+=\s+).*,\1'${CPREFIX}',g" "${ED}${CPREFIX:-/usr}"/share/adeskbar/plugins/*.py
		eend $?
		exeinto /usr/share/adeskbar/plugins/conf
		doexe "${FILESDIR}"/plugins/conf/*.py

		insinto /usr/share/adeskbar
		rm "${ED}${CPREFIX:-/usr}/share/adeskbar/default.cfg"
		if use clip-livecd; then
			doins "${FILESDIR}"/livecd.cfg
		elif use clip-hermes; then
			doins "${FILESDIR}"/hermes.cfg/*
		else
			doins "${FILESDIR}"/clip.cfg/*
		fi

		insinto /etc/adeskbar
		if use clip-hermes; then
			doins "${FILESDIR}"/hermes.skel/*
		fi

		# Not needed on CLIP, generates warnings
		rm "${ED}${CPREFIX:-/usr}/share/applications/${PN}.desktop"
	fi
	EPYTHON=python python_optimize "${ED}${CPREFIX:-/usr}/share/adeskbar/plugins" \
					"${ED}${CPREFIX:-/usr}/share/adeskbar/adesk"
}
