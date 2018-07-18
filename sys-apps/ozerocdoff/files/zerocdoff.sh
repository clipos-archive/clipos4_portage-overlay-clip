#!/bin/sh

VENDORS="0af0"	# ZeroCD vendor

if [[ -z "${PRODUCT}" ]]; then
	logger -p daemon.error "zerocdoff.sh: no PRODUCT"
	exit 1
fi

COUNT=3

if [[ -z "${VENDOR}" ]]; then
	logger -p daemon.error "zerocdoff.sh: no VENDOR"
	exit 1
fi

for v in ${VENDORS}; do
	if [[ "${VENDOR}" == "${v}" ]]; then
		for i in $(seq 1 ${COUNT}); do
			/sbin/ozerocdoff -i "0x${PRODUCT}"
			if [[ $? -ne 0 ]]; then
				logger -p daemon.debug "zerocdoff.sh: try $i failed on ${PRODUCT}"
				sleep 2
			else
				logger -p daemon.info "zerocdoff.sh: deactivated ${PRODUCT}"
				exit 0
			fi
		done
		logger -p daemon.error "zerocdoff.sh: failed on ${PRODUCT}"
		exit 1
	fi
done

logger -p daemon.debug "zerocdoff.sh: no deactivation for ${PRODUCT}"
exit 0
