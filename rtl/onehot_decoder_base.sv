///////////////////////////////////////////////////////////////////////////////
// one-hot decoder,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module onehot_decoder_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - loop
    // 1 - table
    // 2 - shift
)(
    input  logic [WIDTH_LOG-1:0] enc_idx,
    output logic [WIDTH    -1:0] dec_vld
);

    generate
    case (IMPLEMENTATION)
        0:  // loop
            always_comb
            begin
                for (int unsigned i=0; i<WIDTH; i++) begin
                    dec_vld[i] = (i == enc_idx);
                end
            end
        1:  // table
        begin
            // table unpacked array type
            typedef bit [WIDTH_LOG-1:0] pow2_mask_t [WIDTH-1:0];

            // table function definition
            function automatic pow2_mask_t pow2_mask_f();
                for (int unsigned i=0; i<WIDTH; i++) begin
                    for (int unsigned j=0; j<WIDTH_LOG; j++) begin
                        pow2_mask_f[i][j] = i[j];
                    end
                end
            endfunction: pow2_mask_f

            // table constant
            localparam pow2_mask_t POW2_MASK = pow2_mask_f();

            // power
            always_comb
            for (int unsigned i=0; i<WIDTH; i++) begin
                dec_vld[i] = (value == POW2_MASK[i]);
            end
        2:  // shift
            assign dec_vld = 1'b1 << enc_idx;
        end
    endcase
    endgenerate

endmodule: onehot_decoder_base
