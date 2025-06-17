internal-print-options-generic-optimizations-disable-non-standard-gcc-3-4() {
    internal-print-option -fno-fast-math

    internal-print-option -fmath-errno -fno-unsafe-math-optimizations -fno-finite-math-only -ftrapping-math -frounding-math
    "$1" && internal-print-option -fsignaling-nans
}

internal-print-options-generic-optimizations-disable-non-standard-gcc-4-0() {
    internal-print-options-generic-optimizations-disable-non-standard-gcc-3-4 "$@"
    internal-print-option -fno-cx-limited-range
}

internal-print-options-generic-optimizations-disable-non-standard-gcc-4-4() {
    internal-print-options-generic-optimizations-non-standard-gcc-4-0 "$@"
    internal-print-option -fno-associative-math -fno-reciprocal-math -fsigned-zeros
    internal-print-option -fno-cx-fortran-rules
}

internal-print-options-generic-optimizations-disable-non-standard-gcc-4-5() {
    internal-print-options-generic-optimizations-disable-non-standard-gcc-4-4 "$@"
    internal-print-option -fexcess-precision=standard
}

internal-print-options-generic-optimizations-disable-non-standard-gcc-4-6() {
    internal-print-options-generic-optimizations-disable-non-standard-gcc-4-5 "$@"
    internal-print-option -ffp-contract=on
}

internal-print-options-generic-optimizations-disable-non-standard-gcc-5() {
    internal-print-options-generic-optimizations-disable-non-standard-gcc-4-6 "$@"
    internal-print-option -fsemantic-interposition
}

internal-print-options-generic-optimizations-disable-non-standard-gcc-7() {
    internal-print-options-generic-optimizations-disable-non-standard-gcc-5 "$@"
    "$1" && internal-print-option -fno-fp-int-builtin-inexact
}

internal-print-options-generic-optimizations-disable-non-standard-gcc-10() {
    internal-print-options-generic-optimizations-disable-non-standard-gcc-7 "$@"
    internal-print-option -fno-allow-store-data-races
    # We do not set -fno-finite-loops here - let the language standard decide whether loops are finite or not
    # C++11 and later require that loops are finite, so setting -fno-finite-loops there would be going beyond what the standard requires
}

internal-print-options-generic-optimizations-disable-non-standard() {
    internal-print-options-generic-optimizations-disable-non-standard-gcc-10 "$@"
    "$1" && internal-print-option -fcx-method=stdc
    "$1" || internal-print-option -ffp-model=strict
    "$1" || internal-print-option -fhonor-nans
}
