#!/usr/bin/env bash
# We don't enable set -e because we use stuff like `false` to control the flow of the script and that makes it exit (e.g. "$1" && internal-print-option -fgnu-tm would exit if "$1" is false)
set -uo pipefail

# Based off GCC documentation from e37eb8578c5c9a62d4f804908ad57fc38c71a3a2
# Check gcc/doc (i.e. the manual - perhaps only invoke.texi and riscv-ext.texi, though...), gcc/params.opt, gcc/config/i386/x86-tune.def

# TODO:
# - If we get the issues with random unrolling on PowerPC again, look into -munroll-only-small-loops and -f[no-]unroll-[all-]loops (or perhaps --param values like max-unroll-times ?)
# - Technically we haven't checked GCC 11.5 and GCC 4.5.4 (we only have GCC 11.4 and GCC 4.5.3) though I wouldn't expect them to introduce any flags
# - GCC 4.3.6 and 4.2.4 haven't been checked, along with GCC versions before 3.4.6
# - No minor versions of GCC have been checked below 4.6.4 (that is, 4.6.x hasn't been checked either)
# - re-examine -freg-struct-return on Clang once we've added most targets

internal-print-option() {
    printf '%s ' "$@"
}

# Options to make the compiler accept as much C++ code as possible (even invalid/non-compliant code or code that uses extensions)
internal-print-generic-options-standards-and-extended-features-gcc-3-4() {
    internal-print-option -std=gnu++98
    internal-print-option -pthread
    internal-print-option -fexceptions -frtti

    internal-print-option -fasm -fgnu-keywords
    # internal-print-option -fcond-mismatch # Only for C, not C++
    # internal-print-option -fgimple # Only for C, not C++
    internal-print-option -fms-extensions # -fplan9-extensions # -fplan9-extensions is only for C, not C++
    internal-print-option -fpermissive

     # Hmmmm... Clang doesn't like this option much on most targets, it seems (it spits out "error: unsupported option '-freg-struct-return' for target 'x86_64-unknown-linux-gnu'" on x86),
     # but it might work on some targets. Something to look at later, I guess
    "$1" && internal-print-option -freg-struct-return
}

internal-print-generic-options-standards-and-extended-features-gcc-4-4() {
    internal-print-generic-options-standards-and-extended-features-gcc-3-4 "$@"

    internal-print-option -std=gnu++0x

    internal-print-option -flax-vector-conversions
    internal-print-option -fopenmp
}

internal-print-generic-options-standards-and-extended-features-gcc-4-5() {
    internal-print-generic-options-standards-and-extended-features-gcc-4-4 "$@"
    internal-print-option -ftemplate-depth=900000
}

internal-print-generic-options-standards-and-extended-features-gcc-4-7() {
    internal-print-generic-options-standards-and-extended-features-gcc-4-5 "$@"
    "$1" && internal-print-option -fgnu-tm
}

internal-print-generic-options-standards-and-extended-features-gcc-4-8() {
    internal-print-generic-options-standards-and-extended-features-gcc-4-7 "$@"
    internal-print-option -std=gnu++1y
    "$1" && internal-print-option -fext-numeric-literals
}

internal-print-generic-options-standards-and-extended-features-gcc-4-9() {
    internal-print-generic-options-standards-and-extended-features-gcc-4-8 "$@"
    internal-print-option -fopenmp-simd
}

internal-print-generic-options-standards-and-extended-features-gcc-5() {
    internal-print-generic-options-standards-and-extended-features-gcc-4-9 "$@"
    internal-print-option -std=gnu++1z
    internal-print-option -fopenacc
}

internal-print-generic-options-standards-and-extended-features-gcc-8() {
    internal-print-generic-options-standards-and-extended-features-gcc-5 "$@"
    internal-print-option -std=gnu++2a
}

internal-print-generic-options-standards-and-extended-features-gcc-10() {
    internal-print-generic-options-standards-and-extended-features-gcc-8 "$@"
    "$1" && internal-print-option -fcoroutines
}

internal-print-generic-options-standards-and-extended-features-gcc-11() {
    internal-print-generic-options-standards-and-extended-features-gcc-10 "$@"
    internal-print-option -std=gnu++2b
}

internal-print-generic-options-standards-and-extended-features-gcc-13() {
    internal-print-generic-options-standards-and-extended-features-gcc-11 "$@"
    "$1" && internal-print-option -fcontracts
}

internal-print-generic-options-standards-and-extended-features-gcc-14() {
    internal-print-generic-options-standards-and-extended-features-gcc-13 "$@"
    internal-print-option -std=gnu++2c
}

internal-print-generic-options-standards-and-extended-features-gcc-15() {
    internal-print-generic-options-standards-and-extended-features-gcc-14 "$@"
    internal-print-option -fmodules
}

internal-print-generic-options-standards-and-extended-features() {
    internal-print-generic-options-standards-and-extended-features-gcc-15 "$@"
}

