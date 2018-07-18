# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit kde4-meta-pkg

DESCRIPTION="Merge this to pull in all kdebase-derived packages"
KEYWORDS="amd64 ~arm ppc ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="+display-manager minimal +wallpapers"

RDEPEND="
	$(add_kdeapps_dep dolphin)
	$(add_kdebase_dep kcheckpass)
	wallpapers? ( $(add_kdeapps_dep kde-wallpapers '' 4.14) )
	$(add_kdeapps_dep kdebase-runtime-meta)
	$(add_kdeapps_dep kdialog)
	$(add_kdeapps_dep keditbookmarks)
	$(add_kdebase_dep kephal)
	$(add_kdeapps_dep kfind)
	$(add_kdeapps_dep kfmclient)
	$(add_kdeapps_dep konqueror)
	$(add_kdeapps_dep konsole)
	$(add_kdebase_dep kstartupconfig)
	$(add_kdeapps_dep libkonq)
	$(add_kdebase_dep liboxygenstyle)
	$(add_kdebase_dep libplasmaclock)
	$(add_kdeapps_dep phonon-kde)
	$(add_kdeapps_dep plasma-apps)
	!minimal? (
		$(add_kdebase_dep freespacenotifier)
		$(add_kdebase_dep kcminit )
		$(add_kdebase_dep kdebase-cursors )
		$(add_kdebase_dep khotkeys )
		$(add_kdebase_dep krunner )
		$(add_kdebase_dep ksmserver )
		$(add_kdebase_dep ksplash )
		$(add_kdebase_dep ksysguard )
		$(add_kdebase_dep kwin )
		$(add_kdebase_dep libkworkspace )
		$(add_kdebase_dep libplasmagenericshell )
		$(add_kdebase_dep libtaskmanager)
		$(add_kdebase_dep plasma-workspace)
		$(add_kdebase_dep systemsettings)
	)
"
