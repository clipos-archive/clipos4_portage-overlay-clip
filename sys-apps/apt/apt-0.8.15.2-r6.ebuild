# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils multilib verictl2

HOMEPAGE="http://www.debian.org"
DESCRIPTION="Advanced Package management for debian"
SRC_URI="mirror://debian/pool/main/a/apt/${P/-/_}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-devel clip-core clip-devstation clip-livecd clip-rm doc nls"

LANGS="
	ast bs ca cs da de dz el eo es et eu fr gl hu id it ja km ko ku lt mr nb ne
	nl nn pa pl pt_BR pt ro ru sk sv th tl vi zh_CN zh_TW
"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

RDEPEND="app-arch/dpkg
		!clip-rm? ( >=net-misc/curl-7.15.5 sys-libs/db )"
DEPEND="${RDEPEND}
	sys-devel/automake:1.10
	doc? (
		app-text/po4a
		app-text/docbook-xml-dtd
		app-text/docbook-xsl-stylesheets
	)"

pkg_setup() {
	if use clip-core; then
		CLIP_CONF_FILES_VIRTUAL="/etc/admin/clip_download/private/apt.cert.pem /etc/admin/clip_download/private/apt.key.pem" 
	fi
}

src_prepare() {
	# Move /var to /var/pkg for apt (hardcoded paths).
	epatch "${FILESDIR}/${PN}-0.8.15-clip-varpkg.patch" 

	if ! use clip-devel; then
		epatch "${FILESDIR}/${PN}-0.7.9-clip-noforce.patch" 
	fi

	# HTTPS : deal with empty answer, restore CaPath option.
	epatch "${FILESDIR}/${PN}-0.8.15-clip-https.patch" 
	epatch "${FILESDIR}/${PN}-0.8.15-clip-fix-https-link.patch" 

	# Log to /var/log, change group ownership of files to syslog
	epatch "${FILESDIR}/${PN}-0.8.15-clip-dpkglog.patch" 

	# Make the 'copy' apt method try to link files instead of copying them
	epatch "${FILESDIR}/${PN}-0.8.15-clip-copy-link.patch" 

	# Even without NLS support, libintl.h is needed for dgettext (used to parse
	# dpkg output).
	epatch "${FILESDIR}/${PN}-0.8.15-clip-no-nls.patch" 

	# Make an extra-deep dependency analysis, so that even already satisfied
	# dependencies get updated by apt-get install (i.e. make it behave as 
	# emerge -u :)
	epatch "${FILESDIR}/${PN}-0.8.15-clip-deep-deps.patch" 

	# Support a 'remote-only' option for downloads
	epatch "${FILESDIR}/${PN}-0.8.15-clip-local-sources.patch" 

	# Yep, ugly.
	rm "${S}/buildlib/"config.{guess,sub}
	cp "/usr/share/automake-1.10/"config.{guess,sub} "${S}/buildlib/"

	# Patch LINGUAS
	echo "${LINGUAS}" > ${S}/po/LINGUAS
}

src_configure() {
	local confvar=""
	
	if ! use clip-devel; then
		confvar="CPPFLAGS=-DCLIP_NO_FORCE"
	fi

	econf \
		--localstatedir="/var/pkg" \
		$(use_enable nls) \
		"${confvar}" \
		|| die
}

src_compile() {
	emake binary || die
	if use doc; then
		emake doc || die
	fi
}

src_install() {
	strip-linguas ${LANGS}
	if [ -z "${LINGUAS}" ] ; then
		LINGUAS=none
	fi

	dodir /usr/lib/apt/methods
	cd ${S}/bin
	exeinto /usr/bin
	doexe apt-*
	insinto /usr/lib
	doins lib*
	
	cd ${S}/bin/methods
	exeinto /usr/lib/apt/methods
	doexe *

	cd ${S}/scripts/dselect
	insinto /usr/lib/dpkg/methods/apt
	exeinto /usr/lib/dpkg/methods/apt
	doexe setup install update
	doins names desc.apt


	dodir /usr/include/apt-pkg
	insinto /usr/include/apt-pkg
	cd ${S}/include/apt-pkg
	doins *
	
	if use clip-devstation || use clip-livecd; then
		keepdir /var/pkg/lib/apt/lists/partial
		keepdir /var/pkg/cache/apt/archives/partial
		keepdir /var/pkg/lib/dpkg
		keepdir /etc/apt/apt.conf.d
	fi

	if use clip-core; then
		dodir /mounts/admin_root/usr/bin
		cp "${D}/usr/bin/apt-cache" "${D}/mounts/admin_root/usr/bin/apt-cache" \
			|| die "apt-cache copy failed"
	fi
}

pkg_predeb() {
	use clip-core && \
		doverictld2 /usr/lib/apt/methods/https e - - - c ccsd
	use clip-devel && \
		doverictld2 /usr/lib/apt/methods/http e - - - c ccsd 
}
