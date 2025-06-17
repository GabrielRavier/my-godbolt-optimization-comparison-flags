internal-print-options-generic-optimizations-gcc-3-4() {
    # Options for optimization
    internal-print-option -fbuiltin
    "$1" && internal-print-option -fnonansi-builtins
    # internal-print-option -fhosted # Only for C, not C++
    internal-print-option -fstrict-aliasing
    internal-print-option -O3
    internal-print-option -fomit-frame-pointer # Should be enabled by -O3, but just in case (some distros are disabling it these days...)
    "$1" && internal-print-option -fgcse-sm -fgcse-las
    internal-print-option -fdelete-null-pointer-checks
    "$1" && internal-print-option -fprefetch-loop-arrays -freorder-blocks-and-partition -fweb -frename-registers -ftracer -funswitch-loops

    "$1" && internal-print-option -fschedule-insns -fschedule-insns2
    "$1" && internal-print-option -fsched-spec-load -fsched-spec-load-dangerous
    # Maybe -fsched-stalled-insns and -fsched-stalled-insns-dep ? No idea if they're actually beneficial to optimization, though...
    "$1" && internal-print-option -fsched2-use-superblocks
}

internal-print-options-generic-optimizations-gcc-4-0() {
    internal-print-options-generic-optimizations-gcc-3-4 "$@"
    "$1" && internal-print-option -ftree-loop-im -ftree-loop-ivcanon
    internal-print-option -ftree-vectorize
    "$1" && internal-print-option -fmodulo-sched -fvariable-expansion-in-unroller -fivopts
}

internal-print-options-generic-optimizations-gcc-4-1() {
    internal-print-options-generic-optimizations-gcc-4-0 "$@"
    "$1" && internal-print-option -fipa-cp
}

internal-print-options-generic-optimizations-gcc-4-4() {
    internal-print-options-generic-optimizations-gcc-4-1 "$@"
    internal-print-option -fstrict-overflow
    "$1" && internal-print-option -fmodulo-sched-allow-regmoves -fsection-anchors
    "$1" && internal-print-option -fira-algorithm=CB # Apparently should be better in general but it might just be that it's enabled by default on every architecture where it works (i.e. this would either do nothing or error)
    "$1" && internal-print-option -fipa-pta
    "$1" && internal-print-option -ftree-cselim -ftree-builtin-call-dce
}

internal-print-options-generic-optimizations-gcc-4-5() {
    internal-print-options-generic-optimizations-gcc-4-4 "$@"
    "$1" && internal-print-option -fira-loop-pressure
    "$1" && internal-print-option -fsched-pressure
}

internal-print-options-generic-optimizations-gcc-4-6() {
    internal-print-options-generic-optimizations-gcc-4-5 "$@"
    internal-print-option -fstrict-enums
    "$1" && internal-print-option -ftree-loop-if-convert
}

internal-print-options-generic-optimizations-gcc-4-7() {
    internal-print-options-generic-optimizations-gcc-4-6 "$@"

    "$1" && internal-print-option -free

    # Enable LTO in case we want to use it, but also make the compiler emit non-LTO code so we can read it
    # Note: I don't know if the outputted fat parts are the same as without -flto, but I hope so - remove this if they aren't
    internal-print-option -flto=auto -ffat-lto-objects
}

internal-print-options-generic-optimizations-gcc-4-8() {
    internal-print-options-generic-optimizations-gcc-4-7 "$@"
    "$1" && internal-print-option -fira-hoist-pressure -ftree-coalesce-vars
}

internal-print-options-generic-optimizations-gcc-4-9() {
    internal-print-options-generic-optimizations-gcc-4-8 "$@"

    "$1" && internal-print-option -fdevirtualize-speculatively -flive-range-shrinkage

    # These require Graphite/ISL
    "$1" && internal-print-option -ftree-loop-linear -fgraphite-identity
    "$1" && internal-print-option -floop-strip-mine -floop-block -floop-nest-optimize
}

internal-print-options-generic-optimizations-gcc-5() {
    internal-print-options-generic-optimizations-gcc-4-9 "$@"
    "$1" && internal-print-option -fdevirtualize-at-ltrans -fstdarg-opt -fschedule-fusion
    "$1" && internal-print-option -fipa-ra -fipa-icf
}

internal-print-options-generic-optimizations-gcc-7() {
    internal-print-options-generic-optimizations-gcc-5 "$@"
    "$1" && internal-print-option -fsplit-loops
    "$1" && internal-print-option -fipa-bit-cp -fipa-vrp
}

internal-print-options-generic-optimizations-gcc-10() {
    internal-print-options-generic-optimizations-gcc-7 "$@"
    "$1" && internal-print-option -fallocation-dce
}

internal-print-options-generic-optimizations-gcc-12() {
    internal-print-options-generic-optimizations-gcc-10 "$@"
    internal-print-option -ftrivial-auto-var-init=uninitialized
}

internal-print-options-generic-optimizations-gcc-13() {
    internal-print-options-generic-optimizations-gcc-12 "$@"
    internal-print-option -fstrict-flex-arrays=3
    "$1" && internal-print-option -fno-unreachable-traps
}

internal-print-options-generic-optimizations() {
    internal-print-options-generic-optimizations-gcc-13 "$@"

    "$1" && internal-print-option -flate-combine-instructions -fmalloc-dce=2
    "$1" && internal-print-option -fipa-reorder-for-locality # Might not be much good without profile feedback ?

    "$1" || internal-print-option -fclangir # Apparently required to make -fopenacc do anything, but obviously not supported by GCC

    "$1" || internal-print-option -mllvm -polly
    "$1" || internal-print-option -mllvm -polly-parallel
    "$1" || internal-print-option -mllvm -polly-vectorizer=stripmine
}
