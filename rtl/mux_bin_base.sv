///////////////////////////////////////////////////////////////////////////////
// multiplexer with binary select (priority multiplexer),
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_bin_base #(
    // data type
    parameter  type DAT_T = logic [4-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - index
)(
    input  logic [WIDTH_LOG-1:0] bin,              // binary select
    input  DAT_T                 ary [WIDTH-1:0],  // data array
    output DAT_T                 dat               // data selected
);

    generate
    case (IMPLEMENTATION)
        0:  // index
            always_comb
            begin: index
                dat = ary[bin];
            end: index
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: mux_bin_base
