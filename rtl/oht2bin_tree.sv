///////////////////////////////////////////////////////////////////////////////
// one-hot to binary conversion (one-hot encoder)
// implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module oht2bin_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `oht2bin_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH    -1:0] oht,  // one-hot
    output logic [WIDTH_LOG-1:0] bin,  // binary
    output logic                 vld   // valid
);

    // SPLIT to the power of logarithm of WIDTH base SPLIT
    localparam int unsigned POWER_LOG = WIDTH_LOG/SPLIT_LOG;
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        oht2bin_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) encoder (
            .oht (oht),
            .bin (bin),
            .vld (vld)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] bin_sub;  // binary from sub-branches
        logic [SPLIT-1:0]                           vld_sub;  // valid  from sub-branches
        logic                       [SPLIT_LOG-1:0] bin_brn;  // binary from     branch

        // sub-branches
        oht2bin_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_sub [SPLIT-1:0] (
            .oht (oht),
            .bin (bin_sub),
            .vld (vld_sub)
        );

        // branch
        oht2bin_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_brn (
            .oht (vld_sub),
            .bin (bin_brn),
            .vld (vld)
        );

        // multiplex sub-branches into branch
        assign bin = {bin_brn, bin_sub[bin_brn]};

    end: branch
    endgenerate

endmodule: oht2bin_tree
