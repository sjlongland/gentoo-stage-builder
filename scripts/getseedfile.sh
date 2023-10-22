#!/bin/sh

CATALYST_ROOT=$( realpath $( dirname "${0}" )/.. )
BUILD_DIR=${CATALYST_ROOT}/builds

REL_TYPE=${1}
ARCH=${2}
ABI=${3}

seed=${BUILD_DIR}/${REL_TYPE}/seed-${ARCH}${ABI}.tar.bz2
latest=${BUILD_DIR}/${REL_TYPE}/stage3-${ARCH}${ABI}-latest.tar.bz2

if [ -f ${seed} ]; then
	seed_mtime=$( stat -c %Y ${seed} )
else
	seed_mtime=0
fi

if [ -f ${latest} ]; then
	latest_mtime=$( stat -c %Y ${latest} )
else
	latest_mtime=0
fi

if [ ${seed_mtime} -gt ${latest_mtime} ]; then
	use=${seed}
else
	use=${latest}
fi

realpath --relative-base=${CATALYST_ROOT} ${use}
