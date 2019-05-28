# Based on gentoo's sys-apps/baselayout, which is
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit flag-o-matic eutils toolchain-funcs multilib deb screen-geom rootdisk

TCB_PV="1.3"

DESCRIPTION="Filesystem baselayout and init scripts for CLIP"
SRC_URI="mirror://clip/${P}.tar.xz
		 mirror://clip/${PN}-tcb-${TCB_PV}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="clip-single clip-x11 clip-gtw clip-rb"

RDEPEND=">=sys-apps/sysvinit-2.86-r3
		>=app-shells/bash-3.0-r10
		>=sys-apps/coreutils-5.2.1
		>=sys-apps/util-linux-2.13.1.1-r2
		>=sys-kernel/clip-kernel-2.6.32.11-r2
		>=app-clip/verictl-2.0.0"
DEPEND="virtual/os-headers
	>=sys-apps/portage-2.1.2.2-r11"
PROVIDE="virtual/baselayout"

CLIP_CONF_FILES="/mounts/audit_priv/etc.audit/logfiles
				 /etc/admin/conf.d/hostname"
CLIP_CONF_FILES_NOCOPY="/etc/core/passwd
						/etc/core/group
						/etc/tcb/root/shadow"

src_configure() {
	if use clip-x11; then
		echo xdm >> "${S}"/rc-lists/default
	else
		rm "${S}"/init.d/xdm
	fi
}

create_var_tree() {
	local target="$1"
	[[ -z "${target}" ]] && die "create_var_tree called with no args"

	keepdir "${target}" 
	keepdir "${target}"/syslog/log
	keepdir "${target}"/log
	keepdir "${target}"/lib/misc
	keepdir "${target}"/lib/xkb
	keepdir "${target}"/lock/subsys
	keepdir "${target}"/log/news
	keepdir "${target}"/run
	keepdir "${target}"/spool
	keepdir "${target}"/state
	keepdir "${target}"/tmp
	fperms 1777 "${target}"/tmp

	# SSM
	keepdir "${target}"/run/ssm_db_rm_h
	keepdir "${target}"/run/ssm_db_rm_b
	keepdir "${target}"/run/ssm_key
	keepdir "${target}"/run/ssm_display

	# utmp, wtmp
	touch "${D}${target}"/run/utmp
	fowners root:utmp "${target}"/run/utmp
	fperms 664 "${target}"/run/utmp

	touch "${D}${target}"/log/wtmp
	fowners root:utmp "${target}"/log/wtmp
	fperms 664 "${target}"/log/wtmp
	
	keepdir "${target}"/lock
	chown root:uucp "${D}${target}"/lock
	fperms 0755 "${target}"/lock

	touch "${D}${target}/log/lastlog"

	keepdir "${target}"/env.d
}

