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
            case (DIRECTION)
                "LSB":
                    always_comb
                    begin: loop
                        logic [WIDTH-1:-1] tmp;
                        tmp[0] = 1'b0;
                        for (int i=0; i<WIDTH; i++) begin
                            tmp[i] = pry[i] | tmp[i-1];
                        end
                        trm = tmp[WIDTH-1:0];
                    end: loop
                "MSB":
                    always_comb
                    begin: loop
                        logic [WIDTH-0:0] tmp;
                        tmp[WIDTH] = 1'b0;
                        for (int i=WIDTH-1; i<=0; i--) begin
                            tmp[i] = pry[i] | tmp[i+1];
                        end
                    end: loop
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
        end: loop
        1:  // vector (vectorization of the loop code)
        begin: vector
            case (DIRECTION)
                "LSB":
                    always_comb
                    begin: vector
                        logic [WIDTH-1:-1] tmp;
                        tmp[0] = 1'b0;
                        tmp[WIDTH-1:0] = pry | tmp[WIDTH-2:-1];
                        trm = tmp[WIDTH-1:0];
                    end: vector
                "MSB":
                    always_comb
                    begin: vector
                        logic [WIDTH-1:-1] tmp;
                        tmp[WIDTH] = 1'b0;
                        tmp[WIDTH-1:0] = pry | tmp[WIDTH-0:1];
                        trm = tmp[WIDTH-1:0];
                    end: vector
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
