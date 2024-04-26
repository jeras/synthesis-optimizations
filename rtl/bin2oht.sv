///////////////////////////////////////////////////////////////////////////////
// binary to one-hot conversion (one-hot decoder),
// generic version with padding
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
    input  logic [WIDTH_LOG-1:0] bin,
    output logic [WIDTH    -1:0] oht
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

        logic [POWER-1:0] tmp_vld;
        
        // zero extend the input vector
        assign tmp_vld = POWER'(oht);

        // the synthesis tool is expected to optimize out the logic for constant inputs
        bin2oht_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc (
            .bin (bin),
            .oht (tmp_vld)
        );

    end: extend

endmodule: bin2oht_tree
