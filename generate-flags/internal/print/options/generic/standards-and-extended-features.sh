# Options to make the compiler accept as much C++ code as possible (even invalid/non-compliant code or code that uses extensions)
internal-print-options-generic-standards-and-extended-features-gcc-3-4() {
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

internal-print-options-generic-standards-and-extended-features-gcc-4-4() {
    internal-print-options-generic-standards-and-extended-features-gcc-3-4 "$@"

    internal-print-option -std=gnu++0x

    internal-print-option -flax-vector-conversions
    internal-print-option -fopenmp
}

internal-print-options-generic-standards-and-extended-features-gcc-4-5() {
    internal-print-options-generic-standards-and-extended-features-gcc-4-4 "$@"
    internal-print-option -ftemplate-depth=900000
}

internal-print-options-generic-standards-and-extended-features-gcc-4-7() {
    internal-print-options-generic-standards-and-extended-features-gcc-4-5 "$@"
    "$1" && internal-print-option -fgnu-tm
}

internal-print-options-generic-standards-and-extended-features-gcc-4-8() {
    internal-print-options-generic-standards-and-extended-features-gcc-4-7 "$@"
    internal-print-option -std=gnu++1y
    "$1" && internal-print-option -fext-numeric-literals
}

internal-print-options-generic-standards-and-extended-features-gcc-4-9() {
    internal-print-options-generic-standards-and-extended-features-gcc-4-8 "$@"
    internal-print-option -fopenmp-simd
}

internal-print-options-generic-standards-and-extended-features-gcc-5() {
    internal-print-options-generic-standards-and-extended-features-gcc-4-9 "$@"
    internal-print-option -std=gnu++1z
    internal-print-option -fopenacc
}

internal-print-options-generic-standards-and-extended-features-gcc-8() {
    internal-print-options-generic-standards-and-extended-features-gcc-5 "$@"
    internal-print-option -std=gnu++2a
}

internal-print-options-generic-standards-and-extended-features-gcc-10() {
    internal-print-options-generic-standards-and-extended-features-gcc-8 "$@"
    "$1" && internal-print-option -fcoroutines
}

internal-print-options-generic-standards-and-extended-features-gcc-11() {
    internal-print-options-generic-standards-and-extended-features-gcc-10 "$@"
    internal-print-option -std=gnu++2b
}

internal-print-options-generic-standards-and-extended-features-gcc-13() {
    internal-print-options-generic-standards-and-extended-features-gcc-11 "$@"
    "$1" && internal-print-option -fcontracts
}

internal-print-options-generic-standards-and-extended-features-gcc-14() {
    internal-print-options-generic-standards-and-extended-features-gcc-13 "$@"
    internal-print-option -std=gnu++2c
}

internal-print-options-generic-standards-and-extended-features-gcc-15() {
    internal-print-options-generic-standards-and-extended-features-gcc-14 "$@"
    internal-print-option -fmodules
}

internal-print-options-generic-standards-and-extended-features() {
    internal-print-options-generic-standards-and-extended-features-gcc-15 "$@"
}
