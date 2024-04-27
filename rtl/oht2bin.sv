///////////////////////////////////////////////////////////////////////////////
// one-hot to binary conversion (one-hot encoder)
// generic version with padding
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module oht2bin #(
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
    // if SPLIT is not a power of 2
    if (SPLIT != (2**SPLIT_LOG)) begin: validation

        $error("Parameter SPLIT is not a power of 2.");

    end: validation
    // if WIDTH is not a power of SPLIT
    else if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] oht_tmp;
        
        // zero extend the input vector
        assign oht_tmp = POWER'(oht);

        // the synthesis tool is expected to optimize out the logic for constant inputs
        oht2bin_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc (
            .oht (oht_tmp),
            .bin (bin),
            .vld (vld)
        );

    end: extend
    // width is a power of split
    else begin: exact

        oht2bin_tree #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) encoder (
            .oht (oht),
            .bin (bin),
            .vld (vld)
        );

    end: exact
    endgenerate

endmodule: oht2bin
