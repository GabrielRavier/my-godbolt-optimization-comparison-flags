internal-print-options-x86-gcc-3-4() {
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

internal-print-options-x86-gcc-4-4() {
    internal-print-options-x86-gcc-3-4 "$@"
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

internal-print-options-x86-gcc-4-5() {
    internal-print-options-x86-gcc-4-4 "$@"
    internal-print-option -mfma4 -mxop -mlwp -mmovbe -mcrc32
}

internal-print-options-x86-gcc-4-6() {
    internal-print-options-x86-gcc-4-5 "$@"
    internal-print-option -march=core-avx-i
    internal-print-option -mbmi -mrdrnd -mtbm -mfsgsbase -mf16c
    internal-print-option -mabi=sysv
}

internal-print-options-x86-gcc-4-7() {
    internal-print-options-x86-gcc-4-6 "$@"

    internal-print-option -march=core-avx2

    internal-print-option -mavx2
    internal-print-option -mbmi2 -mlzcnt
}

internal-print-options-x86-gcc-4-8() {
    internal-print-options-x86-gcc-4-7 "$@"
    internal-print-option -mfxsr -mxsave -mxsaveopt
    internal-print-option -mrdseed -madx -mrtm -mprfchw
    "$2" && internal-print-option -mhle
}

internal-print-options-x86-gcc-4-9-before-4-9-2() {
    internal-print-options-x86-gcc-4-8 "$@"

    internal-print-option -march=broadwell
    internal-print-option -mavx512f -mavx512cd
    internal-print-option -msha

    X86_OPTIONS_TUNE_CTRL_LIST='^lcp_stall,use_incdec,use_himode_fiop,use_simode_fiop,use_ffreep,ext_80387_constants'
}

internal-print-options-x86-gcc-4-9() {
    internal-print-options-x86-gcc-4-9-before-4-9-2 "$@"
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',^avoid_false_dep_for_bmi'
}

internal-print-options-x86-gcc-5-before-5-1() {
    internal-print-options-x86-gcc-4-9 "$@"
    internal-print-option -mavx512vl -mavx512bw -mavx512dq -mavx512ifma -mavx512vbmi
    internal-print-option -mclflushopt -mclwb
    internal-print-option -mxsavec -mxsaves
}

internal-print-options-x86-gcc-5() {
    internal-print-options-x86-gcc-5-before-5-1 "$@"
    internal-print-option -mmwaitx
}

internal-print-options-x86-gcc-6() {
    internal-print-options-x86-gcc-5 "$@"
    internal-print-option -march=skylake-avx512
    internal-print-option -mclzero -mpku
}

internal-print-options-x86-gcc-7() {
    internal-print-options-x86-gcc-6 "$@"
    internal-print-option -mavx512vpopcntdq
    "$2" && internal-print-option -m3dnowa
    internal-print-option -mrdpid -msgx
}

internal-print-options-x86-gcc-8() {
    internal-print-options-x86-gcc-7 "$@"

    internal-print-option -march=icelake-server

    internal-print-option -mavx512vbmi2 -mavx512bitalg -mavx512vnni
    internal-print-option -mmovdiri -mmovdir64b
    internal-print-option -mpconfig -mwbnoinvd -mgfni -mvaes -mvpclmulqdq -mshstk

    internal-print-option -mprefer-vector-width=512
}

internal-print-options-x86-gcc-9-before-9-4() {
    internal-print-options-x86-gcc-8 "$@"
    internal-print-option -mptwrite -mwaitpkg -mcldemote
}

internal-print-options-x86-gcc-9() {
    internal-print-options-x86-gcc-9-before-9-4 "$@"
    internal-print-option -march=tigerlake
}

internal-print-options-x86-gcc-10() {
    internal-print-options-x86-gcc-9 "$@"
    internal-print-option -mavx512bf16 -mavx512vp2intersect
    internal-print-option -menqcmd
}

internal-print-options-x86-gcc-11-before-11-3() {
    internal-print-options-x86-gcc-10 "$@"

    internal-print-option -march=x86-64-v4 # Seems like a good baseline

    internal-print-option -mavxvnni
    internal-print-option -mamx-tile -mamx-int8 -mamx-bf16
    internal-print-option -mkl -mwidekl
    internal-print-option -mtsxldtrk -mserialize -mhreset
    # -muintr is not supported for 32-bit code
    "$1" && internal-print-option -muintr

    "$2" && internal-print-option -mneeded
}

internal-print-options-x86-gcc-11() {
    internal-print-options-x86-gcc-11-before-11-3 "$@"
    "$2" && internal-print-option -mmwait
}

internal-print-options-x86-gcc-12-before-12-3() {
    internal-print-options-x86-gcc-11 "$@"

    internal-print-option -mavx512fp16

    "$2" && internal-print-option -mmove-max=512 -mstore-max=512

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_gather_2parts,use_gather_4parts'
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',avx512_move_by_pieces,avx512_store_by_pieces'
}

internal-print-options-x86-gcc-12-before-12-4() {
    internal-print-options-x86-gcc-12-before-12-3 "$@"

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_scatter_2parts,use_scatter_4parts'
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',^avoid_fma512_chains'
}

internal-print-options-x86-gcc-12() {
    internal-print-options-x86-gcc-12-before-12-4 "$@"

    # Note: use_gather_8parts and use_scatter_8parts appear to not be supported in GCC 13.1 and GCC 13.2, even though GCC 12.4 supports them...
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_gather_8parts,use_scatter_8parts'
}

internal-print-options-x86-gcc-13-before-13-3() {
    internal-print-options-x86-gcc-12 "$@"

    internal-print-option -mavxifma -mavxvnniint8 -mavxneconvert
    internal-print-option -mamx-fp16 -mamx-complex
    internal-print-option -mcmpccxadd -mprefetchi -mraoint

    # Remove use_gather_8parts and use_scatter_8parts, as they are not supported in GCC 13.1 and GCC 13.2
    X86_OPTIONS_TUNE_CTRL_LIST="$(echo "$X86_OPTIONS_TUNE_CTRL_LIST" | sed 's/,use_gather_8parts//;s/,use_scatter_8parts//')"

    "$2" && internal-print-option --param=x86-stv-max-visits=1000000 # 10000 at -O3 (1000000 is the maximum value)
}

internal-print-options-x86-gcc-13() {
    internal-print-options-x86-gcc-13-before-13-3 "$@"

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',use_gather_8parts,use_scatter_8parts' # Was already added in GCC 12 but removed in GCC 13.1 and GCC 13.2, so add it back here
}

internal-print-options-x86-gcc-14() {
    internal-print-options-x86-gcc-13 "$@"

    internal-print-option -mavxvnniint16
    internal-print-option -msm3 -msm4
    internal-print-option -mavx10.1 # -mavx10.1-256 -mavx10.1-512 # -mavx10.1-256 and -mavx10.1-512 are removed in GCC 16, it seems
    internal-print-option -msha512 -musermsr
    # -mapxf is not supported for 32-bit code
    "$1" && internal-print-option -mapxf

    "$2" && internal-print-option -mnoreturn-no-callee-saved-registers
}

internal-print-options-x86-gcc-15()
{
    internal-print-options-x86-gcc-14 "$@"

    internal-print-option -mavx10.2
    internal-print-option -mamx-avx512 -mamx-tf32 -mamx-transpose -mamx-fp8
    internal-print-option -mmovrs -mamx-movrs

    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST",'^avoid_false_dep_for_tzcnt,^avoid_false_dep_for_bls'
    X86_OPTIONS_TUNE_CTRL_LIST="$X86_OPTIONS_TUNE_CTRL_LIST"',avx512_two_epilogues'
}

# $1 is a boolean that indicates whether we're on x86-64 or x86-32 (if true, we're on x86-64, if false, we're on x86-32)
# $2 is a boolean that indicates whether we're using GCC (true for GCC, false for Clang)
internal-print-options-x86() {
    internal-print-options-x86-gcc-15 "$@"

    # If X86_OPTIONS_TUNE_CTRL_LIST is set (and we're using GCC), set the -mtune-ctrl option to it
    [ -n "${X86_OPTIONS_TUNE_CTRL_LIST:-}" ] && "$2" && internal-print-option -mtune-ctrl="$X86_OPTIONS_TUNE_CTRL_LIST"

    # Print -m64 if we're on x86-64, or -m32 if we're on x86-32
    "$1" && internal-print-option -m64; "$1" || internal-print-option -m32

    # position-independent code is a bit awkward to handle (it seems to output assembly output that llvm-mca has trouble parsing, for instance) and also makes code a bit longer, so disable it
    internal-print-option -fno-pie
}
