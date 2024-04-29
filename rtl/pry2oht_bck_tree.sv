///////////////////////////////////////////////////////////////////////////////
// priority (rightmost) to one-hot conversion,
// backward tree propagation,
// implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2oht_bck_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `pry2oht_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] pry,  // priority
    input  logic             ena,  // enable
    output logic [WIDTH-1:0] oht,  // one-hot
    output logic             vld   // valid
);

    generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        pry2oht_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht (
            .pry (pry),
            .ena (ena),
            .oht (oht),
            .vld (vld)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] [WIDTH/SPLIT-1:0] oht_sub;  // one-hot from sub-branches
        logic [SPLIT-1:0]                   vld_sub;  // valid   from sub-branches
        logic [SPLIT-1:0]                   oht_brn;  // one-hot from     branch

        // sub-branches
        pry2oht_bck_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht_sub [SPLIT-1:0] (
            .pry (pry),
            .ena (oht_brn),
            .oht (oht_sub),
            .vld (vld_sub)
        );

        // branch
        pry2oht_bck_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht_brn (
            .pry (vld_sub),
            .ena (ena),
            .oht (oht_brn),
            .vld (vld)
        );

    end: branch
    endgenerate

endmodule: pry2oht_bck_tree
