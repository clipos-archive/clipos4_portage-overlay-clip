# Copyright 2007 SGDN/DCSSI
# Distributed under the terms of the GNU General Public License v2
# Author: Vincent Strubel <clipos@ssi.gouv.fr>

#
# Original Author: vincent
# Purpose: common functions to create views/jails trees
#

ECLASS="views"
INHERITED="$INHERITED $ECLASS"

views_create_etc_symlinks() {
	local pref="${1}"
	keepdir ${pref}/etc/core ${pref}/etc/admin ${pref}/etc/shared
	for f in passwd group passwd- group- localtime; do 
		dosym core/${f} ${pref}/etc/${f}
	done
	for f in hosts resolv.conf; do 
		dosym admin/${f} ${pref}/etc/${f}
	done
	for f in nsswitch.conf host.conf shells services protocols; do 
		dosym shared/${f} ${pref}/etc/${f}
	done
}

views_create_prefixed_etc_symlinks() {
	local pref="$1"
	# Note: /etc/core, etc are not created
	if [ -z "${pref}" ]; then
		ewarn "No prefix specified, aborting"
		return 1
	else
		pref="${pref%/}/"
	fi
	for f in passwd group passwd- group- localtime; do 
		dosym "${pref}"core/${f} /etc/${f}
	done
	for f in hosts resolv.conf; do 
		dosym "${pref}"admin/${f} /etc/${f}
	done
	for f in nsswitch.conf host.conf shells services protocols; do 
		dosym "${pref}"shared/${f} /etc/${f}
	done
}

