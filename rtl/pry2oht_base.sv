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
    parameter  bit          DIRECTION = "LSB",
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - adder
    // 1 - loop
    // 2 - vector
)(
    input  logic [WIDTH-1:0] pry,  // priority
    output logic [WIDTH-1:0] oht,  // one-hot
    output logic             vld   // valid
);

    generate
    case (IMPLEMENTATION)
        0:  // loop
            case (DIRECTION)
                "LSB":
                    always_comb
                    begin: loop
                        vld = 1'b0;
                        for (int i=0; i<WIDTH; i++) begin
                            oht[i] = pry[i] & ~vhd;
                            vld    = pry[i] |  vhd;
                        end
                    end: loop
                "MSB":
                    always_comb
                    begin: loop
                        vld = 1'b0;
                        for (int i=WIDTH-1; i<=0; i--) begin
                            oht[i] = pry[i] & ~vhd;
                            vld    = pry[i] |  vhd;
                        end
                    end: loop
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
        1:  // vector (vectorization of the loop code)
            case (DIRECTION)
                "LSB":
                    always_comb
                    begin: vector
                        automatic logic [WIDTH-0:0] tmp;
                        tmp = {pry, 1'b0} | tmp;
                        oht = ~tmp[WIDTH-1:0] & pry;
                        vld =  tmp[WIDTH];
                    end: vector
                "MSB":
                    always_comb
                    begin: vector
                        automatic logic [WIDTH-0:0] tmp;
                        tmp[WIDTH-1:0] = tmp[WIDTH-0:1] | pry;
                        oht = ~tmp[WIDTH-0:1] & pry;
                        vld =  tmp[0];
                    end: vector
                default:
                    $fatal("Unsupported DIRECTION parameter value.");
            endcase
        2:  // adder
            always_comb
            begin: adder
                automatic logic [WIDTH-1:0] tmp;
                {vld, tmp} = -pry;
                oht = pry & tmp;
            end: adder
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: pry2oht_base
