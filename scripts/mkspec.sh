#!/bin/sh -ex

. $( dirname "${0}" )/getopt.sh

dump_opt() {
	if [ -n "${2}" ]; then
		printf "${1}: ${2}\n" "${1}" "${2}"
	fi
}

dump_opt subarch "${SUBARCH}"
dump_opt version_stamp "${VERSION_STAMP:=${SNAPSHOT}}"
dump_opt snapshot_treeish "${SNAPSHOT}"
dump_opt target "${TARGET}"
dump_opt rel_type "${REL_TYPE}"
dump_opt profile "${PROFILE}"
dump_opt source_subpath "${SOURCE_SUBPATH}"
dump_opt portage_overlay "${OVERLAY}"
dump_opt portage_confdir "${CONFDIR}"
dump_opt compression_mode "${COMPRESSION_MODE:=pixz_x}"

case "${TARGET}" in
	stage1|stage2)
		dump_opt chost "${CHOST}"
		;;
esac

dump_opt cflags "${TARGET_CFLAGS}"
