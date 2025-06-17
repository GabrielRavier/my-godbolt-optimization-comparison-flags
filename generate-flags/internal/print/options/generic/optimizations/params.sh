internal-print-options-generic-optimizations-params-gcc-3-4() {
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

internal-print-options-generic-optimizations-params-gcc-4-0() {
    internal-print-options-generic-optimizations-params-gcc-3-4 "$@"

    internal-print-option --param=max-goto-duplication-insns=8888 # 8 at -O3
    internal-print-option --param=max-iterations-to-track=10000000 # 1000 at -O3
    internal-print-option --param=max-sched-region-insns=200000 # 100 at -O3

    internal-print-option --param=iv-consider-all-candidates-bound=40000 # 40 at -O3
    internal-print-option --param=iv-max-considered-uses=250000 # 250 at -O3

    internal-print-option --param=scev-max-expr-size=100000 # 100 at -O3
    internal-print-option --param=sms-dfa-history=16 # 0 at -O3
}

internal-print-options-generic-optimizations-params-gcc-4-1() {
    internal-print-options-generic-optimizations-params-gcc-4-0 "$@"
    internal-print-option --param=max-fields-for-field-sensitive=100000 # 100 at -O3
    internal-print-option --param=max-cse-insns=1000000 # 1000 at -O3
}

internal-print-options-generic-optimizations-params-gcc-4-4() {
    internal-print-options-generic-optimizations-params-gcc-4-1 "$@"

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

internal-print-options-generic-optimizations-params-gcc-4-5() {
    internal-print-options-generic-optimizations-params-gcc-4-4 "$@"
    internal-print-option --param=max-early-inliner-iterations=1000 # 1 at -O3
    internal-print-option --param=max-vartrack-size=1000000000 # 50000000 at -O3 (50000000000 would be far above the maximum of 2147483647, and we use less than half of that just in case there could be overflow issues)
    internal-print-option --param=graphite-max-nb-scop-params=10000 # 10 at -O3
}

internal-print-options-generic-optimizations-params-gcc-4-6() {
    internal-print-options-generic-optimizations-params-gcc-4-5 "$@"

    internal-print-option --param=max-hoist-depth=300000 # 300 at -O3
    internal-print-option --param=max-dse-active-local-stores=5000000 # 5000 at -O3

    internal-print-option --param=scev-max-expr-complexity=10000 # 10 at -O3
    internal-print-option --param=cxx-max-namespaces-for-diagnostic-help=1000000 # 1000 at -O3
}

internal-print-options-generic-optimizations-params-gcc-4-7() {
    internal-print-options-generic-optimizations-params-gcc-4-6 "$@"

    internal-print-option --param=max-modulo-backtrack-attempts=40000 # 40 at -O3
    internal-print-option --param=max-tracked-strlens=10000000 # 10000 at -O3
    internal-print-option --param=max-vartrack-expr-depth=12000 # 12 at -O3

    internal-print-option --param=max-tail-merge-comparisons=10000 # 10 at -O3
    internal-print-option --param=max-tail-merge-iterations=2000 # 2 at -O3

    internal-print-option --param=loop-max-datarefs-for-datadeps=1000000 # 1000 at -O3
    internal-print-option --param=ipa-cp-value-list-size=8000 # 8 at -O3
}

internal-print-options-generic-optimizations-params-gcc-4-8-before-4-8-3() {
    internal-print-options-generic-optimizations-params-gcc-4-7 "$@"

    internal-print-option --param=max-slsr-cand-scan=999999 # 50 at -O3 (999999 is the maximum value)
    internal-print-option --param=sccvn-max-alias-queries-per-access=1000000 # 1000 at -O3
    internal-print-option --param=max-vartrack-reverse-op-size=50000 # 50 at -O3

    internal-print-option --param=sched-pressure-algorithm=2 # 1 at -O3 (note: 2 just means a different algorithm that should be better so long as the machine has "a regular register file and accurate register pressure classes")
}

internal-print-options-generic-optimizations-params-gcc-4-8() {
    internal-print-options-generic-optimizations-params-gcc-4-8-before-4-8-3 "$@"
    internal-print-option --param=uninit-control-dep-attempts=65536 # 100 at -O3
}

internal-print-options-generic-optimizations-params-gcc-4-9() {
    internal-print-options-generic-optimizations-params-gcc-4-8 "$@"
    internal-print-option --param=lra-max-considered-reload-pseudos=500000 # 500 at -O3
}

internal-print-options-generic-optimizations-params-gcc-5() {
    internal-print-options-generic-optimizations-params-gcc-4-9 "$@"
    internal-print-option --param=ipa-max-aa-steps=25000000 # 25000 at -O3
}

internal-print-options-generic-optimizations-params-gcc-6() {
    internal-print-options-generic-optimizations-params-gcc-5 "$@"

    internal-print-option --param=graphite-max-arrays-per-scop=100000 # 100 at -O3

    internal-print-option --param=max-ssa-name-query-depth=10 # 3 at -O3 (10 is the maximum value)
    internal-print-option --param=max-speculative-devirt-maydefs=50000 # 50 at -O3
    internal-print-option --param=max-pow-sqrt-depth=32 # 5 at -O3
    internal-print-option --param=max-isl-operations=350000000 # 350000 at -O3
}

internal-print-options-generic-optimizations-params-gcc-7() {
    internal-print-options-generic-optimizations-params-gcc-6 "$@"
    internal-print-option --param=max-stores-to-merge=65536 # 64 at -O3 (65536 is the maximum value)
    internal-print-option --param=dse-max-object-size=262144 # 256 at -O3
}

internal-print-options-generic-optimizations-params-gcc-8-before-8-5() {
    internal-print-options-generic-optimizations-params-gcc-7 "$@"
    internal-print-option --param=max-debug-marker-count=100000000 # 100000 at -O3
}

internal-print-options-generic-optimizations-params-gcc-8() {
    internal-print-options-generic-optimizations-params-gcc-8-before-8-5 "$@"
    internal-print-option --param=sra-max-propagations=32768 # 32 at -O3
}

internal-print-options-generic-optimizations-params-gcc-9-before-9-2() {
    internal-print-options-generic-optimizations-params-gcc-8 "$@" | sed 's/--param=sra-max-propagations=[0-9]\+ //g' # sra-max-propagations is not supported in GCC 9.1 to GCC 9.3, so remove it
    internal-print-option --param=dse-max-alias-queries-per-store=262144 # 256 at -O3
}

internal-print-options-generic-optimizations-params-gcc-9-before-9-4() {
    internal-print-options-generic-optimizations-params-gcc-9-before-9-2 "$@"
    internal-print-option --param=ssa-name-def-chain-limit=524288 # 512 at -O3
}

internal-print-options-generic-optimizations-params-gcc-9() {
    internal-print-options-generic-optimizations-params-gcc-9-before-9-4 "$@"
    internal-print-option --param=sra-max-propagations=32768 # 32 at -O3 # Was already added in GCC 8, but removed in GCC 9.1 to GCC 9.3, so add it back here
}

internal-print-options-generic-optimizations-params-gcc-10() {
    internal-print-options-generic-optimizations-params-gcc-9 "$@"

    internal-print-option --param=ipa-sra-max-replacements=16 # 8 at -O3 (16 is the maximum value)
    internal-print-option --param=ipa-max-switch-predicate-bounds=5000 # 5 at -O3
    internal-print-option --param=ipa-max-param-expr-ops=10000 # 10 at -O3

    internal-print-option --param=max-find-base-term-values=200000 # 200 at -O3
}

internal-print-options-generic-optimizations-params-gcc-11() {
    internal-print-options-generic-optimizations-params-gcc-10 "$@"

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

internal-print-options-generic-optimizations-params-gcc-12() {
    internal-print-options-generic-optimizations-params-gcc-11 "$@"
    internal-print-option --param=modref-max-adjustments=254 # 8 at -O3 (254 is the maximum value)
    internal-print-option --param=relation-block-limit=9999 # 200 at -O3 (9999 is the maximum value)
}

internal-print-options-generic-optimizations-params-gcc-13-before-13-3() {
    internal-print-options-generic-optimizations-params-gcc-12 "$@"

    internal-print-option --param=vect-max-layout-candidates=32768 # 32 at -O3
    internal-print-option --param=max-jump-thread-paths=65536 # 64 at -O3 (65536 is the maximum value)
    internal-print-option --param=ira-simple-lra-insn-threshold=1000000 # 1000 at -O3
    internal-print-option --param=ranger-recompute-depth=100 # 5 at -O3 (100 is the maximum value)
}

internal-print-options-generic-optimizations-params-gcc-13() {
    internal-print-options-generic-optimizations-params-gcc-13-before-13-3 "$@"
    internal-print-option --param=uninit-max-chain-len=128 # 8 at -O3 (128 is the maximum value)
    internal-print-option --param=uninit-max-num-chains=128 # 8 at -O3 (128 is the maximum value)
}

internal-print-options-generic-optimizations-params-gcc-14() {
    internal-print-options-generic-optimizations-params-gcc-13 "$@"
    internal-print-option --param=vrp-sparse-threshold=3000000 # 3000 at -O3
    internal-print-option --param=vrp-switch-limit=50000 # 50 at -O3
}

internal-print-options-generic-optimizations-params-gcc-15() {
    internal-print-options-generic-optimizations-params-gcc-14 "$@"
    internal-print-option --param=max-combine-search-insns=3000000 # 3000 at -O3
    internal-print-option --param=vrp-block-limit=150000000 # 150000 at -O3
    internal-print-option --param=transitive-relations-work-bound=9999 # 256 at -O3 (9999 is the maximum value)
}

internal-print-options-generic-optimizations-params() {
    internal-print-options-generic-optimizations-params-gcc-15 "$@"
}
