#!/bin/sh

# Part 1: Determine new release parameters
# First, we look on the command line
SKIP=0
TEMP_SEED=0
OVERLAY=""
CONFDIR=""
while [ $# -gt 0 ]; do
	case $1 in
		--type)
			REL_TYPE=$2
			shift
			;;
		--seed)	
			SEED=$2
			shift
			;;
		--abi)
			if [ "$2" != "o32" ]; then
				ABI=$2
			fi
			shift
			;;
		--snapshot)
			SNAPSHOT=$2
			shift
			;;
		--overlay)
			OVERLAY=$2
			shift
			;;
		--confdir)
			CONFDIR=$2
			shift
			;;
		--makesnap)
			MKSNAP=1
			;;
		--sync-portage)
			emerge --sync
			;;
		--profile)
			PROFILE=$2
			shift
			;;
		--subarches)
			SUBARCHES=$2
			shift
			;;
		--force)
			FORCE=$2
			shift
			;;
		--noccache)
			CCACHE=off
			;;
		--chost)
			TARGET_CHOST=$2
			shift
			;;
		--cflags)
			TARGET_CFLAGS=$2
			shift
			;;
		--temp-seed)
			TEMP_SEED=1
			;;
	esac
	shift
done

if [ "${SNAPSHOT}" = "new" ]; then
	SNAPSHOT=$( date +%Y%m%d )
	catalyst -s "${SNAPSHOT}"
fi

if [ "${SNAPSHOT}" = "today" ]; then
	SNAPSHOT=$( date +%Y%m%d )
fi

# Drag in defaults for unset values
CHOST=$( gcc -dumpmachine )
ARCH=${CHOST%%-*}
if [ "${ARCH}" = x86_64 ]; then
	ARCH=amd64
fi

# Handling of temporary seed stage builds
if [ "${TEMP_SEED}" = 1 ]; then
	if [ -z "${SEED}" ]; then
		SEED="${REL_TYPE}/stage3-${ARCH}${ABI}-latest"
	fi

	$0 --type "${REL_TYPE}-SEED" \
		--seed "${SEED}" \
		--abi "${ABI}" \
		${MKSNAP:+--makesnap} \
		--snapshot "${SNAPSHOT}" \
		--profile "${PROFILE}" \
		--overlay "${OVERLAY}" \
		--confdir "${CONFDIR}" \
		--subarches "${SUBARCHES}" \
		--chost "${TARGET_CHOST}" \
		--cflags "${TARGET_CFLAGS}" \
			|| exit $?
	$0 --type "${REL_TYPE}" \
		--seed "${REL_TYPE}-SEED/stage3-${ARCH}${ABI}-latest" \
		--abi "${ABI}" \
		${MKSNAP:+--makesnap} \
		--snapshot "${SNAPSHOT}" \
		--profile "${PROFILE}" \
		--overlay "${OVERLAY}" \
		--confdir "${CONFDIR}" \
		--subarches "${SUBARCHES}" \
		--chost "${TARGET_CHOST}" \
		--cflags "${TARGET_CFLAGS}" \
			|| exit $?
	rm -fr builds/${REL_TYPE}-SEED tmp/${REL_TYPE}-SEED
fi

if [ -z "${REL_TYPE}" ]; then
	if [ "${CHOST##*-}" = "uclibc" ]; then
		REL_TYPE=uclibc
		: ${TARGET_CHOST:=${ARCH}-pc-linux-uclibc}
	else
		REL_TYPE=default
	fi
fi

if [ -z "${SEED}" ]; then
	SEED=${REL_TYPE}/seed-${ARCH}${ABI}
fi

if [ -z "${SNAPSHOT}" ]; then
	if [ -f release ]; then
		SNAPSHOT=$(< release )
	else
		echo "No snapshot specified and no 'release' file found"
		exit 1
	fi
else
	echo "${SNAPSHOT}" > release
fi

if [ -z "${SUBARCHES}" ]; then
	SUBARCHES=${ARCH}1,${ARCH}3,${ARCH}4
fi

if [ -z "${PROFILE}" ]; then
	if [ -f "profile-${REL_TYPE}-${SNAPSHOT}" ]; then
		PROFILE=$(< "profile-${REL_TYPE}-${SNAPSHOT}" )
	else
		echo "Need a profile to use.  Try running:"
		echo "  $0 $@ --profile profile/to/use"
		exit 1
	fi
else
	echo ${PROFILE} > "profile-${REL_TYPE}-${SNAPSHOT}"
fi

# Target list
targets="stage3"
if [ "${SKIP}" -lt 2 ]; then
	targets="stage2 ${targets}"
