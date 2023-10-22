#!/bin/sh

TARGET=
ABI=
ARCH=
SUBARCH=
SNAPSHOT=
VERSION_STAMP=
REL_TYPE=
PROFILE=
SOURCE_SUBPATH=
OVERLAY=
CONFDIR=
TARGET_CHOST=
TARGET_CFLAGS=
COMPRESSION_MODE=pixz_x

while [ $# -gt 0 ]; do
	case "$1" in
		--target)	TARGET="${2}"
				shift
				;;
		--abi)		ABI="${2}"
				shift
				;;
		--arch)		ARCH="${2}"
				shift
				;;
		--subarch)	SUBARCH="${2}"
				shift
				;;
		--snapshot)	SNAPSHOT="${2}"
				shift
				;;
		--version)	VERSION_STAMP="${2}"
				shift
				;;
		--rel-type)	REL_TYPE="${2}"
				shift
				;;
		--profile)	PROFILE="${2}"
				shift
				;;
		--source)	SOURCE_SUBPATH="${2}"
				shift
				;;
		--overlay)	OVERLAY="${2}"
				shift
				;;
		--confdir)	CONFDIR="${2}"
				shift
				;;
		--chost)	CHOST="${2}"
				shift
				;;
		--cflags)	CFLAGS="${2}"
				shift
				;;
		--compression-mode)	COMPRESSION_MODE="${2}"
				shift
				;;
	esac
	shift
done
