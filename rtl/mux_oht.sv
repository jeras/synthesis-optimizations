///////////////////////////////////////////////////////////////////////////////
// multiplexer with one-hot select,
// generic version with padding
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_oht #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `bin2oht_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] oht,              // one-hot select
    input  DAT_T             ary [0:WIDTH-1],  // data array
    output DAT_T             dat               // data selected
);

    // SPLIT to the power of logarithm of WIDTH base SPLIT
    localparam int unsigned POWER_LOG = WIDTH_LOG/SPLIT_LOG;
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // if WIDTH is not a power of SPLIT
    if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] oht_tmp;
        DAT_T             ary_tmp [0:WIDTH-1];
        
        // zero extend the one-hot vector
        assign oht_tmp = POWER'(oht);
        // don't care extend the data array
        always_comb
        for (int unsigned i=0; i<POWER; i++) begin
            if (i<WIDTH)  ary_tmp[i] = ary[i];
        end

        // the synthesis tool is expected to optimize out the logic for constant inputs
        mux_oht_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_oht (
            .oht (oht_tmp),
            .ary (ary_tmp),
            .dat (dat)
        );

    end: extend
    // width is a power of split
    else begin: exact

        mux_oht_tree #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_oht (
            .oht (oht),
            .ary (ary),
            .dat (dat)
        );

    end: exact
    endgenerate

endmodule: mux_oht
