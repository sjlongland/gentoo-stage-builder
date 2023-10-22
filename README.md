# Crude stage-building wrapper around `catalyst`

This is a basic wrapper based on scripts that I used to use for the official
Gentoo/MIPS releases back when I was maintaining that sort of thing.  I've since
expanded my scripts to cover `x86`, `amd64` as well as the `musl` C library.

These scripts try to automate the process of building a set of stage tarballs,
including taking a snapshot (now done via `git`).
