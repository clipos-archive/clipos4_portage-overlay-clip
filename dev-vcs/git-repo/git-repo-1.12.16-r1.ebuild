# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils

DESCRIPTION="repo - The Multiple Git Repository Tool"
HOMEPAGE="https://gerrit.googlesource.com/git-repo"

# git archive --prefix=${P}/ v${PV} | xz > ../${P}.tar.xz
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip clip-rm"

RDEPEND="
	!clip-rm? ( dev-vcs/git )
	dev-lang/python[readline]"
DEPEND=""

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.12.16-offline.patch"
}

src_install() {
	local share="${CPREFIX:-/usr}/share/${PN}"
	dodir "${share}"
	cp -r "${WORKDIR}/${P}"/* "${D}/${share}"
	newbin "${FILESDIR}/repo.sh" repo
	sed -i -r "s,@REPO_PATH@,${share}/repo,g" "${D}/${CPREFIX:-/usr}/bin/repo"
}
