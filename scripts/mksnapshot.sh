#!/bin/sh -ex

MY_DIR="$( dirname "$0" )"
SNAPSHOT="$1"

# Grab the current stable snapshot
catalyst --snapshot stable

# Figure out what commit it was
COMMIT_HASH=$( git --git-dir=${MY_DIR}/../repos/gentoo.git log --format=%H )

# Do we need to rename?
if [ "${COMMIT_HASH}" = "${SNAPSHOT}" ]; then
	exit 0
fi

# Rename the file
mv -v "${MY_DIR}/../snapshots/gentoo-${COMMIT_HASH}.sqfs" \
	"${MY_DIR}/../snapshots/gentoo-${SNAPSHOT}.sqfs"
