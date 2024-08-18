#!/bin/sh

TOPS="\
    eql_cmp_tb \
    bin2oht_tb \
    oht2bin_tb \
    mux_oht_tb \
    mux_bin_tb \
    pry2thr_tb \
    pry2oht_tb \
    mag_cmp_tb
"

TOPS="pry2thr_tb"

for TOP in $TOPS
do
    verilator -j 0 --lint-only --timing --top $TOP -f ../files_rtl.lst -f ../files_tb.lst
#    verilator -j 0 --binary    --timing --top $TOP -f ../files_rtl.lst -f ../files_tb.lst -Wall
    verilator -j 0 --binary    --timing --top $TOP -f ../files_rtl.lst -f ../files_tb.lst --trace-fst
    obj_dir/V${TOP}
done