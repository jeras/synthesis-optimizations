///////////////////////////////////////////////////////////////////////////////
// priority to thermometer conversion,
// implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2thr_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // direction: "LSB" - rightmost, "MSB" - leftmost
    parameter  string       DIRECTION = "LSB",
    // implementation (see `pry2thr_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] pry,  // priority
    output logic [WIDTH-1:0] thr,  // thermometer
    output logic             vld   // valid
);

    generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        pry2thr_base #(
            .WIDTH (WIDTH),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2thr (
            .pry (pry),
            .thr (thr),
            .vld (vld)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] [WIDTH/SPLIT-1:0] thr_sub;  // thermometer from sub-branches
        logic [SPLIT-1:0]                   vld_sub;  // valid   from sub-branches
        logic [SPLIT-1:0]                   thr_brn;  // thermometer from     branch

        // sub-branches
        pry2thr_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2thr_sub [SPLIT-1:0] (
            .pry (pry),
            .thr (thr_sub),
            .vld (vld_sub)
        );

        // branch
        pry2thr_base #(
            .WIDTH (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2thr_brn (
            .pry (vld_sub),
            .thr (thr_brn),
            .vld (vld)
        );

        // mask thermometer signals from sub-branches
        for (genvar i=0; i<SPLIT; i++) begin: mask
            assign thr[i*(WIDTH/SPLIT)+:(WIDTH/SPLIT)] = thr_brn[i] ? thr_sub[i] : '0;
        end: mask

    end: branch
    endgenerate

endmodule: pry2thr_tree
