#!/bin/sh

TOPS="\
    eql_cmp_tb \
    bin2oht_tb \
    oht2bin_tb \
    mux_oht_tb \
    mux_bin_tb \
    pry2oht_tb \
    mag_cmp_tb
"

for TOP in $TOPS
do
    verilator --lint-only --timing --top $TOP -f ../files_rtl.lst -f ../files_tb.lst
done