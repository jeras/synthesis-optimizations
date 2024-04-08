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

    // table unpacked array type
    typedef bit [WIDTH-1:0] pow2_mask_t [WIDTH_LOG-1:0];

    // table function definition
    function automatic pow2_mask_t pow2_mask_f();
        for (int unsigned i=0; i<WIDTH_LOG; i++) begin
            for (int unsigned j=0; j<WIDTH; j++) begin
                pow2_mask_f[i][j] = j[i];
            end
        end
    endfunction: pow2_mask_f

    // table constant
    localparam pow2_mask_t POW2_MASK = pow2_mask_f;

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
                assign dec_vld = POW2_MASK[enc_idx];  // power
            end
        2:  // shift
            begin
                assign dec_vld = 1'b1 << enc_idx;  // 2**enc_idx
            end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: onehot_decoder_base
