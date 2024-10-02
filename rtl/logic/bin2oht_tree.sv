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
    input  logic                 vld,  // valid
    input  logic [WIDTH_LOG-1:0] bin,  // binary
    output logic [WIDTH    -1:0] oht   // one-hot
);

    generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        bin2oht_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) bin2oht (
            .vld (vld),
            .bin (bin),
            .oht (oht)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic           [SPLIT    -1:0] oht_brn;
        logic           [SPLIT_LOG-1:0] bin_brn;
        logic [WIDTH_LOG-SPLIT_LOG-1:0] bin_sub;

        // multiplex sub-branches into branch
        assign {bin_brn, bin_sub} = bin;

        // branch
        bin2oht_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) bin2oht_brn (
            .vld (vld),
            .bin (bin_brn),
            .oht (oht_brn)
        );

        // sub-branches
        bin2oht_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) bin2oht_sub [SPLIT-1:0] (
            .vld (oht_brn),
            .bin (bin_sub),
            .oht (oht)
        );

    end: branch
    endgenerate

endmodule: bin2oht_tree
