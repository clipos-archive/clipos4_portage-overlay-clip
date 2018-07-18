# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit verictl2 remove-other-perms autotools

DESCRIPTION="Signature creation / verification tool"
HOMEPAGE="https://www.ssi.gouv.fr"
SRC_URI="mirror://clip/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="clip-devstation clip-core clip-civil rm-core clip-rm"

RDEPEND="!clip-civil? ( >=clip-libs/libacidfile-2.0.16
					>=clip-libs/clip-lib-1.2.14
					>=clip-libs/libacidcrypt-3.0.7 )
		clip-civil? ( rm-core? ( >=dev-libs/openssl-rm-core-1.0.2e )
					  !rm-core? ( >=dev-libs/openssl-1.0.2e ) )
						"
DEPEND="${RDEPEND}
		!clip-civil? ( clip-dev/ccsd-headers:3.3 )"

src_configure() {
	eautoreconf

	# On development stations we should configure with --enable-sign
	# For crypto, we choose between --with-crypto=ccsd (if clip-ccsd is
	# activated) and --with-crypto=civil otherwise
	if use clip-civil; then
		econf $(use_enable clip-devstation sign) \
				$(use_with clip-civil crypto civil)
	else
		econf $(use_enable clip-devstation sign) \
				$(use_with !clip-civil crypto ccsd)
	fi
}

src_install() {
	default

	if use clip-civil; then
		if use clip-core; then
			# Daemon for signature verification chroots in /var/empty/gen-crypt
			# and needs certificates in there.
			# On the other hand, paths to keys must be functional when the
			# standalone program is used.
			# As a result, the most practical solution seems to have paths to
			# keys inside the chroot identical to those when no chroot is
			# performed.
			# So we need to create the appropriate directories, and mount key
			# material inside the chroot.
			# The reason we need to do this in the civil version
			# and not in the CCSD version is that the CCSD library does not
			# require access to a certificate once connection is performed.
			# Mount point creation for core
			dodir "/var/empty/gen-crypt/update_root/etc/clip_update/keys"
			insinto "/etc/fstab.d"
			doins "${FILESDIR}/core_fstab.gen-crypt"
			# Mount point creation for jail update
			dodir "/mounts/update_priv/var/empty/gen-crypt/etc/clip_update/keys"
			insinto "/etc/jails/update/fstab.external.d"
			doins "${FILESDIR}/update_fstab.gen-crypt"
			# Mount point creation for jails RM_H and RM_B
			dodir "/vservers/rm_b/update_priv/var/empty/gen-crypt/etc/clip_update/keys"
			dodir "/vservers/rm_h/update_priv/var/empty/gen-crypt/etc/clip_update/keys"
			insinto "/etc/jails/rm_h/fstab.external.d"
			doins "${FILESDIR}/rm_fstab.gen-crypt"
			insinto "/etc/jails/rm_b/fstab.external.d"
			doins "${FILESDIR}/rm_fstab.gen-crypt"
		fi
		# find "${D}/var/empty/gen-crypt/etc" -type d -exec chmod 0755 {} \;
		# use clip-core && dodir
		# "/mounts/update_priv/var/empty/gen-crypt/etc/clip_update/keys"
		# find "${D}/mounts/update_priv/var/empty/gen-crypt/etc" -type d -exec chmod 0755 {} \;
	else
		dodir "/var/empty/gen-crypt"
		use clip-core && dodir "/mounts/update_priv/var/empty/gen-crypt"
	fi

	if ! use clip-devstation; then
		remove-other-perms "*fstab*"
		# does not raise problem for directories created
		# above, only files are impacted.
	fi
}

pkg_predeb() {
	doverictld2 /usr/bin/check-daemon er 'SYS_CHROOT' 'SYS_CHROOT' - -
	if use clip-core; then
		# Create an entry for the UPDATE context as well
		VERIEXEC_CTX=501 doverictld2 /usr/bin/check-daemon er 'SYS_CHROOT' 'SYS_CHROOT' - -
	fi
}
