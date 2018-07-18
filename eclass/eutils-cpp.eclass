# Copyright 2010 SGDSN/ANSSI
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: Mickaël Salaün <clipos@ssi.gouv.fr>
# Purpose: manage preprocessed files
#

ECLASS="eutils-cpp"
INHERITED="$INHERITED $ECLASS"
IUSE="${IUSE} core-rm"

_cpp() {
	local src="$1"
	local name="$(basename "$src")"
	local tmp="$2"
	#[[ -e "${tmp}" ]] && die "duplicate file: $tmp"
	local cppargs="-DPREFIX=${CPREFIX:-/usr} -DFILE_NAME=\"$name\""
	use core-rm && cppargs="${cppargs} -DWITH_RM"
	einfo "Preprocessing ${name}"
	if [[ -e "${src}" ]]; then
		cpp -P ${cppargs} "${src}" | sed '/^$/d' >"${tmp}"
	else
		[[ -e "${tmp}" ]] && rm -- "${tmp}"
		for f in "${src}."*; do
			if [[ -z "${f/%*.pp/}" ]]; then
				cpp -P ${cppargs} "${f}" | sed '/^$/d' >>"${tmp}"
			else
				cat "${f}" >>"$tmp"
			fi
		done
	fi
}

doexe_cpp() {
	local src="$1"
	local tmp="${T}/$(basename "${src}")"
	_cpp "${src}" "${tmp}"
	doexe "${tmp}" || die "doexe failed"
}

newexe_cpp() {
	local src="$1"
	local dst="$2"
	local tmp="${T}/$(basename "${src}").tmp"
	_cpp "${src}" "${tmp}"
	newexe "${tmp}" "${dst}" || die "newexe failed"
}
