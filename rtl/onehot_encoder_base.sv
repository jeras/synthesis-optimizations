///////////////////////////////////////////////////////////////////////////////
// one-hot encoder,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module onehot_encoder_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - loop
    // 1 - table
)(
    input  logic [WIDTH    -1:0] dec_vld,
    output logic [WIDTH_LOG-1:0] enc_idx,
    output logic                 enc_vld
);

    generate
    case (IMPLEMENTATION)
        0:  // loop
            always_comb
            begin
                enc_idx = '0;
                for (int unsigned i=0; i<WIDTH; i++) begin
                    // the OR operator prevents synthesis of a priority encoder
                    if (dec_vld[i])  enc_idx = enc_idx | i[WIDTH_LOG-1:0];
                end
                enc_vld = |dec_vld;
            end
        1:  // table
        begin
            // table unpacked array type
            typedef bit [WIDTH-1:0] log2_mask_t [WIDTH_LOG-1:0];

            // table function definition
            function automatic log2_mask_t log2_mask_f;
                for (int unsigned i=0; i<WIDTH_LOG; i++) begin
                    for (int unsigned j=0; j<WIDTH; j++) begin
                        log2_mask_f[i][j] = j[i];
                    end
                end
            endfunction: log2_mask_f

            // table constant
            localparam log2_mask_t LOG2_MASK = log2_mask_f;

            // logarithm
            function automatic logic [WIDTH_LOG-1:0] log2_f (
                logic [WIDTH-1:0] value
            );
                for (int unsigned i=0; i<WIDTH_LOG; i++) begin
                    log2_f[i] = |(value & LOG2_MASK[i]);
                end
            endfunction: log2_f

            assign enc_idx = log2_f(dec_vld);
            assign enc_vld = |dec_vld;
        end
    endcase
    endgenerate

endmodule: onehot_encoder_base
