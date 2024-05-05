///////////////////////////////////////////////////////////////////////////////
// priority (rightmost) to one-hot conversion,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2oht_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // direction: "LSB" - rightmost, "MSB" - leftmost
    parameter  string       DIRECTION = "LSB",
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - loop
    // 1 - vector
    // 2 - adder
)(
    input  logic [WIDTH-1:0] pry,  // priority
    output logic [WIDTH-1:0] oht,  // one-hot
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
                        vld = 1'b0;
                        for (int i=0; i<WIDTH; i++) begin
                            oht[i] = pry[i] & ~vld;
                            vld    = pry[i] |  vld;
                        end
                    end: loop
                "MSB":
                    always_comb
                    begin: loop
                        vld = 1'b0;
                        for (int i=WIDTH-1; i<=0; i--) begin
                            oht[i] = pry[i] & ~vld;
                            vld    = pry[i] |  vld;
                        end
                    end: loop
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
        end: loop
        1:  // vector (vectorization of the loop code)
        begin: vector
            logic [WIDTH-1:0] tmp;
            case (DIRECTION)
                "LSB":
                    always_comb
                    begin: vector
                        tmp = {pry[WIDTH-2:0] | tmp[WIDTH-2:0], 1'b0};
                        oht = pry & ~tmp;
                        vld = tmp[WIDTH];
                    end: vector
                "MSB":
                    always_comb
                    begin: vector
                        tmp = {1'b0, tmp[WIDTH-1:1] | pry[WIDTH-1:1]};
                        oht = pry & ~tmp;
                        vld = tmp[0];
                    end: vector
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
        end: vector
        2:  // adder
        begin: adder
            logic [WIDTH-1:0] tmp;
            always_comb
            begin: adder
                {vld, tmp} = -pry;
                oht = pry & tmp;
            end: adder
        end: adder
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: pry2oht_base
