///////////////////////////////////////////////////////////////////////////////
// magnitude comparator (unsigned),
// implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mag_cmp_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `mag_cmp_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] val,  // value
    input  logic [WIDTH-1:0] rfr,  // reference
    output logic             grt,  // greater than
    output logic             lst   // less    than
);

    generate
    // leafs at the end of tree branches
    if (WIDTH == SPLIT) begin: leaf

        // leaf
        mag_cmp_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mag_cmp (
            .val (val),
            .rfr (rfr),
            .grt (grt),
            .lst (lst)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        // tree signals
        logic [WIDTH/SPLIT-1:0] grt_val;  // greater than used as value
        logic [WIDTH/SPLIT-1:0] lst_rfr;  // less    than used as reference

        // sub-branches
        mag_cmp_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mag_cmp_sub [SPLIT-1:0] (
            .val (val),
            .rfr (rfr),
            .grt (grt_val),
            .lst (lst_rfr)
        );

        // branch
        mag_cmp_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mag_cmp_brn (
            .val (grt_val),
            .rfr (lst_rfr),
            .grt (grt),
            .lst (lst)
        );

    end: branch
    endgenerate

endmodule: mag_cmp_tree
