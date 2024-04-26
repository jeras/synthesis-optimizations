///////////////////////////////////////////////////////////////////////////////
// binary to one-hot conversion (one-hot decoder),
// implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module bin2oht_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `bin2oht_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH_LOG-1:0] bin,
    output logic [WIDTH    -1:0] oht
);

    // SPLIT to the power of logarithm of WIDTH base SPLIT
    localparam int unsigned POWER_LOG = WIDTH_LOG/SPLIT_LOG;
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        bin2oht_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) decoder (
            .oht (oht),
            .bin (bin)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx;
        logic                       [SPLIT_LOG-1:0] brn_idx;

        // sub-branches
        bin2oht_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_sub [SPLIT-1:0] (
            .oht (oht),
            .bin (sub_idx),
        );

        // branch
        bin2oht_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_brn (
            .oht (sub_vld),
            .bin (brn_idx),
        );

        // multiplex sub-branches into branch
        assign bin = {brn_idx, sub_idx[brn_idx]};

    end: branch
    endgenerate

endmodule: bin2oht_tree
