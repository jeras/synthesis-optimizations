///////////////////////////////////////////////////////////////////////////////
// priority to thermometer conversion,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2thr_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // direction: "LSB" - rightmost, "MSB" - leftmost
    parameter  string       DIRECTION = "LSB",
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - loop
    // 1 - vector
    // 2 - adder
)(
    input  logic [WIDTH-1:0] pry,  // priority
    output logic [WIDTH-1:0] thr,  // thermometer
    output logic             vld   // valid
);

    generate
    case (IMPLEMENTATION)
        0:  // loop
        begin: loop
            /* verilator lint_off ALWCOMBORDER */
            case (DIRECTION)
                "LSB":
                    always_comb
                    begin: loop
                        thr[0] = pry[0];
                        for (int i=1; i<WIDTH; i++) begin
                            thr[i] = pry[i] | thr[i-1];
                        end
                    end: loop
                "MSB":
                    always_comb
                    begin: loop
                        thr[WIDTH-1] = pry[WIDTH-1];
                        for (int i=WIDTH-2; i>=0; i--) begin
                            thr[i] = pry[i] | thr[i+1];
                        end
                    end: loop
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
            /* verilator lint_on ALWCOMBORDER */
        end: loop
        1:  // vector (vectorization of the loop code)
        begin: vector
            case (DIRECTION)
                "LSB":
                    always_comb
                    thr = pry | {thr[WIDTH-2:0], 1'b0};
                "MSB":
                    always_comb
                    thr = pry | {1'b0, thr[WIDTH-1:1]};
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
        end: vector
        2:  // adder
        begin: adder
            logic [WIDTH-1:0] tmp;
            case (DIRECTION)
                "LSB":
                    always_comb
                    begin: adder
                        // TODO
                        {vld, tmp} = -pry;
                        thr = pry & tmp;
                    end: adder
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
        end: adder
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: pry2thr_base
