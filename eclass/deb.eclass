# Copyright 2007 SGDN/DCSSI
# Distributed under the terms of the GNU General Public License v2
# Author: Vincent Strubel <clipos@ssi.gouv.fr>

#
# Original Author: vincent
# Purpose: common utilities for .deb generation
#

ECLASS="deb"
INHERITED="$INHERITED $ECLASS"

init_maintainer() {
	local script="$1"
	[[ -z "${script}" ]] && die "No script name specified"
	[[ -z "${D}" ]] && die "\$D is not defined"

	mkdir -p "${D}/DEBIAN"
	[[ -f "${D}/DEBIAN/${script}" ]] && return

	einfo "Creating maintainer script : ${script}"

	cat > "${D}/DEBIAN/${script}" <<EOF
#!/bin/sh

set -e

EOF
	
	chmod +x "${D}/DEBIAN/${script}"
}
