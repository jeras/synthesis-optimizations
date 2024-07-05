///////////////////////////////////////////////////////////////////////////////
// multiplexer with priority select,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_pry_tree #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // implementation (see `mux_pry_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] pry,              // priority select
    input  DAT_T             ary [WIDTH-1:0],  // data array
    output logic             vld,              // valid (OR reduced priority)
    output DAT_T             dat               // data selected
);

generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        mux_pry_base #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_pry (
            .pry (pry),
            .ary (ary),
            .vld (vld),
            .dat (dat)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] vld_pry;
        DAT_T             dat_ary [SPLIT-1:0];

        for (genvar i=0; i<SPLIT; i++) begin: sub

            // sub-branches
            mux_pry_tree #(
                .DAT_T (DAT_T),
                .WIDTH (WIDTH/SPLIT),
                .SPLIT (SPLIT),
                .IMPLEMENTATION (IMPLEMENTATION)
            ) mux_bin_sub (
                .pry (pry    [i*WIDTH/SPLIT+:WIDTH/SPLIT]),
                .ary (ary    [i*WIDTH/SPLIT+:WIDTH/SPLIT]),
                .vld (vld_pry[i]),
                .dat (dat_ary[i])
            );

        end: sub

        // branch
        mux_pry_base #(
            .DAT_T (DAT_T),
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_pry_brn (
            .pry (vld_pry),
            .ary (dat_ary),
            .vld (    vld),
            .dat (    dat)
        );

    end: branch
    endgenerate

endmodule: mux_pry_tree
