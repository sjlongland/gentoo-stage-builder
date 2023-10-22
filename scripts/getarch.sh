#!/bin/sh
CHOST=$1
ARCH="${CHOST%%-*}"
if [ "${ARCH}" = x86_64 ]; then
	ARCH=amd64
fi
echo "${ARCH}"
