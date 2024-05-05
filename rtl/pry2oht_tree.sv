///////////////////////////////////////////////////////////////////////////////
// priority (rightmost) to one-hot conversion,
// implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2oht_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // direction: "LSB" - rightmost, "MSB" - leftmost
    parameter  string       DIRECTION = "LSB",
    // implementation (see `pry2oht_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] pry,  // priority
    output logic [WIDTH-1:0] oht,  // one-hot
    output logic             vld   // valid
);

    generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        pry2oht_base #(
            .WIDTH (WIDTH),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht (
            .pry (pry),
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
        pry2oht_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht_sub [SPLIT-1:0] (
            .pry (pry),
            .oht (oht_sub),
            .vld (vld_sub)
        );

        // branch
        pry2oht_base #(
            .WIDTH (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2oht_brn (
            .pry (vld_sub),
            .oht (oht_brn),
            .vld (vld)
        );

        // mask one-hot signals from sub-branches
        for (genvar i=0; i<SPLIT; i++) begin: mask
            assign oht[i*(WIDTH/SPLIT)+:(WIDTH/SPLIT)] = oht_brn[i] ? oht_sub[i] : '0;
        end: mask

    end: branch
    endgenerate

endmodule: pry2oht_tree
