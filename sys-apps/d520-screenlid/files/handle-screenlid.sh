#!/bin/sh

if (grep open /proc/acpi/button/lid/LID/state &> /dev/null)
then
	echo "$* - Open !" >> /tmp/screenlid
	/usr/sbin/vbetool dpms on
else
	echo "$* - Closed !" >> /tmp/screenlid
	/usr/sbin/vbetool dpms off
fi
