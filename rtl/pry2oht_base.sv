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
        0:  // adder
            always_comb
            begin: adder
                automatic logic [WIDTH-1:0] neg_pry;
                {vld, neg_pry} = -pry;
                oht = pry & neg_pry;
            end: adder
        1:  // loop
            always_comb
            begin: loop
                vld = 1'b0;
                for (int i=0; i<WIDTH; i++) begin
                    if (vld) begin
                        oht[i] = 1'b0;
                    end else begin
                        oht[i] = pry[i];
                        if (pry[i]) begin
                            vld = 1'b1;
                        end
                    end
                end
            end: loop
        2:  // vector (vectorization of the loop code)
            always_comb
            begin: vector
                automatic logic [WIDTH-0:0] carry_chain;
                carry_chain = {pry, 1'b0} | carry_chain;
                oht = pry & ~carry_chain[WIDTH-1:0];
                vld = carry_chain[WIDTH];
            end: vector
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: pry2oht_base