fi
if [ "${SKIP}" -lt 1 ]; then
	targets="stage1 ${targets}"
fi

# Dump them out for the user
cat <<EOF
Building stages with parameters:
	Release Type (--type):	${REL_TYPE}
	Seed Stage (--seed):	${SEED}
	Snapshot (--snapshot):	${SNAPSHOT}
	Overlay (--overlay):	${OVERLAY}
	Conf Dir (--confdir):	${CONFDIR}
	Sub Architectures (--subarches):
		${SUBARCHES//,/, }.
	ABI (--abi):		${ABI:-x86}
	Profile (--profile):	${PROFILE}
	CHOST (--chost):	${TARGET_CHOST}
	CFLAGS (--cflags):	${TARGET_CFLAGS}
EOF

# Part 2: Write the specfiles for the new release.
for subarch in ${SUBARCHES//,/ }; do
	seed=${SEED}
	for target in ${targets}; do
		specfile=specs/${target}-${REL_TYPE}-${subarch}-${SNAPSHOT}.spec
		cat > ${specfile} <<EOF
subarch: ${subarch}
version_stamp: ${SNAPSHOT}
snapshot: ${SNAPSHOT}
target: ${target}
rel_type: ${REL_TYPE}
profile: ${PROFILE}
source_subpath: ${seed}
EOF
		if [ -n "${OVERLAY}" ]; then
			echo "portage_overlay: ${OVERLAY}" >> ${specfile}
		fi
		if [ -n "${CONFDIR}" ]; then
			echo "portage_confdir: ${CONFDIR}" >> ${specfile}
		fi
		if [ -n "${TARGET_CHOST}" ] && ( [ ${target} = stage1 ] || [ ${target} = stage2 ] ); then
			cat >> ${specfile} << EOF
chost: ${TARGET_CHOST}
EOF
		fi
		if [ -n "${TARGET_CFLAGS}" ]; then
			cat >> ${specfile} << EOF
cflags: ${TARGET_CFLAGS}
EOF
		fi
		echo "o ${specfile} written"

		# We use the previously generated file to build the next stage
		seed="${REL_TYPE}/${target}-${subarch}-${SNAPSHOT}"
	done
done

# Forcing snapshot?
if [ "${FORCE}" ]; then
	for target in ${FORCE//,/ }; do
		if [ "${target}" = "snapshot" ]; then
			rm -f snapshots/portage-${SNAPSHOT}.tar.bz2*
			break
		fi
	done
fi

# Part 3: Build/download the snapshot if it doesn't exist
if [ ! -f "snapshots/portage-${SNAPSHOT}.tar.bz2" ]; then
	case "${SNAPSHOT}" in
		*-pre*)	# Pre-release snapshot... sync and build
			emerge --sync || exit 1
			catalyst -s "${SNAPSHOT}" || exit 1
			;;
		*)	# Official Release
			if [ -z "${MKSNAP}" ]; then
				wget -P snapshots --no-check-certificate \
					https://poseidon.amd64.dev.gentoo.org/snapshots/portage-${SNAPSHOT}.tar.bz2{,.DIGESTS,.CONTENTS} \
					|| exit 1
				# Check digests
				(	cd snapshots
					md5sum -c portage-${SNAPSHOT}.tar.bz2.DIGESTS || exit 1
					sha1sum -c portage-${SNAPSHOT}.tar.bz2.DIGESTS || exit 1
				) || exit 1
			else
				emerge --sync || exit 1
				catalyst -s "${SNAPSHOT}" || exit 1
			fi
			;;
	esac
fi

# Part 4: Build each new stage in order.
for subarch in ${SUBARCHES//,/ }; do
	if [ "${FORCE}" ]; then
		for target in ${FORCE//,/ }; do
			rm -fv builds/${REL_TYPE}/${target}-${subarch}-${SNAPSHOT}.tar.bz2
		done
	fi

	for target in ${targets}; do
		specfile=specs/${target}-${REL_TYPE}-${subarch}-${SNAPSHOT}.spec
		outfile=builds/${REL_TYPE}/${target}-${subarch}-${SNAPSHOT}.tar.bz2
		latest=builds/${REL_TYPE}/${target}-${subarch}-latest.tar.bz2
		if [ ! -f ${outfile} ]; then
			catalyst -f "${specfile}" || exit 1
		else
			echo "Already built ${outfile}.  Skipping."
			echo "Specify --force ${target} if this is not what you want."
		fi
		rm -f ${latest} && ln -s $( basename ${outfile} ) ${latest}
	done
done
