# Copyright 2007 SGDN/DCSSI
# Copyright 2011 SGDSN/ANSSI
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: Vincent Strubel <clipos@ssi.gouv.fr>
# Purpose: get the root disk device in a CLIP .deb's maintainer scripts
#

ECLASS="rootdisk"
INHERITED="$INHERITED $ECLASS"

gen_rootdisk() {
	[[ -z "${1}" ]] && die "Not enough arguments"

	local out="${D}/DEBIAN/${1}"
	cat >> "${out}" <<EOF
get_partition() {
	local _part=""
	if [[ -n "\${2}" ]]; then
		_part="\${2}"
	else 
		_part=\$(/bin/awk -vmount="\$1" '{if (\$2 == mount) print \$1 }' /etc/fstab)
	fi
	_part="\${_part#/dev/}"
	[[ -z "\${_part}" ]] && /bin/echo " ! Could not find device for \${1}" >&2
	/bin/echo "\${_part}"
}

ROOT_PARTITION=\$(get_partition / \${CLIP_ROOT_PART})
HOME_PARTITION=\$(get_partition /home \${CLIP_HOME_PART})
LOG_PARTITION=\$(get_partition /var/log \${CLIP_LOG_PART})
SWAP_PARTITION=\$(get_partition none \${CLIP_SWAP_PART})

ROOT_DEVICE="\${ROOT_PARTITION%%[1-9]*}"
ROOT_DEVICE_NOCRYPT="\${ROOT_DEVICE#mapper/}"
ROOT_PARTNUM="\${ROOT_PARTITION/\${ROOT_DEVICE}/}"

EOF
}
