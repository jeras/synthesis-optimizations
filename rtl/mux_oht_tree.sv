///////////////////////////////////////////////////////////////////////////////
// multiplexer with one-hot select,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_oht_tree #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `mux_oht_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] oht,              // one-hot select
    input  DAT_T             ary [WIDTH-1:0],  // data array
    output logic             vld,              // valid (OR reduced one-hot)
    output DAT_T             dat               // data selected
);

generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        mux_oht_base #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_oht (
            .oht (oht),
            .ary (ary),
            .vld (vld),
            .dat (dat)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] vld_oht;
        DAT_T             dat_ary [SPLIT-1:0];

        for (genvar i=0; i<SPLIT; i++) begin: sub

            // sub-branches
            mux_oht_tree #(
                .DAT_T (DAT_T),
                .WIDTH (WIDTH/SPLIT),
                .SPLIT (SPLIT),
                .IMPLEMENTATION (IMPLEMENTATION)
            ) mux_bin_sub (
                .oht (oht    [i*WIDTH/SPLIT+:WIDTH/SPLIT]),
                .ary (ary    [i*WIDTH/SPLIT+:WIDTH/SPLIT]),
                .vld (vld_oht[i]),
                .dat (dat_ary[i])
            );

        end: sub

        // branch
        mux_oht_base #(
            .DAT_T (DAT_T),
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_oht_brn (
            .oht (vld_oht),
            .ary (dat_ary),
            .vld (    vld),
            .dat (    dat)
        );

    end: branch
    endgenerate

endmodule: mux_oht_tree
