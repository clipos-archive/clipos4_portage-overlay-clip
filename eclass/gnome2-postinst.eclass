# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: Vincent Strubel <clipos@ssi.gouv.fr>
# Purpose: Generate postinst scripts as needed for gnome2/gtk+-2 packages
#

inherit gnome2-utils deb

case "${EAPI:-0}" in
	0|1|2|3|4|5) ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

EXPORT_FUNCTIONS pkg_predeb

# @FUNCTION: gnome2_pkg_predeb
# @DESCRIPTION:
# Generate postinst for CLIP
gnome2-postinst_pkg_predeb() {
	gnome2_gconf_savelist
	gnome2_schemas_savelist
	gnome2_gdk_pixbuf_savelist

	local gconf="" schemas="" pixbuf="" postinst=""
	
	if [[ -n "${GNOME2_ECLASS_SCHEMAS}" ]]; then
		gconf="yes"
		postinst="yes"
	fi
	if [[ -n "${GNOME2_ECLASS_GLIB_SCHEMAS}" ]]; then
		schemas="yes"
		postinst="yes"
	fi
	if [[ -n "${GNOME2_ECLASS_GDK_PIXBUF_LOADERS}" ]]; then
		pixbuf="yes"
		postinst="yes"
	fi

	[[ -z "${postinst}" ]] && return 0

	init_maintainer "postinst"
	cat >>"${D}/DEBIAN/postinst" <<EOF
if [[ "\${1}" == "configure" || "\${1}" == "abort-remove" ]]; then
EOF
	if [[ -n "${gconf}" ]]; then
		einfo "Adding gconftool-2 postinst"
		cat >>"${D}/DEBIAN/postinst" <<EOF
	if [[ -x "${CPREFIX:-/usr}/bin/gconftool-2" ]]; then
		for F in ${GNOME2_ECLASS_SCHEMAS}; do
			${CPREFIX:-/usr}/bin/gconftool-2 --makefile-install-rule "\${F}"
		done
	fi
				
EOF
	fi

	if [[ -n "${schemas}" ]]; then
		einfo "Adding glib-compile-schemas postinst"
		cat >>"${D}/DEBIAN/postinst" <<EOF
	if [[ -x "/usr/bin/glib-compile-schemas" ]]; then
		/usr/bin/glib-compile-schemas --allow-any-name \\
			"${CPREFIX:-/usr}/share/glib-2.0/schemas" &>/dev/null
	fi
				
EOF
	fi

	if [[ -n "${pixbuf}" ]]; then
		einfo "Adding gdk-pixbuf-query-loaders postinst"
		cat >>"${D}/DEBIAN/postinst" <<EOF
	if [[ -x "${CPREFIX:-/usr}/bin/gdk-pixbuf-query-loaders" ]]; then
		TMPFILE=\$(mktemp /tmp/pixbuf.XXXXXXXX)
		${CPREFIX:-/usr}/bin/gdk-pixbuf-query-loaders > \${TMPFILE} \\
			&& chmod 644 \${TMPFILE} \\
			&& mv \${TMPFILE} ${CPREFIX:-/usr}/$(get_libdir)/gdk-pixbuf-2.0/2.10.0/loaders.cache
	fi
				
EOF
	fi
	cat >>"${D}/DEBIAN/postinst" <<EOF
fi
EOF
}
