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
    // direction: "LSB" - rightmost first, "MSB" - leftmost first
    parameter  string       DIRECTION = "LSB",
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

        pry2oht_bck_base #(
            .WIDTH (WIDTH),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht_bck (
            .pry (pry),
            .ena (ena),
            .oht (oht),
            .vld (vld)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0]                   vld_pry;  // valid   from sub-branches
        logic [SPLIT-1:0]                   oht_ena;  // one-hot from     branch

        // sub-branches
        pry2oht_bck_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht_bck_sub [SPLIT-1:0] (
            .pry (    pry),
            .ena (oht_ena),
            .oht (oht),
            .vld (vld_pry)
        );

        // branch
        pry2oht_bck_base #(
            .WIDTH (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht_bck_brn (
            .pry (vld_pry),
            .ena (    ena),
            .oht (oht_ena),
            .vld (vld)
        );

    end: branch
    endgenerate

endmodule: pry2oht_bck_tree
