///////////////////////////////////////////////////////////////////////////////
// One-hot encoder, base with parametrized implementation options
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
    // 0 - casez
    // 1 - unique   if
    // 2 - priority if
    // 3 - unique   case inside
    // 4 - priority case inside
)(
    input  logic [WIDTH    -1:0] dec_vld,
    output logic [WIDTH_LOG-1:0] enc_idx,
    output logic                 enc_vld
);

    typedef bit [WIDTH-1:0] log2_mask_t [$clog2(WIDTH)-1:0];

    // function definition
    function log2_mask_t log2_mask_f();
        for (int unsigned i=0; i<$clog2(WIDTH); i++) begin
            for (int unsigned j=0; j<WIDTH; j++) begin
                log2_mask_f[i][j] = j[i];
            end
        end
    endfunction: log2_mask_f

    localparam log2_mask_t LOG2_MASK = log2_mask_f();

    function logic [$clog2(WIDTH)-1:0] log2_f (
        logic [WIDTH-1:0] value
    );
        for (int unsigned i=0; i<$clog2(WIDTH); i++) begin
            log2_f[i] = |(value & LOG2_MASK[i]);
        end
    endfunction: log2_f

    assign enc_idx = log2_f(dec_vld);
    assign enc_vld = |dec_vld;

endmodule: onehot_encoder_base
