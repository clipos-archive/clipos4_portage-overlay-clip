# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit python-any-r1

DESCRIPTION="Mozilla extension to provide GPG support in mail clients"
HOMEPAGE="http://www.enigmail.net/"

SLOT="0"
LICENSE="MPL-2.0 GPL-3"
IUSE=""
if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.code.sf.net/p/enigmail/source"
	S="${WORKDIR}/${P}"
else
	if [[ ${PV} = *_beta* ]] ; then
		SRC_URI="http://www.enigmail.net/download/beta/${P/_/-}.tar.gz"
	else
		SRC_URI="http://www.enigmail.net/download/source/${P}.tar.gz"
		KEYWORDS="~alpha amd64 ~arm ~ppc ~ppc64 x86 ~x86-fbsd ~amd64-linux ~x86-linux"
	fi
	PATCHES=( "${FILESDIR}"/${P}-fix-missing-missingMdcError.patch )
	S="${WORKDIR}/${PN}"
fi

RDEPEND="
	>=app-crypt/gnupg-2.0
	 app-crypt/pinentry[qt4]
	 !<mail-client/thunderbird-52.5.0
	 !<www-client/seamonkey-2.49.5.0_p0
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	app-arch/zip
	dev-lang/perl
	"

src_compile() {
	emake ipc public ui package lang stdlib
	emake xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/thunderbird"
	local emid=$(sed -n '/<em:id>/!d; s/.*\({.*}\).*/\1/; p; q' build/dist/install.rdf)
	[[ -n ${emid} ]] || die "Could not scrape EM:ID from install.rdf"

	# thunderbird
	insinto "${MOZILLA_FIVE_HOME}/extensions/${emid}"
	doins -r build/dist/{bootstrap.js,chrome,modules,chrome.manifest,install.rdf}
}

pkg_postinst() {
	local peimpl=$(eselect --brief --colour=no pinentry show)
	case "${peimpl}" in
	*gtk*|*qt*) ;;
	*)	ewarn "The pinentry front-end currently selected is not one supported by thunderbird."
		ewarn "You may be prompted for your password in an inaccessible shell!!"
		ewarn "Please use 'eselect pinentry' to select either the gtk or qt front-end"
		;;
	esac
	if [[ -n ${REPLACING_VERSIONS} ]]; then
		elog
		elog "Please restart thunderbird and/or seamonkey in order for them to use"
		elog "the newly installed version of enigmail."
	fi
}
