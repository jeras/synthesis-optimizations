///////////////////////////////////////////////////////////////////////////////
// Conversion from a priority (rightmost) to one-hot,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module priority_to_onehot_base #(
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
    input  logic [WIDTH-1:0] dec_vld,  // priority valid
    output logic [WIDTH-1:0] dec_oht,  // one-hot valid
    output logic             enc_vld   // cumulative valid
);

    generate
    case (IMPLEMENTATION)
        0:  // adder
            always_comb
            begin: adder
                automatic logic [WIDTH-1:0] neg_pry;
                {enc_vld, neg_pry} = -dec_vld;
                dec_oht = dec_vld & neg_pry;
            end: adder
        1:  // loop
            always_comb
            begin: loop
                enc_vld = 1'b0;
                for (int i=0; i<WIDTH; i++) begin
                    if (enc_vld) begin
                        dec_oht[i] = 1'b0;
                    end else begin
                        dec_oht[i] = dec_vld[i];
                        if (dec_vld[i]) begin
                            enc_vld = 1'b1;
                        end
                    end
                end
            end: loop
        2:  // vector (vectorization of the loop code)
            always_comb
            begin: vector
                automatic logic [WIDTH-0:0] carry_chain;
                carry_chain = {dec_vld, 1'b0} | carry_chain;
                dec_oht = dec_vld & ~carry_chain[WIDTH-1:0];
                enc_vld = carry_chain[WIDTH];
            end: vector
    endcase
    endgenerate

endmodule: priority_to_onehot_base
