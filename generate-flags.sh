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

source "$(dirname "$0")/generate-flags/internal/print/options/generic/standards-and-extended-features.sh"
source "$(dirname "$0")/generate-flags/internal/print/options/generic/optimizations/non-standard.sh"
source "$(dirname "$0")/generate-flags/internal/print/options/generic/optimizations/disable-non-standard.sh"
source "$(dirname "$0")/generate-flags/internal/print/options/generic/optimizations.sh"
source "$(dirname "$0")/generate-flags/internal/print/options/generic/optimizations/params.sh"

# Note: $1 is a boolean that indicates whether we're using GCC or Clang (true for GCC, false for Clang)
# Note: $2 is a boolean that indicates whether to print the non-standard optimizations or to disable them (true enables them, false disables them)
internal-print-options-generic() {
    internal-print-options-generic-standards-and-extended-features "$@"
    internal-print-options-generic-optimizations "$@"
    "$2" && internal-print-options-generic-optimizations-non-standard "$@"
    "$2" || internal-print-options-generic-optimizations-disable-non-standard "$@"

    # --param options are not supported by Clang, so we only print them if we're using GCC
    "$1" && internal-print-options-generic-optimizations-params "$@"

    internal-print-option -g0 # We specifically want to avoid debugging statements, as they clutter assembly output and make it harder to read
}

source "$(dirname "$0")/generate-flags/internal/print/options/x86.sh"

# $1 is a boolean that indicates whether we're on x86-64 or x86-32 (if true, we're on x86-64, if false, we're on x86-32)
# $2 is a boolean that indicates whether we're using GCC (true for GCC, false for Clang)
internal-do-x86-64() {
    internal-print-options-generic "$2" true
    internal-print-options-x86 "$1" "$2"
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
