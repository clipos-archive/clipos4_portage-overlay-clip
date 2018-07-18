# Copyright 2016 SGDSN/ANSSI
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: Timothée Ravier <clipos@ssi.gouv.fr>
# Purpose: remove rwx permissions for "other" user on all files installed
#

ECLASS="remove-other-perms"
INHERITED="${INHERITED} ${ECLASS}"

remove-other-perms() {
	local exceptionregexp="${1}"
	find "${D}" -type f | while read file; do
		if [[ ${file} == ${exceptionregexp} ]]; then
			einfo "File '${file}' matches regexp ${1}, permissions remain unchanged";
		else
		ebegin "	Calling 'chmod o-rwx' on '${file}'"
		chmod o-rwx -- "${file}"
		eend $?
		fi
	done
}
