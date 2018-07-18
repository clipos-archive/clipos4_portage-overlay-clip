# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.28.2.ebuild,v 1.6 2010/08/18 22:06:45 maekke Exp $

EAPI="5"

inherit virtualx eutils autotools libtool deb pax-utils verictl2

DESCRIPTION="PKCS#11 Filtering Proxy - Caml Crush"
HOMEPAGE="https://github.com/caml-pkcs11/caml-crush"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ~mips ~ppc ~ppc64 sh sparc x86 ~x86-fbsd"
IUSE="clip clip-core clip-rm rm-deps"
# USE=valgrind is probably not a good idea for the tree

RDEPEND="!rm-deps? ( >=dev-libs/glib-2.16 )
	clip-core? (
		clip-libs/clip-libvserver
	)
	!gnome-base/gnome-keyring"
DEPEND="dev-lang/ocaml
		dev-ml/camlidl
		dev-ml/findlib
		dev-ml/ocamlnet
		dev-ml/ocaml-ssl
		dev-ml/config-file
		dev-util/coccinelle
		${RDEPEND}"

pkg_setup() {
	if use clip-core; then
		# The following lines register the files as configuration files so that
		# they are not erased when the package is updated.
		# New conf files appear in the same place as the previous ones
		# with the same name, prefixed by "." and suffixed by ".confnew"
		# To take into account new configuration, the admin has to
		# rename these new files as the old ones MANUALLY.
		CLIP_CONF_FILES="/etc/admin/conf.d/pkcs11proxyd-conf/core/filter/filter_core.conf"
		CLIP_CONF_FILES+=" /etc/admin/conf.d/pkcs11proxyd-conf/core/conf/pkcs11proxyd_core.conf"
		CLIP_CONF_FILES+=" /etc/admin/conf.d/pkcs11proxyd-conf/rm_b/filter/filter_rm_b.conf"
		CLIP_CONF_FILES+=" /etc/admin/conf.d/pkcs11proxyd-conf/rm_b/conf/pkcs11proxyd_rm_b.conf"
		CLIP_CONF_FILES+=" /etc/admin/conf.d/pkcs11proxyd-conf/rm_h/filter/filter_rm_h.conf"
		CLIP_CONF_FILES+=" /etc/admin/conf.d/pkcs11proxyd-conf/rm_h/conf/pkcs11proxyd_rm_h.conf"
	fi
}

src_configure() {
	econf \
		--with-client-socket=unix,/var/run/p11proxy/socket \
		--with-filter \
		--with-cclient \
		--with-rpcgen \
		--with-idlgen \
		--with-daemonize \
		--with-libnames=',ssm'
}

src_prepare() {
	#Apply patch to launch the binary and append -lclip -lcipserver to cclib
	epatch ${FILESDIR}/${PN}-daemonize-clip.patch
	#Apply patch to support entering a vserver
	epatch ${FILESDIR}/${PN}-drop-priv-clip.patch
	#Apply patch to support the CLIP SSM and ANSSI-PKI
	epatch ${FILESDIR}/${PN}-anssipki.patch
	cp -r ${FILESDIR}/anssipki_patches/ src/filter/filter/
	./autogen.sh
	#eautoreconf -i
}

src_compile() {
	emake -j1 || die
}

