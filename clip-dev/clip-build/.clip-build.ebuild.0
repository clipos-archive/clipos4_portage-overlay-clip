# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="clip-build : build clip fake roots"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 arm amd64"
IUSE=""

RDEPEND=">=sys-apps/portage-2.1.8.3-r6
	dev-perl/XML-Simple"

src_compile () {

	case "${ARCH}" in
	i386 | i686 | x86)
		sed -i -e 's/@CLIP_CHOST@/i686-pc-linux-gnu/g' -e 's/@CLIP_ARCH@/x86/g' ${S}/etc/clip-build.conf
	;;
	amd64 | x86_64)
		sed -i -e 's/@CLIP_CHOST@/x86_64-pc-linux-gnu/g' -e 's/@CLIP_ARCH@/amd64/g' ${S}/etc/clip-build.conf
	;;
	arm*)
		sed -i -e 's/@CLIP_CHOST@/armv7a-hardfloat-linux-gnueabi/g' -e 's/@CLIP_ARCH@/armel/g' ${S}/etc/clip-build.conf
	;;
	*)
		die "Unknown architecture"
	;;
	esac

	emake || die "Make compile failed"
}

src_install () {
	emake DESTDIR="${D}" install || die "Make install failed"
}

pkg_postinst () {
	ewarn "The 2.0.0 version brings a lot of changes to"
	ewarn "the way clip-build works."
	ewarn "If you are upgrading from version 1.*, you need to:"
	ewarn " - edit the new configuration file /etc/clip-build.conf"
	ewarn "   to insert your local settings,"
	ewarn " - rewrite your homegrown clip-build wrappers, if any"
	ewarn "   (core.sh, rm.sh, ...) to use clip-compile, or simply"
	ewarn "   drop those wrappers and use clip-compile directly."
	ewarn " For example, a core.sh wrapper using clip-compile would"
	ewarn " now be a simple one-liner:"
	ewarn "    exec clip-compile clip-rm/clip \"\${@}\""
	ewarn ""
	ewarn "For more information, read man 7 clip-build."
	ewarn ""
	ewarn "You might also want to update clip-dev/clip-devutils to"
	ewarn "update or install >=clip-dev/clip-devutils-2.0.0, and"
	ewarn "read man 7 clip-devutils to discover the new utility"
	ewarn "scripts in that package."

	mkdir -p "${ROOT}/usr/local"
	for d in include lib kde qt share; do
		[[ -d "${ROOT}/usr/local/${d}" ]] && rm -fr "${ROOT}/usr/local/${d}"
		if [[ ! -L "${ROOT}/usr/local/${d}" ]]; then
			einfo "Symlinking /usr/local/${d}"
			ln -sf "${ROOT}/usr/${d}" "/usr/local/${d}" \
				|| die "Failed to symlink ${d}"
		fi
	done
}
