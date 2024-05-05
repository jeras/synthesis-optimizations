///////////////////////////////////////////////////////////////////////////////
// multiplexer with binary select (priority multipleser),
// generic version with padding
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_bin #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `mux_bin_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH_LOG-1:0] bin,              // binary select
    input  DAT_T                 ary [WIDTH-1:0],  // data array
    output DAT_T                 dat               // data selected
);

    // SPLIT to the power of POWER_LOG (logarithm of WIDTH base SPLIT rounded up)
    localparam int unsigned POWER_LOG = WIDTH_LOG/SPLIT_LOG + (WIDTH_LOG%SPLIT_LOG ? 1 : 0);
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // if SPLIT is not a power of 2
    if (SPLIT != (2**SPLIT_LOG)) begin: validation

        $error("Parameter SPLIT is not a power of 2.");

    end: validation
    // if WIDTH is not a power of SPLIT
    else if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] oht_tmp;
        DAT_T             ary_tmp [WIDTH-1:0];
        
        // zero extend the binary vector
        assign oht_tmp = POWER'(bin);
        // don't care extend the data array
        always_comb
        for (int unsigned i=0; i<POWER; i++) begin
            if (i<WIDTH)  ary_tmp[i] = ary[i];
        end

        // the synthesis tool is expected to optimize out the logic for constant inputs
        mux_bin_tree #(
            .DAT_T (DAT_T),
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_bin_tree (
            .bin (oht_tmp),
            .ary (ary_tmp),
            .dat (dat    )
        );

    end: extend
    // width is a power of split
    else begin: exact

        mux_bin_tree #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_bin_tree (
            .bin (bin),
            .ary (ary),
            .dat (dat)
        );

    end: exact
    endgenerate

endmodule: mux_bin
