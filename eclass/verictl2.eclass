# Copyright 2007-2009 SGDN/DCSSI
# All rights reserved
# Author: Vincent Strubel <clipos@ssi.gouv.fr>

ECLASS="verictl2"
INHERITED="$INHERITED $ECLASS"

inherit deb

doverictld2_vroots() {
	if [[ -n "${CLIP_VROOTS}" ]]; then
		local name="${1}"
		shift 1
		for vroot in "${CLIP_VROOTS}"; do
			doverictld2 "${vroot}/${name}" $@
		done
	else
		doverictld2 $@
	fi
}

doverictld2() {
	local name="${1}"
	local flags="${2}"
	local cap_e="${3}"
	local cap_p="${4}"
	local cap_i="${5}"
	local privs="${6}"
	local ctx="${VERIEXEC_CTX}"
	local algo="${VERICTL_HASH_ALG:-sha256}"

	test -z "${privs}" && die "Not enough args"

	einfo "Generating verictl config for ${name}"

	local fname="${PN}${DEB_NAME_SUFFIX}"
	if [[ -z "${ctx}" ]] ; then
		ctx="-1"
	fi
	local dir="${D}${CPREFIX}/etc/verictl.d"
	local realdir="${CPREFIX}/etc/verictl.d"

	[[ -e "${D}/${name}" ]] || die "No such file: ${D}/${name}"

	local fp=""
	if [[ "${algo}" == "ccsd" ]]; then
		fp="$(ccsd-hash "${D}/${name}")"
		[[ $? -ne 0 ]] && die "ccsd-hash failed for ${name}"
	else
		fp="$(cat "${D}/${name}" | openssl dgst -${algo} | cut -d" " -f 2)"
		[[ $? -ne 0 ]] && die "openssl hashing failed for ${name}"
	fi

	mkdir -m0700 -p "${dir}"
	echo "$name $ctx $flags $cap_e $cap_p $cap_i $privs $algo $fp" >> "${dir}/${fname}" || die "Failed to create entry for ${name}"
	chmod 600 "${dir}/${fname}" || die "Failed to chmod entry for ${name}"

	init_maintainer "prerm"
	init_maintainer "postinst"
	if ! grep -q BOOTSTRAP_NOVERIEXEC "${D}/DEBIAN/prerm"; then
		cat >> "${D}/DEBIAN/prerm" <<EOF
if [[ "\${1}" == "remove" || "\${1}" == "upgrade" ]]; then
	if test -c /dev/veriexec && test -z "\${BOOTSTRAP_NOVERIEXEC}" ; then
		/sbin/verictl -f "${realdir}/${fname}" -u \\
		|| echo "* Failed to unload verictl entry for ${fname} *" >&2
	fi
fi

EOF
		cat >> "${D}/DEBIAN/postinst" <<EOF
if [[ "\${1}" == "configure" || "\${1}" == "abort-remove" ]]; then
	if test -c /dev/veriexec && test -z "\${BOOTSTRAP_NOVERIEXEC}" ; then
		/sbin/verictl -f "${realdir}/${fname}" -l \\
		|| echo "* Failed to load verictl entry for ${fname} *" >&2
	fi
fi

EOF
	fi
}
