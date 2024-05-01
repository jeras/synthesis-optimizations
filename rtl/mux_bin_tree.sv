///////////////////////////////////////////////////////////////////////////////
// multiplexer with binary select,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_bin_tree #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `bin2oht_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH_LOG-1:0] bin,              // binary select
    input  DAT_T                 ary [WIDTH-1:0],  // data array
    output DAT_T                 dat               // data selected
);

generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        mux_bin_base #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_bin (
            .bin (bin),
            .ary (ary),
            .dat (dat)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        DAT_T             dat_ary [SPLIT-1:0];

        for (genvar i=0; i<SPLIT; i++) begin: sub

            // sub-branches
            mux_bin_tree #(
                .DAT_T (DAT_T),
                .WIDTH (WIDTH/SPLIT),
                .SPLIT (SPLIT),
                .IMPLEMENTATION (IMPLEMENTATION)
            ) mux_bin_sub (
                .bin (bin    [WIDTH_LOG-1-SPLIT_LOG:0]),
                .ary (ary    [i*WIDTH/SPLIT+:WIDTH/SPLIT]),
                .dat (dat_ary[i])
            );

        end: sub

        // branch
        mux_bin_base #(
            .DAT_T (DAT_T),
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_bin_brn (
            .bin (    bin[WIDTH_LOG-1-:SPLIT_LOG]),
            .ary (dat_ary),
            .dat (    dat)
        );

    end: branch
    endgenerate

endmodule: mux_bin_tree