src_install() {
	if use clip-core; then
		exeinto /usr/sbin/
		doexe "${S}"/src/pkcs11proxyd/pkcs11proxyd
		doexe "${S}"/src/pkcs11proxyd/pkcs11proxyd-clip-launcher

		#Adapt init script
		doinitd "${FILESDIR}"/pk11proxy

		local ctx="505"
		for jail in rm_b rm_h core ; do

			if [ ${jail} = core ] ; then
				dodir "/var/run/p11proxy"
			else
				dodir "/vservers/${jail}/user_priv/var/run/p11proxy"
			fi

		    insinto "/etc/jails/p11proxy_${jail}"
		    doins "${FILESDIR}"/jails/p11proxy/*
			#Copy jails specific fstab with filter rules export
		    newins "${FILESDIR}"/jails/p11proxy_fstab/fstab.external_${jail} fstab.external

		    if [[ "${ARCH}" = x86 ]] ; then
				sed -i -e 's/^@X86_ONLY@//' "${D}/etc/jails/p11proxy_${jail}/fstab.external"
		    else
				sed -i -e '/^@X86_ONLY@/d' "${D}/etc/jails/p11proxy_${jail}/fstab.external"
		    fi

			if [[ "${ARCH}" =~ ^.*64$ ]] ; then
				sed -i -e '/@clip32@/d' "${D}/etc/jails/p11proxy_${jail}/fstab.external"
				sed -i -e 's/@clip64@//' "${D}/etc/jails/p11proxy_${jail}/fstab.external"
			else
				sed -i -e 's/@clip32@//' "${D}/etc/jails/p11proxy_${jail}/fstab.external"
				sed -i -e '/@clip64@/d' "${D}/etc/jails/p11proxy_${jail}/fstab.external"
			fi

		    echo "/var/lib/p11proxy_${jail}" > "${D}/etc/jails/p11proxy_${jail}/root"
		    echo "${ctx}" > "${D}/etc/jails/p11proxy_${jail}/context"
		    dodir "/var/lib/p11proxy_${jail}/var/run/pcscd"
		    dodir "/var/lib/p11proxy_${jail}/var/run/p11proxy"
			# SSM stuff, only in rm jail
			if [ "${jail}" != 'core' ] ; then
		    	dodir "/var/lib/p11proxy_${jail}/var/run/ssm_db"
		    	dodir "/var/lib/p11proxy_${jail}/var/run/ssm_display"
		    	dodir "/var/lib/p11proxy_${jail}/var/run/ssm_key"
		    	dodir "/var/lib/p11proxy_${jail}/bin"
		    	dodir "/var/lib/p11proxy_${jail}/etc"
				dodir "/mounts/vsdev/ssm_${jail}_devs"
				cd "${D}/mounts/vsdev/ssm_${jail}_devs"
				mknod -m 0666 urandom  c 1 9
				ln -sf urandom random
				cd -
				insinto "/var/lib/p11proxy_${jail}/etc"
				newins ${FILESDIR}/softhsm2.conf softhsm2.conf
			fi
			if [[ "${ARCH}" =~ ^.*64$ ]] ; then
		    	dodir "/var/lib/p11proxy_${jail}/usr/lib64"
				dosym lib64 "/var/lib/p11proxy_${jail}/usr/lib"
		    	dodir "/var/lib/p11proxy_${jail}/lib64"
				dosym lib64 "/var/lib/p11proxy_${jail}/lib"
			else
		    	dodir "/var/lib/p11proxy_${jail}/usr/lib"
		    	dodir "/var/lib/p11proxy_${jail}/lib"
			fi
			dodir "/var/lib/p11proxy_${jail}/usr/local/etc"
			#/dev needed to export /dev/log from syslog-ng
		    dodir "/var/lib/p11proxy_${jail}/dev"
			#tmp needed for netplex
		    dodir "/var/lib/p11proxy_${jail}/tmp"
			#Create /etc directory that will be bind/mount for filter rules
		    dodir "/var/lib/p11proxy_${jail}/etc/pkcs11proxyd"
			#Create directory for OpenSC bind mounts of profiles
			dodir "/var/lib/p11proxy_${jail}/usr/share/opensc"
			dodir "/var/lib/p11proxy_${jail}/etc/opensc"
		    ctx=$((${ctx}+1))
		done

		#Install only clientlib for smartcard in core
		exeinto /usr/lib
		doexe "${S}"/src/client-lib/libp11client.so
		dosym /usr/lib/libp11client.so /usr/lib/p11proxy.so

		insopts -o 4000 -g 4000
		insinto /etc/admin/conf.d/
		newins "${FILESDIR}"/conf/pkcs11proxyd.admin pkcs11proxyd
		for jail in rm_b rm_h core ; do
			#Create conf/filter directories
		    dodir "/etc/admin/conf.d/pkcs11proxyd-conf/${jail}/conf"
		    insinto "/etc/admin/conf.d/pkcs11proxyd-conf/${jail}/conf"
		    doins "${FILESDIR}"/conf/${jail}/pkcs11proxyd_${jail}.conf
		    dodir "/etc/admin/conf.d/pkcs11proxyd-conf/${jail}/filter"
		    insinto "/etc/admin/conf.d/pkcs11proxyd-conf/${jail}/filter"
		    doins "${FILESDIR}"/conf/${jail}/filter_${jail}.conf
		done

		exeinto /sbin/
		doexe "${FILESDIR}"/pampkcs11confgen.sh

	elif use clip-rm; then
		#Install all libs
		for clientlib in '' 'ssm' ; do
			exeinto /usr/lib
			doexe "${S}"/src/client-lib/libp11client${clientlib}.so
		done
	fi
}


pkg_predeb() {
	if use clip-core; then
		doverictld2 /usr/sbin/pkcs11proxyd er 'CONTEXT|SYS_ADMIN' 'CONTEXT|SYS_ADMIN' - -
		init_maintainer "prerm"
		cat >> "${D}/DEBIAN/prerm" << ENDSCRIPT
/sbin/rc-update del pk11proxy default
ENDSCRIPT
		init_maintainer "postinst"
		cat >> "${D}/DEBIAN/postinst" << ENDSCRIPT
/sbin/rc-update add pk11proxy default
ENDSCRIPT
	fi
}
