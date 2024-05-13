///////////////////////////////////////////////////////////////////////////////
// priority to thermometer conversion,
// generic version with padding
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2thr #(
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

    // calculate `$ceil($ln(WIDTH), $ln(SPLIT))` using just integers
    function int unsigned clogbase (int unsigned number, base);
        clogbase = 0;
        while (base**clogbase < number)  clogbase++;
    endfunction: clogbase

    // SPLIT to the power of POWER_LOG (logarithm of WIDTH base SPLIT rounded up)
    localparam int unsigned POWER_LOG = clogbase(WIDTH, SPLIT);
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // if WIDTH is not a power of SPLIT
    if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] pry_tmp;
        logic [POWER-1:0] thr_tmp;
        
        // zero extend the input vector
        assign pry_tmp = POWER'(pry);

        // the synthesis tool is expected to optimize out the logic for constant inputs
        pry2thr_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2thr_tree (
            .pry (pry_tmp),
            .thr (thr_tmp),
            .vld (vld)
        );

        // crop zero extension from output vector
        assign thr = WIDTH'(thr_tmp);

    end: extend
    // width is a power of split
    else begin: exact

        pry2thr_tree #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) pry2thr_tree (
            .pry (pry),
            .thr (thr),
            .vld (vld)
        );

    end: exact
    endgenerate

endmodule: pry2thr
