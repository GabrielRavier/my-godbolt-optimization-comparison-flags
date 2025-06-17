# Options that make the compiler generate code that is as fast as possible, even if it means breaking some standards or making the code non-portable
internal-print-options-generic-optimizations-non-standard-gcc-3-4() {
    internal-print-option -ffast-math # The stuff enabled by -Ofast, used instead of -Ofast because Clang deprecated -Ofast

    "$1" && internal-print-option -fno-float-store
    internal-print-option -fno-math-errno -funsafe-math-optimizations -ffinite-math-only -fno-trapping-math -fno-rounding-math
    "$1" && internal-print-option -fno-signaling-nans
}

internal-print-options-generic-optimizations-non-standard-gcc-4-0() {
    internal-print-options-generic-optimizations-non-standard-gcc-3-4 "$@"
    internal-print-option -fcx-limited-range
}

internal-print-options-generic-optimizations-non-standard-gcc-4-4() {
    internal-print-options-generic-optimizations-non-standard-gcc-4-0 "$@"
    internal-print-option -fassociative-math -freciprocal-math -fno-signed-zeros

    # internal-print-option -fcx-fortran-rules # -fcx-fortran-rules actually pessimizes code as compared to -fcx-limited-range, so we don't use it (thanks Clang for the warning lol)
}

internal-print-options-generic-optimizations-non-standard-gcc-4-5() {
    internal-print-options-generic-optimizations-non-standard-gcc-4-4 "$@"
    internal-print-option -fexcess-precision=fast
}

internal-print-options-generic-optimizations-non-standard-gcc-4-6() {
    internal-print-options-generic-optimizations-non-standard-gcc-4-5 "$@"
    internal-print-option -ffp-contract=fast
}

internal-print-options-generic-optimizations-non-standard-gcc-5() {
    internal-print-options-generic-optimizations-non-standard-gcc-4-6 "$@"
    internal-print-option -fno-semantic-interposition # Only added in GCC 5 but is also part of the stuff enabled by -Ofast (see also above comment on using this instead of -Ofast)
}

internal-print-options-generic-optimizations-non-standard-gcc-7() {
    internal-print-options-generic-optimizations-non-standard-gcc-5 "$@"
    "$1" && internal-print-option -ffp-int-builtin-inexact
}

internal-print-options-generic-optimizations-non-standard-gcc-10() {
    internal-print-options-generic-optimizations-non-standard-gcc-7 "$@"
    "$1" && internal-print-option -fallow-store-data-races # Only added in GCC 10 but is also part of the stuff enabled by -Ofast (see also above comment on using this instead of -Ofast)
    internal-print-option -ffinite-loops
}

internal-print-options-generic-optimizations-non-standard() {
    internal-print-options-generic-optimizations-non-standard-gcc-10 "$@"
    "$1" && internal-print-option -fcx-method=limited-range
    "$1" || internal-print-option -ffp-model=aggressive
    "$1" || internal-print-option -fno-honor-nans
}
