# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
DESCRIPTION="Common CLIP core subroutines"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip-devstation clip-gtw"

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	# set gtw/responder specific IKE rules
	if use clip-gtw; then
		mv "${D}/lib/clip/netfilter_misc_gtw.sub" "${D}/lib/clip/netfilter_misc.sub"
		rm "${D}/lib/clip/netfilter_misc_clt.sub" 
	else
		mv "${D}/lib/clip/netfilter_misc_clt.sub" "${D}/lib/clip/netfilter_misc.sub"
		rm "${D}/lib/clip/netfilter_misc_gtw.sub" 
	fi
	use clip-devstation && rm -rf -- "${D}/home"
}