src_install() {
	einfo "Creating directories..."

	keepdir /boot

	keepdir /etc
	keepdir /etc/conf.d
	keepdir /etc/env.d
	keepdir /etc/core
	keepdir /etc/tcb
	keepdir /etc/init.d			# .keep file might mess up init.d stuff
	keepdir /etc/fstab.d

	keepdir /home

	# Admin and audit home directories
	keepdir /home/adminclip
	chown 4000:4000 ${D}/home/adminclip
	keepdir /home/auditclip
	chown 5000:5000 ${D}/home/auditclip

	# Passwd lock file 
	keepdir /home/etc.users
	dosym /var/run/.pwd.lock /etc/.pwd.lock
	
	# encrypted home support
	keepdir /home/user
	fperms 0600 /home/user
	keepdir /home{/rm_h,/rm_b,}/{parts,keys}
	fperms 0700 /home{/rm_h,/rm_b,}/{parts,keys}

	# USB key export
	keepdir /home/usb_keys
	fperms 700 /home/usb_keys
	
	keepdir /opt

	keepdir /proc
	
	keepdir /root
	fperms 0700 /root
	
	keepdir /sbin
	keepdir /sys	# for 2.6 kernels
	keepdir /run	# for openrc
	
	if use amd64; then
		keepdir /lib64
		dosym lib64 /lib
	else
		keepdir /lib
	fi
	
	keepdir /mnt
	keepdir /mnt/{cdrom,usb}
	fperms 0700 /mnt/{cdrom,usb}

	keepdir /usr
	
	# mount points for /mounts stuff
	keepdir /dev
	keepdir /var
	keepdir /usr/local
	keepdir /tmp

	############# Dev ##################
	keepdir /mounts/tmp
	fperms 1777 /mounts/tmp
	keepdir /mounts/xauth/rm_{h,b}
	fperms 1777 /mounts/xauth/rm_{h,b}
	
	############# Usr ###################
	if use amd64; then
		keepdir /usr/lib64
		dosym lib64 /usr/lib
	else
		keepdir /usr/lib
	fi
	keepdir /usr/bin
	keepdir /usr/sbin
	keepdir /usr/share/doc
	keepdir /usr/share/info
	keepdir /usr/share/man
	
	############# Usr/local #############
	keepdir /mounts/usr
	keepdir /mounts/viewers
	if use amd64; then
		keepdir /mounts/usr/lib64
		dosym lib64 /mounts/usr/lib
	else
		keepdir /mounts/usr/lib
	fi
	keepdir /mounts/usr/bin
	keepdir /mounts/usr/sbin
	keepdir /mounts/usr/share/doc
	keepdir /mounts/usr/share/info
	keepdir /mounts/usr/share/man
	keepdir /mounts/usr/share/misc
	
	############# Var ##################
	create_var_tree "/mounts/var"

	# needed for fstab mounting into user view
	keepdir /var/run/authdir
	
	# FHS compatibility symlinks stuff
	dosym /var/tmp /mounts/usr/tmp
	
	# FHS compatibility symlinks stuff
	dosym share/man /mounts/usr/man

	# CLIP: /etc/X11 moved to /usr/local/etc/X11, provide symlink for compat.
	dosym ../usr/local/etc/X11 /etc/X11

	############# RM Devs ##################
	keepdir /mounts/vsdev

	############# User View ################
	keepdir /user
	keepdir /mounts/user_root /mounts/user_priv

	############ Update View ###############
	keepdir /update
	keepdir /update_root /mounts/update_priv
	keepdir /mounts/update_priv/pkgs

	keepdir /audit
	keepdir /mounts/audit_root

	keepdir /admin
	keepdir /mounts/admin_root

	############ X11 View ###############
	if use clip-x11; then
		keepdir /x11/dev /x11/var /x11/usr /x11/bin /x11/tmp /x11/proc /x11/sys
		if use amd64; then
			keepdir /x11/lib64
			dosym lib64 /x11/lib
		else
			keepdir /x11/lib
		fi
		for dir in var/run/authdir var/log var/lib/xkb; do
			keepdir /mounts/x11_priv/"${dir}"
		done
	fi

	############ Admin ##################
	keepdir /mounts/admin_priv/etc.admin 
	keepdir /mounts/admin_priv/etc.admin/conf.d
	keepdir /etc/admin
	fowners 4000:4000 /mounts/admin_priv/etc.admin
	fowners 4000:4000 /mounts/admin_priv/etc.admin/conf.d

	############ Audit ###################
	keepdir /mounts/audit_priv/etc.audit 
	keepdir /mounts/audit_priv/etc.audit/cacert
	keepdir /mounts/audit_priv/etc.audit/keys
	keepdir /etc/audit
	fowners 5000:5000 /mounts/audit_priv/etc.audit
	fowners 5000:5000 /mounts/audit_priv/etc.audit/cacert
	fowners 5000:5000 /mounts/audit_priv/etc.audit/keys

############################ END of DIRS ################################

	cd "${S}"/sbin
	into /
	dosbin test_fsck

	#
	# Setup files in /etc
	#

	insopts -m0644
	insinto /etc
	doins -r "${S}"/etc/*
	fperms 0640 /etc/sysctl.conf

	keepdir /etc/core
	ebegin "Creating CLIP /etc/core symlinks"
	for _f in passwd{,-} group{,-} localtime ; do
		dosym core/${_f} /etc/${_f}
	done
	eend $?

	# doinitd doesnt respect symlinks
	keepdir /etc/init.d
	doinitd "${S}"/init.d/*
	doconfd "${S}"/etc/conf.d/*
	doenvd "${S}"/etc/env.d/*

	for f in passwd group; do
		cp "${D}/etc/core/${f}" "${D}/etc/${f}.base"
		if use clip-rb; then
			cat "${FILESDIR}/rb/${f}" >> "${D}/etc/${f}.base" || die
		fi
	done

	# Formerly postinstall stuff

	for x in boot default nonetwork single shutdown; do
		einfo "Creating default runlevel symlinks for ${x}"
		mkdir -p "${D}"/etc/runlevels/${x}
		for y in $(<"${S}"/rc-lists/${x}); do
			ln -sfn /etc/init.d/${y} \
				"${D}"/etc/runlevels/${x}/${y}
		done
	done

	# mtab handling
	dosym /proc/mounts /etc/mtab

	#################### Devices #######################
	keepdir /vservers
	fperms 700 /vservers

	# Admin stuff
	insopts -o 4000 -g 4000
	insinto /etc/admin/conf.d
	doins ${FILESDIR}/hostname

	# Audit stuff
	insopts -o 5000 -g 5000
	insinto /mounts/audit_priv/etc.audit
	doins ${FILESDIR}/logfiles

	# TCB stuff
	cd "${D}/etc"
	ebegin "Unpacking default tcb files"
	tar --numeric-owner --strip-components 1 -xjvpf "${DISTDIR}/${PN}-tcb-${TCB_PV}.tar.bz2"
	eend $?
	chown -R root:409 "${D}/etc/tcb"
}

pkg_predeb() {
	init_maintainer "postinst"
	gen_get_screen_geom "postinst"

	# Note: we still provide compatibility with
	# installers that do not define CLIP_SCREEN_GEOM
	# In that case, the default "1024x768" is used

	cat >> "${D}"/DEBIAN/postinst << ENDSCRIPT

export PATH="/bin:/sbin:/usr/bin:/usr/sbin"

get_screen_geom || CLIP_SCREEN_GEOM="1024x768"

if [[ -f /etc/core/screen.geom ]]; then
	chattr -i /etc/core/screen.geom
fi
echo "\${CLIP_SCREEN_GEOM}" > /etc/core/screen.geom
chattr +i /etc/core/screen.geom

ENDSCRIPT

	gen_rootdisk "postinst"
	cat >> "${D}"/DEBIAN/postinst << ENDSCRIPT
update_fstab_line() {
	local file="\${1}"
	local pattern="\${2}"
	local device="\${3}"

	if [[ -z "\${device}" ]]; then
		echo " ! Device is not set for \${pattern}" >&2
		exit 1
	fi
	local sedstr="s:^/dev/\${pattern}:/dev/\${device}:"
	echo " * Setting \${pattern} to \${device}"
	sed -i -e "\${sedstr}" "\${file}"
	if [[ \$? -ne 0 ]]; then
		echo " ! sed failed" >&2
		exit 1
	fi
}

cp /etc/fstab.tmpl /etc/fstab.new 

update_fstab_line /etc/fstab.new ROOT_DEV "\${ROOT_PARTITION}"
update_fstab_line /etc/fstab.new HOME_DEV "\${HOME_PARTITION}"
update_fstab_line /etc/fstab.new LOG_DEV "\${LOG_PARTITION}"
update_fstab_line /etc/fstab.new SWAP_DEV "\${SWAP_PARTITION}"

let devnum="\${ROOT_PARTNUM}"
let "devnum+=1"
update_fstab_line /etc/fstab.new MOUNTS_DEV "\${ROOT_DEVICE}\${devnum}"

if [[ -e /etc/conf.d/clip ]]; then
	source /etc/conf.d/clip
else 
	# switch to conffile
	source /etc/conf.d/.clip.confnew
fi

for jail in \$CLIP_JAILS; do
	if [[ "\$jail" = "rm_h" ]]; then
		HAS_RM_H='yes'
		HAS_RM='yes'
	elif [[ "\$jail" = "rm_b" ]]; then
		HAS_RM_B='yes'
		HAS_RM='yes'
	fi
done

if [[ "\$HAS_RM_H" = 'yes' ]]; then
	update_fstab_line /etc/fstab.new RMH_DEV "\${ROOT_DEVICE}7"
	echo '' >> /etc/fstab.new
	cat /etc/fstab.rm_h.tmpl >> /etc/fstab.new
else
	sed -i -e '/.*RMH.*/d' /etc/fstab.new
fi
if [[ "\$HAS_RM_B" = 'yes' ]]; then
	update_fstab_line /etc/fstab.new RMB_DEV "\${ROOT_DEVICE}8"
	echo '' >> /etc/fstab.new
	cat /etc/fstab.rm_b.tmpl >> /etc/fstab.new
else
	sed -i -e '/.*RMB.*/d' /etc/fstab.new
fi
if [[ "\$HAS_RM" = 'yes' ]]; then
	echo '' >> /etc/fstab.new
	cat /etc/fstab.rm.tmpl >> /etc/fstab.new
fi

mv /etc/fstab.new /etc/fstab 

add_missing_line() {
	local file="\${1}"
	local type="\${2}"
	local line="\${3}"
	local group="\$(echo "\${line}" | awk -F":" '{print \$1}')"
	[[ -n "\${group}" ]] || return 0

	if ! grep -qE "^\${group}:" "\${file}"; then
		echo " * Adding missing \${type}: \${group}"
		echo "\${line}" >> "\${file}"
	fi
	return 0
}

if [[ -x "/bin/grep" ]]; then
	if [[ -e "/etc/core/passwd" ]]; then
		cat "/etc/passwd.base" | while read line; do
			add_missing_line "/etc/core/passwd" "user" "\${line}"
		done
	fi
	if [[ -e "/etc/core/group" ]]; then
		cat "/etc/group.base" | while read line; do
			add_missing_line "/etc/core/group" "group" "\${line}"
		done
	fi
fi
	
ENDSCRIPT
}
