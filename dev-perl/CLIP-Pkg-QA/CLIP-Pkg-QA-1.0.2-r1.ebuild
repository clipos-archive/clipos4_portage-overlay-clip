# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

inherit perl-module

DESCRIPTION="CLIP::Pkg::QA - common CLIP package QA functions"
SRC_URI="mirror://clip/${P}.tar.xz"

SLOT="0"
LICENSE="LGPL-2.1+"
KEYWORDS="x86 amd64"
SRC_TEST=""
IUSE=""
DEPEND="dev-lang/perl"
RDEPEND="
	dev-perl/Sort-Versions
	dev-perl/CLIP-Logger"
