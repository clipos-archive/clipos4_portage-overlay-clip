# Copyright 2007 SGDN
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: Vincent Strubel <clipos@ssi.gouv.fr>
# Purpose: manage screen geometry issues in the CLIP maintainer-scripts
#

ECLASS="screen-geom"
INHERITED="$INHERITED $ECLASS"

gen_get_screen_geom() {
	local out="${D}/DEBIAN/${1}"
cat >> "${out}" <<EOF
get_screen_geom() {
	local _geom=""
	if [[ -n "\${CLIP_SCREEN_GEOM}" ]]; then
		echo " * Using screen geometry provided by environment"
	else 
		if [[ -f "/etc/core/screen.geom" ]]; then
			echo " * Using screen geometry provided by /etc/core/screen.geom"
			CLIP_SCREEN_GEOM=\`cat /etc/core/screen.geom | cut -d" " -f1\`
		else
			echo " ! Could not find a definition for screen geometry !" >& 2
			return 1
		fi
	fi
	_geom="\${CLIP_SCREEN_GEOM%:*}"
	CLIP_SCREEN_DEPTH="\${CLIP_SCREEN_GEOM#*:}"
	if [[ -z "\${CLIP_SCREEN_DEPTH}" ]]; then
		echo " ! Using default depth (32) !" >& 2
		CLIP_SCREEN_DEPTH=32
		CLIP_SCREEN_GEOM="\${CLIP_SCREEN_GEOM}:\${CLIP_SCREEN_DEPTH}"
	fi
	
	CLIP_SCREEN_X="\${_geom%x*}"
	CLIP_SCREEN_Y="\${_geom#*x}"

	if [[ -z "\${CLIP_SCREEN_X}" ]] || [[ -z "\${CLIP_SCREEN_Y}" ]]; then
		echo " ! Error parsing screen geometry : \${CLIP_SCREEN_GEOM}" >& 2
		return 1
	fi
}

EOF
}

gen_get_screen_matches() {
	if [[ $# -lt 5 ]]; then
		echo "Not enough arguments to gen_get_screen_matches: $*" > /dev/stderr
		return 1
	fi
	local var="$1"
	local fun="$2"
	local out="${D}/DEBIAN/${3}"
	local default="$4"
	shift 4
	cat >> "${out}" <<EOF
${fun}() {
	case \${${var}} in
EOF
	for couple in $*; do 
		local match="${couple%-*}"
		local ret="${couple#*-}"
		cat >> "${out}" <<EOF
		"${match}")
			echo "${ret}"
			;;
EOF
	done
	cat >> "${out}" << EOF
		*)
			echo "${default}"
			;;
	esac
}

EOF
}

gen_get_x_matches() {
	gen_get_screen_matches "CLIP_SCREEN_X" "get_x_matches" $*
}

gen_get_y_matches() {
	gen_get_screen_matches "CLIP_SCREEN_Y" "get_y_matches" $*
}

gen_get_depth_matches() {
	gen_get_screen_matches "CLIP_SCREEN_DEPTH" "get_depth_matches" $*
}
