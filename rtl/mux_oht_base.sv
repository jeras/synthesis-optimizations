///////////////////////////////////////////////////////////////////////////////
// multiplexer with one-hot select,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_oht_base #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - reduction
    // 1 - linear
)(
    input  logic [WIDTH-1:0] oht,              // one-hot select
    input  DAT_T             ary [0:WIDTH-1],  // data array
    output DAT_T             dat               // data selected
);

    generate
    case (IMPLEMENTATION)
        0:  // reduction
            always_comb
            begin: adder
                dat = '0;
                for (int unsigned i=0; i<WIDTH; i++) begin
                    dat |= oht[i] ? ary[i] : '0;
                end
            end: adder
        1:  // linear
            always_comb
            begin: linear
                dat = 'x;
                for (int unsigned i=0; i<WIDTH; i++) begin
                    dat = oht[i] ? ary[i] : dat;
                end
            end: linear
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: mux_oht_base
