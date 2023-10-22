#!/bin/sh
seed=$1
if [ -L "${seed}" ]; then
	seed="$( dirname "${seed}" )/$( readlink "${seed}" )"
fi

# Accepted extensions
# 'tar.xz', 'tpxz', 'xz', 'tar.bz2', 'bz2', 'tbz2', 'squashfs', 'sfs',
# 'tar.gz', 'gz', 'tar'
case "${seed}" in
*.tar.xz)
	seed="${seed%%.tar.xz}"
	;;
*.tpxz)
	seed="${seed%%.tpxz}"
	;;
*.xz)
	seed="${seed%%.xz}"
	;;
*.tar.bz2)
	seed="${seed%%.tar.bz2}"
	;;
*.bz2)
	seed="${seed%%.bz2}"
	;;
*.tbz2)
	seed="${seed%%.tbz2}"
	;;
*.squashfs)
	seed="${seed%%.squashfs}"
	;;
*.sfs)
	seed="${seed%%.sfs}"
	;;
*.tar.gz)
	seed="${seed%%.tar.gz}"
	;;
*.gz)
	seed="${seed%%.gz}"
	;;
*.tar)
	seed="${seed%%.tar}"
	;;
esac
seed="${seed##builds/}"
echo "${seed}"