# Options that make the compiler generate code that is as fast as possible, even if it means breaking some standards or making the code non-portable
internal-print-generic-options-optimizations-non-standard-gcc-3-4() {
    internal-print-option -ffast-math # The stuff enabled by -Ofast, used instead of -Ofast because Clang deprecated -Ofast

    "$1" && internal-print-option -fno-float-store
    internal-print-option -fno-math-errno -funsafe-math-optimizations -ffinite-math-only -fno-trapping-math -fno-rounding-math
    "$1" && internal-print-option -fno-signaling-nans
}

internal-print-generic-options-optimizations-non-standard-gcc-4-0() {
    internal-print-generic-options-optimizations-non-standard-gcc-3-4 "$@"
    internal-print-option -fcx-limited-range
}

internal-print-generic-options-optimizations-non-standard-gcc-4-4() {
    internal-print-generic-options-optimizations-non-standard-gcc-4-0 "$@"
    internal-print-option -fassociative-math -freciprocal-math -fno-signed-zeros

    # internal-print-option -fcx-fortran-rules # -fcx-fortran-rules actually pessimizes code as compared to -fcx-limited-range, so we don't use it (thanks Clang for the warning lol)
}

internal-print-generic-options-optimizations-non-standard-gcc-4-5() {
    internal-print-generic-options-optimizations-non-standard-gcc-4-4 "$@"
    internal-print-option -fexcess-precision=fast
}

internal-print-generic-options-optimizations-non-standard-gcc-4-6() {
    internal-print-generic-options-optimizations-non-standard-gcc-4-5 "$@"
    internal-print-option -ffp-contract=fast
}

internal-print-generic-options-optimizations-non-standard-gcc-5() {
    internal-print-generic-options-optimizations-non-standard-gcc-4-6 "$@"
    internal-print-option -fno-semantic-interposition # Only added in GCC 5 but is also part of the stuff enabled by -Ofast (see also above comment on using this instead of -Ofast)
}

internal-print-generic-options-optimizations-non-standard-gcc-7() {
    internal-print-generic-options-optimizations-non-standard-gcc-5 "$@"
    "$1" && internal-print-option -ffp-int-builtin-inexact
}

internal-print-generic-options-optimizations-non-standard-gcc-10() {
    internal-print-generic-options-optimizations-non-standard-gcc-7 "$@"
    "$1" && internal-print-option -fallow-store-data-races # Only added in GCC 10 but is also part of the stuff enabled by -Ofast (see also above comment on using this instead of -Ofast)
    internal-print-option -ffinite-loops
}

