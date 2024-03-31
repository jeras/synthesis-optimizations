///////////////////////////////////////////////////////////////////////////////
// Magnitude comparator (unsigned) implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module magnitude_comparator_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `magnitude_comparator_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] i_a,
    input  logic [WIDTH-1:0] i_b,
    output logic             o_a,
    output logic             o_b
);

    // SPLIT to the power of logarithm of WIDTH base SPLIT
    localparam int unsigned POWER = SPLIT**(WIDTH_LOG/SPLIT_LOG);

    generate
    // if WIDTH is not a power of SPLIT
    if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] t_a;
        logic [POWER-1:0] t_b;
        
        // zero extend the input vector
        assign t_a = POWER'(i_a);
        assign t_b = POWER'(i_b);

        // the synthesis tool is expected to optimize out the logic for constant inputs
        magnitude_comparator_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) cmp [SPLIT-1:0] (
            .i_a (t_a),
            .i_b (t_b),
            .o_a (o_a),
            .o_b (o_b)
        );

    end: extend
    // leafs at the end of tree branches
    else if (WIDTH == SPLIT) begin: leaf

        // leaf
        magnitude_comparator_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) cmp (
            .i_a (i_a),
            .i_b (i_b),
            .o_a (o_a),
            .o_b (o_b)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        // tree signals
        logic [WIDTH/SPLIT-1:0] t_a;
        logic [WIDTH/SPLIT-1:0] t_b;

        // sub-branches
        magnitude_comparator_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) cmp_sub [SPLIT-1:0] (
            .i_a (i_a),
            .i_b (i_b),
            .o_a (t_a),
            .o_b (t_b)
        );

        // branch
        magnitude_comparator_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) cmp_brn (
            .i_a (t_a),
            .i_b (t_b),
            .o_a (o_a),
            .o_b (o_b)
        );

    end: branch
    endgenerate

endmodule: magnitude_comparator_tree
