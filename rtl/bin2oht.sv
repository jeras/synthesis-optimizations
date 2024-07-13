///////////////////////////////////////////////////////////////////////////////
// binary to one-hot conversion (one-hot decoder),
// generic version with cropping
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module bin2oht #(
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

    // SPLIT to the power of POWER_LOG (logarithm of WIDTH base SPLIT rounded up)
    localparam int unsigned POWER_LOG = WIDTH_LOG/SPLIT_LOG + (WIDTH_LOG%SPLIT_LOG>0 ? 1 : 0);
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // if SPLIT is not a power of 2
    if (SPLIT != (2**SPLIT_LOG)) begin: validation

        $error("Parameter SPLIT is not a power of 2.");

    end: validation
    // if WIDTH is not a power of SPLIT
    else if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] oht_tmp;
        
        bin2oht_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) bin2oht_tree (
            .vld (vld),
            .bin (bin),
            .oht (oht_tmp)
        );

        // crop the output vector
        assign oht = WIDTH'(oht_tmp);

    end: extend
    // width is a power of split
    else begin: exact

        bin2oht_tree #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) bin2oht_tree (
            .vld (vld),
            .bin (bin),
            .oht (oht)
        );

    end: exact
    endgenerate

endmodule: bin2oht
