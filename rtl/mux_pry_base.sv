///////////////////////////////////////////////////////////////////////////////
// multiplexer with priority select,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_pry_base #(
    // data type
    parameter  type DAT_T = logic [4-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // direction: "LSB" - rightmost first, "MSB" - leftmost first
    parameter  string       DIRECTION = "LSB",
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - priority
)(
    input  logic [WIDTH-1:0] pry,              // priority select
    input  DAT_T             ary [WIDTH-1:0],  // data array
    output logic             vld,              // valid (OR reduced priority)
    output DAT_T             dat               // data selected
);

    generate
    case (IMPLEMENTATION)
        0:  // priority
            case (DIRECTION)
            "LSB":
                always_comb
                begin: lsb
                    dat = 'x;
                    vld = 1'b0;
                    for (int unsigned i=0; i<WIDTH; i++) begin
                        vld = pry[i] ? 1'b1   : vld;
                        dat = pry[i] ? ary[i] : dat;
                    end
                end: lsb
            "MSB":
                always_comb
                begin: msb
                    dat = 'x;
                    vld = 1'b0;
                    for (int unsigned i=0; i<WIDTH; i++) begin
                        vld = pry[i] ? 1'b1   : vld;
                        dat = pry[i] ? ary[i] : dat;
                    end
                end: msb
            default:
                $fatal("Unsupported DIRECTION parameter value.");
            endcase
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: mux_pry_base
