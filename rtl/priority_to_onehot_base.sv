///////////////////////////////////////////////////////////////////////////////
// Conversion from a priority (rightmost) to one-hot encoding,
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
)(
    input  logic [WIDTH-1:0] enc_pry,  // priority encoding
    output logic [WIDTH-1:0] enc_oht,  // one-hot encoding
    output logic             dec_vld   // cumulative valid
);

    generate
    case (IMPLEMENTATION)
        0:  // adder
            always_comb
            begin: adder
                logic [WIDTH-1:0] neg_pry;
                {dec_vld, neg_pry} = -enc_pry;
                enc_oht = enc_pry & neg_pry;
            end: adder
        1:  // loop
            always_comb
            begin: loop
                automatic logic dec_vld = 1'b0;
                for (int i=0; i<WIDTH; i++) begin
                    if (dec_vld) begin
                        enc_oht[i] = 1'b0;
                    end else begin
                        enc_oht[i] = enc_pry[i];
                        if (enc_pry[i]) begin
                            dec_vld = 1'b1;
                        end
                    end
                end
            end: loop
    endcase
    endgenerate

endmodule: priority_to_onehot_base