internal-print-generic-options-optimizations-non-standard() {
    internal-print-generic-options-optimizations-non-standard-gcc-10 "$@"
    "$1" && internal-print-option -fcx-method=limited-range
    "$1" || internal-print-option -ffp-model=aggressive
    "$1" || internal-print-option -fno-honor-nans
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-3-4() {
    internal-print-option -fno-fast-math

    internal-print-option -fmath-errno -fno-unsafe-math-optimizations -fno-finite-math-only -ftrapping-math -frounding-math
    "$1" && internal-print-option -fsignaling-nans
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-4-0() {
    internal-print-generic-options-optimizations-disable-non-standard-gcc-3-4 "$@"
    internal-print-option -fno-cx-limited-range
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-4-4() {
    internal-print-generic-options-optimizations-non-standard-gcc-4-0 "$@"
    internal-print-option -fno-associative-math -fno-reciprocal-math -fsigned-zeros
    internal-print-option -fno-cx-fortran-rules
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-4-5() {
    internal-print-generic-options-optimizations-disable-non-standard-gcc-4-4 "$@"
    internal-print-option -fexcess-precision=standard
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-4-6() {
    internal-print-generic-options-optimizations-disable-non-standard-gcc-4-5 "$@"
    internal-print-option -ffp-contract=on
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-5() {
    internal-print-generic-options-optimizations-disable-non-standard-gcc-4-6 "$@"
    internal-print-option -fsemantic-interposition
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-7() {
    internal-print-generic-options-optimizations-disable-non-standard-gcc-5 "$@"
    "$1" && internal-print-option -fno-fp-int-builtin-inexact
}

internal-print-generic-options-optimizations-disable-non-standard-gcc-10() {
    internal-print-generic-options-optimizations-disable-non-standard-gcc-7 "$@"
    internal-print-option -fno-allow-store-data-races
    # We do not set -fno-finite-loops here - let the language standard decide whether loops are finite or not
    # C++11 and later require that loops are finite, so setting -fno-finite-loops there would be going beyond what the standard requires
}

internal-print-generic-options-optimizations-disable-non-standard() {
    internal-print-generic-options-optimizations-disable-non-standard-gcc-10 "$@"
    "$1" && internal-print-option -fcx-method=stdc
    "$1" || internal-print-option -ffp-model=strict
    "$1" || internal-print-option -fhonor-nans
}

internal-print-generic-options-optimization-gcc-3-4() {
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

internal-print-generic-options-optimization-gcc-4-0() {
    internal-print-generic-options-optimization-gcc-3-4 "$@"
    "$1" && internal-print-option -ftree-loop-im -ftree-loop-ivcanon
    internal-print-option -ftree-vectorize
    "$1" && internal-print-option -fmodulo-sched -fvariable-expansion-in-unroller -fivopts
}

internal-print-generic-options-optimization-gcc-4-1() {
    internal-print-generic-options-optimization-gcc-4-0 "$@"
    "$1" && internal-print-option -fipa-cp
}

internal-print-generic-options-optimization-gcc-4-4() {
    internal-print-generic-options-optimization-gcc-4-1 "$@"
    internal-print-option -fstrict-overflow
    "$1" && internal-print-option -fmodulo-sched-allow-regmoves -fsection-anchors
    "$1" && internal-print-option -fira-algorithm=CB # Apparently should be better in general but it might just be that it's enabled by default on every architecture where it works (i.e. this would either do nothing or error)
    "$1" && internal-print-option -fipa-pta
    "$1" && internal-print-option -ftree-cselim -ftree-builtin-call-dce
}

internal-print-generic-options-optimization-gcc-4-5() {
    internal-print-generic-options-optimization-gcc-4-4 "$@"
    "$1" && internal-print-option -fira-loop-pressure
    "$1" && internal-print-option -fsched-pressure
}

internal-print-generic-options-optimization-gcc-4-6() {
    internal-print-generic-options-optimization-gcc-4-5 "$@"
    internal-print-option -fstrict-enums
    "$1" && internal-print-option -ftree-loop-if-convert
}

internal-print-generic-options-optimization-gcc-4-7() {
    internal-print-generic-options-optimization-gcc-4-6 "$@"

    "$1" && internal-print-option -free

    # Enable LTO in case we want to use it, but also make the compiler emit non-LTO code so we can read it
    # Note: I don't know if the outputted fat parts are the same as without -flto, but I hope so - remove this if they aren't
    internal-print-option -flto=auto -ffat-lto-objects
}

internal-print-generic-options-optimization-gcc-4-8() {
    internal-print-generic-options-optimization-gcc-4-7 "$@"
    "$1" && internal-print-option -fira-hoist-pressure -ftree-coalesce-vars
}

internal-print-generic-options-optimization-gcc-4-9() {
    internal-print-generic-options-optimization-gcc-4-8 "$@"

    "$1" && internal-print-option -fdevirtualize-speculatively -flive-range-shrinkage

    # These require Graphite/ISL
    "$1" && internal-print-option -ftree-loop-linear -fgraphite-identity
    "$1" && internal-print-option -floop-strip-mine -floop-block -floop-nest-optimize
}

internal-print-generic-options-optimization-gcc-5() {
    internal-print-generic-options-optimization-gcc-4-9 "$@"
    "$1" && internal-print-option -fdevirtualize-at-ltrans -fstdarg-opt -fschedule-fusion
    "$1" && internal-print-option -fipa-ra -fipa-icf
}

internal-print-generic-options-optimization-gcc-7() {
    internal-print-generic-options-optimization-gcc-5 "$@"
    "$1" && internal-print-option -fsplit-loops
    "$1" && internal-print-option -fipa-bit-cp -fipa-vrp
}

internal-print-generic-options-optimization-gcc-10() {
    internal-print-generic-options-optimization-gcc-7 "$@"
    "$1" && internal-print-option -fallocation-dce
}

internal-print-generic-options-optimization-gcc-12() {
    internal-print-generic-options-optimization-gcc-10 "$@"
    internal-print-option -ftrivial-auto-var-init=uninitialized
}

internal-print-generic-options-optimization-gcc-13() {
    internal-print-generic-options-optimization-gcc-12 "$@"
    internal-print-option -fstrict-flex-arrays=3
    "$1" && internal-print-option -fno-unreachable-traps
}

internal-print-generic-options-optimization() {
    internal-print-generic-options-optimization-gcc-13 "$@"

    "$1" && internal-print-option -flate-combine-instructions -fmalloc-dce=2
    "$1" && internal-print-option -fipa-reorder-for-locality # Might not be much good without profile feedback ?

    "$1" || internal-print-option -fclangir # Apparently required to make -fopenacc do anything, but obviously not supported by GCC

    "$1" || internal-print-option -mllvm -polly
    "$1" || internal-print-option -mllvm -polly-parallel
    "$1" || internal-print-option -mllvm -polly-vectorizer=stripmine
}

internal-print-generic-options-optimization-params-gcc-3-4() {
    internal-print-option --param=max-crossjump-edges=100000 # 100 at -O3
    internal-print-option --param=max-delay-slot-insn-search=100000 # 100 at -O3
    internal-print-option --param=max-delay-slot-live-search=333333 # 333 at -O3
    internal-print-option --param=max-gcse-memory=134217728 # 131072 at -O3
    internal-print-option --param=max-pending-list-length=32768 # 32 at -O3
    internal-print-option --param=max-reload-search-insns=100000 # 100 at -O3
    internal-print-option --param=max-cselib-memory-locations=500000 # 500 at -O3
    internal-print-option --param=max-last-value-rtl=10000000 # 10000 at -O3
    internal-print-option --param=max-cse-path-length=65536 # 10 at -O3 (65536 is the maximum value)

    # internal-print-option --param=hash-table-verification-limit=10000 # 10 at -O3 # Takes a long time to run, to the point Godbolt times out, so disable it for now
}

internal-print-generic-options-optimization-params-gcc-4-0() {
    internal-print-generic-options-optimization-params-gcc-3-4 "$@"

    internal-print-option --param=max-goto-duplication-insns=8888 # 8 at -O3
    internal-print-option --param=max-iterations-to-track=10000000 # 1000 at -O3
    internal-print-option --param=max-sched-region-insns=200000 # 100 at -O3

    internal-print-option --param=iv-consider-all-candidates-bound=40000 # 40 at -O3
    internal-print-option --param=iv-max-considered-uses=250000 # 250 at -O3

    internal-print-option --param=scev-max-expr-size=100000 # 100 at -O3
    internal-print-option --param=sms-dfa-history=16 # 0 at -O3
}

internal-print-generic-options-optimization-params-gcc-4-1() {
    internal-print-generic-options-optimization-params-gcc-4-0 "$@"
    internal-print-option --param=max-fields-for-field-sensitive=100000 # 100 at -O3
    internal-print-option --param=max-cse-insns=1000000 # 1000 at -O3
}

internal-print-generic-options-optimization-params-gcc-4-4() {
    internal-print-generic-options-optimization-params-gcc-4-1 "$@"

    internal-print-option --param=max-sched-ready-insns=65536 # 100 at -O3 (65536 is the maximum value)
    internal-print-option --param=max-sched-region-blocks=10000 # 10 at -O3
    internal-print-option --param=max-pipeline-region-blocks=16384 # 15 at -O3
    internal-print-option --param=max-pipeline-region-insns=200000 # 200 at -O3
    internal-print-option --param=max-sched-extend-regions-iters=1000000 # 0 at -O3

    internal-print-option --param=selsched-max-lookahead=50000 # 50 at -O3
    internal-print-option --param=selsched-max-sched-times=65536 # 2 at -O3 (65536 is the maximum value)
    internal-print-option --param=selsched-insns-to-rename=20000 # 2 at -O3

    internal-print-option --param=ira-max-loops-num=100000 # 100 at -O3
    internal-print-option --param=ira-max-conflict-table-size=1000000 # 1000 at -O3

    internal-print-option --param=max-partial-antic-length=1000000 # 100 at -O3
    internal-print-option --param=loop-invariant-max-bbs-in-loop=10000000 # 10000 at -O3
}

internal-print-generic-options-optimization-params-gcc-4-5() {
    internal-print-generic-options-optimization-params-gcc-4-4 "$@"
        internal-print-option --param=max-early-inliner-iterations=1000 # 1 at -O3
    internal-print-option --param=max-vartrack-size=1000000000 # 50000000 at -O3 (50000000000 would be far above the maximum of 2147483647, and we use less than half of that just in case there could be overflow issues)
    internal-print-option --param=graphite-max-nb-scop-params=10000 # 10 at -O3
}

internal-print-generic-options-optimization-params-gcc-4-6() {
    internal-print-generic-options-optimization-params-gcc-4-5 "$@"

    internal-print-option --param=max-hoist-depth=300000 # 300 at -O3
    internal-print-option --param=max-dse-active-local-stores=5000000 # 5000 at -O3

    internal-print-option --param=scev-max-expr-complexity=10000 # 10 at -O3
    internal-print-option --param=cxx-max-namespaces-for-diagnostic-help=1000000 # 1000 at -O3
}

internal-print-generic-options-optimization-params-gcc-4-7() {
    internal-print-generic-options-optimization-params-gcc-4-6 "$@"

    internal-print-option --param=max-modulo-backtrack-attempts=40000 # 40 at -O3
    internal-print-option --param=max-tracked-strlens=10000000 # 10000 at -O3
    internal-print-option --param=max-vartrack-expr-depth=12000 # 12 at -O3

    internal-print-option --param=max-tail-merge-comparisons=10000 # 10 at -O3
    internal-print-option --param=max-tail-merge-iterations=2000 # 2 at -O3

    internal-print-option --param=loop-max-datarefs-for-datadeps=1000000 # 1000 at -O3
    internal-print-option --param=ipa-cp-value-list-size=8000 # 8 at -O3
}

internal-print-generic-options-optimization-params-gcc-4-8-before-4-8-3() {
    internal-print-generic-options-optimization-params-gcc-4-7 "$@"

    internal-print-option --param=max-slsr-cand-scan=999999 # 50 at -O3 (999999 is the maximum value)
    internal-print-option --param=sccvn-max-alias-queries-per-access=1000000 # 1000 at -O3
    internal-print-option --param=max-vartrack-reverse-op-size=50000 # 50 at -O3

    internal-print-option --param=sched-pressure-algorithm=2 # 1 at -O3 (note: 2 just means a different algorithm that should be better so long as the machine has "a regular register file and accurate register pressure classes")
}

internal-print-generic-options-optimization-params-gcc-4-8() {
    internal-print-generic-options-optimization-params-gcc-4-8-before-4-8-3 "$@"
    internal-print-option --param=uninit-control-dep-attempts=65536 # 100 at -O3
}

internal-print-generic-options-optimization-params-gcc-4-9() {
    internal-print-generic-options-optimization-params-gcc-4-8 "$@"
    internal-print-option --param=lra-max-considered-reload-pseudos=500000 # 500 at -O3
}

internal-print-generic-options-optimization-params-gcc-5() {
    internal-print-generic-options-optimization-params-gcc-4-9 "$@"
    internal-print-option --param=ipa-max-aa-steps=25000000 # 25000 at -O3
}

internal-print-generic-options-optimization-params-gcc-6() {
    internal-print-generic-options-optimization-params-gcc-5 "$@"

    internal-print-option --param=graphite-max-arrays-per-scop=100000 # 100 at -O3

    internal-print-option --param=max-ssa-name-query-depth=10 # 3 at -O3 (10 is the maximum value)
    internal-print-option --param=max-speculative-devirt-maydefs=50000 # 50 at -O3
    internal-print-option --param=max-pow-sqrt-depth=32 # 5 at -O3
    internal-print-option --param=max-isl-operations=350000000 # 350000 at -O3
}

internal-print-generic-options-optimization-params-gcc-7() {
    internal-print-generic-options-optimization-params-gcc-6 "$@"
    internal-print-option --param=max-stores-to-merge=65536 # 64 at -O3 (65536 is the maximum value)
    internal-print-option --param=dse-max-object-size=262144 # 256 at -O3
}

internal-print-generic-options-optimization-params-gcc-8-before-8-5() {
    internal-print-generic-options-optimization-params-gcc-7 "$@"
    internal-print-option --param=max-debug-marker-count=100000000 # 100000 at -O3
}

internal-print-generic-options-optimization-params-gcc-8() {
    internal-print-generic-options-optimization-params-gcc-8-before-8-5 "$@"
    internal-print-option --param=sra-max-propagations=32768 # 32 at -O3
}

internal-print-generic-options-optimization-params-gcc-9-before-9-2() {
    internal-print-generic-options-optimization-params-gcc-8 "$@" | sed 's/--param=sra-max-propagations=[0-9]\+ //g' # sra-max-propagations is not supported in GCC 9.1 to GCC 9.3, so remove it
    internal-print-option --param=dse-max-alias-queries-per-store=262144 # 256 at -O3
}

internal-print-generic-options-optimization-params-gcc-9-before-9-4() {
    internal-print-generic-options-optimization-params-gcc-9-before-9-2 "$@"
    internal-print-option --param=ssa-name-def-chain-limit=524288 # 512 at -O3
}

internal-print-generic-options-optimization-params-gcc-9() {
    internal-print-generic-options-optimization-params-gcc-9-before-9-4 "$@"
    internal-print-option --param=sra-max-propagations=32768 # 32 at -O3 # Was already added in GCC 8, but removed in GCC 9.1 to GCC 9.3, so add it back here
}

internal-print-generic-options-optimization-params-gcc-10() {
    internal-print-generic-options-optimization-params-gcc-9 "$@"

    internal-print-option --param=ipa-sra-max-replacements=16 # 8 at -O3 (16 is the maximum value)
    internal-print-option --param=ipa-max-switch-predicate-bounds=5000 # 5 at -O3
    internal-print-option --param=ipa-max-param-expr-ops=10000 # 10 at -O3

    internal-print-option --param=max-find-base-term-values=200000 # 200 at -O3
}

internal-print-generic-options-optimization-params-gcc-11() {
    internal-print-generic-options-optimization-params-gcc-10 "$@"

    # Note that modref-max-tests 'ought to be bigger than --param modref-max-bases and --param modref-max-refs'
    # I assume this also applies to modref-max-accesses
    # We should probably make sure this holds (probably adjust all the values at once when modref-max-tests is adjusted)
    internal-print-option --param=modref-max-bases=32768 # 32 at -O3
    internal-print-option --param=modref-max-refs=16384 # 16 at -O3
    internal-print-option --param=modref-max-accesses=16384 # 16 at -O3
    internal-print-option --param=modref-max-tests=65536 # 64 at -O3
    internal-print-option --param=modref-max-depth=65536 # 256 at -O3 (65536 is the maximum value)
    internal-print-option --param=modref-max-escape-points=262144 # 256 at -O3

    internal-print-option --param=max-store-chains-to-track=65536 # 64 at -O3 (65536 is the maximum value)
    internal-print-option --param=max-stores-to-track=1048576 # 1024 at -O3

    internal-print-option --param=ipa-jump-function-lookups=8000 # 8 at -O3

    internal-print-option --param=ranger-logical-depth=999 # 6 at -O3 (999 is the maximum value)
}

internal-print-generic-options-optimization-params-gcc-12() {
    internal-print-generic-options-optimization-params-gcc-11 "$@"
    internal-print-option --param=modref-max-adjustments=254 # 8 at -O3 (254 is the maximum value)
    internal-print-option --param=relation-block-limit=9999 # 200 at -O3 (9999 is the maximum value)
}

internal-print-generic-options-optimization-params-gcc-13-before-13-3() {
    internal-print-generic-options-optimization-params-gcc-12 "$@"

    internal-print-option --param=vect-max-layout-candidates=32768 # 32 at -O3
    internal-print-option --param=max-jump-thread-paths=65536 # 64 at -O3 (65536 is the maximum value)
    internal-print-option --param=ira-simple-lra-insn-threshold=1000000 # 1000 at -O3
    internal-print-option --param=ranger-recompute-depth=100 # 5 at -O3 (100 is the maximum value)
}

internal-print-generic-options-optimization-params-gcc-13() {
    internal-print-generic-options-optimization-params-gcc-13-before-13-3 "$@"
    internal-print-option --param=uninit-max-chain-len=128 # 8 at -O3 (128 is the maximum value)
    internal-print-option --param=uninit-max-num-chains=128 # 8 at -O3 (128 is the maximum value)
}

internal-print-generic-options-optimization-params-gcc-14() {
    internal-print-generic-options-optimization-params-gcc-13 "$@"
    internal-print-option --param=vrp-sparse-threshold=3000000 # 3000 at -O3
    internal-print-option --param=vrp-switch-limit=50000 # 50 at -O3
}

internal-print-generic-options-optimization-params-gcc-15() {
    internal-print-generic-options-optimization-params-gcc-14 "$@"
    internal-print-option --param=max-combine-search-insns=3000000 # 3000 at -O3
    internal-print-option --param=vrp-block-limit=150000000 # 150000 at -O3
    internal-print-option --param=transitive-relations-work-bound=9999 # 256 at -O3 (9999 is the maximum value)
}

internal-print-generic-options-optimization-params() {
    internal-print-generic-options-optimization-params-gcc-15 "$@"
}

# Note: $1 is a boolean that indicates whether we're using GCC or Clang (true for GCC, false for Clang)
# Note: $2 is a boolean that indicates whether to print the non-standard optimizations or to disable them (true enables them, false disables them)
internal-print-generic-options() {
    internal-print-generic-options-standards-and-extended-features "$@"
    internal-print-generic-options-optimization "$@"
    "$2" && internal-print-generic-options-optimizations-non-standard "$@"
    "$2" || internal-print-generic-options-optimizations-disable-non-standard "$@"

    # --param options are not supported by Clang, so we only print them if we're using GCC
    "$1" && internal-print-generic-options-optimization-params "$@"

    internal-print-option -g0 # We specifically want to avoid debugging statements, as they clutter assembly output and make it harder to read
}

internal-print-x86-options-gcc-3-4() {
    internal-print-option -mieee-fp
    "$2" && internal-print-option -mhard-float

    internal-print-option -mmmx
    "$2" && internal-print-option -m3dnow
    internal-print-option -msse -msse2 -msse3
    # internal-print-option -mevex512 # Removed in GCC 16, it seems

    internal-print-option -momit-leaf-frame-pointer

    # internal-print-option -mthreads # Doesn't actually work anywhere except MinGW
    internal-print-option -masm=intel # Obviously (note: could potentially interfere with Godbolt... will have to see how it works out)
}

internal-print-x86-options-gcc-4-4() {
    internal-print-x86-options-gcc-3-4 "$@"
    internal-print-option -march=barcelona
    internal-print-option -mtune=generic

    "$2" && internal-print-option -mfpmath=both # GCC says it's "still experimental" and results "in unstable performance" according to documentation, we'll have to see how it works out
    "$2" || internal-print-option -mfpmath=sse # Clang does not support -mfpmath=both, so use sse instead

    internal-print-option -mssse3 -msse4 -msse4a -msse4.1 -msse4.2
    internal-print-option -mavx
    internal-print-option -mpopcnt -maes -mpclmul -mfma -mcx16 -msahf

    internal-print-option -mtls-dialect=gnu2

    "$2" && internal-print-option -fno-section-anchors # GCC does not support this option on x86 targets, so disable it to avoid a warning
}

internal-print-x86-options-gcc-4-5() {
    internal-print-x86-options-gcc-4-4 "$@"
    internal-print-option -mfma4 -mxop -mlwp -mmovbe -mcrc32
}

internal-print-x86-options-gcc-4-6() {
    internal-print-x86-options-gcc-4-5 "$@"
    internal-print-option -march=core-avx-i
    internal-print-option -mbmi -mrdrnd -mtbm -mfsgsbase -mf16c
    internal-print-option -mabi=sysv
}

internal-print-x86-options-gcc-4-7() {
    internal-print-x86-options-gcc-4-6 "$@"

    internal-print-option -march=core-avx2

    internal-print-option -mavx2
    internal-print-option -mbmi2 -mlzcnt
}

internal-print-x86-options-gcc-4-8() {
    internal-print-x86-options-gcc-4-7 "$@"
    internal-print-option -mfxsr -mxsave -mxsaveopt
    internal-print-option -mrdseed -madx -mrtm -mprfchw
    "$2" && internal-print-option -mhle
}

internal-print-x86-options-gcc-4-9-before-4-9-2() {
    internal-print-x86-options-gcc-4-8 "$@"

    internal-print-option -march=broadwell
    internal-print-option -mavx512f -mavx512cd
    internal-print-option -msha

    X86_OPTIONS_TUNE_CTRL_LIST='^lcp_stall,use_incdec,use_himode_fiop,use_simode_fiop,use_ffreep,ext_80387_constants'
}

internal-print-x86-options-gcc-4-9() {
    internal-print-x86-options-gcc-4-9-before-4-9-2 "$@"
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',^avoid_false_dep_for_bmi'
}

internal-print-x86-options-gcc-5-before-5-1() {
    internal-print-x86-options-gcc-4-9 "$@"
    internal-print-option -mavx512vl -mavx512bw -mavx512dq -mavx512ifma -mavx512vbmi
    internal-print-option -mclflushopt -mclwb
    internal-print-option -mxsavec -mxsaves
}

internal-print-x86-options-gcc-5() {
    internal-print-x86-options-gcc-5-before-5-1 "$@"
    internal-print-option -mmwaitx
}

internal-print-x86-options-gcc-6() {
    internal-print-x86-options-gcc-5 "$@"
    internal-print-option -march=skylake-avx512
    internal-print-option -mclzero -mpku
}

internal-print-x86-options-gcc-7() {
    internal-print-x86-options-gcc-6 "$@"
    internal-print-option -mavx512vpopcntdq
    "$2" && internal-print-option -m3dnowa
    internal-print-option -mrdpid -msgx
}

internal-print-x86-options-gcc-8() {
    internal-print-x86-options-gcc-7 "$@"

    internal-print-option -march=icelake-server

    internal-print-option -mavx512vbmi2 -mavx512bitalg -mavx512vnni
    internal-print-option -mmovdiri -mmovdir64b
    internal-print-option -mpconfig -mwbnoinvd -mgfni -mvaes -mvpclmulqdq -mshstk

    internal-print-option -mprefer-vector-width=512
}

internal-print-x86-options-gcc-9-before-9-4() {
    internal-print-x86-options-gcc-8 "$@"
    internal-print-option -mptwrite -mwaitpkg -mcldemote
}

internal-print-x86-options-gcc-9() {
    internal-print-x86-options-gcc-9-before-9-4 "$@"
    internal-print-option -march=tigerlake
}

internal-print-x86-options-gcc-10() {
    internal-print-x86-options-gcc-9 "$@"
    internal-print-option -mavx512bf16 -mavx512vp2intersect
    internal-print-option -menqcmd
}

internal-print-x86-options-gcc-11-before-11-3() {
    internal-print-x86-options-gcc-10 "$@"

    internal-print-option -march=x86-64-v4 # Seems like a good baseline

    internal-print-option -mavxvnni
    internal-print-option -mamx-tile -mamx-int8 -mamx-bf16
    internal-print-option -mkl -mwidekl
    internal-print-option -mtsxldtrk -mserialize -mhreset
    # -muintr is not supported for 32-bit code
    "$1" && internal-print-option -muintr

    "$2" && internal-print-option -mneeded
}

internal-print-x86-options-gcc-11() {
    internal-print-x86-options-gcc-11-before-11-3 "$@"
    "$2" && internal-print-option -mmwait
}

internal-print-x86-options-gcc-12-before-12-3() {
    internal-print-x86-options-gcc-11 "$@"

    internal-print-option -mavx512fp16

    "$2" && internal-print-option -mmove-max=512 -mstore-max=512

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_gather_2parts,use_gather_4parts'
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',avx512_move_by_pieces,avx512_store_by_pieces'
}

internal-print-x86-options-gcc-12-before-12-4() {
    internal-print-x86-options-gcc-12-before-12-3 "$@"

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_scatter_2parts,use_scatter_4parts'
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',^avoid_fma512_chains'
}

internal-print-x86-options-gcc-12() {
    internal-print-x86-options-gcc-12-before-12-4 "$@"

    # Note: use_gather_8parts and use_scatter_8parts appear to not be supported in GCC 13.1 and GCC 13.2, even though GCC 12.4 supports them...
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_gather_8parts,use_scatter_8parts'
}

internal-print-x86-options-gcc-13-before-13-3() {
    internal-print-x86-options-gcc-12 "$@"

    internal-print-option -mavxifma -mavxvnniint8 -mavxneconvert
    internal-print-option -mamx-fp16 -mamx-complex
    internal-print-option -mcmpccxadd -mprefetchi -mraoint

    # Remove use_gather_8parts and use_scatter_8parts, as they are not supported in GCC 13.1 and GCC 13.2
    X86_OPTIONS_TUNE_CTRL_LIST="$(echo "$X86_OPTIONS_TUNE_CTRL_LIST" | sed 's/,use_gather_8parts//;s/,use_scatter_8parts//')"

    "$2" && internal-print-option --param=x86-stv-max-visits=1000000 # 10000 at -O3 (1000000 is the maximum value)
}

internal-print-x86-options-gcc-13() {
    internal-print-x86-options-gcc-13-before-13-3 "$@"

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_gather_8parts,use_scatter_8parts' # Was already added in GCC 12 but removed in GCC 13.1 and GCC 13.2, so add it back here
}

internal-print-x86-options-gcc-14() {
    internal-print-x86-options-gcc-13 "$@"

    internal-print-option -mavxvnniint16
    internal-print-option -msm3 -msm4
    internal-print-option -mavx10.1 # -mavx10.1-256 -mavx10.1-512 # -mavx10.1-256 and -mavx10.1-512 are removed in GCC 16, it seems
    internal-print-option -msha512 -musermsr
    # -mapxf is not supported for 32-bit code
    "$1" && internal-print-option -mapxf

    "$2" && internal-print-option -mnoreturn-no-callee-saved-registers
}

internal-print-x86-options-gcc-15()
{
    internal-print-x86-options-gcc-14 "$@"

    internal-print-option -mavx10.2
    internal-print-option -mamx-avx512 -mamx-tf32 -mamx-transpose -mamx-fp8
    internal-print-option -mmovrs -mamx-movrs

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST",'^avoid_false_dep_for_tzcnt,^avoid_false_dep_for_bls'
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',avx512_two_epilogues'
}

# $1 is a boolean that indicates whether we're on x86-64 or x86-32 (if true, we're on x86-64, if false, we're on x86-32)
# $2 is a boolean that indicates whether we're using GCC (true for GCC, false for Clang)
internal-print-x86-options() {
    internal-print-x86-options-gcc-15 "$@"

    # If X86_OPTIONS_TUNE_CTRL_LIST is set (and we're using GCC), set the -mtune-ctrl option to it
    [ -n "${X86_OPTIONS_TUNE_CTRL_LIST:-}" ] && "$2" && internal-print-option -mtune-ctrl="$X86_OPTIONS_TUNE_CTRL_LIST"

    # Print -m64 if we're on x86-64, or -m32 if we're on x86-32
    "$1" && internal-print-option -m64; "$1" || internal-print-option -m32

    # position-independent code is a bit awkward to handle (it seems to output assembly output that llvm-mca has trouble parsing, for instance) and also makes code a bit longer, so disable it
    internal-print-option -fno-pie
}

# $1 is a boolean that indicates whether we're on x86-64 or x86-32 (if true, we're on x86-64, if false, we're on x86-32)
# $2 is a boolean that indicates whether we're using GCC (true for GCC, false for Clang)
internal-do-x86-64() {
    internal-print-generic-options "$2" true
    internal-print-x86-options "$1" "$2"
    printf '\n'
}

gcc-x86-64() {
    internal-do-x86-64 true true
}

clang-x86-64() {
    internal-do-x86-64 true false
}

gcc-x86-32() {
    internal-do-x86-64 false true
}


do-single-compiler() {
    "$1"
}

# For each argument, we print the "{argument}: {flags}"
do-compilers() {
    for compiler in "$@"; do
        printf "%s:\n" "$compiler"
        do-single-compiler "$compiler"
        printf '\n'
    done
}

# If we have no arguments, print the flags for every single compiler (as if the name of every single compiler was passed)
# If we have 1 argument, print the flags for that compiler without any prefixing
# If we have more than 1 argument, print the flags for each of those compilers, prefixed with the compiler name
if [ $# -eq 0 ]; then
    do-compilers gcc-x86-64 clang-x86-64 gcc-x86-32
elif [ $# -eq 1 ]; then
    do-single-compiler "$1"
else
    do-compilers "$@"
fi
