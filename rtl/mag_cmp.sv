///////////////////////////////////////////////////////////////////////////////
// magnitude comparator (unsigned),
// generic version with padding
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mag_cmp #(
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

    // SPLIT to the power of logarithm of WIDTH base SPLIT
    localparam int unsigned POWER = SPLIT**(WIDTH_LOG/SPLIT_LOG);

    generate
    // if WIDTH is not a power of SPLIT
    if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] grt_tmp;
        logic [POWER-1:0] lst_tmp;
        
        // zero extend the input vector
        assign grt_tmp = POWER'(val);
        assign lst_tmp = POWER'(rfr);

        // the synthesis tool is expected to optimize out the logic for constant inputs
        mag_cmp_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mag_cmp (
            .val (grt_tmp),
            .rfr (lst_tmp),
            .grt (grt),
            .lst (lst)
        );

    end: extend
    else begin: exact

        // the synthesis tool is expected to optimize out the logic for constant inputs
        mag_cmp_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mag_cmp (
            .val (val),
            .rfr (rfr),
            .grt (grt),
            .lst (lst)
        );

    end: exact
    endgenerate

endmodule: mag_cmp
