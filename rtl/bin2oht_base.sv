///////////////////////////////////////////////////////////////////////////////
// binary to one-hot conversion (one-hot decoder),
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module bin2oht_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - loop
    // 1 - power
    // 2 - shift
)(
    input  logic                 vld,  // valid
    input  logic [WIDTH_LOG-1:0] bin,  // binary
    output logic [WIDTH    -1:0] oht   // one-hot
);

    generate
    case (IMPLEMENTATION)
        0:  // loop
            always_comb
            for (int unsigned i=0; i<WIDTH; i++) begin
                oht[i] = (i[WIDTH_LOG-1:0] == bin) ? vld : 1'b0;
            end
        1:  // power
            assign oht = vld ? 2 ** bin : '0;
        2:  // shift
            assign oht = WIDTH'(vld) << bin;
        default:  // parameter validation
            /* verilator lint_off USERFATAL */
            $fatal("Unsupported IMPLEMENTATION parameter value.");
            /* verilator lint_on USERFATAL */
    endcase
    endgenerate

endmodule: bin2oht_base
