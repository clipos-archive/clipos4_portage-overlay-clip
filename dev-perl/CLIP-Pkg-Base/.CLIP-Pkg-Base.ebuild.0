# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="3"

inherit perl-module

DESCRIPTION="CLIP::Pkg::Base - common CLIP package management functions"
SRC_URI="mirror://clip/${P}.tar.xz"

SLOT="0"
LICENSE="LGPL-2.1+"
KEYWORDS="x86 arm amd64"
SRC_TEST=""
IUSE="clip-hermes clip-civil"
DEPEND="dev-lang/perl"
RDEPEND="
	>=app-crypt/gen-crypt-1.0.0
	dev-perl/Sort-Versions
	dev-perl/CLIP-Logger"

src_unpack() {
	default
	if use clip-hermes; then
		ebegin "Enabling specific level config"
		sed -i -r 's/(g_with_rm_apps_specific = )0;/\11;/' "${WORKDIR}/${P}/lib/CLIP/Pkg/Base.pm"
		eend $?
	fi
}

src_install() {
	perl-module_src_install

	# Here we copy from files the right version of the Perl Package containing
	# the arguments values
	if use clip-civil; then
		ebegin "Setting up CIVIL paths for arguments passed to the signature checker"
		mv "${D}${VENDOR_LIB}/CLIP/Pkg/Gencrypt_civil.pm" "${D}${VENDOR_LIB}/CLIP/Pkg/Gencrypt.pm"
		rm "${D}${VENDOR_LIB}/CLIP/Pkg/Gencrypt_ccsd.pm"
		eend $?
	else
		ebegin "Setting up CCSD paths for arguments passed to the signature checker"
		mv "${D}${VENDOR_LIB}/CLIP/Pkg/Gencrypt_ccsd.pm" "${D}${VENDOR_LIB}/CLIP/Pkg/Gencrypt.pm"
		rm "${D}${VENDOR_LIB}/CLIP/Pkg/Gencrypt_civil.pm"
		eend $?
	fi

}
