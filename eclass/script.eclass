# Copyright 2011 SGDSN/ANSSI
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: Mickaël Salaün <clipos@ssi.gouv.fr>
# Purpose: fix scripts
#

ECLASS="script"
INHERITED="${INHERITED} ${ECLASS}"

shebang_fix() {
	[[ $# -lt 1 ]] && die "usage: [CPREFIX=/usr/local] shebang_fix <dir|file> [interpreter-regexp [interpreter-replacement]]"
	local path="$1"
	local int_old="$2"
	[[ -z "${int_old}" ]] && int_old='[^ \t]+'
	local int_new="$3"
	[[ -z "${int_new}" ]] && int_new='\2'
	local shebang_re="^#![ \t]*/usr/bin/(env[ \t]+|)(${int_old})(.*)$"
	einfo "looking for shebang matching '${int_old}' in '${path}':"
	# -a -perm /111
	find "${path}" -type f | while read file; do
		if head -n 1 -- "${file}" | grep -q -E "${shebang_re}"; then
			if [[ -d "${path}" ]]; then
				filename="${file##${path}}"
			else
				filename="$(basename "${path}")"
			fi
			ebegin "	fixing '${filename}'"
			sed -i -r "1s:${shebang_re}:#!${CPREFIX:-/usr}/bin/${int_new}\3:" "${file}"
			eend $?
		fi
	done
}
