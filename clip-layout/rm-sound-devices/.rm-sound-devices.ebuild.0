# Copyright © 2007-2018 ANSSI. All Rights Reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Sound devices for RM jails"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	dodir /user_devs
	cd "${D}/user_devs"
	mknod -m 0666 mixer c 14 0
	mknod -m 0666 dsp 	c 14 3
	mkdir snd
	mknod -m 0666 snd/controlC0 	c 116 0
	mknod -m 0666 snd/pcmC0D0p		c 116 16
	mknod -m 0666 snd/pcmC0D0c		c 116 24
	mknod -m 0666 snd/timer			c 116 33
}

